module memory
import rv32i::*;
(
    input logic [31:0] addr,
    input logic [31:0] data_in,
    input logic [2:0] funct3,
    input logic mem_write_en,
    output logic [31:0] data_out
);
    assign data_out = 32'b0; // Placeholder for memory read operation

endmodule