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
module SSD_Driver(
   input             clk,
	input      [19:0] in,
	output reg [3:0]  AN_out,
	output reg [6:0]  CN_out
);

	reg  [1:0] count;
	wire [6:0] wire_disp0_out;
	wire [6:0] wire_disp1_out;
	wire [6:0] wire_disp2_out;
	wire [6:0] wire_disp3_out;
	// Initial block , used for correct simulations
	// initial begin
	// 	AN = 4'b1110;
	// 	seven_in = 0;
	// 	count = 0;
	// end

	// tranlate to 7 LED values
	bintochar disp0(in[4:0], wire_disp0_out);
	bintochar disp1(in[9:5], wire_disp1_out);
	bintochar disp2(in[14:10], wire_disp2_out);
	bintochar disp3(in[19:15], wire_disp3_out);

	// Also count value is operating in very high frequency? Think about how to fix it!
	always @ (posedge clk) begin
		count <= count + 1;
		case (count)
			2'b00: begin
				AN_out <= 4'b1110;
				CN_out <= wire_disp0_out;
			end
			2'b01: begin
				AN_out <= 4'b1101;
				CN_out <= wire_disp1_out;
			end
			2'b10: begin
				AN_out <= 4'b1011;
				CN_out <= wire_disp2_out;
			end
			2'b11: begin
				AN_out <= 4'b0111;
				CN_out <= wire_disp3_out;
			end
		endcase
	end
endmodule
