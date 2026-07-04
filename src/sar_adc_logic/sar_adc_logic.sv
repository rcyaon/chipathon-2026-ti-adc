`timescale 1ns / 1ps

module sar_adc_logic #(
    parameter int RESOLUTION = 8
)(
    input  logic rst_n, 
    input  logic clk_i, 
    input  logic out_p, 
    input  logic out_n,
    
    output logic [RESOLUTION-1:0] dac_ctrl, 
    output logic [RESOLUTION-1:0] dout, 
    output logic clk_o, 
    output logic clk_o_n
);

    logic rst_n_tree;
    gf180mcu_fd_sc_mcu7t5v0__buf_8 rst_root (
        .I(rst_n),
        .Z(rst_n_tree)
    );

    logic valid_clk;
    gf180mcu_fd_sc_mcu7t5v0__xor2_4 valid_clk_xor (
        .A1(out_p),
        .A2(out_n),
        .Z(valid_clk)
    );

    logic [RESOLUTION:0] seq; 
    logic [RESOLUTION-1:0] sar_reg;
    logic [RESOLUTION-1:0] sar_reg_next;
    logic eoc;

    assign eoc = seq[0];

    logic start_req;
    logic seq_at_msb;
    assign seq_at_msb = seq[RESOLUTION];

    // Reset logic using the buffered reset
    always_ff @(posedge clk_i or negedge rst_n_tree) begin
        if (!rst_n_tree) start_req <= 1'b0;
        else if (seq_at_msb) start_req <= 1'b0;
        else start_req <= 1'b1;
    end

    logic seq_rst;
    assign seq_rst = ~rst_n_tree | start_req;

    always_comb begin
        sar_reg_next = sar_reg;
        for (int i = 0; i < RESOLUTION; i++) begin
            if (seq[i+1]) sar_reg_next[i] = out_p ? 1'b1 : 1'b0;
        end
        for (int i = 0; i < RESOLUTION-1; i++) begin
            if (seq[i+2]) sar_reg_next[i] = 1'b1;
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

    always_ff @(posedge eoc or negedge rst_n_tree) begin
        if (!rst_n_tree) dout <= '0;
        else dout <= sar_reg;
    end
    
    logic comp_trigger, comp_trigger_raw;
    gf180mcu_fd_sc_mcu7t5v0__nor3_4 comp_trigger_nor (
        .A1(valid_clk), .A2(eoc), .A3(start_req), .ZN(comp_trigger_raw)
    );
    gf180mcu_fd_sc_mcu7t5v0__buf_16 comp_trigger_driver (
        .I(comp_trigger_raw), .Z(comp_trigger)
    );
    
    assign clk_o    = comp_trigger;
    assign clk_o_n  = ~comp_trigger;
    assign dac_ctrl = sar_reg;

endmodule