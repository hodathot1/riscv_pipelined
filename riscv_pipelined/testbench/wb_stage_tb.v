module wb_stage_tb;
    reg [31:0] mem_data;
    reg [31:0] alu_result;
    reg mem_to_reg;
    wire [31:0] wb_data;

    wb_stage dut (
        .mem_data(mem_data),
        .alu_result(alu_result),
        .mem_to_reg(mem_to_reg),
        .wb_data(wb_data)
    );

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, wb_stage_tb);
    end

    initial begin
        $display("Starting WB stage test...");

        mem_data = 32'hAAAAAAAA;
        alu_result = 32'h12345678;
        mem_to_reg = 0;
        #1;
        $display("Test 1 - Select ALU: mem_data=%h, alu_result=%h, mem_to_reg=%b, wb_data=%h",
                 mem_data, alu_result, mem_to_reg, wb_data);
        
        mem_data = 32'h87654321;
        alu_result = 32'hBBBBBBBB;
        mem_to_reg = 1;
        #1;
        $display("Test 2 - Select MEM: mem_data=%h, alu_result=%h, mem_to_reg=%b, wb_data=%h",
                 mem_data, alu_result, mem_to_reg, wb_data);

        #10 $finish;
    end

endmodule