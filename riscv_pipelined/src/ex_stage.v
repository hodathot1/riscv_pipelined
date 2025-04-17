module ex_stage (
    input wire [31:0] pc,
    input wire [31:0] rs1_data,
    input wire [31:0] rs2_data,
    input wire [31:0] imm,
    input wire [3:0]  alu_op,
    input wire        alu_src,
    input wire        branch,
    input wire [1:0]  forward_a,
    input wire [1:0]  forward_b,
    input wire [31:0] ex_mem_alu_result,
    input wire [31:0] mem_wb_result,
    input wire [2:0]  funct3,    
    output wire [31:0] alu_result,
    output wire        zero_flag,
    output wire [31:0] branch_target,
    output wire        branch_taken
);
    // Function để xử lý forwarding
    function [31:0] get_forwarded_data;
        input [31:0] original_data;
        input [1:0] forward_sel;
        input [31:0] ex_mem_data;
        input [31:0] mem_wb_data;
        begin
            case (forward_sel)
                2'b00: get_forwarded_data = original_data;      
                2'b10: get_forwarded_data = ex_mem_data;        
                2'b01: get_forwarded_data = mem_wb_data;        
                default: get_forwarded_data = original_data;
            endcase
        end
    endfunction

    function [31:0] execute_alu;
        input [31:0] operand1;
        input [31:0] operand2;
        input [3:0] operation;
        begin
            case (operation)
                4'b0000: execute_alu = operand1 + operand2;                          // ADD
                4'b0001: execute_alu = operand1 - operand2;                          // SUB
                4'b0010: execute_alu = operand1 << operand2[4:0];                    // SLL
                4'b0011: execute_alu = ($signed(operand1) < $signed(operand2)) ? 1 : 0; // SLT
                4'b0100: execute_alu = (operand1 < operand2) ? 1 : 0;                // SLTU
                4'b0101: execute_alu = operand1 ^ operand2;                          // XOR
                4'b0110: execute_alu = operand1 >> operand2[4:0];                    // SRL
                4'b0111: execute_alu = $signed(operand1) >>> operand2[4:0];          // SRA
                4'b1000: execute_alu = operand1 | operand2;                          // OR
                4'b1001: execute_alu = operand1 & operand2;                          // AND
                4'b1010: execute_alu = operand2;                                     // LUI
                4'b1011: execute_alu = operand1 + operand2;                          // AUIPC
                4'b1100: execute_alu = operand1 + 4;                                 // JAL/JALR
                default: execute_alu = 32'h0;
            endcase
        end
    endfunction

    // Function để kiểm tra điều kiện nhánh
    function check_branch_condition;
        input [3:0] operation;
        input is_zero;
        input branch_enable;
        begin
            case (operation)
                4'b0001: check_branch_condition = branch_enable && (
                    (funct3 == 3'b000 && is_zero) ||     // BEQ
                    (funct3 == 3'b001 && !is_zero)       // BNE
                );
                4'b0011: check_branch_condition = branch_enable && (
                    (funct3 == 3'b100 && !is_zero) ||    // BLT
                    (funct3 == 3'b101 && is_zero)        // BGE
                );
                4'b0100: check_branch_condition = branch_enable && (
                    (funct3 == 3'b110 && !is_zero) ||    // BLTU
                    (funct3 == 3'b111 && is_zero)        // BGEU
                );
                4'b1100: check_branch_condition = branch_enable;  // JAL
                default: check_branch_condition = 0;
            endcase
        end
    endfunction

    wire [31:0] forwarded_rs1_data = get_forwarded_data(rs1_data, forward_a, 
                                                       ex_mem_alu_result, mem_wb_result);
    wire [31:0] forwarded_rs2_data = get_forwarded_data(rs2_data, forward_b,
                                                       ex_mem_alu_result, mem_wb_result);

    wire [31:0] alu_operand_2 = alu_src ? imm : forwarded_rs2_data;
    
    reg [31:0] alu_result_reg;
    always @(*) begin
        alu_result_reg = execute_alu(forwarded_rs1_data, alu_operand_2, alu_op);
    end
    
    assign alu_result = alu_result_reg;
    assign zero_flag = (alu_result_reg == 32'h0);
    assign branch_target = pc + imm;
    assign branch_taken = check_branch_condition(alu_op, zero_flag, branch);
    
endmodule