// Example Verilog Testbench
`timescale 1ns / 1ps

module adder_tb();
  reg [5:0] a, b;
  wire [5:0] sum;
  adder6b uut (.a(a), .b(b), .sum(sum));
  initial begin
    $dumpfile("adder_tb.vcd");
    $dumpvars(0, adder_tb);
    repeat (10) begin
    	a = $random;  // Ensure positive 6-bit values
    	b = $random;
      #10;
      $display("Inputs: a=%h b=%h | Sum: %h | Expected: %h", a, b, sum, a + b);
      if (sum !== ((a + b) & 6'h3F)) begin
        $display("Error! Mismatch detected.");
      end
    end
    $finish;
  end
endmodule

    
        
