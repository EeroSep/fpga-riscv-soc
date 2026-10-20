module core
import rv32i::*;
(
    input logic clk,
    input logic rst_n,
    output logic [31:0] io_addr,    // store address (alu_result)
    output logic [31:0] io_wdata,   // store data (rs2_data)
    output logic io_we              // store enable
);

    // PC
    logic [31:0] pc;
    logic [31:0] next_pc;
    logic [31:0] selected_pc;
    pc_sel_e pc_sel;

    // Instruction
    logic [31:0] instruction;

    // Decoder outputs
    logic [4:0] rs1, rs2, rd;
    alu_op_e alu_op;
    alu_a_sel_e alu_a_sel;
    alu_b_sel_e alu_b_sel;
    logic register_write_en;
    logic mem_write_en;
    flow_e flow;
    logic [2:0] funct3;
    wb_sel_e wb_sel;
    imm_sel_e imm_sel;

    // Datapath
    logic [31:0] imm;
    logic [31:0] rs1_data, rs2_data;
    logic [31:0] alu_result;
    logic [31:0] data_out;
    logic branch;

    assign next_pc = pc + 4;

    imem imem(                      // Instruction memory
        .addr(pc),                  // program counter as address
        .instruction(instruction)   // output instruction
    );

    decoder decoder(
        .instruction(instruction),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .alu_op(alu_op),
        .alu_a_sel(alu_a_sel),
        .alu_b_sel(alu_b_sel),
        .register_write_en(register_write_en),
        .mem_write_en(mem_write_en),
        .flow(flow),
        .imm_sel(imm_sel),
        .funct3(funct3),
        .wb_sel(wb_sel)
    );

    immediate_generator imm_gen(
        .instruction(instruction),
        .imm_sel(imm_sel),
        .imm(imm)
    );

    registers registers(
        .clk(clk),
        .write_data(wb_sel == WB_MEM ? data_out : wb_sel == WB_ALU ? alu_result : next_pc), // Write back from memory, ALU result or pc + 4
        .write_en(register_write_en),
        .rd(rd),
        .rs1(rs1),
        .rs2(rs2),
        .reg_out1(rs1_data),
        .reg_out2(rs2_data)
    );

    alu alu(
        .a(alu_a_sel == ALU_RS1 ? rs1_data : alu_a_sel == ALU_PC ? pc : 32'b0),  // a input mux: rs1, pc, or zero
        .b(alu_b_sel == ALU_RS2 ? rs2_data : imm),                               // b input mux: rs2 or immediate
        .alu_op(alu_op),                                                    // ALU operation
        .alu_result(alu_result)
    );

    memory memory(
        .addr(alu_result),
        .data_in(rs2_data),
        .funct3(funct3),
        .mem_write_en(mem_write_en),
        .data_out(data_out)
    );

    // Store bus out to main for memory-mapped IO
    assign io_addr = alu_result;
    assign io_wdata = rs2_data;
    assign io_we = mem_write_en;

    branch_logic branch_logic(
        .rs1(rs1_data),
        .rs2(rs2_data),
        .funct3(funct3),
        .branch_taken(branch)
    );

    next_pc_sel next_pc_sel(
        .flow(flow),
        .branch_taken(branch),
        .pc_sel(pc_sel)
    );

    // next pc mux, & ~1 clears bit 0 for JALR (branch/JAL targets are already even)
    assign selected_pc = (pc_sel == PC_TARGET) ? (alu_result & ~32'd1) : next_pc;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc <= 32'b0;
        end else begin
            pc <= selected_pc;
        end
    end

endmodule
