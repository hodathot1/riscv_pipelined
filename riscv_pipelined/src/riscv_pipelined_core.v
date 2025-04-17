module riscv_pipelined_core (
    input wire clk,
    input wire rst_n,
    
    output wire [31:0] if_id_pc,
    output wire [31:0] if_id_instr,
    output wire [31:0] id_ex_pc,
    output wire [31:0] id_ex_rs1_data,
    output wire [31:0] id_ex_rs2_data,
    output wire [31:0] id_ex_imm,
    output wire [4:0]  id_ex_rd,
    output wire        id_ex_reg_write,
    output wire [3:0]  id_ex_alu_op,
    output wire        id_ex_alu_src,
    output wire        id_ex_mem_read,
    output wire        id_ex_mem_write,
    output wire        id_ex_branch,
    output wire        id_ex_mem_to_reg,
    output wire [31:0] ex_mem_alu_result,
    output wire [31:0] ex_mem_rs2_data,
    output wire [4:0]  ex_mem_rd,
    output wire        ex_mem_reg_write,
    output wire        ex_mem_mem_read,
    output wire        ex_mem_mem_write,
    output wire        ex_mem_branch,
    output wire        ex_mem_mem_to_reg,
    output wire [31:0] mem_wb_mem_data,
    output wire [31:0] mem_wb_alu_result,
    output wire [4:0]  mem_wb_rd,
    output wire        mem_wb_reg_write,
    output wire        mem_wb_mem_to_reg
);

    wire stall;
    wire branch_taken;
    wire [31:0] branch_target;
    wire [1:0] forward_a, forward_b;
    
    wire [31:0] if_pc;
    wire [31:0] if_instruction;
    
    wire id_mem_to_reg, id_mem_read, id_mem_write;
    wire [3:0] id_alu_op;
    wire id_alu_src, id_reg_write, id_branch;
    wire [31:0] id_rs1_data, id_rs2_data, id_imm;
    wire [4:0] id_rd, id_rs1, id_rs2;
    
    wire ex_zero_flag;
    wire [31:0] ex_alu_result;
    
    wire [31:0] mem_data;
    
    wire [31:0] wb_data;
    
    if_stage if_stage_inst (
        .clk(clk),
        .rst_n(rst_n),
        .stall(stall),
        .branch_taken(branch_taken),
        .branch_target(branch_target),
        .pc(if_pc),
        .instruction(if_instruction)
    );
    
    reg [31:0] if_id_pc_reg;
    reg [31:0] if_id_instr_reg;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            if_id_pc_reg <= 32'h0;
            if_id_instr_reg <= 32'h0;
        end else if (!stall) begin
            if_id_pc_reg <= if_pc;
            if_id_instr_reg <= if_instruction;
        end
    end
    
    assign if_id_pc = if_id_pc_reg;
    assign if_id_instr = if_id_instr_reg;
    
    id_stage id_stage_inst (
        .clk(clk),
        .rst_n(rst_n),
        .instruction(if_id_instr),
        .pc(if_id_pc),
        .wb_reg_write(mem_wb_reg_write),
        .wb_rd(mem_wb_rd),
        .wb_data(wb_data),
        .stall(stall),
        .mem_to_reg(id_mem_to_reg),
        .mem_read(id_mem_read),
        .mem_write(id_mem_write),
        .alu_op(id_alu_op),
        .alu_src(id_alu_src),
        .reg_write(id_reg_write),
        .branch(id_branch),
        .rs1_data(id_rs1_data),
        .rs2_data(id_rs2_data),
        .imm(id_imm),
        .rd(id_rd),
        .rs1(id_rs1),
        .rs2(id_rs2)
    );
    
    reg [31:0] id_ex_pc_reg;
    reg [31:0] id_ex_rs1_data_reg;
    reg [31:0] id_ex_rs2_data_reg;
    reg [31:0] id_ex_imm_reg;
    reg [4:0]  id_ex_rd_reg;
    reg        id_ex_reg_write_reg;
    reg [3:0]  id_ex_alu_op_reg;
    reg        id_ex_alu_src_reg;
    reg        id_ex_mem_read_reg;
    reg        id_ex_mem_write_reg;
    reg        id_ex_branch_reg;
    reg        id_ex_mem_to_reg_reg;
    reg [2:0]  id_ex_funct3_reg;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            id_ex_pc_reg <= 32'h0;
            id_ex_rs1_data_reg <= 32'h0;
            id_ex_rs2_data_reg <= 32'h0;
            id_ex_imm_reg <= 32'h0;
            id_ex_rd_reg <= 5'h0;
            id_ex_reg_write_reg <= 1'b0;
            id_ex_alu_op_reg <= 4'h0;
            id_ex_alu_src_reg <= 1'b0;
            id_ex_mem_read_reg <= 1'b0;
            id_ex_mem_write_reg <= 1'b0;
            id_ex_branch_reg <= 1'b0;
            id_ex_mem_to_reg_reg <= 1'b0;
            id_ex_funct3_reg <= 3'b0;    
        end else begin
            id_ex_pc_reg <= if_id_pc;
            id_ex_rs1_data_reg <= id_rs1_data;
            id_ex_rs2_data_reg <= id_rs2_data;
            id_ex_imm_reg <= id_imm;
            id_ex_rd_reg <= id_rd;
            id_ex_reg_write_reg <= id_reg_write;
            id_ex_alu_op_reg <= id_alu_op;
            id_ex_alu_src_reg <= id_alu_src;
            id_ex_mem_read_reg <= id_mem_read;
            id_ex_mem_write_reg <= id_mem_write;
            id_ex_branch_reg <= id_branch;
            id_ex_mem_to_reg_reg <= id_mem_to_reg;
            id_ex_funct3_reg <= if_id_instr[14:12];    
        end
    end
    
    assign id_ex_pc = id_ex_pc_reg;
    assign id_ex_rs1_data = id_ex_rs1_data_reg;
    assign id_ex_rs2_data = id_ex_rs2_data_reg;
    assign id_ex_imm = id_ex_imm_reg;
    assign id_ex_rd = id_ex_rd_reg;
    assign id_ex_reg_write = id_ex_reg_write_reg;
    assign id_ex_alu_op = id_ex_alu_op_reg;
    assign id_ex_alu_src = id_ex_alu_src_reg;
    assign id_ex_mem_read = id_ex_mem_read_reg;
    assign id_ex_mem_write = id_ex_mem_write_reg;
    assign id_ex_branch = id_ex_branch_reg;
    assign id_ex_mem_to_reg = id_ex_mem_to_reg_reg;
    
    ex_stage ex_stage_inst (
        .pc(id_ex_pc),
        .rs1_data(id_ex_rs1_data),
        .rs2_data(id_ex_rs2_data),
        .imm(id_ex_imm),
        .alu_op(id_ex_alu_op),
        .alu_src(id_ex_alu_src),
        .branch(id_ex_branch),
        .forward_a(forward_a),
        .forward_b(forward_b),
        .ex_mem_alu_result(ex_mem_alu_result),
        .mem_wb_result(wb_data),
        .funct3(id_ex_funct3_reg),  
        .alu_result(ex_alu_result),
        .zero_flag(ex_zero_flag),
        .branch_target(branch_target),
        .branch_taken(branch_taken)
    );
    
    reg [31:0] ex_mem_alu_result_reg;
    reg [31:0] ex_mem_rs2_data_reg;
    reg [4:0]  ex_mem_rd_reg;
    reg        ex_mem_reg_write_reg;
    reg        ex_mem_mem_read_reg;
    reg        ex_mem_mem_write_reg;
    reg        ex_mem_branch_reg;
    reg        ex_mem_mem_to_reg_reg;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ex_mem_alu_result_reg <= 32'h0;
            ex_mem_rs2_data_reg <= 32'h0;
            ex_mem_rd_reg <= 5'h0; 
            ex_mem_reg_write_reg <= 1'b0;
            ex_mem_mem_read_reg <= 1'b0;
            ex_mem_mem_write_reg <= 1'b0;
            ex_mem_branch_reg <= 1'b0;
            ex_mem_mem_to_reg_reg <= 1'b0;
        end else begin
            ex_mem_alu_result_reg <= ex_alu_result;
            ex_mem_rs2_data_reg <= id_ex_rs2_data;
            ex_mem_rd_reg <= id_ex_rd;
            ex_mem_reg_write_reg <= id_ex_reg_write;
            ex_mem_mem_read_reg <= id_ex_mem_read;
            ex_mem_mem_write_reg <= id_ex_mem_write;
            ex_mem_branch_reg <= id_ex_branch;
            ex_mem_mem_to_reg_reg <= id_ex_mem_to_reg;
        end
    end
    
    assign ex_mem_alu_result = ex_mem_alu_result_reg;
    assign ex_mem_rs2_data = ex_mem_rs2_data_reg;
    assign ex_mem_rd = ex_mem_rd_reg;
    assign ex_mem_reg_write = ex_mem_reg_write_reg;
    assign ex_mem_mem_read = ex_mem_mem_read_reg;
    assign ex_mem_mem_write = ex_mem_mem_write_reg;
    assign ex_mem_branch = ex_mem_branch_reg;
    assign ex_mem_mem_to_reg = ex_mem_mem_to_reg_reg;
    
    mem_stage mem_stage_inst (
        .clk(clk),
        .rst_n(rst_n),
        .alu_result(ex_mem_alu_result),
        .rs2_data(ex_mem_rs2_data),
        .mem_read(ex_mem_mem_read),
        .mem_write(ex_mem_mem_write),
        .mem_data(mem_data)
    );
    
    reg [31:0] mem_wb_mem_data_reg;
    reg [31:0] mem_wb_alu_result_reg;
    reg [4:0]  mem_wb_rd_reg;
    reg        mem_wb_reg_write_reg;
    reg        mem_wb_mem_to_reg_reg;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mem_wb_mem_data_reg <= 32'h0;
            mem_wb_alu_result_reg <= 32'h0;
            mem_wb_rd_reg <= 5'h0;
            mem_wb_reg_write_reg <= 1'b0;
            mem_wb_mem_to_reg_reg <= 1'b0;
        end else begin
            mem_wb_mem_data_reg <= mem_data;
            mem_wb_alu_result_reg <= ex_mem_alu_result;
            mem_wb_rd_reg <= ex_mem_rd;
            mem_wb_reg_write_reg <= ex_mem_reg_write;
            mem_wb_mem_to_reg_reg <= ex_mem_mem_to_reg;
        end
    end
    
    assign mem_wb_mem_data = mem_wb_mem_data_reg;
    assign mem_wb_alu_result = mem_wb_alu_result_reg;
    assign mem_wb_rd = mem_wb_rd_reg;
    assign mem_wb_reg_write = mem_wb_reg_write_reg;
    assign mem_wb_mem_to_reg = mem_wb_mem_to_reg_reg;
    
    wb_stage wb_stage_inst (
        .mem_data(mem_wb_mem_data),
        .alu_result(mem_wb_alu_result),
        .mem_to_reg(mem_wb_mem_to_reg),
        .wb_data(wb_data)
    );
    
    hazard_control hazard_control_inst (
        .id_rs1(id_rs1),
        .id_rs2(id_rs2),
        .ex_mem_read(id_ex_mem_read),
        .ex_rd(id_ex_rd),
        .mem_rd(ex_mem_rd),
        .mem_reg_write(ex_mem_reg_write),
        .wb_rd(mem_wb_rd),
        .wb_reg_write(mem_wb_reg_write),
        .stall(stall),
        .forward_a(forward_a),
        .forward_b(forward_b)
    );

endmodule