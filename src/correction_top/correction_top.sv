module correction_top #(
    // ---- Shared ADC / datapath width (applies to both stages) ----
    parameter int DATA_W             = 14,

    // ---- Gain-correction coefficient format & LMS tuning (see gain_correction) ----
    parameter int GAIN_COEFF_FRAC    = 16,
    parameter int GAIN_COEFF_INT     = 3,
    parameter int GAIN_AVG_LOG2      = 16,
    parameter int GAIN_MU_SHIFT      = 10,
    parameter int GAIN_CLAMP_MAX_NUM = 4,
    parameter int GAIN_CLAMP_MIN_DEN = 4,
    parameter bit GAIN_CALIB_EN      = 1,   // compile-time only, see caveat above

    // ---- Offset-correction LMS tuning (see offset_correction) ----
    parameter int OFFSET_FRAC        = 8,
    parameter int OFS_AVG_SHIFT      = 16,
    parameter int OFS_MU_SHIFT       = 8,

    // ---- Output serializer ----
    parameter int FIFO_DEPTH         = 4    // must be a power of 2; see note below
)(
    input  logic                      clk,             // 50 MHz
    input  logic                      rst_n,

    input  logic                      calib_en_i,       // runtime enable, forwarded to offset_correction only
    input  logic                      adc_valid_i,      // ~25 MHz sample-pair strobe (period-2 cadence assumed)
    input  logic [DATA_W-1:0]         adc0_i,           // raw unsigned SAR ADC CH0 code, earlier sample of the pair
    input  logic [DATA_W-1:0]         adc1_i,           // raw unsigned SAR ADC CH1 code, later sample of the pair

    output logic                      out_valid_o,      // 1-cycle strobe, up to every clk cycle at 50 MHz
    output logic signed [DATA_W-1:0]  sample_o,         // single interleaved, gain+offset corrected sample stream
    output logic                      sample_ch_o,      // 0 = this sample originated from adc0_i, 1 = from adc1_i
    output logic                      fifo_overflow_o,  // sticky: adc_valid_i cadence exceeded serializer capacity

    // debug / monitor, passthrough from the two calibration engines
    output logic signed [GAIN_COEFF_INT+GAIN_COEFF_FRAC:0] gain_coeff_o,
    output logic                                            gain_freeze_flag_o,
    output logic signed [DATA_W+OFFSET_FRAC+3:0]            offset_reg_o
);

    localparam int FIFO_AW = $clog2(FIFO_DEPTH);

    initial begin
        if ((1 <<< FIFO_AW) != FIFO_DEPTH)
            $error("correction_top: FIFO_DEPTH (%0d) must be a power of 2", FIFO_DEPTH);
        if (FIFO_DEPTH < 4)
            $error("correction_top: FIFO_DEPTH must be >= 4 (one full pair of margin), got %0d", FIFO_DEPTH);
    end

    logic                      gc_valid;
    logic [DATA_W-1:0]         gc_ch0, gc_ch1;
    logic signed [DATA_W+1:0]  unused_egain;

    gain_correction #(
        .DATA_W             (DATA_W),
        .COEFF_FRAC         (GAIN_COEFF_FRAC),
        .COEFF_INT          (GAIN_COEFF_INT),
        .AVG_LOG2           (GAIN_AVG_LOG2),
        .MU_SHIFT           (GAIN_MU_SHIFT),
        .COEFF_CLAMP_MAX_NUM(GAIN_CLAMP_MAX_NUM),
        .COEFF_CLAMP_MIN_DEN(GAIN_CLAMP_MIN_DEN),
        .CALIB_EN           (GAIN_CALIB_EN)
    ) u_gain_correction (
        .clk           (clk),
        .rst_n         (rst_n),
        .valid_i       (adc_valid_i),
        .ch0_i         (adc0_i),
        .ch1_i         (adc1_i),
        .valid_o       (gc_valid),
        .ch0_o         (gc_ch0),
        .ch1_o         (gc_ch1),
        .gain_coeff_o  (gain_coeff_o),
        .freeze_flag_o (gain_freeze_flag_o),
        .e_gain_o      (unused_egain)
    );

    function automatic logic signed [DATA_W-1:0] u2s(input logic [DATA_W-1:0] u);
        u2s = signed'({~u[DATA_W-1], u[DATA_W-2:0]});
    endfunction

    logic signed [DATA_W-1:0] gc_ch0_s, gc_ch1_s;
    assign gc_ch0_s = u2s(gc_ch0);
    assign gc_ch1_s = u2s(gc_ch1);

    logic                      cal_valid;
    logic signed [DATA_W-1:0]  cal_ch0, cal_ch1;
    logic signed [DATA_W+1:0]  unused_eoffset;

    offset_correction #(
        .DATA_W      (DATA_W),
        .OFFSET_FRAC (OFFSET_FRAC),
        .AVG_SHIFT   (OFS_AVG_SHIFT),
        .MU_SHIFT    (OFS_MU_SHIFT)
    ) u_offset_correction (
        .clk          (clk),
        .rst_n        (rst_n),
        .calib_en_i   (calib_en_i),
        .valid_i      (gc_valid),
        .ch0_i        (gc_ch0_s),
        .ch1_i        (gc_ch1_s),
        .valid_o      (cal_valid),
        .ch0_o        (cal_ch0),
        .ch1_o        (cal_ch1),
        .offset_reg_o (offset_reg_o),
        .e_offset_o   (unused_eoffset)
    );

    logic signed [DATA_W-1:0] fifo_data [FIFO_DEPTH];
    logic                     fifo_chid [FIFO_DEPTH];
    logic [FIFO_AW-1:0]       wr_ptr_r, rd_ptr_r;
    logic [FIFO_AW:0]     fifo_count_r;

    logic                 push_en, pop_en, overflow_this_cyc;
    logic [FIFO_AW:0]     count_after_pop;
    logic [FIFO_AW-1:0]   wr_ptr_p1;

    assign push_en          = cal_valid;
    assign pop_en           = (fifo_count_r != '0);
    assign count_after_pop  = fifo_count_r - (pop_en ? {{FIFO_AW{1'b0}}, 1'b1} : '0);
    assign overflow_this_cyc = push_en && ((count_after_pop + 2) > FIFO_DEPTH);
    assign wr_ptr_p1        = wr_ptr_r + 1'b1;   // wraps mod FIFO_DEPTH (power-of-2 width)

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            wr_ptr_r        <= '0;
            rd_ptr_r        <= '0;
            fifo_count_r    <= '0;
            out_valid_o     <= 1'b0;
            sample_o        <= '0;
            sample_ch_o     <= 1'b0;
            fifo_overflow_o <= 1'b0;
        end else begin
            // pop: present the oldest buffered sample this cycle
            if (pop_en) begin
                out_valid_o <= 1'b1;
                sample_o    <= fifo_data[rd_ptr_r];
                sample_ch_o <= fifo_chid[rd_ptr_r];
                rd_ptr_r    <= rd_ptr_r + 1'b1;
            end else begin
                out_valid_o <= 1'b0;
            end

            // push: buffer the newly corrected pair, ch0 ahead of ch1 in time
            if (push_en) begin
                if (overflow_this_cyc) begin
                    fifo_overflow_o <= 1'b1;   // sticky -- cadence assumption violated, pair dropped
                end else begin
                    fifo_data[wr_ptr_r]  <= cal_ch0;
                    fifo_chid[wr_ptr_r]  <= 1'b0;
                    fifo_data[wr_ptr_p1] <= cal_ch1;
                    fifo_chid[wr_ptr_p1] <= 1'b1;
                    wr_ptr_r            <= wr_ptr_r + 2'd2;
                end
            end

            fifo_count_r <= count_after_pop + ((push_en && !overflow_this_cyc) ? 2'd2 : 2'd0);
        end
    end

endmodule