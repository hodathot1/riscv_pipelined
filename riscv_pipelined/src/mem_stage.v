module mem_stage (
    input wire clk,
    input wire rst_n,
    input wire [31:0] alu_result,
    input wire [31:0] rs2_data,
    input wire mem_read,
    input wire mem_write,
    output wire [31:0] mem_data
);
    reg [31:0] data_mem [0:1023]; 
    
    function is_valid_address;
        input [31:0] address;
        begin
            is_valid_address = (address[1:0] == 2'b00) && 
                             (address[31:12] == 20'h0);  
        end
    endfunction
    
    function [31:0] read_memory;
        input [31:0] address;
        begin
            if (is_valid_address(address))
                read_memory = data_mem[address[11:2]];
            else
                read_memory = 32'h0;
        end
    endfunction
    
    function write_memory;
        input [31:0] address;
        input [31:0] write_data;
        begin
            if (is_valid_address(address))
                data_mem[address[11:2]] = write_data;
        end
    endfunction
    
    integer i;
    initial begin
        for (i = 0; i < 1024; i = i + 1) begin
            data_mem[i] = 32'h0;
        end
    end
    
    assign mem_data = mem_read ? read_memory(alu_result) : 32'h0;
    
    always @(posedge clk) begin
        if (mem_write) begin
            if (is_valid_address(alu_result))
                data_mem[alu_result[11:2]] <= rs2_data;
        end
    end

endmodule