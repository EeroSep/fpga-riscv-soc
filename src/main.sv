module main  // Top-level module. Processor core + IO + memory + other stuff
import rv32i::*;
( input logic clk,
  input logic rst_n
);

    core core(
        .clk(clk),
        .rst_n(rst_n)
    );
endmodule
