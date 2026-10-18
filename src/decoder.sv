module decoder 
import rv32i::*;
(
    input logic [31:0] instruction,
    output logic [4:0] rs1, rs2, rd,
    output alu_op_e alu_op,
    output alu_a_sel_e alu_a_sel,
    output alu_b_sel_e alu_b_sel,
    output logic register_write_en,
    output logic mem_write_en,
    output flow_e flow,
    output imm_sel_e imm_sel,
    output logic [2:0] funct3,
    output wb_sel_e wb_sel
);
    r_inst_t inst;
    assign inst = r_inst_t'(instruction);


    assign rs1 = inst.rs1;
    assign rs2 = inst.rs2;
    assign rd = inst.rd;
    assign funct3 = inst.funct3;


    function automatic alu_op_e alu_from_funct(input logic [2:0] f3, input logic f7_b5, input logic is_reg);
        case (f3)
            3'b000: return (is_reg && f7_b5) ? ALU_SUB : ALU_ADD; // ADD/SUB/ADDI
            3'b001: return ALU_SLL;
            3'b010: return ALU_SLT;
            3'b011: return ALU_SLTU;
            3'b100: return ALU_XOR;
            3'b101: return f7_b5 ? ALU_SRA : ALU_SRL;            // SRL/SRA/SRLI/SRAI
            3'b110: return ALU_OR;
            3'b111: return ALU_AND;
            default: return ALU_ADD;
        endcase
    endfunction

    always_comb begin
        // Default values to avoid latches
        alu_a_sel = ALU_RS1; 
        alu_b_sel = ALU_IMM; 
        alu_op = ALU_ADD; 
        wb_sel = WB_ALU;
        flow = FLOW_NEXT;
        imm_sel = IMM_I;
        register_write_en = 1'b0;
        mem_write_en = 1'b0;
        
        case (opcode_e'(inst.opcode))
            OP_LUI: begin
                imm_sel = IMM_U; 
                alu_a_sel = ALU_ZERO; 
                alu_b_sel = ALU_IMM; 
                alu_op = ALU_ADD;
                wb_sel = WB_ALU;
                register_write_en = 1'b1;
            end
            OP_AUIPC: begin
                imm_sel = IMM_U;
                alu_a_sel = ALU_PC; 
                alu_b_sel = ALU_IMM; 
                alu_op = ALU_ADD;
                wb_sel = WB_ALU;
                register_write_en = 1'b1;
            end
            OP_JAL: begin
                imm_sel = IMM_J;
                alu_a_sel = ALU_PC;
                alu_b_sel = ALU_IMM;
                alu_op = ALU_ADD;
                wb_sel = WB_PC_PLUS_4;
                register_write_en = 1'b1;
                flow = FLOW_JUMP;
            end
            OP_JALR: begin
                imm_sel = IMM_I;
                alu_a_sel = ALU_RS1;
                alu_b_sel = ALU_IMM;
                alu_op = ALU_ADD;
                wb_sel = WB_PC_PLUS_4;
                register_write_en = 1'b1;
                flow = FLOW_JUMP;
            end
            OP_BRANCH: begin
                imm_sel = IMM_B;
                alu_a_sel = ALU_PC;
                alu_b_sel = ALU_IMM;
                alu_op = ALU_ADD;
                flow = FLOW_BRANCH;
            end
            OP_LOAD: begin
                imm_sel = IMM_I;
                alu_a_sel = ALU_RS1;
                alu_b_sel = ALU_IMM;
                alu_op = ALU_ADD;
                register_write_en = 1'b1;
                wb_sel = WB_MEM;
            end
            OP_STORE: begin
                imm_sel = IMM_S;
                mem_write_en = 1'b1;
                alu_a_sel = ALU_RS1;
                alu_b_sel = ALU_IMM;
                alu_op = ALU_ADD;
            end
            OP_IMM: begin
                imm_sel = IMM_I;
                register_write_en = 1'b1;
                alu_a_sel = ALU_RS1;
                alu_b_sel = ALU_IMM;
                alu_op = alu_from_funct(inst.funct3, inst.funct7[5], 1'b0);
            end
            OP_REG: begin
                register_write_en = 1'b1;
                alu_a_sel = ALU_RS1;
                alu_b_sel = ALU_RS2;
                alu_op = alu_from_funct(inst.funct3, inst.funct7[5], 1'b1);
            end
            OP_FENCE: begin
                flow = FLOW_NEXT; // FENCE is NOP for now
            end
            OP_SYSTEM: begin
                
            end
            default: ;
        endcase
    end

endmodule