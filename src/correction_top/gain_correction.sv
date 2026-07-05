module gain_correction #(
    parameter int DATA_W       = 8,    // SAR ADC output width (unsigned straight binary)

    parameter int COEFF_FRAC   = 16,   // fractional bits
    parameter int COEFF_INT    = 3,    // integer bits (sign bit is separate)
    parameter int COEFF_W      = COEFF_INT + COEFF_FRAC + 1,

    parameter int AVG_LOG2      = 16,          // averaging window = 2^AVG_LOG2 samples
    parameter int MU_SHIFT      = 10,          // mu = 2^-MU_SHIFT
    parameter int THRESH_W      = DATA_W + 2 + AVG_LOG2 + 2,
    parameter logic [THRESH_W-1:0] FREEZE_THRESH = THRESH_W'(1 <<< (AVG_LOG2 > 4 ? AVG_LOG2-4 : 0)),
                                                // activity-sum floor below which the loop freezes;
                                                // pick via simulation against your expected noise floor

    parameter int COEFF_CLAMP_MAX_NUM = 4,     // clamp ceiling  = COEFF_CLAMP_MAX_NUM x unity
    parameter int COEFF_CLAMP_MIN_DEN = 4,     // clamp floor    = unity / COEFF_CLAMP_MIN_DEN

    parameter bit CALIB_EN      = 1
)(
    input  logic                      clk,             // 50 MHz
    input  logic                      rst_n,           // active-low sync reset

    input  logic                      valid_i,         // 1-cycle strobe: new (ch0_i, ch1_i) sample pair valid
    input  logic [DATA_W-1:0]         ch0_i,           // reference channel, raw unsigned ADC code
    input  logic [DATA_W-1:0]         ch1_i,           // channel to be gain-corrected, raw unsigned ADC code

    output logic                      valid_o,
    output logic [DATA_W-1:0]         ch0_o,           // unsigned ADC code, delay-matched
    output logic [DATA_W-1:0]         ch1_o,           // unsigned ADC code, gain-corrected

    // debug / monitor ports (read-only, no effect on calibration behavior)
    output logic signed [COEFF_W-1:0] gain_coeff_o,
    output logic                      freeze_flag_o,
    output logic signed [DATA_W+1:0]  e_gain_o
);

    function automatic logic signed [DATA_W-1:0] u2s(input logic [DATA_W-1:0] u);
        u2s = signed'({~u[DATA_W-1], u[DATA_W-2:0]});
    endfunction

    function automatic logic [DATA_W-1:0] s2u(input logic signed [DATA_W-1:0] s);
        s2u = {~s[DATA_W-1], s[DATA_W-2:0]};
    endfunction

    localparam logic signed [COEFF_W-1:0] COEFF_UNITY = COEFF_W'(1 <<< COEFF_FRAC);
    localparam logic signed [COEFF_W-1:0] COEFF_MAX   = COEFF_W'(COEFF_CLAMP_MAX_NUM <<< COEFF_FRAC);
    localparam logic signed [COEFF_W-1:0] COEFF_MIN   = COEFF_W'((1 <<< COEFF_FRAC) / COEFF_CLAMP_MIN_DEN);


    function automatic logic [DATA_W-1:0] f_abs(input logic signed [DATA_W-1:0] a);
        // saturating absolute value (protects against |-2^(N-1)| overflow)
        if (a == {1'b1, {(DATA_W-1){1'b0}}})
            f_abs = {1'b0, {(DATA_W-1){1'b1}}};
        else
            f_abs = a[DATA_W-1] ? -a : a;
    endfunction

    function automatic logic [DATA_W:0] f_absdiff(input logic signed [DATA_W-1:0] a,
                                                    input logic signed [DATA_W-1:0] b);
        logic signed [DATA_W:0] d;
        d = {a[DATA_W-1], a} - {b[DATA_W-1], b};
        f_absdiff = d[DATA_W] ? (~d + 1'b1) : d;
    endfunction

    logic signed [DATA_W-1:0] ch0_s, ch1_s;
    assign ch0_s = u2s(ch0_i);
    assign ch1_s = u2s(ch1_i);

    localparam int CNT_W     = AVG_LOG2 + 1;
    localparam int ACC_W     = DATA_W + AVG_LOG2 + 2;          // abs-value accumulators
    localparam int ACT_ACC_W = DATA_W + 2 + AVG_LOG2 + 2;      // activity accumulator
    localparam logic [CNT_W-1:0] WIN_LEN = CNT_W'(1) <<< AVG_LOG2;

    logic [CNT_W-1:0]     sample_cnt;
    logic [ACC_W-1:0]     abs_acc0, abs_acc1;
    logic [ACT_ACC_W-1:0] act_acc;
    logic signed [DATA_W-1:0] ch0_prev, ch1_prev;
    logic                 win_done;

    assign win_done = valid_i && (sample_cnt == (WIN_LEN - 1'b1));

    logic signed [DATA_W-1:0] ch1_corr_s;
    assign ch1_corr_s = product_s1 >>> COEFF_FRAC;   // live corrected estimate, no rounding needed for stats

    logic [DATA_W-1:0] abs_ch0_w, abs_ch1_w;
    logic [DATA_W:0]   absdiff0_w, absdiff1_w;
    assign abs_ch0_w  = f_abs(ch0_s);
    assign abs_ch1_w  = f_abs(ch1_corr_s);
    assign absdiff0_w = f_absdiff(ch0_s, ch0_prev);
    assign absdiff1_w = f_absdiff(ch1_s, ch1_prev);

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            sample_cnt <= '0;
            abs_acc0   <= '0;
            abs_acc1   <= '0;
            act_acc    <= '0;
            ch0_prev   <= '0;
            ch1_prev   <= '0;
        end else if (CALIB_EN && valid_i) begin
            abs_acc0 <= win_done ? '0 : abs_acc0 + ACC_W'(abs_ch0_w);
            abs_acc1 <= win_done ? '0 : abs_acc1 + ACC_W'(abs_ch1_w);
            act_acc  <= win_done ? '0 : act_acc  + ACT_ACC_W'(absdiff0_w)
                                                  + ACT_ACC_W'(absdiff1_w);
            sample_cnt <= win_done ? '0 : sample_cnt + 1'b1;
            ch0_prev <= ch0_s;
            ch1_prev <= ch1_s;
        end
    end

    logic [DATA_W-1:0]        avg_abs0, avg_abs1;
    logic signed [DATA_W+1:0] e_gain;                 // avg1 - avg0
    logic                     freeze_this_win;
    logic signed [DATA_W+1+COEFF_FRAC:0] e_gain_scaled; // e_gain shifted into coeff fractional domain
    logic signed [DATA_W+1+COEFF_FRAC:0] coeff_delta;
    logic signed [COEFF_W-1:0]           gain_coeff_r, gain_coeff_nxt;
    logic                                freeze_flag_r;

    assign avg_abs0 = abs_acc0[ACC_W-1:AVG_LOG2];   // fixed-shift divide == plain bit slice, no shifter
    assign avg_abs1 = abs_acc1[ACC_W-1:AVG_LOG2];
    assign e_gain   = $signed({1'b0, avg_abs1}) - $signed({1'b0, avg_abs0});

    assign freeze_this_win = (act_acc < ACT_ACC_W'(FREEZE_THRESH));

    // scale e_gain (raw code units) into the coefficient's Q(COEFF_FRAC) domain,
    // then apply the mu step size as a fixed right shift (mu = 2^-MU_SHIFT)
    assign e_gain_scaled = {{(COEFF_FRAC){e_gain[DATA_W+1]}}, e_gain} <<< COEFF_FRAC;
    assign coeff_delta   = e_gain_scaled >>> MU_SHIFT;

    logic signed [COEFF_W:0] gain_coeff_r_ext, coeff_delta_ext, coeff_max_ext, coeff_min_ext, sum_gain;
    assign gain_coeff_r_ext = gain_coeff_r;
    assign coeff_delta_ext  = coeff_delta[COEFF_W:0];
    assign coeff_max_ext    = COEFF_MAX;
    assign coeff_min_ext    = COEFF_MIN;
    assign sum_gain         = gain_coeff_r_ext - coeff_delta_ext;

    assign gain_coeff_nxt =
        (win_done && CALIB_EN && !freeze_this_win) ?
            ((sum_gain > coeff_max_ext) ? COEFF_MAX :
             (sum_gain < coeff_min_ext) ? COEFF_MIN :
             sum_gain[COEFF_W-1:0]) :
            gain_coeff_r;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            gain_coeff_r  <= COEFF_UNITY;
            freeze_flag_r <= 1'b0;
            e_gain_o      <= '0;
        end else if (!CALIB_EN) begin
            gain_coeff_r  <= COEFF_UNITY;   // held at unity; bypass mode fixed at elaboration
            freeze_flag_r <= 1'b0;
        end else if (win_done) begin
            gain_coeff_r  <= gain_coeff_nxt;
            freeze_flag_r <= freeze_this_win;
            e_gain_o      <= e_gain;
        end
    end

    assign gain_coeff_o = gain_coeff_r;
    assign freeze_flag_o = freeze_flag_r;

    logic [DATA_W-1:0]                     ch0_s1, ch0_s2;
    logic                                  valid_s1, valid_s2;
    logic signed [DATA_W+COEFF_W-1:0]      product_s1, product_r;
    logic signed [DATA_W+COEFF_W:0]        product_rounded;
    logic signed [DATA_W-1:0]              ch1_sat_s;

    // Stage 1: capture inputs, compute product against current coefficient
    assign product_s1 = ch1_s * gain_coeff_r;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            valid_s1 <= 1'b0;
            ch0_s1   <= '0;
            product_r<= '0;
        end else begin
            valid_s1 <= valid_i;
            ch0_s1   <= ch0_i;   // pass through unsigned, no domain conversion needed for CH0
            product_r<= CALIB_EN ? product_s1
                                  : (ch1_s <<< COEFF_FRAC); // bypass: unity scale
        end
    end

    // Stage 2: round (round-to-nearest) + saturate back to DATA_W, then convert to unsigned
    localparam logic signed [DATA_W+COEFF_W:0] ROUND_CONST = (COEFF_FRAC > 0) ?
                                                              (1 <<< (COEFF_FRAC-1)) : 0;
    localparam logic signed [DATA_W+COEFF_W:0] SAT_MAX = (1 <<< (DATA_W-1)) - 1;
    localparam logic signed [DATA_W+COEFF_W:0] SAT_MIN = -(1 <<< (DATA_W-1));

    logic signed [DATA_W+COEFF_W:0] product_r_ext, shifted;
    assign product_r_ext   = product_r;
    assign product_rounded = product_r_ext + ROUND_CONST;
    assign shifted          = product_rounded >>> COEFF_FRAC;
    assign ch1_sat_s = (shifted > SAT_MAX) ? SAT_MAX[DATA_W-1:0] :
                       (shifted < SAT_MIN) ? SAT_MIN[DATA_W-1:0] :
                       shifted[DATA_W-1:0];

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            valid_s2 <= 1'b0;
            ch0_s2   <= '0;
            ch1_o    <= '0;
        end else begin
            valid_s2 <= valid_s1;
            ch0_s2   <= ch0_s1;
            ch1_o    <= s2u(ch1_sat_s);   // back to unsigned straight binary
        end
    end

    assign valid_o = valid_s2;
    assign ch0_o   = ch0_s2;

endmodule