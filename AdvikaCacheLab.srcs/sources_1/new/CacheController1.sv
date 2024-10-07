`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/06/2024 12:13:06 PM
// Design Name: 
// Module Name: CacheController1
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


module CacheController(
    input  CLK,
    input RST,
//    input addr_in,
    input reg memRead,
    input reg memWrite,
    input logic hit,
    input logic memValid,
    input reg up,
    input logic dirty,
    input reg CLA_read,
    input reg CLA_write,
    input logic full,
    input reg write,
    input reg read,
    output reg L1_write, //because turned on in testbench
    output reg L1_sel,
    output reg L1_read, //testbench
    output logic data_sel,
    output logic addr_sel,
    output logic memValidWorld

   
   
    );
   
//     logic [7:0] dirty0;
//     logic [7:0] dirty1;
//     logic [23:0] tag0 [0:7];  // 2D array
//     logic [23:0] tag1 [0:7];
//     logic [23:0] data0 [0:7];  // 2D array
//     logic [23:0] data1 [0:7];
//     logic [7:0] offset0;
//     logic [2:0] word_off0;
//     logic [1:0] byte_off0;
   
//    logic [23:0] tag;
//    logic [2:0] index;
//    logic [2:0] word_off0;
//    logic [1:0] byte_off0;
   
   
//    logic MEM_L1_addr; // recontructed addr to update cache from MM
   
       
//     always_comb
//     begin
//        tag = addr_in[31:8];
//        index = addr_in[7:5];
//        word_off0 = addr_in[4:2];
//        byte_off0 = addr_in[1:0];
//     end
   
   
    typedef enum logic [2:0] {
    IDLE,
    CHECK,
    L1_CLA,
    CLA_L1,
    CLA_MEM,
    MEM_CLA
    } state_type;
    state_type NS, PS;
   
    always @ (posedge CLK)
    begin
        if (RST == 1)
            PS <= CHECK;
           
        else
            PS <= NS;            
    end
   
   
always_comb
begin
     L1_write = 0;     data_sel = 0;
     L1_read = 0;     addr_sel = 0;  
     memValidWorld = 0; memRead = 0; memWrite = 0; up = 0;
     CLA_read = 0;
     CLA_write = 0;
     L1_sel = 0;


     case (PS)  
//        IDLE:
//        begin
//            if (memRead || memWrite)
//            begin
//                NS = CHECK;
               
//            end
//            else
//            begin
//                NS = IDLE;
//            end
//        end
       
        CHECK:
        begin
        L1_sel = 0;
//        if (memRead || memWrite) begin
            if (hit == 1'b1) begin
                L1_write = write; // can I have both of these on at once? I need it to be able to write on a hit too. 
                L1_read = read;  
                memValidWorld = read || write;
                NS = PS;  
            end
           
            else if ( ( hit == 1'b0) && (dirty == 1'b1) )  //need to write from mem
            begin
                NS = L1_CLA;
            end
               
            else if ( ( hit == 1'b0) && (dirty == 1'b0) ) // need to read from mem
            begin
                NS = MEM_CLA;
            end  
           
        end
      //  end
       
        L1_CLA:
        begin
            L1_read = 1;
            CLA_write = 1;  
            data_sel = 0; //input from L1 dataout
            up = 1;  //start counter counting    
             
            if (full)
            NS = CLA_MEM;  
               
            else
            begin
            NS = PS;  
            end  
        end
       
        CLA_MEM:
        begin
            if (memValid) begin //only write to the memory if its ready to be written to
                memWrite = 1;
                CLA_read = 1; //want to read from here and write to the memory
                up = 1;
               
                if (full) begin
                NS = MEM_CLA; //next state goes here so that you can read from memory back to the cache
                end
            end
            else begin
            NS = PS;
            end
        end
       
        MEM_CLA:
        begin
           data_sel = 1;   // data from MM
           addr_sel = 1;
           memRead = 1;
           memWrite = 0;
           if (memValid) begin
                CLA_write = 1; //if
               
                up = 1;
            end    
            if (full) begin
                NS = CLA_L1;
                end
               
            else
                NS = PS;
            end
       
        CLA_L1:
        begin
            L1_sel = 1;
            addr_sel = 1;
            up = 1;
            L1_write = 1;
         if (full)
            begin
               
                NS = CHECK;
            end
        else begin
            NS = PS;
        end
        end
       
        default: NS = IDLE;

     endcase
   
end
   
   
   
endmodule