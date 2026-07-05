module offset_correction #(
    parameter int DATA_W       = 14,   // must match gain_correction output width
    parameter int OFFSET_FRAC  = 8,    // extra fractional bits kept in the offset integrator

    // ---- Algorithm coefficients (determined in simulation, fixed at build time) ----
    parameter int AVG_SHIFT    = 16,   // log2(window length) -- was cfg_avg_shift_i
    parameter int MU_SHIFT     = 8,    // log2(1/mu)          -- was cfg_mu_shift_i

    // ---- Derived sizing (do not override) ----
    parameter int CNT_W        = AVG_SHIFT + 1,
    parameter int ACC_W        = DATA_W + AVG_SHIFT + 2,
    parameter int OFFSET_W     = DATA_W + OFFSET_FRAC + 4 // integrator width w/ guard bits
)(
    input  logic                      clk,             // 50 MHz
    input  logic                      rst_n,           // active-low sync reset

    input  logic                      calib_en_i,      // 1 = run calibration; 0 = bypass
    input  logic                      valid_i,         // 1-cycle strobe: new (ch0_i, ch1_i) sample pair valid
    input  logic signed [DATA_W-1:0]  ch0_i,           // reference channel (post gain-correction)
    input  logic signed [DATA_W-1:0]  ch1_i,           // channel to be offset-corrected (post gain-correction)

    output logic                      valid_o,
    output logic signed [DATA_W-1:0]  ch0_o,
    output logic signed [DATA_W-1:0]  ch1_o,           // offset-corrected

    // debug / monitor ports
    output logic signed [OFFSET_W-1:0] offset_reg_o,
    output logic signed [DATA_W+1:0]   e_offset_o
);

    initial begin
        if (AVG_SHIFT < 1)
            $error("offset_correction: AVG_SHIFT must be >= 1 (got %0d)", AVG_SHIFT);
        if (MU_SHIFT < 0)
            $error("offset_correction: MU_SHIFT must be >= 0 (got %0d)", MU_SHIFT);
    end

    localparam logic signed [OFFSET_W-1:0] OFFSET_MAX =
        OFFSET_W'((1 <<< (DATA_W-1)) <<< OFFSET_FRAC);
    localparam logic signed [OFFSET_W-1:0] OFFSET_MIN = -OFFSET_MAX;

    localparam logic [CNT_W-1:0] WIN_LEN = CNT_W'(1) << AVG_SHIFT;

    logic signed [DATA_W-1:0] ch1_corr_for_stats;
    assign ch1_corr_for_stats = ch1_i - DATA_W'(offset_reg_r >>> OFFSET_FRAC);

    logic [CNT_W-1:0]         sample_cnt;
    logic signed [ACC_W-1:0]  acc0, acc1;
    logic                     win_done;

    assign win_done = valid_i && (sample_cnt == (WIN_LEN - 1'b1));

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            sample_cnt <= '0;
            acc0       <= '0;
            acc1       <= '0;
        end else if (calib_en_i && valid_i) begin
            acc0 <= win_done ? '0 : acc0 + ACC_W'(ch0_i);
            acc1 <= win_done ? '0 : acc1 + ACC_W'(ch1_corr_for_stats);
            sample_cnt <= win_done ? '0 : sample_cnt + 1'b1;
        end
    end

    logic signed [DATA_W-1:0]  avg0, avg1;
    logic signed [DATA_W+1:0]  e_offset;
    logic signed [DATA_W+1+OFFSET_FRAC:0] e_offset_scaled;
    logic signed [DATA_W+1+OFFSET_FRAC:0] offset_delta;
    logic signed [OFFSET_W-1:0]           offset_reg_r, offset_reg_nxt;

    // arithmetic shift on signed accumulator = divide, rounding toward -inf (acceptable for DC estimate)
    assign avg0 = acc0 >>> AVG_SHIFT;
    assign avg1 = acc1 >>> AVG_SHIFT;
    assign e_offset = {avg1[DATA_W-1], avg1} - {avg0[DATA_W-1], avg0};

    // scale e_offset into the integrator's Q(OFFSET_FRAC) fractional domain, then apply mu
    assign e_offset_scaled = {{(OFFSET_FRAC){e_offset[DATA_W+1]}}, e_offset} <<< OFFSET_FRAC;
    assign offset_delta    = e_offset_scaled >>> MU_SHIFT;

    logic signed [OFFSET_W:0] offset_reg_r_ext, offset_delta_ext, offset_max_ext, offset_min_ext, sum_ofs;
    assign offset_reg_r_ext = offset_reg_r;
    assign offset_delta_ext = offset_delta;
    assign offset_max_ext   = OFFSET_MAX;
    assign offset_min_ext   = OFFSET_MIN;
    assign sum_ofs          = offset_reg_r_ext + offset_delta_ext;

    assign offset_reg_nxt =
        (win_done && calib_en_i) ?
            ((sum_ofs > offset_max_ext) ? OFFSET_MAX :
             (sum_ofs < offset_min_ext) ? OFFSET_MIN :
             sum_ofs[OFFSET_W-1:0]) :
            offset_reg_r;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            offset_reg_r <= '0;
            e_offset_o   <= '0;
        end else if (!calib_en_i) begin
            offset_reg_r <= '0;   // hold at zero correction while bypassed
        end else if (win_done) begin
            offset_reg_r <= offset_reg_nxt;
            e_offset_o   <= e_offset;
        end
    end

    assign offset_reg_o = offset_reg_r;

    localparam logic signed [OFFSET_W-1:0] ROUND_CONST =
        (OFFSET_FRAC > 0) ? OFFSET_W'(1 <<< (OFFSET_FRAC-1)) : 0;

    logic signed [OFFSET_W-1:0] offset_rounded;
    logic signed [DATA_W:0]     diff;
    logic signed [DATA_W-1:0]   ch1_sat;

    localparam logic signed [DATA_W:0] SAT_MAX = (1 <<< (DATA_W-1)) - 1;
    localparam logic signed [DATA_W:0] SAT_MIN = -(1 <<< (DATA_W-1));

    logic signed [DATA_W:0] ch1_i_ext;
    assign ch1_i_ext      = ch1_i;
    assign offset_rounded = offset_reg_r + ROUND_CONST;
    assign diff           = ch1_i_ext - (offset_rounded >>> OFFSET_FRAC);
    assign ch1_sat = (diff > SAT_MAX) ? SAT_MAX[DATA_W-1:0] :
                     (diff < SAT_MIN) ? SAT_MIN[DATA_W-1:0] :
                     diff[DATA_W-1:0];

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            valid_o <= 1'b0;
            ch0_o   <= '0;
            ch1_o   <= '0;
        end else begin
            valid_o <= valid_i;
            ch0_o   <= ch0_i;
            ch1_o   <= ch1_sat;
        end
    end

endmodule