CPE 333: Computer Hardware Architecture and Design 
Lab 3: Caches

Executive Summary: 
- In this lab, we implemented the L1 Cache with a given Single Port Memory Module, representing just the data memory. We put together the L1 Cache, the Cache Line Adapter, and Cache Controller to control the flow of data in and out of the cache and memory. We also implemented the LRU as our replacement policy.

Summary of Design:

- The design choices within this lab were between what parts to control within the individual modules and what parts to let the Cache Controller control. We decided to put all of the logic of determining when there is a hit or a miss within the cache itself, and the controller would just determine the transition within the states and turn on the read enable and write enable for each module. Our CLA was kept relatively simple as well, with it only handling reading and writing, and then the FSM would control which data is being written in and read out. 
Our cache module has three parts to it. The first block of logic takes care of just determining if there was a hit or not and  setting the corresponding hit bit. The second part handles the reading, that spits out the correct data out if the cache_re signal is on from the FSM and if there is a hit. The third part handles the writing and the writebacks. If the FSM indicates a cache_we, and there is a hit, the LRU gets updated, the data is re-written, and the dirty bit gets turned on since the data was just edited. If there is a miss, then we check the LRU at that index, find the least recently used set, go into it, and check the dirty bit at that index as well. If the data there is dirty, then we reconstruct the address to go into the memory, and set the dirty flag to on. If the data there is not dirty, then the dirty flag gets turned off.  Here, instead of there being an address generator, the cache reconstructs the address by putting together the tag, and index, and hardcoding the last 5 bits as zeros since we don’t need to know the byte offset or the word offset since the memory is also word addressable in this case. If the data is not dirty, then there is no updating of the memory required, and the dirty flag stays off. If there is a miss and the data is not dirty, then we have to go to the memory and write the given address and write that data into the cache. The data gets written into the cache,  and the tag gets updated to the new tag. Once the word offset reaches 7 indicating that all of the words have been re-written in the cache line, the valid bit gets turned on, and the dirty bit gets turned off since the data is not dirty anymore.

- In the CLA, we kept the logic pretty simple. There is a 3 bit counter within here that counts up to iterate through the array that holds the data from the cache or the memory. Since writing is synchronous, we have logic that writes to a specific index on every positive edge of the clock. We also have logic in here that reconstructs the address for when you are writing to or reading from memory by putting together the tag, the index, and then using the counter’s current count as the word offset since since the counter is what is helping us read or write one word at a time until you are at 8 words. Since reading is asynchronous, we have the CLA reading happening in an always comb block. The counter’s RCO in this module goes off when the counter reaches 7, indicating that the CLA has been filled with data. This “full” signal is connected to the FSM, helping determine when the states change. 

- The FSM or the Cache Controller module has signals that control the read enable and write enable of the cache, the memory, and the CLA. We chose to create 6 states: IDLE, CHECK, L1 to CLA, CLA to L1, MEM to CLA, and CLA to MEM. In the IDLE state, we just have start-up conditions which start the entire process. The only signals that cause state changes are if the data is dirty or not, if there is a hit or not, and if the CLA is full or not. The only additional hardware we added were two MUX’s, one for the address and one for the data. The address mux chose between the reconstructed address from the cache or the outside address that is provided from the testbench, and the data mux chose between the data out of the cache or the memory. The two selects for these muxes are also controlled within the states of the FSM.

- During testing, we decided to test every single module and verify that it works before doing one large test for the entire cache system. Some issues we ran into while testing were that we realized we needed two more MUX’s, one that chooses between the address_in coming from the CLA and the one coming from user  input, as well as the data_in coming from the CLA or the one from user input. After adding these, we had to change the logic in the controller to manage those selects. Additionally, during testing, we realized that since we did not have a decoder helping us know if there is a read or write instruction, we had to manage that within the test bench. These read and write signals needed to be different from the read enable and write enable signals of each module, so we included them in our top module and turned them on within the testbench. 

https://docs.google.com/document/d/1SJRMnrsyPLJvExQYRJoFhyqvzqSE6jMfcEbmvqTo95w/edit?usp=sharing - Link to Full Lab Report with photos of Schematic, FSM, and Simulation Proof.
