`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/02/2024 10:23:51 PM
// Design Name: 
// Module Name: MUX_2to1
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

 
 module MUX_2to1  #(parameter n=32) (
       input wire SEL,
       input wire [n-1:0] D0, 
       input wire [n-1:0] D1, 
       output reg [n-1:0] D_OUT ) ;  

        
       always @ (*)
       begin 
          if      (SEL == 1'b0)  D_OUT = D0;
          else if (SEL == 1'b1)  D_OUT = D1; 
          else                   D_OUT = 0; 
       end
                
endmodule

`default_nettype wire