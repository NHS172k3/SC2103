`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: NTU
// Engineer: Payithiyam
//
// Module Name: Lab2_top_tb
// Project Name: Lab2 - Memory Primitives
// Description: Testbench for Lab2_top module
//
//////////////////////////////////////////////////////////////////////////////////

module Lab2_top_tb;

    // Declare inputs as reg and outputs as wire
    reg clk;
    reg rst;
    reg write_en;
    reg save_data;
    reg show_reg;
    reg [7:0] d_in;
    wire [7:0] d_out;

    // Instantiate the Unit Under Test (UUT)
    Lab2_top uut (
        .clk(clk),
        .rst(rst),
        .write_en(write_en),
        .save_data(save_data),
        .show_reg(show_reg),
        .d_in(d_in),
        .d_out(d_out)
    );

    // Clock generation: toggle every 5 timesteps (period = 10 timesteps)
    always #5 clk = ~clk;

    // Test stimulus
    initial begin
        // Initialize all inputs
        clk = 0;
        rst = 1;
        write_en = 0;
        save_data = 0;
        show_reg = 0;
        d_in = 8'h00;

        // Test sequence from Figure 2
        #10 rst = 0;
        #10 d_in = 8'h15;
        #10 save_data = 1;
        #10 save_data = 0; d_in = 8'h01;
        #10 write_en = 1;
        #10 write_en = 0;
        #10 d_in = 8'hA3;
        #10 save_data = 1;
        #10 save_data = 0; d_in = 8'h02;
        #10 write_en = 1;
        #10 write_en = 0;
        #10 d_in = 8'h87;
        #10 save_data = 1;
        #10 save_data = 0;
        #10 d_in = 8'h01;
        #10 show_reg = 1;
        #10 d_in = 8'h01; show_reg = 0;
        #10 $finish();
    end

    // Monitor output changes
    initial begin
        $monitor("Time=%0t rst=%b d_in=%h save_data=%b write_en=%b show_reg=%b d_out=%h",
                 $time, rst, d_in, save_data, write_en, show_reg, d_out);
    end

    // Expected output sequence: 0, 15, A3, 87, 15, 87
    // Time 0:   d_out = 0x00 (reset)
    // Time 30:  d_out = 0x15 (saved to register)
    // Time 80:  d_out = 0xA3 (saved to register)
    // Time 130: d_out = 0x87 (saved to register)
    // Time 150: d_out = 0x15 (reading Memory[1])
    // Time 160: d_out = 0x87 (back to register)

endmodule
