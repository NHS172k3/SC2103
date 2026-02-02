module adder6b (
    input  [5:0] a,
    input  [5:0] b,
    output [5:0] sum
);

    // Continuous assignment performs the addition.
    assign sum = a - b;

endmodule