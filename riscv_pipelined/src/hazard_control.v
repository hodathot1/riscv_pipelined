module hazard_control (
    input wire [4:0] id_rs1,
    input wire [4:0] id_rs2,
    input wire ex_mem_read,
    input wire [4:0] ex_rd,
    input wire [4:0] mem_rd,
    input wire mem_reg_write,
    input wire [4:0] wb_rd,
    input wire wb_reg_write,
    output reg stall,
    output reg [1:0] forward_a,
    output reg [1:0] forward_b
);

    function detect_load_use_hazard;
        input [4:0] rs1;
        input [4:0] rs2;
        input [4:0] ex_dest;
        input is_load;
        begin
            detect_load_use_hazard = is_load && 
                                   (ex_dest != 0) &&
                                   ((ex_dest == rs1) || (ex_dest == rs2));
        end
    endfunction

    function [1:0] determine_forwarding;
        input [4:0] rs;
        input [4:0] mem_dest;
        input mem_write_enable;
        input [4:0] wb_dest;
        input wb_write_enable;
        begin
            if ((mem_write_enable) && (mem_dest != 0) && (mem_dest == rs))
                determine_forwarding = 2'b10; 
            else if ((wb_write_enable) && (wb_dest != 0) && (wb_dest == rs))
                determine_forwarding = 2'b01; 
            else
                determine_forwarding = 2'b00;  
        end
    endfunction

    always @(*) begin
        stall = detect_load_use_hazard(id_rs1, id_rs2, ex_rd, ex_mem_read);
    end
    
    always @(*) begin
        forward_a = determine_forwarding(id_rs1, mem_rd, mem_reg_write, wb_rd, wb_reg_write);
        forward_b = determine_forwarding(id_rs2, mem_rd, mem_reg_write, wb_rd, wb_reg_write);
    end

endmodule