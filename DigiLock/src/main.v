`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Rachel Manzelli & Vijay Thakkar
// 
// Create Date: 15:39:19 04/25/2018 
// Design Name:  
// Module Name:    main 
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
module main(
	output [2:0] led,
	output [3:0] AN_out,
	output [6:0] CN_out,
	input clk, rst, clear, enter, change,
	input [3:0] switch
);
	wire [19:0] wire_ssd;
	wire deb_clear, deb_enter, deb_change, fast_as_fuk_boi, slow_clk;

	// Instantiate clock driver
	Clk_Divider slow_clk_driver(clk, rst, slow_clk);
	fast_clock fast_clk_driver(clk, rst, fast_as_fuk_boi);
	
	// SSD, might want to hardcode stuff here for testing
	SSD_Driver ssd_driver(fast_as_fuk_boi, wire_ssd, AN_out, CN_out);

	// Debounce button inputs
	Debouncer debounce_clr(slow_clk, rst, clear, deb_clear);
	Debouncer debounce_ent(slow_clk, rst, enter, deb_enter);
	Debouncer debounce_cng(slow_clk, rst, change, deb_change);

	// Instantiate ASM
	ASM asm(led, wire_ssd, slow_clk, rst, deb_clear, deb_enter, deb_change, switch);
endmodule
