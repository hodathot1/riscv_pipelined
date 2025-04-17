module id_stage_tb;
    reg clk;
    reg rst_n;
    
    reg [31:0] instruction;
    reg [31:0] pc;
    reg wb_reg_write;
    reg [4:0] wb_rd;
    reg [31:0] wb_data;
    reg stall;
    
    wire mem_to_reg;
    wire mem_read;
    wire mem_write;
    wire [3:0] alu_op;
    wire alu_src;
    wire reg_write;
    wire branch;
    wire [31:0] rs1_data;
    wire [31:0] rs2_data;
    wire [31:0] imm;
    wire [4:0] rd;
    wire [4:0] rs1;
    wire [4:0] rs2;

    id_stage dut (
        .clk(clk),
        .rst_n(rst_n),
        .instruction(instruction),
        .pc(pc),
        .wb_reg_write(wb_reg_write),
        .wb_rd(wb_rd),
        .wb_data(wb_data),
        .stall(stall),
        .mem_to_reg(mem_to_reg),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .alu_op(alu_op),
        .alu_src(alu_src),
        .reg_write(reg_write),
        .branch(branch),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .imm(imm),
        .rd(rd),
        .rs1(rs1),
        .rs2(rs2)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, id_stage_tb);
    end

    initial begin
        $display("Starting ID stage test...");
        
        rst_n = 0;
        instruction = 32'h0;
        pc = 32'h0;
        wb_reg_write = 0;
        wb_rd = 5'h0;
        wb_data = 32'h0;
        stall = 0;
        
        #20 rst_n = 1;

        #10 instruction = 32'h002081b3;  // add x3, x1, x2
        pc = 32'h4;
        #10 $display("R-type (ADD) decode: alu_op=%b, rs1=%d, rs2=%d, rd=%d", 
                    alu_op, rs1, rs2, rd);

        #10 instruction = 32'h00500093;  // addi x1, x0, 5
        #10 $display("I-type (ADDI) decode: alu_op=%b, rs1=%d, imm=%h, rd=%d",
                    alu_op, rs1, imm, rd);

        #10 wb_reg_write = 1;
        wb_rd = 5'h1;  // x1
        wb_data = 32'h5;  // = 5
        #10 $display("After write to x1: rs1_data=%h", rs1_data);

        #10 stall = 1;
        #10 $display("During stall: reg_write=%b, mem_read=%b", reg_write, mem_read);
        #10 stall = 0;

        #10 instruction = 32'h00208463;  // beq x1, x2, offset
        #10 $display("Branch decode: branch=%b, alu_op=%b", branch, alu_op);

        #100 $finish;
    end

    always @(posedge clk) begin
        if (rst_n) begin
            $display("Time=%0t instruction=%h", $time, instruction);
            $display("Control: reg_write=%b mem_read=%b mem_write=%b branch=%b alu_op=%b",
                    reg_write, mem_read, mem_write, branch, alu_op);
            $display("Data: rs1_data=%h rs2_data=%h imm=%h",
                    rs1_data, rs2_data, imm);
        end
    end

    task check_register_value;
        input [4:0] reg_num;
        input [31:0] expected_value;
        begin
            if (dut.registers[reg_num] !== expected_value) begin
                $display("Error: Register x%0d = %h, Expected = %h",
                        reg_num, dut.registers[reg_num], expected_value);
            end else begin
                $display("Pass: Register x%0d = %h",
                        reg_num, dut.registers[reg_num]);
            end
        end
    endtask

endmodule