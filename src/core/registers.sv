module registers 
import rv32i::*;
(
    input logic clk,
    input [31:0] write_data,
    input logic write_en,
    input logic [4:0] rd,
    input logic [4:0] rs1,
    input logic [4:0] rs2,
    output logic [31:0] reg_out1,
    output logic [31:0] reg_out2
);
    reg [31:0] registers [0:31];

    always @(posedge clk) begin
        if ( write_en && rd != 5'b0) begin
            registers[rd] <= write_data;
        end
    end
    assign reg_out1 = (rs1 != 5'b0) ? registers[rs1] : 32'b0;
    assign reg_out2 = (rs2 != 5'b0) ? registers[rs2] : 32'b0;
endmodule