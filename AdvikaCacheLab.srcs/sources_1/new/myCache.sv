`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/21/2024 10:50:46 AM
// Design Name: 
// Module Name: myCache
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

module myCache(
    input logic clk,
    input [31:0] addr_in,  //address input
    input [31:0] data_in, //data input for writing
    input cache_we, //cache write enable
    input cache_re, //cache read enable
    input validate, //validated signal
    input [1:0] size,
    input sign,
//    output logic LRU, //least recently used bit
    output logic [31:0] addr_out, //output address
    output logic hit, dirty , //dirty bit and cache hit signal
    output logic [31:0] data_out,
    output logic read_memory
    );
   
    logic [7:0] dirty0; //dirty bit for set 0
    logic [7:0] dirty1; //dirty bits for set 1
    logic [23:0] tag0 [0:7];  // tag for set 0
    logic [23:0] tag1 [0:7]; //tagg for set 1
    logic [31:0] data0 [0:7][0:7];  // data for set 0
    logic [31:0] data1 [0:7][0:7]; //data for set 1
    logic [0:7] valid0; //valid bit for set 0
    logic [0:7] valid1; //valid bit for set 1
    logic hit0;
    logic hit1;
    logic [7:0] LRU;
//     logic [7:0] offset0; //don't need this?
    logic [2:0] index;
    logic [23:0] tag;
    logic [2:0] word_off;
    logic [1:0] byte_offset;
     
   //take in the address and extract the parts I need
    always_comb
    begin
        tag = addr_in[31:8];
        index = addr_in[7:5];
        word_off = addr_in[4:2];
        byte_offset = addr_in[1:0];
    end
     
//     always_comb begin
//        dirty0 = 1'b0;
//        dirty1 = 1'b0;
//     end
     
     
    //Logic just for determining if there is a hit or not and a read - will deal with write later
    // danny - only hit logic
    always_comb
    begin
        // if (cache_re || cache_we) //start logic when cache can be read from
        // begin
            if ((tag == tag0[index]) && (valid0[index] == 1'b1)) //check if tag matches and data is valid
            begin
                // = 1'b1;    //set 0 was used, so least recently used becoems set 1
                hit0 = 1'b1;     //in set0
                hit1 = 1'b0;
                //data_out = data0[index][word_off]; //if there is a hit in set 0, the output data is the data at that index in that set
            end
            else if ((tag == tag1[index]) & (valid1[index] == 1)) //check if tag matches and data is valid
            begin
                //LRU = 1'b0;  //set 1 was used so least recently used becomes set 0
                hit1 = 1'b1;     // in set1
                hit0 = 1'b0;
                //data_out = data1[index][word_off]; //if hit in set 1, data out is the data from that index in that set
            end    
            else
            begin
                hit0 = 1'b0;     //no hit in either set  - miss
                hit1 = 1'b0;     //no hit in either set  - miss
            end
       
            hit = hit0 || hit1; // output to outside world
        // end
    end
       
    // danny - read logic
    always_comb
        begin
            if (cache_re) begin
                if (hit0) begin
                    data_out = data0[index][word_off];
                end
                if (hit1) begin
                    data_out = data1[index][word_off];
                end
            end
        end
     
//        else
//        begin
//            hit = 1'b0; //check the case that cache_re doesn't turn on
//            hit0 = 1'b0;
//            hit1 = 1'b0;
//        end
    //end for the always comb block  
     
     
    //now logic for handling if its a hit and a write
   
    always_ff @(posedge clk) begin
        dirty = 0;
        if (cache_we) begin
            if (hit) begin
//                $display("from hit");                
                if (hit0 == 1'b1) begin //if its a write and a hit in set 0
                    //$display("BOOBS");
                    LRU[index] <= 1'b1;
                    data0[index][word_off] <= data_in; //re-write the data in set 0
                    //$display("");
                    dirty0[index] <= 1'b1; //set 0 is now dirty because it was changed
                end
                else if (hit1 == 1'b1) begin
                    //so now its a hit within set 1
                    LRU[index] <= 1'b0;
                    data1[index][word_off] <= data_in; //rewrite the data in set 1
                    dirty1[index] <= 1'b1; //set 1 data at that index is now dirty
                end
            end
       
            // filling up from main memory
            //now handling the logic for if there is a miss and its not a write its a read
            //if (!hit) begin
            else begin
//                $display("from !hit");
                if (LRU[index] == 1'b1) begin //go into the least recernly used set
                    if (dirty1[index] == 1'b1) begin //check dirty bit at that index
                        //must tell CLA to do the writing back now
                        //output the reconstructed address
                        //$display("BOOBS");
                        addr_out <= {tag1[index], index, 3'b000, 2'b00}; //reconstructed address
                        dirty <= 1'b1; //set the dirty bit so that the CLA knows to write back
                    end
                    else begin //the data at that cache line is not dirty
                        dirty <= 1'b0; // no need to write back from memory
                    end
               
                    //now go to memory at address and write into cache + update stuff
                    //the writing back to the memory will happen within the CLA automatically?
                    //read_memory <= 1'b1; //turn on for the CLA to know to go to memory
                    data1[index][word_off] <= data_in; //take data and write it into the cache at that index
                    tag1[index] <= tag; //update the tag to new tag
                    //valid1[index] <= 1'b1;
                    if (word_off == 7) begin
                       valid1[index] <= 1'b1; //set the valid bit since just updated data
                       LRU[index] <= 1'b0; //just did all of this in set 1 so now set 0 is least used
                    end
                    else begin 
                        valid1[index] <= 1'b0;
                    end
                    dirty1[index] <= 1'b0; //data is no longer dirty since it was updated in memory
                    
                end
           
                else if (LRU[index] == 1'b0) begin //go into the least recernly used set
                    if (dirty0[index] == 1'b1) begin //check dirty bit at that index
                        //must tell CLA to do the writing back now
                        //output the reconstructed address
                        addr_out <= {tag0[index], index, 3'b000, 2'b00}; //reconstructed address
                        dirty <= 1'b1; //set the dirty bit so that the CLA knows to write back
                    end
               
                    else begin //the data at that cache line is not dirty
                        dirty <= 1'b0; // no need to write back from memory
                    end
               
                    //now go to memory at address and write into cache + update stuff
                    //get new data from memory (done by CLA??)
                    //read_memory <= 1'b1; //turn on for the CLA to know to go to memory
                    data0[index][word_off] <= data_in; //take data and write it into the cache at that index
                    tag0[index] <= tag; //update the tag to new tag
                    //valid0[index] <= 1'b1; //trying this out again 
                    if (word_off == 7) begin
                       valid0[index] <= 1'b1; //set the valid bit since just updated data
                       LRU[index] <= 1'b1; //just did all of this in set 1 so now set 0 is least used
                    end
                    else begin
                        valid0[index] <= 1'b0;
                    end
                    dirty0[index] <= 1'b0; //data is no longer dirty since it was updated in memory
                    
                end

            end // else !hit

        end // if (cache_we)

    end // always ff
         
         
         
    initial begin
        for (int i = 0; i < 8; i++) begin
            valid0[i] = 0;
            valid1[i] = 0;
            dirty0[i] = 0;
            dirty1[i] = 0;
            LRU[i] = 0;
        end
    end
 
//always_comb begin

//    // signed byte        // 4 words 
//    if (sign == 1'b0 && size == 2'b00 && byte_offset == 2'b11) begin
//        data_out = {{24{data_out[31]}}, data_out[31:24]};                     
//    end else if (sign == 1'b0 && size == 2'b00 && byte_offset == 2'b10) begin
//        data_out = {{24{data_out[23]}}, data_out[23:16]};       
//    end else if (sign == 1'b0 && size == 2'b00 && byte_offset == 2'b01) begin
//        data_out = {{24{data_out[15]}}, data_out[15:8]};     
//    end else if (sign == 1'b0 && size == 2'b00 && byte_offset == 2'b00) begin
//        data_out = {{24{data_out[7]}}, data_out[7:0]};
     
//     // signed half      // read 3 words
//    end else if (sign == 1'b0 && size == 2'b01 && byte_offset == 2'b10) begin
//        data_out = {{16{data_out[31]}}, data_out[31:16]}; 
//    end else if (sign == 1'b0 && size == 2'b01 && byte_offset == 2'b01) begin
//        data_out = {{16{data_out[23]}}, data_out[23:8]};
//    end else if (sign == 1'b0 && size == 2'b01 && byte_offset == 2'b00) begin
//        data_out = {{16{data_out[15]}}, data_out[15:0]};
         
//    // word         // read 1 word
//    end else if (sign == 1'b0 && size == 2'b10 && byte_offset == 2'b00) begin
//        data_out = data_out; 
        
        
        
//     //unsigned byte   
//    end else if (sign == 1'b1 && size == 2'b00 && byte_offset == 2'b11) begin
//        data_out = {24'd0, data_out[31:24]};
//    end else if (sign == 1'b1 && size == 2'b00 && byte_offset == 2'b10) begin
//        data_out = {24'd0, data_out[23:16]};
//    end else if (sign == 1'b1 && size == 2'b00 && byte_offset == 2'b01) begin
//        data_out = {24'd0, data_out[15:8]};
//    end else if (sign == 1'b1 && size == 2'b00 && byte_offset == 2'b00) begin
//        data_out = {24'd0, data_out[7:0]};
        
//    //unsigned half   
//    end else if (sign == 1'b1 && size == 2'b01 && byte_offset == 2'b10) begin
//        data_out = {16'd0, data_out[31:16]}; 
//    end else if (sign == 1'b1 && size == 2'b01 && byte_offset == 2'b01) begin
//        data_out = {16'd0, data_out[23:8]};
//    end else if (sign == 1'b1 && size == 2'b01 && byte_offset == 2'b00) begin
//        data_out = {16'd0, data_out[15:0]};
        
//   // unsupported size, byte offset combination     
//    end else begin
//        data_out = data_out; 
//    end
//end
    
         
     
endmodule