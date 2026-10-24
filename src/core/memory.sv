module memory
import rv32i::*;
(
    input logic clk,
    input logic [31:0] addr,    // ALU result as address
    input logic [31:0] data_in, // rs2 data
    input logic [2:0] funct3,
    input logic mem_write_en,
    output logic [31:0] data_out // to WB mux
);
    logic [31:0] mem [0:1023]; // 4KB memory

    logic [9:0] word_addr;
    logic [31:0] word;
    logic [15:0] halfword;
    logic [7:0] byte;
    
    assign word_addr = addr[11:2]; // Word-aligned address
    assign rd_word = mem[word_addr];
    assign rd_halfword = word[addr[1]*16 +: 16];    // 
    assign rd_byte = word[addr[1:0]*8 +: 8]; 

    always_ff @(posedge clk) begin
        if (mem_write_en) begin
            case (funct3)
                3'b000: mem[word_addr][addr[1:0]*8 +: 8] <= data_in[7:0];   // SB
                3'b001: mem[word_addr][addr[1]*16 +: 16] <= data_in[15:0];  // SH
                3'b010: mem[word_addr] <= data_in;                          // SW
                default: ;
            endcase
        end
    end
    always_comb begin
        case (funct3)
            3'b000:  data_out = {{24{rd_byte[7]}},  rd_byte};   // LB
            3'b001:  data_out = {{16{rd_half[15]}}, rd_half};   // LH
            3'b010:  data_out = rd_word;                        // LW
            3'b100:  data_out = {24'b0, rd_byte};               // LBU
            3'b101:  data_out = {16'b0, rd_half};               // LHU
            default: data_out = 32'b0;
        endcase
    end
endmodule