module next_pc_sel
import rv32i::*;
(
    input flow_e flow,
    input logic branch_taken,
    output pc_sel_e pc_sel
);
    always_comb begin
        case (flow)
            FLOW_NEXT: pc_sel = PC_PLUS_4;
            FLOW_BRANCH: pc_sel = branch_taken ? PC_TARGET : PC_PLUS_4;
            FLOW_JUMP: pc_sel = PC_TARGET; // JAL and JALR always jump
            default: pc_sel = PC_PLUS_4; // Default to pc + 4 if flow is invalid
        endcase
    end

endmodule
