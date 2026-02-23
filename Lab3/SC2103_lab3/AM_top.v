`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:58:13 09/06/2019 
// Design Name: 
// Module Name:    AM_top 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module AM_top (input clk, rst, input [5:0] a, b, output reg [11:0] result);

	reg [5:0] a_r, b_r;
	wire [11:0] P;

	// Instantiate the array multiplier
	array_mult_6bit uut (.a(a_r), .b(b_r), .P(P));
	
	always @ (posedge clk)
		if (rst)		// a positive edge triggered reset.
		begin
			a_r <= 0;
			b_r <= 0;
			result <= 0;
		end
		else
		begin
			a_r <= a;
			b_r <= b;
			result <= P;
		end

endmodule
