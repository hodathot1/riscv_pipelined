module id_stage (
    input wire clk,
    input wire rst_n,
    input wire [31:0] instruction,
    input wire [31:0] pc,
    input wire wb_reg_write,
    input wire [4:0] wb_rd,
    input wire [31:0] wb_data,
    input wire stall,
    output reg mem_to_reg,
    output reg mem_read,
    output reg mem_write,
    output reg [3:0] alu_op,
    output reg alu_src,
    output reg reg_write,
    output reg branch,
    output reg [31:0] rs1_data,
    output reg [31:0] rs2_data,
    output reg [31:0] imm,
    output reg [4:0] rd,
    output reg [4:0] rs1,
    output reg [4:0] rs2
);

    reg [31:0] registers [0:31];
    
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1)
            registers[i] = 32'h0;
    end
    
    function [6:0] get_opcode;
        input [31:0] instr;
        begin
            get_opcode = instr[6:0];
        end
    endfunction

    function [2:0] get_funct3;
        input [31:0] instr;
        begin
            get_funct3 = instr[14:12];
        end
    endfunction

    function [6:0] get_funct7;
        input [31:0] instr;
        begin
            get_funct7 = instr[31:25];
        end
    endfunction

    function [31:0] calculate_immediate;
        input [31:0] instr;
        input [6:0] opcode;
        begin
            case (opcode)
                7'b0010011: calculate_immediate = {{20{instr[31]}}, instr[31:20]}; // I-type
                7'b0000011: calculate_immediate = {{20{instr[31]}}, instr[31:20]}; // Load
                7'b0100011: calculate_immediate = {{20{instr[31]}}, instr[31:25], instr[11:7]}; // Store
                7'b1100011: calculate_immediate = {{20{instr[31]}}, instr[7], instr[30:25], 
                                                instr[11:8], 1'b0}; // Branch
                7'b0110111: calculate_immediate = {instr[31:12], 12'b0}; // LUI
                7'b0010111: calculate_immediate = {instr[31:12], 12'b0}; // AUIPC
                7'b1101111: calculate_immediate = {{12{instr[31]}}, instr[19:12], instr[20],
                                                instr[30:21], 1'b0}; // JAL
                default: calculate_immediate = 32'h0;
            endcase
        end
    endfunction

    wire [6:0] opcode = get_opcode(instruction);
    wire [2:0] funct3 = get_funct3(instruction);
    wire [6:0] funct7 = get_funct7(instruction);
    
    always @(*) begin
        rs1 = instruction[19:15];
        rs2 = instruction[24:20];
        rd = instruction[11:7];
        
        imm = calculate_immediate(instruction, opcode);
        
        if (stall) begin
            mem_to_reg = 0;
            mem_read = 0;
            mem_write = 0;
            alu_op = 4'b0;
            alu_src = 0;
            reg_write = 0;
            branch = 0;
        end else begin
            case (opcode)
                7'b0110011: begin // R-type
                    mem_to_reg = 0;
                    mem_read = 0;
                    mem_write = 0;
                    alu_src = 0;
                    reg_write = 1;
                    branch = 0;
                    case (funct3)
                        3'b000: alu_op = (funct7[5]) ? 4'b0001 : 4'b0000; // SUB : ADD
                        3'b001: alu_op = 4'b0010; // SLL
                        3'b010: alu_op = 4'b0011; // SLT
                        3'b011: alu_op = 4'b0100; // SLTU
                        3'b100: alu_op = 4'b0101; // XOR
                        3'b101: alu_op = (funct7[5]) ? 4'b0111 : 4'b0110; // SRA : SRL
                        3'b110: alu_op = 4'b1000; // OR
                        3'b111: alu_op = 4'b1001; // AND
                        default: alu_op = 4'b0000;
                    endcase
                end
                
                7'b0010011: begin // I-type
                    mem_to_reg = 0;
                    mem_read = 0;
                    mem_write = 0;
                    alu_src = 1;
                    reg_write = 1;
                    branch = 0;
                    case (funct3)
                        3'b000: alu_op = 4'b0000; // ADDI
                        3'b001: alu_op = 4'b0010; // SLLI
                        3'b010: alu_op = 4'b0011; // SLTI
                        3'b011: alu_op = 4'b0100; // SLTIU
                        3'b100: alu_op = 4'b0101; // XORI
                        3'b101: alu_op = (funct7[5]) ? 4'b0111 : 4'b0110; // SRAI : SRLI
                        3'b110: alu_op = 4'b1000; // ORI
                        3'b111: alu_op = 4'b1001; // ANDI
                        default: alu_op = 4'b0000;
                    endcase
                end
                
                7'b0000011: begin // Load
                    mem_to_reg = 1;
                    mem_read = 1;
                    mem_write = 0;
                    alu_op = 4'b0000;
                    alu_src = 1;
                    reg_write = 1;
                    branch = 0;
                end
                
                7'b0100011: begin // Store
                    mem_to_reg = 0;
                    mem_read = 0;
                    mem_write = 1;
                    alu_op = 4'b0000;
                    alu_src = 1;
                    reg_write = 0;
                    branch = 0;
                end
                
                7'b1100011: begin // Branch
                    mem_to_reg = 0;
                    mem_read = 0;
                    mem_write = 0;
                    alu_src = 0;
                    reg_write = 0;
                    branch = 1;
                    case (funct3)
                        3'b000: alu_op = 4'b0001; // BEQ
                        3'b001: alu_op = 4'b0001; // BNE
                        3'b100: alu_op = 4'b0011; // BLT
                        3'b101: alu_op = 4'b0011; // BGE
                        3'b110: alu_op = 4'b0100; // BLTU
                        3'b111: alu_op = 4'b0100; // BGEU
                        default: alu_op = 4'b0000;
                    endcase
                end
                
                7'b0110111: begin // LUI
                    mem_to_reg = 0;
                    mem_read = 0;
                    mem_write = 0;
                    alu_op = 4'b1010;
                    alu_src = 1;
                    reg_write = 1;
                    branch = 0;
                end
                
                7'b0010111: begin // AUIPC
                    mem_to_reg = 0;
                    mem_read = 0;
                    mem_write = 0;
                    alu_op = 4'b1011;
                    alu_src = 1;
                    reg_write = 1;
                    branch = 0;
                end
                
                7'b1101111: begin // JAL
                    mem_to_reg = 0;
                    mem_read = 0;
                    mem_write = 0;
                    alu_op = 4'b1100;
                    alu_src = 1;
                    reg_write = 1;
                    branch = 1;
                end
                
                default: begin
                    mem_to_reg = 0;
                    mem_read = 0;
                    mem_write = 0;
                    alu_op = 4'b0;
                    alu_src = 0;
                    reg_write = 0;
                    branch = 0;
                end
            endcase
        end
        
        rs1_data = (rs1 == 5'b0) ? 32'h0 : registers[rs1];
        rs2_data = (rs2 == 5'b0) ? 32'h0 : registers[rs2];
    end
    
    always @(posedge clk) begin
        if (wb_reg_write && (wb_rd != 5'b0))
            registers[wb_rd] <= wb_data;
    end

endmodule