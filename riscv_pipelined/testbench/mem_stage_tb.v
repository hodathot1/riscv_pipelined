module mem_stage_tb;
    reg clk;
    reg rst_n;
    reg [31:0] alu_result;
    reg [31:0] rs2_data;
    reg mem_read;
    reg mem_write;
    wire [31:0] mem_data;

    mem_stage dut (
        .clk(clk),
        .rst_n(rst_n),
        .alu_result(alu_result),
        .rs2_data(rs2_data),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .mem_data(mem_data)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, mem_stage_tb);
    end

    initial begin
        $display("Starting MEM stage test...");
        
        rst_n = 0;
        alu_result = 32'h0;
        rs2_data = 32'h0;
        mem_read = 0;
        mem_write = 0;
        
        #20 rst_n = 1;

        #10;
        alu_result = 32'h4;  
        rs2_data = 32'h12345678;  
        mem_write = 1;
        #10;
        $display("Write: address=%h data=%h", alu_result, rs2_data);
        mem_write = 0;

        #10;
        mem_read = 1;
        #1;
        $display("Read: address=%h data=%h", alu_result, mem_data);
        
        #10;
        alu_result = 32'h8;
        #1;
        $display("Read (empty location): address=%h data=%h", alu_result, mem_data);
        
        #10;
        mem_read = 0;
        mem_write = 1;
        alu_result = 32'h0;
        rs2_data = 32'hAAAAAAAA;
        #10;
        alu_result = 32'h4;
        rs2_data = 32'hBBBBBBBB;
        #10;
        alu_result = 32'h8;
        rs2_data = 32'hCCCCCCCC;
        #10;
        mem_write = 0;
        
        mem_read = 1;
        alu_result = 32'h0;
        #1;
        $display("Read back 0: data=%h", mem_data);
        #10;
        alu_result = 32'h4;
        #1;
        $display("Read back 4: data=%h", mem_data);
        #10;
        alu_result = 32'h8;
        #1;
        $display("Read back 8: data=%h", mem_data);

        #10;
        alu_result = 32'h1;  
        #1;
        $display("Unaligned read: address=%h data=%h", alu_result, mem_data);

        #100 $finish;
    end

    always @(posedge clk) begin
        if (rst_n) begin
            if (mem_write)
                $display("Time=%0t Write: addr=%h data=%h", 
                        $time, alu_result, rs2_data);
            if (mem_read)
                $display("Time=%0t Read: addr=%h data=%h", 
                        $time, alu_result, mem_data);
        end
    end

    task check_memory;
        input [31:0] address;
        input [31:0] expected;
        begin
            if (dut.data_mem[address[11:2]] !== expected) begin
                $display("Error: Memory[%h] = %h, Expected = %h",
                        address, dut.data_mem[address[11:2]], expected);
            end else begin
                $display("Pass: Memory[%h] = %h",
                        address, dut.data_mem[address[11:2]]);
            end
        end
    endtask

endmodule