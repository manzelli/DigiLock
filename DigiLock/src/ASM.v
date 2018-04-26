module ASM (
	output reg [4:0]  led,
	output reg [19:0] ssd,
	input clk,
	input rst,
	input clr,
	input enter,
	input change,
	input [3:0] switch
); 

/* REGISTERS */
	reg [15:0] passwd;
	reg [15:0] in_passwd;
	reg [5:0]  current_state;
	reg [5:0]  next_state;
	reg [2:0]  counter_enter;

/* STATE CODE MAPPING */
	// state_idle state
	parameter state_idle                = 6'b000000;
	parameter state_start_open_passwd   = 6'b000001;
	parameter state_open_first_digit    = 6'b000010;
	parameter state_open_second_digit   = 6'b000011;
	parameter state_open_third_digit    = 6'b000100;
	parameter state_open_fourth_digit   = 6'b000101;

	// state for checking passwd correctness, and intermediate
	parameter state_open_check_passwd   = 6'b000110;

	parameter state_clear_input         = 6'b000111;

	// state_open and waiting for input
	parameter state_open                = 6'b001000;

	// state set new passwd
	parameter state_change_passwd       = 6'b001001;
	parameter state_change_first_digit  = 6'b001010;
	parameter state_change_second_digit = 6'b001011;
	parameter state_change_third_digit  = 6'b001100;
	parameter state_change_fourth_digit = 6'b001101;
	parameter state_set_new_passwrd     = 6'b001110;

	// state lock
	parameter state_lock_passwd         = 6'b001111;
	parameter state_lock_first_digit    = 6'b010000;
	parameter state_lock_second_digit   = 6'b010001;
	parameter state_lock_third_digit    = 6'b010010;
	parameter state_lock_fourth_digit   = 6'b010011;
	parameter state_lock_check_passwd   = 6'b010100;
	parameter state_backdoor_start      = 6'b010101;

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
	parameter ssd_d       = 5'b10010;
	parameter ssd_P       = 5'b10011;
	parameter ssd_n       = 5'b10100;


/* SEQUENTIAL: STATE TRANSITIONS ON RESET */
always @ (posedge clk or posedge rst)
begin
	// your code goes here
	if (rst == 1)                     current_state <= state_idle;
	else if (enter_counter == 3'b110) current_state <= state_backdoor_start;
	else                              current_state <= next_state;
end

/* COMBINATIONAL: STATE TRANSITIONS */
always @ (*) begin
	// IDLE STATE
	if (current_state == state_idle ) begin
		if (enter)      next_state = state_open_first_digit;
		else if (clear) next_state = state_idle;
		else            next_state = current_state;
	end

	// OPENING STATES
	else if ( current_state == state_open_first_digit ) begin
		if (enter)      next_state = state_open_second_digit;
		else if (clear) next_state = state_idle;
		else            next_state = current_state;
	end
	else if ( current_state == state_open_second_digit ) begin
		if (enter)      next_state = state_open_third_digit;
		else if (clear) next_state = state_idle;
		else            next_state = current_state;
	end	
	else if ( current_state == state_open_third_digit )  begin
		if (enter)      next_state = state_open_fourth_digit;
		else if (clear) next_state = state_idle;
		else            next_state = current_state;
	end
	else if ( current_state == state_open_fourth_digit ) begin
		if (enter) next_state = state_open_check_passwd;
		else       next_state = current_state;
	end
	else if ( current_state == state_open_check_passwd )  begin
		if ((passwd ^ in_passwd) == 16'b0) next_state = state_open;
		else                               next_state = state_idle;
	end

	// UNLOCKED
	else if ( current_state == state_open ) begin
		if (enter)       next_state = state_lock_passwd;
		else if (change) next_state = state_change_passwd;
		else             next_state = current_state;
	end

	// CLOSING STATES
	else if ( current_state == state_lock_passwd )  begin
		if (enter)      next_state = state_lock_first_digit;
		else if (clear) next_state = state_open;
		else            next_state = state_idle;
	end
	else if ( current_state == state_lock_first_digit ) begin
		if (enter)      next_state = state_lock_second_digit;
		else if (clear) next_state = state_open;
		else            next_state = current_state;
	end
	else if ( current_state == state_lock_second_digit ) begin
		if (enter)      next_state = state_lock_third_digit;
		else if (clear) next_state = state_open;
		else            next_state = current_state;
	end	
	else if ( current_state == state_lock_third_digit )  begin
		if (enter)      next_state = state_lock_fourth_digit;
		else if (clear) next_state = state_open;
		else            next_state = current_state;
	end
	else if ( current_state == state_lock_fourth_digit ) begin
		if (enter) next_state = state_lock_check_passwd;
		else       next_state = current_state;
	end
	else if ( current_state == state_lock_check_passwd )  begin
		if ((passwd ^ in_passwd) == 16'b0) next_state = state_idle;
		else                               next_state = state_open;
	end

	// CHANGING STATES
	else if ( current_state == state_change_passwd )  bchange
		if (enter)      next_state = state_change_first_digit;
		else if (clear) next_state = state_change_passwd)
		else            next_state = state_idle;
	end
	else if ( current_state == state_change_first_digit ) begin
		if (enter)      next_state = state_change_second_digit;
		else if (clear) next_state = state_change_passwd)
		else            next_state = current_state;
	end
	else if ( current_state == state_change_second_digit ) begin
		if (enter)      next_state = state_change_third_digit;
		else if (clear) next_state = state_change_passwd)
		else            next_state = current_state;
	end	
	else if ( current_state == state_change_third_digit )  begin
		if (enter)      next_state = state_change_fourth_digit;
		else if (clear) next_state = state_change_passwd)
		else            next_state = current_state;
	end
	else if ( current_state == state_change_fourth_digit ) begin
		if (enter) next_state = state_change_check_passwd;
		else       next_state = current_state;
	end
	else if ( current_state == state_change_check_passwd )  begin
		if (enter) next_state = state_idle;
		else       next_state = current_state;
	end


	else next_state = current_state;
