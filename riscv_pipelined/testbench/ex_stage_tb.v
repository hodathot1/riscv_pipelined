module ex_stage_tb;
    reg [31:0] pc;
    reg [31:0] rs1_data;
    reg [31:0] rs2_data;
    reg [31:0] imm;
    reg [3:0]  alu_op;
    reg        alu_src;
    reg        branch;
    reg [1:0]  forward_a;
    reg [1:0]  forward_b;
    reg [31:0] ex_mem_alu_result;
    reg [31:0] mem_wb_result;
    
    wire [31:0] alu_result;
    wire        zero_flag;
    wire [31:0] branch_target;
    wire        branch_taken;

    ex_stage dut (
        .pc(pc),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .imm(imm),
        .alu_op(alu_op),
        .alu_src(alu_src),
        .branch(branch),
        .forward_a(forward_a),
        .forward_b(forward_b),
        .ex_mem_alu_result(ex_mem_alu_result),
        .mem_wb_result(mem_wb_result),
        .alu_result(alu_result),
        .zero_flag(zero_flag),
        .branch_target(branch_target),
        .branch_taken(branch_taken)
    );

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, ex_stage_tb);
    end

    initial begin
        $display("Starting EX stage test...");
        
        pc = 32'h1000;
        rs1_data = 32'h5;
        rs2_data = 32'h3;
        imm = 32'h100;
        alu_op = 4'b0;
        alu_src = 0;
        branch = 0;
        forward_a = 2'b00;
        forward_b = 2'b00;
        ex_mem_alu_result = 32'h0;
        mem_wb_result = 32'h0;
        
        #10;
        alu_op = 4'b0000;  // ADD
        #1 $display("ADD: %h + %h = %h", rs1_data, rs2_data, alu_result);
        
        #10;
        alu_op = 4'b0001;  // SUB
        #1 $display("SUB: %h - %h = %h", rs1_data, rs2_data, alu_result);
        
        #10;
        rs1_data = 32'hFFFFFFFF;  
        rs2_data = 32'h1;         // 1
        alu_op = 4'b0011;  // SLT
        #1 $display("SLT: %h < %h = %h", rs1_data, rs2_data, alu_result);
        
        #10;
        rs1_data = 32'h5;
        forward_a = 2'b10;  
        ex_mem_alu_result = 32'hA;
        alu_op = 4'b0000;  // ADD
        #1 $display("Forwarding EX/MEM: %h + %h = %h", ex_mem_alu_result, rs2_data, alu_result);
        
        #10;
        forward_a = 2'b00;
        rs1_data = 32'h5;
        rs2_data = 32'h5;
        branch = 1;
        alu_op = 4'b0001;  // SUB for BEQ
        #1 $display("BEQ: rs1=%h rs2=%h zero=%b taken=%b target=%h", 
                   rs1_data, rs2_data, zero_flag, branch_taken, branch_target);
        
        #10;
        alu_src = 1;  
        imm = 32'h100;
        alu_op = 4'b0000;  // ADD
        #1 $display("ADD immediate: %h + %h = %h", rs1_data, imm, alu_result);
        
        #10;
        alu_op = 4'b1011;  // AUIPC
        #1 $display("AUIPC: pc=%h + imm=%h = %h", pc, imm, alu_result);

        #100 $finish;
    end

    task check_alu_result;
        input [31:0] expected;
        begin
            if (alu_result !== expected) begin
                $display("Error: ALU result = %h, Expected = %h", 
                        alu_result, expected);
            end else begin
                $display("Pass: ALU result = %h", alu_result);
            end
        end
    endtask

endmodule