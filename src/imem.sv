module imem
import rv32i::*;
(
    input logic [31:0] addr,
    output logic [31:0] instruction
);

    logic [31:0] memory [0:255]; // 256 words of instruction memory
    initial begin
        $readmemh("program.hex", memory); // load instructions from a hex file
    end

    assign instruction = memory[addr[9:2]]; // word-aligned addressing and only using the lower 8 bits of the address because we have 256 words (2^8 = 256)


endmodule