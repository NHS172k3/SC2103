`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:58:13 09/06/2019 
// Design Name: 
// Module Name:    AM_top_pipelined 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: Pipelined 6x6 array multiplier top module
//
// Dependencies: multA.v, multB.v
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module AM_top_pipelined (input clk, rst, input [5:0] a, b, output reg [11:0] result);

    // Stage 1 pipeline registers
    reg [5:0] a_r1, b_r1;
    // Stage 2 pipeline registers
    reg [5:0] a_r2, b_r2;
    reg [9:0] Pin;

    // Combinational outputs
    wire [9:0] Pa;
    wire [11:0] Pb;

    // Instantiate multA (stage 1)
    multA uut_A (.a(a_r1), .b(b_r1), .P(Pa));
    // Instantiate multB (stage 2)
    multB uut_B (.a(a_r2), .b(b_r2), .Pin(Pin), .P(Pb));

    always @ (posedge clk)
        if (rst) begin
            a_r1 <= 0;
            b_r1 <= 0;
            a_r2 <= 0;
            b_r2 <= 0;
            Pin  <= 0;
            result <= 0;
        end else begin
            // Stage 1: latch inputs
            a_r1 <= a;
            b_r1 <= b;
            // Stage 2: latch stage-1 outputs
            a_r2 <= a_r1;
            b_r2 <= b_r1;
            Pin  <= Pa;
            // Output: latch multB result
            result <= Pb;
        end

endmodule
