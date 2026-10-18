
module alu 
import rv32i::*;
(
    input alu_op_e alu_op,
    input logic [31:0] a, b,
    output logic [31:0] alu_result
);
always_comb begin
    case (alu_op)
        ALU_ADD: alu_result = a + b;
        ALU_SUB: alu_result = a - b;
        ALU_AND: alu_result = a & b;
        ALU_OR:  alu_result = a | b;
        ALU_XOR: alu_result = a ^ b;
        ALU_SLL: alu_result = a << b[4:0];
        ALU_SRL: alu_result = a >> b[4:0];
        ALU_SRA: alu_result = $signed(a) >>> b[4:0];
        ALU_SLT: alu_result = {31'b0, $signed(a) < $signed(b)};
        ALU_SLTU: alu_result = {31'b0, a < b};
        default: alu_result = 32'b0;
    endcase
end
endmodule