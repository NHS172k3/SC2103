`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: NTU
// Engineer: NHS
//
// Module Name: Lab2_top
// Project Name: Lab2 - Memory Primitives
// Description: 64 x 8-bit distributed RAM with D flip-flop and MUX
//
//////////////////////////////////////////////////////////////////////////////////

module Lab2_top(
    input clk,
    input rst,
    input write_en,
    input save_data,
    input show_reg,
    input [7:0] d_in,
    output [7:0] d_out
    );

    // Declare internal 8-bit signals
    reg [7:0] reg_d;
    wire [7:0] mem_d;

    // D Flip-Flop: stores d_in to reg_d when save_data is asserted
    always @(posedge clk) begin
        if (rst)
            reg_d <= 8'h00;
        else if (save_data)
            reg_d <= d_in;
    end

    // Instantiate 64 x 8-bit distributed RAM IP (Lab2_mem)
    // NOTE: This IP must be generated using Vivado IP Catalog:
    // 1. Go to IP Catalog > Memories & Storage Elements > RAMs & ROMs > Distributed Memory Generator
    // 2. Set Component Name: Lab2_mem
    // 3. Set Depth: 64, Data Width: 8
    // 4. Select Single port RAM
    // 5. Verify unregistered input/output, no pipelining

    Lab2_mem U1 (
        .a(d_in[5:0]),      // input wire [5 : 0] a (address)
        .d(reg_d),          // input wire [7 : 0] d (data input) - from REGISTER
        .clk(clk),          // input wire clk
        .we(write_en),      // input wire we (write enable)
        .spo(mem_d)         // output wire [7 : 0] spo (single port output)
    );

    // 2:1 MUX: select between register and memory output
    // show_reg = 1: display memory output (mem_d)
    // show_reg = 0: display register output (reg_d)
    assign d_out = show_reg ? mem_d : reg_d;

endmodule
