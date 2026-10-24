package rv32i;

    // Opcodes for RISC-V instructions
    typedef enum logic [6:0] {
        OP_LUI   = 7'b0110111, // Load Upper Immediate
        OP_AUIPC = 7'b0010111, // Add Upper Immediate to PC
        OP_JAL   = 7'b1101111, // Jump and Link
        OP_JALR  = 7'b1100111, // Jump and Link Register
        OP_BRANCH= 7'b1100011, // Branch instructions (BEQ, BNE, BLT, BGE, BLTU, BGEU) same opcode
        OP_LOAD  = 7'b0000011, // Load instructions (LB, LH, LW, LBU, LHU) same opcode
        OP_STORE = 7'b0100011, // Store instructions (SB, SH, SW) same opcode
        OP_IMM   = 7'b0010011, // Immediate ALU operations (ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI)
        OP_REG   = 7'b0110011, // Register-Register ALU operations (ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND)
        OP_FENCE = 7'b0001111, // Fence instructions 
        OP_SYSTEM= 7'b1110011  // System instructions (ECALL, EBREAK )
    } opcode_e;

    // ALU operations, internal use
    typedef enum logic [3:0] {
        ALU_ADD,
        ALU_SUB,
        ALU_AND,
        ALU_OR,
        ALU_XOR,
        ALU_SLL,
        ALU_SRL,
        ALU_SRA,
        ALU_SLT,
        ALU_SLTU
    } alu_op_e;

    // R-type instruction packed struct as base. Get immediate values from slices of instruction for other types.
    typedef struct packed {
        logic [6:0] funct7;
        logic [4:0] rs2;
        logic [4:0] rs1;
        logic [2:0] funct3;
        logic [4:0] rd;
        logic [6:0] opcode;
    } r_inst_t;

    // ALU source selection for immediate values or register values
    typedef enum logic [1:0] {
        ALU_RS1, 
        ALU_PC, 
        ALU_ZERO 
    } alu_a_sel_e;

    typedef enum logic {
        ALU_RS2, 
        ALU_IMM 
    } alu_b_sel_e;

    typedef enum logic [2:0] {
        IMM_I,
        IMM_S,
        IMM_B,
        IMM_U,
        IMM_J
    } imm_sel_e;

    typedef enum logic {
        PC_PLUS_4,
        PC_TARGET
    } pc_sel_e;

    typedef enum logic [1:0] {
        FLOW_NEXT,
        FLOW_BRANCH,
        FLOW_JUMP
    }flow_e;

    typedef enum logic [1:0] {
        WB_ALU,
        WB_MEM,
        WB_PC_PLUS_4
    } wb_sel_e;

endpackage