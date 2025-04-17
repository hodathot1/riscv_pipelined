module if_stage_tb;
    reg clk;
    reg rst_n;
    reg stall;
    reg branch_taken;
    reg [31:0] branch_target;
    wire [31:0] pc;
    wire [31:0] instruction;

    if_stage dut (
        .clk(clk),
        .rst_n(rst_n),
        .stall(stall),
        .branch_taken(branch_taken),
        .branch_target(branch_target),
        .pc(pc),
        .instruction(instruction)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, if_stage_tb);
    end

    initial begin
        $display("Starting IF stage test...");
        rst_n = 0;
        stall = 0;
        branch_taken = 0;
        branch_target = 32'h0;

        #20 rst_n = 1;

        #10 $display("PC = %h, Instruction = %h", pc, instruction);

        #10 stall = 1;
        #10 $display("After stall: PC = %h", pc);
        #10 stall = 0;

        #10 branch_taken = 1;
        branch_target = 32'h20;
        #10 $display("After branch: PC = %h", pc);
        #10 branch_taken = 0;

        #100 $finish;
    end

    always @(posedge clk) begin
        if (rst_n) begin
            $display("Time=%0t pc=%h instruction=%h", $time, pc, instruction);
        end
    end
endmodule