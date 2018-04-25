`timescale 1ns / 1ps

module binary_to_segment(
    input      [4:0] binary_in,
    output reg [6:0] seven_out
);

// add more cases here for the other letters on the display
always @ (binary_in)
begin
	case (binary_in)
		// display NULL
		5'd00000: seven_out <= 7'b1111111;

		// display 0
		5'd00001: seven_out <= 7'b0111111;
		
		// display 1
		5'd00010: seven_out <= 7'b1001111;

		// display 2
		5'd00011: seven_out <= 7'b0010010;

		// display 3
		5'd00100: seven_out <= 7'b0000110;

		// display 4
		5'd00101: seven_out <= 7'b0110011;

		// display 5
		5'd00111: seven_out <= 7'b1011011;

		// display 6
		5'd01000: seven_out <= 7'b1011111;

		// display 7
		5'd01001: seven_out <= 7'b1110000;

		// display 8
		5'd01000: seven_out <= 7'b1111111;

		// display 9
		5'd01001: seven_out <= 7'b1111011;

		// display A
		5'd01010: seven_out <= 7'b1110111;

		// display B
		5'd01011: seven_out <= 7'b1111111;

		// display C
		5'd01100: seven_out <= 7'b1001110;

		// display D
		5'd01101: seven_out <= 7'b1111110;

		// display E
		5'd01110: seven_out <= 7'b1001111;

		// display F
		5'd01111: seven_out <= 7'b1000111;

		// display -
		5'b10000: seven_out <= 7'b0000001;

		// display L
		5'b10001: seven_out <= 7'b0001110;
		
		// display d
		5'b10010: seven_out <= 7'b0111101;

		// display P
		5'b10011: seven_out <= 7'b1100111;

		// display n
		5'b10100: seven_out <= 7'b0010101;

		// DEFAULT:
		default: seven_out <= 7'b1;
	endcase
end
endmodule