end


/* SEQUENTIAL: CONTROL REGISTER ASSIGNMENTS */
always @ (posedge clk or posedge rst) begin
	// Part 1: Back door enter counter
	if (switch == 4'b1111 && enter) counter_enter <= counter_enter + 1;
	else                            counter_enter <= 3'b0;

	if (rst) begin
		in_passwd[15:0] <= 0; // passwd which is taken coming from user,
		passwd[15:0]    <= 0; // setting passwd to zero if reset
	end
 
	else begin
		if (current_state == state_idle) begin
			in_passwd[15:0] <= 0;
		end
	
		// OPEN LOCK
		else if (current_state == state_open_first_digit)    begin
			if (enter) in_passwd[15:12] <= switch[3:0];
		end
		else if (current_state == state_open_second_digit)   begin
			if (enter) in_passwd[11:8]  <= switch[3:0];
		end
		else if (current_state == state_open_third_digit)    begin
			if (enter) in_passwd[7:3]   <= switch[3:0];
		end
		else if (current_state == state_open_fourth_digit)   begin		
			if (enter) in_passwd[3:0]   <= switch[3:0];
		end

		// CLOSE LOCK
		else if (current_state == state_lock_first_digit)    begin
			if (enter) in_passwd[15:12] <= switch[3:0];
		end
		else if (current_state == state_lock_second_digit)   begin
			if (enter) in_passwd[11:8]  <= switch[3:0];
		end
		else if (current_state == state_lock_third_digit)    begin
			if (enter) in_passwd[7:3]   <= switch[3:0];
		end
		else if (current_state == state_lock_fourth_digit)   begin		
			if (enter) in_passwd[3:0]   <= switch[3:0];
		end

		// CHANGE PASSWD
		else if (current_state == state_change_first_digit)  begin
			if (enter) in_passwd[15:12] <= switch[3:0];
		end
		else if (current_state == state_change_second_digit) begin
			if (enter) in_passwd[11:8]  <= switch[3:0];
		end
		else if (current_state == state_change_third_digit)  begin
			if (enter) in_passwd[7:3]   <= switch[3:0];
		end
		else if (current_state == state_change_fourth_digit) begin		
			if (enter) in_passwd[3:0]   <= switch[3:0];
		end
	end
end


// SEQUENTIAL: outputs from this module; i.e. SSD and LEDS
always @ (posedge clk) begin
	if (current_state == state_idle) begin
		ssd <= {ssd_C, ssd_L, ssd_five, ssd_d};	// CL5d
	end
	else if (current_state == state_locked)  begin
		ssd <= {ssd_C, ssd_L, ssd_five, ssd_d};	// CL5d
	end
	else if (current_state == state_open) begin
		ssd <= {ssd_zero, ssd_P, ssd_E, ssd_n}; // OPEn
	end

	// the extra zero in SSD is for padding since 
	// switch inputs are only 4 bits and the ssd takes 5 bit inputs per display

	// OPEN
	else if (current_state == state_open_first_digit)  begin
		ssd <= {1'b0, switch[3:0], ssd_blank, ssd_blank, ssd_blank};
	end
	else if (current_state == state_open_second_digit) begin
		ssd <= {ssd_blank, 1'b0, switch[3:0], ssd_blank, ssd_blank};
	end
	else if (current_state == state_open_third_digit)  begin
		ssd <= {ssd_blank, ssd_blank, 1'b0, switch[3:0], ssd_blank};
	end
	else if (current_state == state_open_fourth_digit) begin
		ssd <= {ssd_blank, ssd_blank,  ssd_blank, 1'b0, switch[3:0]};
	end

	// LOCK
	else if (current_state == state_lock_first_digit)  begin
		ssd <= {1'b0, switch[3:0], ssd_blank, ssd_blank, ssd_blank};
	end
	else if (current_state == state_lock_second_digit) begin
		ssd <= {ssd_blank, 1'b0, switch[3:0], ssd_blank, ssd_blank};
	end
	else if (current_state == state_lock_third_digit)  begin
		ssd <= {ssd_blank, ssd_blank, 1'b0, switch[3:0], ssd_blank};
	end
	else if (current_state == state_lock_fourth_digit) begin
		ssd <= {ssd_blank, ssd_blank,  ssd_blank, 1'b0, switch[3:0]};
	end

	// CHAGE
	else if (current_state == state_change_first_digit)  begin
		ssd <= {
			1'b0, switch[3:0],
			ssd_blank,
			ssd_blank,
			ssd_blank
		};
	end
	else if (current_state == state_change_second_digit) begin
		ssd <= {
			1'b0, in_passwd[3:0],
			1'b0, switch[3:0],
			ssd_blank,
			ssd_blank
		};
	end
	else if (current_state == state_change_third_digit)  begin
		ssd <= {
			1'b0, in_passwd[3:0],
			1'b0, in_passwd[7:4],
			1'b0, switch[3:0],
			ssd_blank
		};
	end
	else if (current_state == state_change_fourth_digit) begin
		ssd <= {
			1'b0, in_passwd[3:0],
			1'b0, in_passwd[7:4],
			1'b0, in_passwd[11:8],
			1'b0, switch[3:0],
		};
	end

	else ssd <= {ssd_blank, ssd_blank, ssd_blank, ssd_blank};
	// TODO: add more screen prints
end
endmodule
