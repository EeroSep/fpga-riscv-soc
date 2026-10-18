module immediate_generator
import rv32i::*;
(
    input logic [31:0] instruction,
    input imm_sel_e imm_sel,
    output logic [31:0] imm
);

    r_inst_t inst;
    assign inst = instruction;

    always_comb begin
        case (imm_sel)
            IMM_I: imm = {{20{inst[31]}}, inst[31:20]}; // Sign-extend 12-bit immediate
            IMM_S: imm = {{20{inst[31]}}, inst[31:25], inst[11:7]}; // Sign-extend 12-bit immediate
            IMM_B: imm = {{19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0}; // Sign-extend 13-bit immediate
            IMM_U: imm = {inst[31:12], 12'b0}; // Zero-extend 20-bit immediate
            IMM_J: imm = {{11{inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0}; // Sign-extend 21-bit immediate
            default: imm = 32'b0; // Default case to avoid latches
        endcase
    end

endmodule