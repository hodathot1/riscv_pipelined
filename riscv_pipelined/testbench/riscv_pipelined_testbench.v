module riscv_pipelined_testbench;
    reg clk;
    reg rst_n;
    
    wire [31:0] if_id_pc;
    wire [31:0] if_id_instr;
    wire [31:0] id_ex_pc;
    wire [31:0] id_ex_rs1_data;
    wire [31:0] id_ex_rs2_data;
    wire [31:0] id_ex_imm;
    wire [4:0]  id_ex_rd;
    wire        id_ex_reg_write;
    wire [3:0]  id_ex_alu_op;
    wire        id_ex_alu_src;
    wire        id_ex_mem_read;
    wire        id_ex_mem_write;
    wire        id_ex_branch;
    wire        id_ex_mem_to_reg;
    wire [31:0] ex_mem_alu_result;
    wire [31:0] ex_mem_rs2_data;
    wire [4:0]  ex_mem_rd;
    wire        ex_mem_reg_write;
    wire        ex_mem_mem_read;
    wire        ex_mem_mem_write;
    wire        ex_mem_branch;
    wire        ex_mem_mem_to_reg;
    wire [31:0] mem_wb_mem_data;
    wire [31:0] mem_wb_alu_result;
    wire [4:0]  mem_wb_rd;
    wire        mem_wb_reg_write;
    wire        mem_wb_mem_to_reg;
    
    riscv_pipelined_core dut (
        .clk(clk),
        .rst_n(rst_n),
        .if_id_pc(if_id_pc),
        .if_id_instr(if_id_instr),
        .id_ex_pc(id_ex_pc),
        .id_ex_rs1_data(id_ex_rs1_data),
        .id_ex_rs2_data(id_ex_rs2_data),
        .id_ex_imm(id_ex_imm),
        .id_ex_rd(id_ex_rd),
        .id_ex_reg_write(id_ex_reg_write),
        .id_ex_alu_op(id_ex_alu_op),
        .id_ex_alu_src(id_ex_alu_src),
        .id_ex_mem_read(id_ex_mem_read),
        .id_ex_mem_write(id_ex_mem_write),
        .id_ex_branch(id_ex_branch),
        .id_ex_mem_to_reg(id_ex_mem_to_reg),
        .ex_mem_alu_result(ex_mem_alu_result),
        .ex_mem_rs2_data(ex_mem_rs2_data),
        .ex_mem_rd(ex_mem_rd),
        .ex_mem_reg_write(ex_mem_reg_write),
        .ex_mem_mem_read(ex_mem_mem_read),
        .ex_mem_mem_write(ex_mem_mem_write),
        .ex_mem_branch(ex_mem_branch),
        .ex_mem_mem_to_reg(ex_mem_mem_to_reg),
        .mem_wb_mem_data(mem_wb_mem_data),
        .mem_wb_alu_result(mem_wb_alu_result),
        .mem_wb_rd(mem_wb_rd),
        .mem_wb_reg_write(mem_wb_reg_write),
        .mem_wb_mem_to_reg(mem_wb_mem_to_reg)
    );
    
    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end
    
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, riscv_pipelined_testbench);
    end
    
    initial begin
        $display("Starting RISC-V pipelined processor simulation...");
        
        rst_n = 0;
        #20;
        rst_n = 1;
        
        #200;
        
        $display("\n\n=== Simulation completed ===");
        $display("Register x1 = %d", dut.id_stage_inst.registers[1]);
        $display("Register x2 = %d", dut.id_stage_inst.registers[2]);
        $display("Register x3 = %d", dut.id_stage_inst.registers[3]);
        
        $finish;
    end
    
    integer cycle_count = 0;
    always @(posedge clk) begin
        if (rst_n) begin
            cycle_count = cycle_count + 1;
            
            $display("\n======== Cycle %0d (Time: %0t) ========", cycle_count, $time);
            $display("IF/ID Stage - PC: %h, Instruction: %h", if_id_pc, if_id_instr);
            
            $display("EX/MEM Stage - ALU Result: %h", ex_mem_alu_result);
            
            $display("Registers - x1: %d, x2: %d, x3: %d", 
                    dut.id_stage_inst.registers[1], 
                    dut.id_stage_inst.registers[2], 
                    dut.id_stage_inst.registers[3]);
        end
    end
    
endmodule