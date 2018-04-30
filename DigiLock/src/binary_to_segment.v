`timescale 1ns / 1ps

module bintochar(bin, char);
    input [4:0] bin;
	 output reg[6:0] char;
	 
	 always @(bin)
	 begin
		case(bin)// order:ABCDEFG
		5'b00000: char =7'b0000001;// 0
		5'b00001: char =7'b1001111;// 1
		5'b00010: char =7'b0010010;// 2		
		5'b00011: char =7'b0000110;// 3
		
		5'b00100: char =7'b1001100;// 4
		5'b00101: char =7'b0100100;// 5
		5'b00110: char =7'b0100000;// 6
		5'b00111: char =7'b0001111;// 7
		
		5'b01000: char =7'b0000000;// 8
		5'b01001: char =7'b0000100;// 9
		5'b01010: char =7'b0001000;// A
		5'b01011: char =7'b1100000;// b
		
		5'b01100: char =7'b0110001;// C
		5'b01101: char =7'b1000010;// d
		5'b01110: char =7'b0110000;// E
		5'b01111: char =7'b0111000;// F
		
		5'b10000: char =7'b1110001;// L
		5'b10001: char =7'b0011000;// p
		5'b10010: char =7'b1101010;// n
		5'b10011: char =7'b1000001;// V
		
		5'b10100: char =7'b1111110;// "-"
		5'b10101: char =7'b1110111;// "_"
		5'b10110: char =7'b1111111;// " "
		
		default: char =7'b1111111;// " ", empty digit.
		endcase
	end
endmodule