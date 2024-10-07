`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/01/2024 05:11:58 PM
// Design Name: 
// Module Name: Counter
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

module Counter #(parameter n=3) (
    input wire clk, 
	input wire clr, 
	input wire up, 
	input wire ld, 
    input wire [n-1:0] D,
    output reg [n-1:0] count,
    output wire rco   ); 

    
    always @(posedge clk)
    begin 
        if (clr == 1)       // asynch reset
           count <= 0;
       // else if (ld == 1)   // load new value
       //   count <= D; 
        else if (up == 1)   // count up (increment)
           count <= count + 1;  
    end 
       
    //- handles the RCO 
    assign rco = &count; 
	
endmodule

`default_nettype wire
    
   