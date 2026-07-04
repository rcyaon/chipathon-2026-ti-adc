`timescale 1ns / 1ps

module sar_adc_logic #(
    parameter int RESOLUTION = 8
)(
    input  logic rst_n, // Global system reset
    input  logic clk_i, // 25 MHz External Sampling Clock (HIGH = Sample, LOW = Convert)

    input  logic out_p, // Comparator outputs
    input  logic out_n,
    
    output logic [RESOLUTION-1:0] dac_ctrl, 
    output logic [RESOLUTION-1:0] dout, // Output for 50 MHz logic
    output logic clk_o, // Drives comparator
    output logic clk_o_n
);

    // Asynchronous clk
    logic valid_clk;
    assign valid_clk = out_p ^ out_n; 


    logic [RESOLUTION:0] seq; 
    logic [RESOLUTION-1:0] sar_reg;
    logic [RESOLUTION-1:0] sar_reg_next; // Combinational next-state for sar_reg
    logic eoc;

    assign eoc = seq[0]; // The 9th bit (index 0) is the End of Conversion flag

    logic start_req;

    // "Token at MSB" condition - used to synchronously acknowledge/clear
    // start_req once the sequencer has confirmed the restart, instead of
    // feeding this back as an async reset (which created a zero-delay
    // combinational loop: start_req -> seq_rst -> seq[RESOLUTION] -> start_req).
    logic seq_at_msb;
    assign seq_at_msb = seq[RESOLUTION];

    // External Clock Domain: Catches the 25 MHz rising edge and holds it
    // until the self-timed domain confirms the sequencer has restarted.
    // NOTE: seq_at_msb is generated in the valid_clk domain and sampled here
    // in the clk_i domain - this is a genuine clock-domain crossing. Since
    // valid_clk and clk_i have no fixed phase relationship, consider passing
    // seq_at_msb through a 2-flop synchronizer in the clk_i domain if you see
    // metastability issues in simulation/silicon (see note below the module).
    always_ff @(posedge clk_i or negedge rst_n) begin
        if (!rst_n) begin
            start_req <= 1'b0;
        end else if (seq_at_msb) begin
            start_req <= 1'b0;      // synchronous clear once seq confirms restart
        end else begin
            start_req <= 1'b1;
        end
    end

    // seq_rst now depends only on rst_n and start_req - not on anything
    // downstream of its own effect - so the loop is broken.
    logic seq_rst;
    assign seq_rst = ~rst_n | start_req;

    // Combinational next-state logic for sar_reg.
    // Computing the full word here (instead of per-bit nonblocking assignments
    // inside the clocked process) keeps the reset branch a clean constant,
    // which is required for Yosys's proc_arst pass to resolve the async reset.
    always_comb begin
        sar_reg_next = sar_reg; // default: hold current value

        // Latch the comparator decision into the current active bit
        for (int i = 0; i < RESOLUTION; i++) begin
            if (seq[i+1]) begin
                sar_reg_next[i] = out_p ? 1'b1 : 1'b0;
            end
        end

        // Set up the next bit for the DAC trial
        for (int i = 0; i < RESOLUTION-1; i++) begin
            if (seq[i+2]) begin
                sar_reg_next[i] = 1'b1;
            end
        end
    end

    always_ff @(posedge valid_clk or posedge seq_rst) begin
        if (seq_rst) begin
            seq     <= 1 << RESOLUTION;
            sar_reg <= 1 << (RESOLUTION - 1);
        end else begin
            seq     <= seq >> 1;
            sar_reg <= sar_reg_next;
        end
    end

    // Output dout 
    always_ff @(posedge eoc or negedge rst_n) begin
        if (!rst_n) begin
            dout <= '0;
        end else begin
            dout <= sar_reg;
        end
    end
    
    // FIXED: Swapped clk_i for start_req so the comparator can fire 
    // while the 25 MHz external clock is still HIGH.
    logic comp_trigger;
    assign comp_trigger = ~(valid_clk | eoc | start_req); 
    
    assign clk_o   = comp_trigger;
    assign clk_o_n = ~comp_trigger;

    assign dac_ctrl = sar_reg;

endmodule