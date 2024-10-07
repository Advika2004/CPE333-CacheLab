`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/03/2024 07:03:42 PM
// Design Name: 
// Module Name: Top_Sim
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

module Top_Sim;

    // Inputs
    reg CLK;
    reg [31:0] ADDR;
    reg [31:0] DATA_IN;
    reg RST;
    reg write;
    reg read;

    // Instantiate the Top module
    Top myTop (
        .CLK(CLK),
        .write(write),
        .read(read),
        .ADDR(ADDR),
        .DATA_IN(DATA_IN),
        .RST(RST)
    );

    // Clock generation
    always #5 CLK = ~CLK; // 10ns clock period
    logic [2:0] index;
    logic [24:0] tag;
    logic [31:0] expected_memory [0:16383];
    initial begin
        $readmemh("otter_memory3.mem", expected_memory, 0, 16383);
    end        

    initial begin
        // Initialize inputs
        CLK = 0;
        RST = 1;
        ADDR = 0;
        DATA_IN = 0;

        // Apply reset
        #10;
        RST = 0;

        // Test Case 1: Write data to cache
//        // Write 0xDEADBEEF to address 0x00000000
//        ADDR = 32'h700;
//        DATA_IN = 32'hDEADBEEF;
//        myTop.L1_write = 1;
//        myTop.L1_read = 0;
//        #50; // Wait for two clock cycles
        
//        myTop.L1_write = 0;
        
        
                // Test Case 1: Write data to cache
        // Write 0xDEADBEEF to address 0x00000000
//        ADDR = 32'h700;
//        DATA_IN = 32'hDEADBEEF;
//        myTop.L1_read = 1;
//        #20; // Wait for two clock cycles
        
//        myTop.L1_read = 0;
        
        //// Test Case 2: Read data from cache (Expecting a hit)
        // Read from address 0x00000000
//        ADDR = 32'h700;
//        myTop.L1_read = 1;
//        @ (posedge CLK iff myTop.Controller.memValidWorld);
        
//        myTop.L1_read = 0;

//        $stop;        
        
         write = 0;
        //first test: filling every line in the cache with data
        // code by the one and only and greatest and most bestest and coolest and raddest and tallest and person with big hands     
        for (int i = 0; i < 2; i++) begin // num of sets
            for (int j = 0; j < 8; j++) begin // num of lines
                index = j[2:0];
                tag = i;
                ADDR = {tag, index, 5'b0};
                read = 1;
                write = 0;
                @ (negedge CLK iff myTop.Controller.memValidWorld);
                assert (myTop.L1_Cache.data_out == expected_memory[ADDR >> 2]) 
                else $fatal("WRONG got %x should be %x at addr: %x", myTop.L1_Cache.data_out, expected_memory[ADDR >> 2], ADDR >> 2);
            end
        end 
        $display("filled all the lines in the sets properly");
        
     
//        now going to overwrite one entire line in the cache 
//        should write new data to the first index from random shit to CAFEBABE
        
    // Setting address and data
//    ADDR = 32'h00000000;
//    DATA_IN = 32'hCAFEBABE;
    
//    // Write operation
//    write = 1;
//    read = 0;
//    expected_memory[ADDR >> 2] = DATA_IN;
    
//   // Perform the write
//    @ (posedge CLK iff myTop.Controller.memValidWorld);
//    write = 0;

    // Verification that the write was triggered
    //$display("Write operation to address %x with data %x completed", ADDR, DATA_IN);

    
    // Optionally stop simulation
    read = 0;
    #20;
    @ (posedge CLK);
    $stop;

    //now writing the test where I need to replace a line in the cache. 
    // Setting address that does not exist in the cache to force a miss
    ADDR = 32'h00000300; // this should miss
    read = 1;
    write = 0;
    // Perform the read to trigger the miss and fetch from memory
    @ (negedge CLK iff myTop.Controller.memValidWorld);
    
    // Verification that the data has been fetched from memory and written to cache
    // Assuming expected_memory contains the data fetched from memory
    assert (myTop.L1_Cache.data_out == expected_memory[ADDR >> 2])
    else $fatal("FAIL: Cache miss handling failed, got %x should be %x at addr: %x", 
                myTop.L1_Cache.data_out, expected_memory[ADDR >> 2], ADDR);
    
    $display("PASS: Cache miss without dirty bit test passed");

    // Optionally stop simulation
    #20;
     @ (posedge CLK);
    $stop;
    
    
    
    //final test, making sure that writing back works
    //need to write twice to create dirty bits within both sets and to set the LRU to 0
    
    //create a miss, go into LRU set, check if data is dirty, then go to that address in memory and and write that new data, take that data and write it into the same index, update the tag, set the valid bit, and set the dirty bit to 0 because the data is no longer dirty.
        // Step 1: Write to a line in set 0 to set the dirty bit
    ADDR = 32'h00000000; // Address in set 0
    DATA_IN = 32'hCAFEBABE;
    write = 1;
    read = 0;
    
    // Perform the write
    @ (negedge CLK iff myTop.Controller.memValidWorld);
    @ (posedge CLK);
    write = 0;
    
    // Step 2: Write to a line in set 1 to set the dirty bit
    ADDR =32'h00000040; // Address in set 1
    DATA_IN = 32'hCAFEBEEF;
    write = 1;
    read = 0;
    
    // Perform the write
    @ (negedge CLK iff myTop.Controller.memValidWorld);
    @ (posedge CLK);
    write = 0;

    // Step 3: Read from an address not in the cache to trigger a miss
    ADDR = 32'h00000300; // This address should miss
    read = 1;
    write = 0;
    
    // Perform the read to trigger the miss and fetch from memory
    @ (negedge CLK iff myTop.Controller.memValidWorld);
    @ (posedge CLK);

    // Verification that the dirty data was written back to memory
    assert (myTop.Main_Memory.DATA_OUT == 32'hCAFEBEEF) // Assuming LRU replaces set 1 first
    else $fatal("Write-back handling failed, got %x should be %x", 
                myTop.Main_Memory.DATA_OUT, 32'hCAFEBEEF);

    // Verification that the new data has been fetched and written to the cache
    assert (myTop.L1_Cache.data_out == expected_memory[ADDR >> 2])
    else $fatal("Cache miss handling failed after write-back, got %x should be %x", 
                myTop.L1_Cache.data_out, expected_memory[ADDR >> 2]);
    
    $display("Cache miss with write-back test passed");

    // Optionally stop simulation
    #20;
    
    $stop;
        
//                // Test Case 1: Write data to cache
//        // Write 0xDEADBEEF to address 0x00000000
//        ADDR = 32'h720;
//        DATA_IN = 32'hDEADBEEF;
//        myTop.L1_write = 0;
//        myTop.L1_read = 1;
//        #20; // Wait for two clock cycles
        
//        myTop.L1_read = 0;
        
//                // Test Case 1: Write data to cache
//        // Write 0xDEADBEEF to address 0x00000000
//        ADDR = 32'h730;
//        DATA_IN = 32'hDEADBEEF;
//        myTop.L1_write = 0;
//        myTop.L1_read = 1;
//        #20; // Wait for two clock cycles
        
//        myTop.L1_read = 0;
        
        
//                      // Test Case 1: Write data to cache
//        // Write 0xDEADBEEF to address 0x00000000
//        ADDR = 32'h740;
//        DATA_IN = 32'hDEADBEEF;
//        myTop.L1_write = 0;
//        myTop.L1_read = 1;
//        #20; // Wait for two clock cycles
        
//        myTop.L1_read = 0;
        
//                      // Test Case 1: Write data to cache
//        // Write 0xDEADBEEF to address 0x00000000
//        ADDR = 32'h750;
//        DATA_IN = 32'hDEADBEEF;
//        myTop.L1_write = 0;
//        myTop.L1_read = 1;
//        #20; // Wait for two clock cycles
        
//        myTop.L1_read = 0;
        
//                            // Test Case 1: Write data to cache
//        // Write 0xDEADBEEF to address 0x00000000
//        ADDR = 32'h760;
//        DATA_IN = 32'hDEADBEEF;
//        myTop.L1_write = 0;
//        myTop.L1_read = 1;
//        #20; // Wait for two clock cycles
        
//        myTop.L1_read = 0;
        
//                                    // Test Case 1: Write data to cache
//        // Write 0xDEADBEEF to address 0x00000000
//        ADDR = 32'h770;
//        DATA_IN = 32'hDEADBEEF;
//        myTop.L1_write = 0;
//        myTop.L1_read = 1;
//        #20; // Wait for two clock cycles
        
//        myTop.L1_read = 0;
        
 
        
        


        
//        // Test Case 2: Write data to cache
//        // Write 0xDEADBEEF to address 0x00000000
//        ADDR = 32'h800;
//        DATA_IN = 32'hCAFEBABE;
//        myTop.L1_write = 1;
//        myTop.L1_read = 0;
//        #20; // Wait for two clock cycles
        
//        myTop.L1_write = 0;

//// Test Case 2: Read data from cache (Expecting a hit)
//        // Read from address 0x00000000
//        ADDR = 32'h700;
//        myTop.L1_read = 1;
//        #20; // Wait for two clock cycles
        
//        myTop.L1_read = 0;

//        // Test Case 2: Read data from cache (Expecting a hit)
//        // Read from address 0x00000000
//        ADDR = 32'h800;
//        myTop.L1_read = 1;
//        #20; // Wait for two clock cycles
        
//        myTop.L1_read = 0;

//        // Check if data read is the same as the data written
//        if (myCache.L1_data_out != 32'hDEADBEEF) begin
//            $display("Test Case 2 Failed: Expected 0xDEADBEEF, got 0x%H", myCache.L1_data_out);
//        end else begin
//            $display("Test Case 2 Passed: Hit and data matched");
//        end
//      

//        // Test Case 3: Read data from a different address (Expecting a miss)
//        // Read from address 0x00000004
//        ADDR = 32'h00000004;
//        myCache.L1_read = 1;
//        #20; // Wait for two clock cycles

//        // Check if data read is not the same as the previous data written (indicating a miss)
//        if (myCache.L1_data_out == 32'hDEADBEEF) begin
//            $display("Test Case 3 Failed: Expected miss, got hit");
//        end else begin
//            $display("Test Case 3 Passed: Miss as expected");
//        end

//        // Test Case 4: Write back data to memory
//        // Write 0xCAFEBABE to address 0x00000004
//        ADDR = 32'h00000004;
//        DATA_IN = 32'hCAFEBABE;
//        myCache.L1_write = 1;
//        myCache.L1_read = 0;
//        #20; // Wait for two clock cycles
        
//        myCache.L1_write = 0;

//        // Read back the data from address 0x00000004 (Expecting a hit)
//        ADDR = 32'h00000004;
//        myCache.L1_read = 1;
//        #20; // Wait for two clock cycles

//        // Check if data read is the same as the data written
//        if (myCache.L1_data_out != 32'hCAFEBABE) begin
//            $display("Test Case 4 Failed: Expected 0xCAFEBABE, got 0x%H", myCache.L1_data_out);
//        end else begin
//            $display("Test Case 4 Passed: Hit and data matched");
//        end

        // End simulation
//        $stop;
    end

endmodule
