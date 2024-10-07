`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/06/2024 12:13:40 PM
// Design Name: 
// Module Name: CacheLineAdapter1
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

module CacheLineAdapter (
    input  clk,
    input logic [31:0] addr_in, //address coming from cache to read from memory
    input logic [31:0] data_in, //data coming from cache to update memory
    input logic up,  //counts up everytime we have to read
    input logic clr, //
    input L1_write,
    output logic [31:0] MM_data_out, //data grabbed from memory
    output logic [31:0] L1_data_out,
    output logic [31:0] MM_addr_out,
    output logic [31:0] L1_addr_out,
    output rco,
    input CLA_write,
    input CLA_read
    );
   
    logic [2:0] count;
   
    always @(posedge clk)
    begin
        if (clr == 1)       // asynch reset
           count <= 0;
        else if (up == 1)   // count up (increment)
           count <= count + 1;  //count is the index of the array
    end
   
    //- handles the RCO
    assign rco = &count;  //checks if full is 7
   
    logic [31:0] CLA_ARRAY [0:7];    //array that stores words loaded to CLA
   
   always_ff @(posedge clk)
    begin
       if (CLA_write)
       begin
           CLA_ARRAY[count] <= data_in; //take data from memory      
       end
    end
   
    always_comb
    begin
            MM_addr_out <= { addr_in[31:5] , count, 2'b00};
            MM_data_out = CLA_ARRAY[count];  // output to MM
 
            L1_data_out = CLA_ARRAY[count]; //output that goes to L1
            L1_addr_out <= { addr_in[31:5] , count, 2'b00};
         
    end
   
   
   
   
//    always_ff @(posedge clk) begin
//    //first case handles going from CLA to memory (for writing back)
//        if (CLA_write) begin
//        //need to write data to memory so that they will match
//            mem_wr <= 1'b1; //turn on memory writing
//            mem_addy <= addr_in; //address to write to will be the reconstructed one from the cache
//            mem_data[index] <= data_in; //the new data to write here will also come from cache
//        end
//        else begin
//        mem_wr <= 1'b0; //no need to write to memory if data is clean (the data matches)
//        end
       
//        //now handles going from memory to CLA for reading
//        if(read_memory) begin
//        //if being told to just read from memory
//            mem_re <= 1'b1; //read enable for the memory is on
//            mem_addy <= addr_in; //address to read from is the output from cache
//        end
//        //else if we dont need to read from memory
//        else begin
//            mem_re <= 1'b0;
//        end
//        end

endmodule
