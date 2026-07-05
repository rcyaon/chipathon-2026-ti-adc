`timescale 1ns/1ps

module tb_correction_top;
    localparam int    DATA_W          = 8;
    localparam int    MIDSCALE        = (1 << (DATA_W-1));      // 128
    localparam int    MAXCODE         = (1 << DATA_W) - 1;      // 255

    localparam int    GAIN_AVG_LOG2   = 8;     // window = 256 samples  (fast, demo-only)
    localparam int    GAIN_MU_SHIFT   = 5;     // will be re-tuned below (amplitude-dependent)
    localparam int    OFS_AVG_SHIFT   = 8;     // window = 256 samples
    localparam int    OFS_MU_SHIFT    = 3;     // will be re-tuned below

    localparam real   PI              = 3.14159265358979323846;
    localparam real   PERIOD_SAMPLES  = 128.0; // sine period, in aggregate samples
    localparam real   AMP             = 45.0;  // sine amplitude, code units (centered) -- ~35% of half-scale, same proportion as the 14-bit run
    localparam real   GAIN_TRUE       = 0.85;  // injected ADC1 gain mismatch (15% low) -- dimensionless, unchanged
    localparam real   OFFSET_TRUE     = 4.0;   // injected ADC1 DC offset mismatch, code units -- rescaled to the same ~1.5% of full-scale

    localparam int    NUM_PAIRS       = 20000; // number of (adc0,adc1) pairs to drive
    localparam int    CLK_PERIOD      = 20;    // 50 MHz

    logic                     clk, rst_n;
    logic                     calib_en_i;
    logic                     adc_valid_i;
    logic [DATA_W-1:0]        adc0_i, adc1_i;

    logic                     out_valid_o;
    logic signed [DATA_W-1:0] sample_o;
    logic                     sample_ch_o;
    logic                     fifo_overflow_o;

    logic signed [3+16:0]     gain_coeff_o;      // GAIN_COEFF_INT+GAIN_COEFF_FRAC : 0  (defaults 3,16)
    logic                     gain_freeze_flag_o;
    logic signed [DATA_W+8+3:0] offset_reg_o;    // DATA_W+OFFSET_FRAC+3 : 0        (default OFFSET_FRAC=8)

    correction_top #(
        .DATA_W        (DATA_W),
        .GAIN_AVG_LOG2 (GAIN_AVG_LOG2),
        .GAIN_MU_SHIFT (GAIN_MU_SHIFT),
        .OFS_AVG_SHIFT (OFS_AVG_SHIFT),
        .OFS_MU_SHIFT  (OFS_MU_SHIFT)
    ) dut (
        .clk              (clk),
        .rst_n            (rst_n),
        .calib_en_i       (calib_en_i),
        .adc_valid_i      (adc_valid_i),
        .adc0_i           (adc0_i),
        .adc1_i           (adc1_i),
        .out_valid_o      (out_valid_o),
        .sample_o         (sample_o),
        .sample_ch_o      (sample_ch_o),
        .fifo_overflow_o  (fifo_overflow_o),
        .gain_coeff_o     (gain_coeff_o),
        .gain_freeze_flag_o(gain_freeze_flag_o),
        .offset_reg_o     (offset_reg_o)
    );

    initial clk = 1'b0;
    always #(CLK_PERIOD/2) clk = ~clk;

    initial begin
        rst_n = 1'b0;
        calib_en_i = 1'b1;
        repeat (10) @(posedge clk);
        rst_n = 1'b1;
    end

    logic valid_toggle;
    logic run_inputs;
    int   pair_cnt;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) valid_toggle <= 1'b0;
        else        valid_toggle <= ~valid_toggle;
    end

    assign adc_valid_i = valid_toggle && run_inputs;

    initial begin
        run_inputs = 1'b0;
        pair_cnt   = 0;
        @(posedge rst_n);
        run_inputs = 1'b1;
    end

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            pair_cnt <= 0;
        end else if (adc_valid_i) begin
            pair_cnt <= pair_cnt + 1;
            if (pair_cnt + 1 >= NUM_PAIRS)
                run_inputs <= 1'b0;
        end
    end

    int n;
    real ideal0_r, ideal1_r, raw1_r;
    integer code0, code1;
    real exp_q[$];

    always_ff @(posedge clk) begin
        if (!rst_n) n <= 0;
        else if (adc_valid_i) n <= n + 2;
    end

    always_comb begin
        ideal0_r = AMP * $sin(2.0*PI*real'(n)   / PERIOD_SAMPLES);
        ideal1_r = AMP * $sin(2.0*PI*real'(n+1) / PERIOD_SAMPLES);
        raw1_r   = GAIN_TRUE * ideal1_r + OFFSET_TRUE;

        code0 = $rtoi(ideal0_r + (ideal0_r >= 0.0 ? 0.5 : -0.5)) + MIDSCALE;
        code1 = $rtoi(raw1_r   + (raw1_r   >= 0.0 ? 0.5 : -0.5)) + MIDSCALE;

        if (code0 < 0)        code0 = 0;
        else if (code0 > MAXCODE) code0 = MAXCODE;
        if (code1 < 0)        code1 = 0;
        else if (code1 > MAXCODE) code1 = MAXCODE;
    end

    assign adc0_i = code0[DATA_W-1:0];
    assign adc1_i = code1[DATA_W-1:0];

    always_ff @(posedge clk) begin
        if (rst_n && adc_valid_i) begin
            exp_q.push_back(ideal0_r);
            exp_q.push_back(ideal1_r);
        end
    end

    integer   fd;
    int       out_idx;
    integer   samp_i, coeff_i, ofs_i;
    real      expected, actual, err, gain_real, ofs_real;

    initial begin
        fd = $fopen("correction_sim_results_8bit.csv", "w");
        if (fd == 0) begin
            $display("ERROR: could not open csv");
            $finish;
        end
        $fwrite(fd, "idx,expected,actual,error,ch,gain_coeff,offset_reg,fifo_overflow\n");
        out_idx = 0;
    end

    always_ff @(posedge clk) begin
        if (rst_n && out_valid_o) begin
            if (exp_q.size() > 0) begin
                expected = exp_q.pop_front();
            end else begin
                expected = 0.0;
                $display("WARNING: exp_q underflow at out_idx=%0d", out_idx);
            end

            samp_i  = sample_o;               // sign-extends (sample_o is signed)
            coeff_i = gain_coeff_o;
            ofs_i   = offset_reg_o;

            actual    = $itor(samp_i);
            gain_real = $itor(coeff_i) / (2.0 ** 16);   // GAIN_COEFF_FRAC = 16 (default)
            ofs_real  = $itor(ofs_i)   / (2.0 ** 8);    // OFFSET_FRAC     = 8  (default)
            err       = actual - expected;

            $fwrite(fd, "%0d,%f,%f,%f,%0d,%f,%f,%0d\n",
                    out_idx, expected, actual, err, sample_ch_o,
                    gain_real, ofs_real, fifo_overflow_o);

            out_idx = out_idx + 1;
        end
    end

    initial begin
        wait (rst_n === 1'b1);
        wait (pair_cnt >= NUM_PAIRS);
        repeat (200) @(posedge clk);   // drain pipeline + serializer FIFO
        $display("Simulation complete: %0d output samples logged.", out_idx);
        if (fifo_overflow_o)
            $display("WARNING: fifo_overflow_o asserted during run -- cadence assumption violated.");
        $fclose(fd);
        $finish;
    end

endmodule
