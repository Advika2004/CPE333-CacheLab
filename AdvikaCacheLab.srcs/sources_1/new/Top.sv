`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/02/2024 09:59:03 PM
// Design Name: 
// Module Name: Top
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


module Top(
    input CLK,
    input [31:0] ADDR,
    input [31:0] DATA_IN,
    input read,
    input write,
    input RST
    );
    
    
    logic LRU, hit, dirty;
    logic data_sel, addr_sel; // MUX selects
    logic [31:0] L1_data_out, L1_addr_out, L1_addr_in, L1_data_in;
    logic [31:0] CLA_data_in, CLA_addr_in, CLA_addr_out, CLA_data_out; //CLA i/o
    
    logic [31:0] CLA_L1_addr_out, CLA_L1_data_out, CLA_MM_addr_out, CLA_MM_data_out;
    
    logic [31:0] MM_data_in, MM_addr_in, MM_data_out, memValid; //CLA i/o 
       
    logic full;      
    logic up;   
    logic CLA_write, CLA_read, memRead, memWrite, L1_read, L1_write; //control signals

    
    myCache L1_Cache (
    
        .clk(CLK),
        .addr_in(L1_sel ? CLA_L1_addr_out : ADDR),
        .data_in(L1_data_in),
        .cache_we(L1_write),
        .cache_re(L1_read),
        .validate(memValid),
        .sign(),
        .size(),
        .addr_out(L1_addr_out),
        .hit(hit),
        .dirty(dirty),
        .data_out(L1_data_out),
        .read_memory(memRead)
        );
        
        
    MUX_2to1 CLA_DATA_MUX (
        .SEL(data_sel),
        .D0(L1_data_out),
        .D1(MM_data_out),
        .D_OUT(CLA_data_in)
        );
        
    MUX_2to1 CLA_ADDR_MUX (
        .SEL(addr_sel),
        .D0(L1_addr_out),
        .D1(ADDR),
        .D_OUT(CLA_addr_in)
        );
        
    logic L1_sel;
        
    MUX_2to1 L1_DATA_MUX (
        .SEL(L1_sel),
        .D0(DATA_IN),
        .D1(CLA_L1_data_out),
        .D_OUT(L1_data_in)
        );
   
  
    CacheLineAdapter CLA (
    
        .clk(CLK),
        .addr_in(CLA_addr_in),
        .data_in(CLA_data_in),
        .up(up),
        .clr(RST),
        .MM_data_out(CLA_MM_data_out),
        .L1_data_out(CLA_L1_data_out), 
        .MM_addr_out(CLA_MM_addr_out),
        .L1_addr_out(CLA_L1_addr_out),
        .rco(full),
        .CLA_write(CLA_write),
        .CLA_read(CLA_read)
        );
        
        
    CacheController Controller (
    
        .CLK(CLK),
        .RST(RST),
        //.addr_in(ADDR),
        .memRead(memRead),
        .memWrite(memWrite),
        .hit(hit),
        .up(up),
        .dirty(dirty),
        .CLA_read(CLA_read), 
        .CLA_write(CLA_write),
        .full(full),
        .L1_write(L1_write),
        .L1_read(L1_read),
        .L1_sel(L1_sel),
        .data_sel(data_sel),
        .addr_sel(addr_sel),
        .memValid(memValid),
        .write(write),
        .read(read),
        .memValidWorld()
        );
        
     
     SinglePortDelayMemory Main_Memory (
        
        .CLK(CLK),
        .RE(memRead),
        .WE(memWrite),
        .DATA_IN(CLA_MM_data_out),
        .ADDR(CLA_MM_addr_out[31:2]),
        .MEM_VALID(memValid),
        .DATA_OUT(MM_data_out)
        );

    
endmodule


