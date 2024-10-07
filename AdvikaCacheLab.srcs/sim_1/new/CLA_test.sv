`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/03/2024 07:18:19 PM
// Design Name: 
// Module Name: CLA_Test
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


module CLA_Test;
 // Signals
    logic clk;
    logic [31:0] addr_in;
    logic [31:0] data_in;
    logic up;
    logic clr;
    logic CLA_write;
    logic CLA_read;
    logic mem_valid;
    logic [31:0] data_out;
    logic [31:0] addr_out;
    logic rco;

    // Instantiate the CacheLineAdapter module
    CacheLineAdapter theCLA (
        .clk(clk),
        .addr_in(addr_in),
        .data_in(data_in),
        .up(up),
        .clr(clr),
        .CLA_write(CLA_write),
        .CLA_read(CLA_read),
        .mem_valid(mem_valid),
        .data_out(data_out),
        .addr_out(addr_out),
        .rco(rco)
    );
    


    // Clock generation
    always begin
        #5 clk = ~clk; // Toggle clock every 5 time units
    end

    // Initial setup
    initial begin
        // Initialize signals
        clk = 0;
        addr_in = 32'd0;
        data_in = 32'd0;
        up = 0;
        clr = 1;
        CLA_write = 0;
        CLA_read = 0;
        mem_valid = 0;
       
        // will print out every time data out address out or the CLAfull signal change
        $monitor("Time: %0d, CLAfull: %b, data_out: %h, addr_out: %h", $time, rco, data_out, addr_out);

        // Wait for initial setup
        #10;

    // Test 1: Write 8 words to CLA_ARRAY
        addr_in = 32'h00000000; // Set the starting address to 0
        CLA_write = 1; // Enable write
        clr = 0;
        up = 1; // Start the counter
        repeat (8) begin
            data_in = $random; // Generate random data
            #10; // Wait one clock cycle because writes are synchronous
        end
        CLA_write = 0; // Disable write
        up = 0; // Stop counter

        // Check if CLAfull is asserted
        // Expect CLAfull to be 1

        // Test 2: Read 8 words from CLA_ARRAY
        addr_in = 32'h00000000; // Set address
        CLA_read = 1; // Enable read
        up = 1;
        repeat (8) begin
            #10; // Wait for read to settle
        end
       // CLA_re = 0; // Disable read

        // Test 3: Generate address for memory access
        addr_in = 32'hABCD1234; // change the address
        #10; // wait for new address to be created
        // Check if addr_out is correct
        // expected addr_out will be = {tag, index, counterOutput, 2'b00}

        // End simulation
        #50;
        $stop;
    end


endmodule
 
