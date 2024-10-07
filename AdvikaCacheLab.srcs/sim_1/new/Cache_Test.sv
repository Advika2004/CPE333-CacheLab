`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/03/2024 08:25:30 PM
// Design Name: 
// Module Name: Cache_Test
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


module Cache_Test;
    logic clk;
    logic addr_in;
    logic data_in;
    logic cache_we;
    logic cache_re;
    logic validate;
    logic LRU;
    logic addr_out;
    logic hit;
    logic dirty;
    logic data_out;
    logic read_memory;
 
 
    myCache CACHE (
        .clk(clk),
        .addr_in(addr_in),
        .data_in(data_in),
        .cache_we(cache_we),
        .cache_re(cache_re),
        .validate(validate),
        .LRU(LRU),
        .addr_out(addr_out),
        .hit(hit),
        .dirty(dirty),
        .data_out(data_out),
        .read_memory(read_memory)
        );
        
          // Clock generation
    always begin
        #5 clk = ~clk; // Toggle clock every 5 time units
    end

  
endmodule
