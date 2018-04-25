`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:11:06 04/07/2016 
// Design Name: 
// Module Name:    seven_segment 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module seven_segment(
    input             clk,
	input      [19:0] big_bin,
	reg        [4:0]  seven_in,
	output reg [3:0]  AN,
	output     [6:0]  seven_out
);

	reg [1:0] count;
	// Initial block , used for correct simulations
	// initial begin
	// 	AN = 4'b1110;
	// 	seven_in = 0;
	// 	count = 0;
	// end

// tranlate to 7 LED values
binary_to_segment disp0(seven_in, seven_out);		

// Always block is missing...
// Also count value is operating in very high frequency? Think about how to fix it!
always @ (posedge clk) begin
	count <= count + 1;
	case (count)
		0: begin
			AN <= 4'b1110;
			// now set the screen to the input value
		end
		1: begin
			AN <= 4'b1101;
			// now set the screen to the input value
		end
		2: begin
			AN <= 4'b1011;
			// now set the screen to the input value
		end
		3: begin
			AN <= 4'b0111;
			// now set the screen to the input value
		end
	endcase
end

endmodule
