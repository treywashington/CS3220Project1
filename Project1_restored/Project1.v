module Project1(SW,KEY,LEDR,LEDG,HEX0,HEX1,HEX2,HEX3,CLOCK_50);
	input  [9:0] SW;
	input  [3:0] KEY;
	input  CLOCK_50;
	output [9:0] LEDR;
	output [7:0] LEDG;
	output [6:0] HEX0,HEX1,HEX2,HEX3;
	// Project1 uses the existing 50MHz clock (no need for a PLL)
	wire clk=CLOCK_50;
	reg KEY0Pushed, KEY1Pushed, KEY2Pushed, KEY3Pushed;
	// No need to use reset/locked because CLOCK_50 is always OK

	reg [26:0] waitsec=26'd0;
	reg [5:0] seconds=5'b0;
	reg [5:0] minutes=6'd55;
	reg [4:0] hours=6'd23;
	
	reg [25:0] hsec=25'd0;
	reg [1:0] blink=1'b0;
	
	reg [1:0] setTimer=1'b0;
	reg [3:0] oldKEY=4'b1111;
	reg [7:0] blinkWire=8'b00000000;	
	

	always @(posedge clk) begin
		
		// ----------------------------------------
		// Blinking logic
		// ----------------------------------------
		hsec<=hsec+25'b1;	
		if(hsec==25'd24999999) begin
			hsec<=25'd0;
			blink<=!blink;		
		end
		
		// ----------------------------------------
		// Set Timer on keypress logic
		// ----------------------------------------
		oldKEY<=KEY;
		KEY0Pushed = {oldKEY[0],KEY[0]}==2'b10;
		KEY1Pushed = {oldKEY[1],KEY[1]}==2'b10;
		KEY2Pushed = {oldKEY[2],KEY[2]}==2'b10;
		KEY3Pushed = {oldKEY[3],KEY[3]}==2'b10;

		if(SW[0]==1'b1) begin
			setTimer<=1'b1;
		end else begin
			setTimer<=1'b0;
		end
		
		if(setTimer==1'b1) begin
			blinkWire<= {2'd0,seconds&{6{blink}}};
		end else begin
			blinkWire<= {2'd0,seconds};
		end
		
		if(setTimer==1'b1) begin
			if(KEY0Pushed) begin
				if(minutes==2'b0)
				minutes<=6'd59;
				else begin
				minutes<=minutes-2'b1;
				end
			seconds<=2'd0;
			end
			if(KEY1Pushed) begin
				if(minutes==6'd59)
				minutes<=2'b0;
				else begin
				minutes<=minutes+2'b1;
				end
			seconds<=2'd0;
			end
			if(KEY2Pushed) begin
				if(hours==6'd0)
				hours<=6'd23;
				else begin
				hours<=hours-2'b1;
				end
			end
			if(KEY3Pushed) begin
				if(hours==6'd23)
				hours<=6'd0;
				else begin
				hours<=hours+2'b1;
				end
			end
		end
		
		
		// ----------------------------------------
		// Timer logic
		// ----------------------------------------
		
		waitsec<=waitsec+26'b1;
		if(waitsec==26'd49_999_999) begin
			waitsec<=26'd0;
			seconds<=seconds+2'b1;		
			if(seconds==6'd59) begin
				seconds<=2'd0;
				minutes<=minutes+2'b1;
				if(minutes==6'd59) begin
					minutes<=2'd0;
					hours<=hours+2'b1;
					if(hours==6'd23) begin
						hours<=2'd0;
					end
				end
			end
		end
	end
	
	// ----------------------------------------
	// Display Values
	// ----------------------------------------
	
	
	// Dispay centiseconds and seconds on HEX
	wire [3:0] digit0=minutes%6'd10;
	wire [3:0] digit1=minutes/6'd10;
	wire [3:0] digit2=hours%6'd10;
	wire [3:0] digit3=hours/6'd10;
	
	// Output hex display
	SevenSeg s0(.IN(digit0),.OUT(HEX0));
	SevenSeg s1(.IN(digit1),.OUT(HEX1));
	SevenSeg s2(.IN(digit2),.OUT(HEX2));
	SevenSeg s3(.IN(digit3),.OUT(HEX3));
	
	// Output LEDG display in binary
	
	// Atempt at blinking timer display doesnt work
	assign LEDG=blinkWire;
	
	// blinking at half second by itself works
	//assign LEDG=blink;

	//standard timer w/out blinking
//	assign LEDG=seconds;

endmodule
