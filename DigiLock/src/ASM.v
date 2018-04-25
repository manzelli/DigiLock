module ASM (
	input clk,
    input rst,
    input clr,
    input enter,
    input change,
	output reg [5:0] led,
	output reg [19:0] ssd,
    input [3:0] switch
); 

/* BUTTON INPUT MAPPING */
    // input rst, // from BTN3
    // input clr, // from BTN0
    // input enter, // from BTN2
    // input change, // BTN1

/* REGISTERS */
	reg [15:0] passwd;
	reg [15:0] in_passwd;
	reg [5:0]  current_state;
	reg [5:0]  next_state;	

/* STATE CODE MAPPING */
	// state_idle state
	parameter state_idle             = 6'b000000;
	parameter state_get_first_digit  = 6'b000001;
	parameter state_get_second_digit = 6'b000010;
	parameter state_get_digit_digit  = 6'b000011;
	parameter state_get_fourth_digit = 6'b000100;
	parameter state_clear_input      = 6'b000101;

	// state for checking passwd correctness, and intermediate
	parameter state_check_pwd        = 6'b000101;

	// state_open and waiting for input
	parameter state_state_open       = 6'b000110;

	// state set new passwd
	parameter state_set_passwd       = 6'b001000;
	parameter state_set_first_digit  = 6'b001001;
	parameter state_set_second_digit = 6'b001010;
	parameter state_set_digit_digit  = 6'b001011;
	parameter state_set_fourth_digit = 6'b001100;


/* SSD OUTPUT CODE MAPPINGS */
	parameter ssd_zero    = 5'b00000;
	parameter ssd_two     = 5'b00010;
	parameter ssd_one     = 5'b00001;
	parameter ssd_three   = 5'b00011;
	parameter ssd_four    = 5'b00100;
	parameter ssd_five    = 5'b00101;
	parameter ssd_six     = 5'b00110;
	parameter ssd_seven   = 5'b00111;
	parameter ssd_eight   = 5'b01000;
	parameter ssd_nine    = 5'b01001;
	parameter ssd_A       = 5'b01010;
	parameter ssd_B       = 5'b01011;
	parameter ssd_C       = 5'b01100;
	parameter ssd_D       = 5'b01101;
	parameter ssd_E       = 5'b01110;
	parameter ssd_F       = 5'b01111;
	parameter ssd_blank   = 5'b10000;
	parameter ssd_L       = 5'b10001;
	parameter ssd_P       = 5'b10011;
	parameter ssd_n       = 5'b10100;


/* SEQUENTIAL: STATE TRANSITIONS */
always @ (posedge clk or posedge rst)
begin
	// your code goes here
	if (rst == 1)
		current_state <= state_idle;
		passwd <= 16'b0000000000000000;
	else
		current_state <= next_state;
end

/* COMBINATIONAL: STATE TRANSITIONS */
always @ (*) begin
	if (current_state == state_idle ) begin
		passwd[15:0] = 16'b0000000000000000;
		if (enter == 1) next_state = state_get_first_digit;
		else            next_state = current_state;
	end

	else if ( current_state == state_get_first_digit ) begin
		if (enter == 1) next_state = state_get_second_digit;
		else            next_state = current_state;
	end

	else if ( current_state == state_get_second_digit ) begin
		if (enter == 1) next_state = state_get_third_digit;
		else            next_state = current_state;
	end
			
	else if ( current_state == state_get_third_digit )  begin
		if (enter == 1) next_state = state_get_fourth_digit;
		else            next_state = current_state;
	end

	else if ( current_state == state_get_fourth_digit ) begin
		if (enter == 1) next_state = check_pwd;
		else            next_state = current_state;
	end

	else if ( current_state == check_pwd )  begin
		if ((passwd ^ in_passwd) > 1) next_state = state_open;
		else                          next_state = state_idle;
	end

	// TODO: this is not correct, open goes to two possible states
	else if ( current_state == state_open ) begin
		if ((passwd ^ in_passwd) > 1) next_state = state_open;
		else                          next_state = state_idle;
	end

	else next_state = current_state;
end


// SEQUENTIAL: CONTROL REGISTER ASSIGNMENTS
always @ (posedge clk or posedge rst) begin
	if (rst) begin
		in_passwd[15:0] <= 0; // passwd which is taken coming from user, 
		passwd[15:0]    <= 0; // setting passwd to zero if reset
	end

	else 
		if (current_state == state_idle) begin
			passwd[15:0] <= 16'b0000000000000000; // Built in reset is 0, when user in state_idle state.
			// you may need to add extra things here.
		end
	
		else if (current_state == state_get_first_digit) begin
			if (enter == 1) in_passwd[15:12] <= switch[3:0];
		end

		else if (current_state == state_get_second_digit) begin
			if (enter == 1) in_passwd[11:8]  <= switch[3:0];
		end
		
		else if (current_state == state_get_third_digit) begin
			if (enter == 1) in_passwd[7:3]   <= switch[3:0];
			
		end
		
		else if (current_state == state_get_fourth_digit) begin		
			if (enter == 1) in_passwd[3:0]   <= switch[3:0];
		end

	/*
		Complete the rest of ASM chart, in this section, you are supposed to set the values for control registers, stored registers(passwd for instance)
		number of trials, counter values etc... 
	*/

end


// Sequential part for outputs; this part is responsible from outputs; i.e. SSD and LEDS
always @ (posedge clk) begin
	if (current_state == state_idle) begin
		ssd <= {C, L, five, d};	//CLSD
	end

	// the extra zero is for padding since switch inputs are only 4 bits
	// and the ssd takes 5 bit inputs per display
	else if (current_state == state_get_first_digit)  begin
		ssd <= { 0, switch[3:0], blank, blank, blank};
	end

	else if (current_state == state_get_second_digit) begin
		ssd <= {blank, 0, switch[3:0], blank, blank};
	end

	else if (current_state == state_get_third_digit)  begin
		ssd <= {blank, blank, 0, switch[3:0], blank};
	end

	else if (current_state == state_get_fourth_digit) begin
		ssd <= {blank, blank,  blank, 0, switch[3:0]};
	end

	else if (current_state == state_open) begin
		ssd <= {ssd_zero, ssd_P,  ssd_E, ssd_n};
	end
	
	else ssd <= {ssd_blank, ssd_blank, ssd_blank, ssd_blank};
	// TODO: add more screen prints
end
endmodule
