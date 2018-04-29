module ASM (
	output reg [2:0]  led,
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
	reg [2:0]  current_state;
	reg [2:0]  next_state;
	reg [2:0]  counter_enter;
	reg [2:0]  backdoor_ct;
	reg [8:0]  timer;
	reg lockedflag;

/* STATE CODE MAPPING */
	parameter idle                = 3'b000;
	parameter locked              = 3'b001;
	parameter enter_pass          = 3'b010;
	parameter unlocked            = 3'b011;
	parameter change_pass         = 3'b100;
	parameter await_in            = 3'b101;
	parameter backdoor            = 3'b110;
	parameter lockout             = 3'b111;

/* SSD OUTPUT CODE MAPPINGS */
	parameter zero = 5'b00000;// 0
	parameter one = 5'b00001;// 1
	parameter two = 5'b00010;// 2		
	parameter three = 5'b00011;// 3
			
	parameter four = 5'b00100;// 4
	parameter five = 5'b00101;// 5
	parameter six = 5'b00110;// 6
	parameter seven = 5'b00111;// 7
			
	parameter eight = 5'b01000;// 8
	parameter nine = 5'b01001;// 9
	parameter A = 5'b01010; // A
	parameter B = 5'b01011; // b

	parameter C = 5'b01100; // C
	parameter D = 5'b01101; // d
	parameter E = 5'b01110;  // E
	parameter F =  5'b01111; // F

	parameter L = 5'b10000; // L
	parameter P = 5'b10001; // p
	parameter N = 5'b10010; // n
	parameter V = 5'b10011; // V
			
	parameter dash = 5'b10100; // "-"
	parameter underscore = 5'b10101; // "_"
	parameter blank = 5'b10110; // " "


/* SEQUENTIAL: STATE TRANSITIONS ON RESET */
always @ (posedge clk or posedge rst)
begin
	if (rst == 1)
		current_state <= idle;
	else
		current_state <= next_state;
end

/* COMBINATIONAL: STATE TRANSITIONS */
always @ (*) begin
	// IDLE STATE
	if (current_state == idle ) begin
		if (backdoor_ct == 3'b110)
			next_state = backdoor;
		else if (enter == 1 && switch != 4'b1111) // not backdoor switch inputs
			next_state = await_in; // look for input
		else
			next_state = current_state;
	end

	// LOCKED
	else if ( current_state == locked ) begin
		if (backdoor_ct == 3'b110)
			next_state = backdoor;
		if (enter == 1 && switch != 4'b1111) // not backdoor switch inputs)
			next_state = await_in;
		else
			next_state = current_state;
	end
	
	// AWAITING INPUT
	else if ( current_state == await_in ) begin
		if (enter == 1) begin
			if (lockedflag == 1)
				next_state = enter_pass; // if locked we need the current pass
			else
				next_state = change_pass; // if unlocked we want ot look for new pass
		end
		else if (rst == 1)
				next_state = idle;
		else if (timer == 9'b100101100 && !rst)
			next_state = lockout;
		else
			next_state = current_state;
	end
	
	// ENTER PASSWORD
	else if ( current_state == enter_pass )
   begin
		if (counter_enter == 3'b100) 
		begin
			if (passwd == in_passwd) 
			begin
				if (lockedflag == 1)
					next_state = unlocked;
				else
					next_state = locked;
			end
		else 
		begin
				if (lockedflag == 1)
				begin
					next_state = locked;
				end
				else
				begin
					next_state = unlocked;
				end
			end
		 end
			
		else if (timer == 9'b100101100 && !rst)
		begin
			next_state = lockout;
		end
		else if (rst == 1)
		begin
			next_state = idle;
		end
		else
			next_state = current_state;
	end

	// UNLOCKED
	else if ( current_state == unlocked ) begin
		if (enter == 1)
			next_state = enter_pass;
		else if (change == 1)
			next_state = await_in;
		else if (timer == 9'b100101100 && !rst)
			next_state = lockout;
		else if (rst == 1)
			next_state = idle;
		else
			next_state = current_state;
	end

	// CHANGE PASSWORD
	else if ( current_state == change_pass )  begin
		if (counter_enter == 3'b101)
			next_state = unlocked;	
		else if (timer == 9'b100101100 && !rst)
			next_state = lockout;
		else if (rst == 1)
			next_state = idle;
		else
			next_state = current_state;
	end
	
	// LOCKOUT STATE
	else if ( current_state == lockout ) begin
		if (timer == 9'b101101000)
			next_state = locked;
		else
			next_state = current_state;
	end
	
	// BACKDOOR	
	else if ( current_state == backdoor ) begin
		if (timer == 9'b101000001)
			next_state = locked;
		else
			next_state = current_state;
	end
	
	else
		next_state = current_state; // just in case

end

/* SEQUENTIAL: CONTROL REGISTER ASSIGNMENTS */
always @ (posedge clk or posedge rst) begin

	if (rst) begin
		in_passwd       <= 16'b0000000000000000; // passwd which is taken coming from user,
		passwd          <= 16'b0000000000000000; // setting passwd to zero if reset
	end
 
	else begin
		// IDLE
		if ( current_state == idle ) begin
			if (switch == 4'b1111 && enter == 1)
				backdoor_ct <= backdoor_ct + 1'b1;
			else begin
				lockedflag <= 1'b1;
				timer <= 9'b000000000;
				counter_enter <= 3'b000;
				passwd <= 16'b0000000000000000; // maybe make this 16 :~)
			end
		end
		
		// UNLOCKED
		else if ( current_state == unlocked ) begin
			counter_enter <= 3'b000;
			backdoor_ct <= 3'b000;
			timer <= timer + 1'b1;
			lockedflag <= 1'b0;
		end
		
		// LOCKED
		else if ( current_state == locked ) begin
			if (switch == 4'b1111 && enter == 1)
				backdoor_ct <= backdoor_ct + 1'b1;
			else begin
				lockedflag <= 1'b1;
				timer <= 9'b000000000;
				counter_enter <= 3'b000; // check password is password.
			end
		end
			
		// BACKDOOR
		else if ( current_state == backdoor ) begin
			timer <= timer + 1'b1;
			passwd <= 16'b0011010001010110;
			// passwd = 4'd3456; // figure out binary
			backdoor_ct <= 0;
		end
	
		// AWAITING INPUT
		else if ( current_state == await_in ) begin
			if (enter == 1)
				timer <= 9'b000000000; // reset timer back to 0 to wait for input
			else begin
				timer <= timer + 1'b1;
				counter_enter <= 3'b000;
			end
		end
		
		// TIMEOUT
		// all we have to do here is increment the counter
		else if ( current_state == lockout )
			timer <= timer + 1'b1;
		
		// ENTER PASSWORD
		// We want to replace every digit of the password as the user enters, as the counter increases
		// so that we can check it later
		else if ( current_state == enter_pass ) begin
			if (enter == 1 && counter_enter == 3'b000) begin // first digit
				timer <= 9'b000000000;
				counter_enter <= counter_enter + 1'b1;
				in_passwd[15:12] <= switch[3:0];
			end
			if (enter == 1 && counter_enter == 3'b001) begin // second digit
				timer <= 9'b000000000;
				counter_enter <= counter_enter + 1'b1;
				in_passwd[11:8] <= switch[3:0];
			end
			if (enter == 1 && counter_enter == 3'b010) begin // third digit
				timer <= 9'b000000000;
				counter_enter <= counter_enter + 1'b1;
				in_passwd[7:4] <= switch[3:0];
			end
			if (enter == 1 && counter_enter == 3'b011) begin // fourth digit
				timer <= 9'b000000000;
				counter_enter <= counter_enter + 1'b1;
				in_passwd[3:0] <= switch[3:0];
			end
			else if (clr == 1) begin // could also press clear here
				counter_enter <= 3'b000;
				timer <= 9'b000000000;
				in_passwd <= 16'b0000000000000000; // clear input pass
			end
			
			else // we want to time them if nothing happens 
				timer <= timer + 1'b1;
				
		end
		
		// CHANGE PASSWORD
		// we do the same thing here except when the count reaches 4 we have to save the entered password into the
		// actual password
		else if ( current_state == change_pass ) begin
			if (enter == 1 && counter_enter == 3'b000) begin // first digit
				timer <= 9'b000000000;
				counter_enter <= counter_enter + 1'b1;
				in_passwd[15:12] <= switch[3:0];
			end
			if (enter == 1 && counter_enter == 3'b001) begin // second digit
				timer <= 9'b000000000;
				counter_enter <= counter_enter + 1'b1;
				in_passwd[11:8] <= switch[3:0];
			end
			if (enter == 1 && counter_enter == 3'b010) begin // third digit
				timer <= 9'b000000000;
				counter_enter <= counter_enter + 1'b1;
				in_passwd[7:4] <= switch[3:0];
			end
			if (enter == 1 && counter_enter == 3'b011) begin // fourth digit
				timer <= 9'b000000000;
				counter_enter <= counter_enter + 1'b1;
				in_passwd[3:0] <= switch[3:0];
			end
			if (enter == 1 && counter_enter == 3'b100) begin // fourth digit
				counter_enter <= counter_enter + 1'b1;
				passwd[15:0] <= in_passwd;
			end
			else if (clr == 1) begin // could also press clear here
				counter_enter <= 3'b000;
				timer <= 9'b000000000;
				in_passwd <= 16'b0000000000000000; // clear input pass
			end
			
			else // we want to time them if nothing happens 
				timer <= timer + 1'b1;
		
		end
				
	
	end // ENDS OVERALL ELSE
end // ENDS ALWAYS BLOCK
	
	
		
//
//
// SEQUENTIAL: outputs from this module; i.e. SSD and LEDS
always @ (posedge clk) begin
	if (current_state == idle) begin
		ssd <= {C, L, five, D};	// CL5d
	end
	else if (current_state == locked)  begin
		ssd <= {C, L, five, D};	// CL5d
	end
	else if (current_state == unlocked) begin
		ssd <= {zero, P, E, N}; // OPEn
		led[2:0] <= unlocked;
	end
	else if (current_state == await_in) begin
		ssd <= {underscore, underscore, underscore, underscore};
		led[2:0] <= await_in;
	end
	// ENTERING PWD - SHOW NUMBERS AS ENTERED
	else if (current_state == enter_pass && counter_enter == 3'b000) begin
		ssd <= { 1'b0, switch, underscore, underscore, underscore};
		led[2:0] <= enter_pass;
	end 
	else if (current_state == enter_pass && counter_enter == 3'b001) begin
		ssd <= { dash, 1'b0, switch, underscore, underscore};
		led[2:0] <= enter_pass;
	end 
	else if (current_state == enter_pass && counter_enter == 3'b010) begin
		ssd <= {dash, dash, 1'b0, switch, underscore};
		led[2:0] <= enter_pass;
	end 
	else if (current_state == enter_pass && counter_enter == 3'b011) begin
		ssd <= {dash, dash, dash, 1'b0, switch};
		led[2:0] <= enter_pass;
	end 
	// CHANGING PWD - SAME AS ENTER
	// SHOW ENTERED PASS AS YOU GO INSTEAD OF HIDING IT
	else if (current_state == change_pass && counter_enter == 3'b000) begin
		ssd <= { 1'b0, switch, underscore, underscore, underscore};
		led[2:0] <= change_pass;
	end 
	else if (current_state == change_pass && counter_enter == 3'b001) begin
		ssd <= {1'b0, in_passwd[15:12], switch, underscore, underscore};
		led[2:0] <= change_pass;
	end 
	else if (current_state == change_pass && counter_enter == 3'b010) begin
		ssd <= {1'b0, in_passwd[15:12], 1'b0, in_passwd[11:8], 1'b0, switch, underscore};
		led[2:0] <= change_pass;
	end 
	else if (current_state == change_pass && counter_enter == 3'b011) begin
		ssd <= { 1'b0, in_passwd[15:12], 1'b0, in_passwd[11:8], 1'b0, in_passwd[7:4], 1'b0, switch};
		led[2:0] <= change_pass;
	end
	// BACKDOOR - I LOVE EC311
	else if (current_state == backdoor) begin
		if (timer == 9'b000000000) begin
			led[2:0] <= backdoor;
			ssd <= {blank, blank, blank, blank};
		end
		else if (timer == 9'b000010100) begin
			led[2:0] <= backdoor;
			ssd <= {blank, blank, blank, one};
		end
		else if (timer == 9'b000101000)
		begin
			led[2:0] <= backdoor;
			ssd <= {blank, blank, one, blank};
		end
		else if (timer == 9'b000111100)
		begin
			led[2:0] <= backdoor;
			ssd <= {blank, one, blank, L};
		end
		else if (timer == 9'b001010000)
		begin
			led[2:0] <= backdoor;
			ssd <= {one, blank, L, zero};
		end
		else if (timer == 9'b001100100)
		begin
			led[2:0] <= backdoor;
			ssd <= {blank, L, zero, V};
		end
		else if (timer == 9'b001111000)
		begin
			led[2:0] <= backdoor;
			ssd <= {L, zero, V, E};
		end
		else if (timer == 9'b010001100)
		begin
			led[2:0] <= backdoor;
			ssd <= {zero, V, E, blank};
		end
		else if (timer == 9'b010100000)
		begin
			led[2:0] <= backdoor;
			ssd <= {V,E,blank,E};
		end
		else if (timer == 9'b010110100)
		begin
			led[2:0] <= backdoor;
			ssd <= {E,blank,E,C};
		end
		else if (timer == 9'b011001000)
		begin
			led[2:0] <= backdoor;
			ssd <= {blank,E,C,three};
		end
		else if (timer == 9'b011011100)
		begin
			led[2:0] <= backdoor;
			ssd <= {E,C,three,one};
		end
		else if (timer == 9'b011110000)
		begin
			led[2:0] <= backdoor;
			ssd <= {C,three,one,one};
		end
		else if (timer == 9'b100000100)
		begin
			led[2:0] <= backdoor;
			ssd <= {three,one,one,blank};
		end
		else if (timer == 9'b100011000)
		begin
			led[2:0] <= backdoor;
			ssd <= {one,one,blank,blank};
		end
		else if (timer == 9'b100101100)
		begin
			led[2:0] <= backdoor;
			ssd <= {one,blank,blank,blank};
		end
		else if (timer == 9'b101000000)
		begin
			led[2:0] <= backdoor;
			ssd <= {blank,blank,blank,blank};
		end
		end
		else if(current_state == lockout)
		begin
		if (timer == 9'b100101110 || timer == 9'b101000000 || timer == 9'b101010100)
		begin
			led[2:0] <= lockout;
			ssd <= {blank,zero,V,seven};
		end
		else if(timer == 9'b100110110 || timer == 9'b101001010 || timer == 9'b101011110)
		begin
			led[2:0] <= lockout;
			ssd <= {blank,blank,blank,blank};
		end
	end
	
end
endmodule
