module if_stage (
    input wire clk,
    input wire rst_n,
    input wire stall,
    input wire branch_taken,
    input wire [31:0] branch_target,
    output reg [31:0] pc,
    output wire [31:0] instruction
);

    reg [31:0] next_pc;

    reg [31:0] instr_mem [0:1023];
    
    function [31:0] calculate_next_pc;
        input [31:0] current_pc;
        input branch_taken;
        input [31:0] branch_target;
        begin
            calculate_next_pc = branch_taken ? branch_target : (current_pc + 4);
        end
    endfunction

    function [31:0] read_instruction;
        input [31:0] address;
        begin
            read_instruction = instr_mem[address[11:2]];
        end
    endfunction

    function is_valid_address;
        input [31:0] address;
        begin
            is_valid_address = (address[1:0] == 2'b00) && (address[31:12] == 20'h0);
        end
    endfunction

    initial begin
        integer i;
        for (i = 0; i < 1024; i = i + 1) begin
            instr_mem[i] = 32'h00000013;  // NOP (addi x0, x0, 0)
        end
        
        // tính 2+3 = 5
        instr_mem[0] = 32'h00200093;  // addi x1, x0, 2     # x1 = 2
        instr_mem[1] = 32'h00300113;  // addi x2, x0, 3     # x2 = 3
        instr_mem[2] = 32'h002081b3;  // add  x3, x1, x2    # x3 = x1 + x2 = 5
        instr_mem[3] = 32'h00000063;  // beq x0, x0, 0      # infinite loop
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc <= 32'h0;
        end else if (!stall) begin
            pc <= calculate_next_pc(pc, branch_taken, branch_target);
        end
    end

    assign instruction = is_valid_address(pc) ? read_instruction(pc) : 32'h00000013; 

endmodule