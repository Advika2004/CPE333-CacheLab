`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/06/2024 12:12:42 PM
// Design Name: 
// Module Name: SinglePortDelayMemory1
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module SinglePortDelayMemory #(
    parameter DELAY_CYCLES = 10,
    parameter BURST_LEN = 8
    ) (
    input CLK,
    input RE,
    input WE,
    input [31:0] DATA_IN,
    input [29:0] ADDR,
    output logic MEM_VALID,
    output logic [31:0] DATA_OUT
    );
   
    logic [31:0] memory [0:16383];
    initial begin
        $readmemh("otter_memory3.mem", memory, 0, 16383);
    end

    initial begin
        forever begin
            MEM_VALID = 0;
            @(posedge CLK iff RE | WE);
            for (int i = 0; i < DELAY_CYCLES; i++) begin
                @(posedge CLK);
            end
            for (int i = 0; i < BURST_LEN; i++) begin
                if (RE ^ WE)
                    MEM_VALID = 1;
                else
                    MEM_VALID = 0;
                @(posedge CLK);
            end
        end
    end

    always_comb begin
        DATA_OUT = MEM_VALID ? memory[ADDR] : 32'hdeadbeef;
    end

    always_ff @(negedge CLK) begin
        if (WE && MEM_VALID) begin
            memory[ADDR] <= DATA_IN;
        end
    end
 
endmodule
