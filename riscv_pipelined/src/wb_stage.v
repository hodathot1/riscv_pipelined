module wb_stage (
    input wire [31:0] mem_data,
    input wire [31:0] alu_result,
    input wire mem_to_reg,
    output wire [31:0] wb_data
);

    assign wb_data = mem_to_reg ? mem_data : alu_result;

endmodule