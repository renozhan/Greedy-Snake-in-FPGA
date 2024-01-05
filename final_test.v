module final_test(
	output [7:0] DATA_R, DATA_G, DATA_B,
	output [6:0] seg,
	output [3:0] rgb_com,
	output [2:0] seg_com,
	output [15:0] score_led,
	output beeper,
	
	input CLK, up, down, left, right
);

//	0 1 2 3 4 5 6 7
//0
//1
//2
//3
//4
//5
//6
//7
	int timer;
	int food_timer;
	int beep_timer;
	int direction;	 // up, down, left, right
	int food_color; // red, green, blue
	int score;
	int bit_countdown;
	int countdown;
	
	bit[2:0] cnt_win;
	
	bit [2:0] head_x;
	int head_y;
	bit [2:0] tail_x;
	int tail_y;	
	bit [2:0] food_x;
	int food_y;
	
	bit [2:0] temp;
	
	bit [7:0] head_rgb;
	bit [7:0] tail_rgb;
	bit [7:0] food_rgb;
	
	divfreq F0(CLK, CLK_div);
	
	parameter logic [7:0] map_win [7:0] = 
		'{8'b00000000, 
		  8'b01111110, 
		  8'b01111110, 
		  8'b01111110, 
		  8'b01111110, 
		  8'b01111110, 
		  8'b01111110, 
		  8'b00000000};
	parameter logic [7:0] map_lose [7:0] = 
		'{8'b01111110, 
		  8'b10111101, 
		  8'b11011011, 
		  8'b11100111, 
		  8'b11100111, 
		  8'b11011011, 
		  8'b10111101, 
		  8'b01111110};	  
	parameter logic [6:0] seg_map [9:0] = 
		'{7'b0000001, 
		  7'b1001111, 
		  7'b0010010, 
		  7'b0000110, 
		  7'b1001100, 
		  7'b0100100, 
		  7'b0100000, 
		  7'b0001111, // 7 seg_map[2]
		  7'b0000000, // 8 seg_map[1]
		  7'b0000100};// 9 seg_map[0]
		  
	initial begin
		timer = 0;
		food_timer = 0;
		direction = 0;
		food_color = 1;
		score = 0;
		head_x = 0;
		head_y = 6;
		tail_x = 0;
		tail_y = 7;
		food_x = 0;
		food_y = 0;
		head_rgb = 8'b10111111;
		tail_rgb = 8'b01111111;
		food_rgb = 8'b11111110;
		rgb_com = 4'b1000;
		DATA_R = 8'b11111111;
		DATA_G = 8'b11111111;
		DATA_B = 8'b11111111;
		score_led = 16'b0000000000000000;
		seg = 7'b1000000;
		seg_com = 3'b000;
		countdown = 120;
		beeper = 0;
		beep_timer = 0;
	end
	
	always @(posedge CLK_div)
		begin
			// win
			if (score >= 16)
				begin
					if (cnt_win >= 7) cnt_win = 0;
					else cnt_win = cnt_win + 1;
					rgb_com = {1'b1, cnt_win};
					DATA_R = map_win[cnt_win];
					DATA_G = 8'b11111111;
					DATA_B = map_win[cnt_win];
					// beeper
					beep_timer += 1;
					if ((beep_timer <= 500) | (beep_timer >= 1000 && beep_timer <= 1500))
						beeper = 1;
					else beeper = 0;
				end
			// lose
			else if (countdown <= 0)
				begin
					if (cnt_win >= 7) cnt_win = 0;
					else cnt_win = cnt_win + 1;
					rgb_com = {1'b1, cnt_win};
					DATA_R = map_lose[cnt_win];
					DATA_G = 8'b11111111;
					DATA_B = 8'b11111111;
					// beeper
					beep_timer += 1;
					if (beep_timer <= 1000) beeper = 1;
					else beeper = 0;
				end
			else
				begin
					timer += 1;
					food_timer += 1;
					if (!up) direction = 0;
					if (!down) direction = 1;
					if (left) direction = 2;
					if (right) direction = 3;
					
					// display head and food
					if (timer % 3 == 0) 
						begin
							// gameboard
							rgb_com <= {1'b1, head_x}; 
							DATA_R = head_rgb;
							DATA_G = head_rgb;
							DATA_B = head_rgb;
							// countdown timer
							bit_countdown = countdown / 100;
							seg = seg_map[9-bit_countdown];
							seg_com = 3'b011;
						end
					else if (timer % 3 == 1)
						begin
							// gameboard
							rgb_com <= {1'b1, tail_x}; 
							DATA_R = tail_rgb;
							DATA_G = tail_rgb;
							DATA_B = tail_rgb;
							// countdown timer
							bit_countdown = (countdown % 100) / 10;
							seg = seg_map[9-bit_countdown];
							seg_com = 3'b101;
						end
					else 
						begin
							// gameboard
							rgb_com <= {1'b1, food_x};
							if (food_color == 0)
								begin
									DATA_R <= food_rgb;
									DATA_G <= 8'b11111111;
									DATA_B <= 8'b11111111;
								end
							else if (food_color == 1)
								begin
									DATA_R <= 8'b11111111;
									DATA_G <= food_rgb;
									DATA_B <= 8'b11111111;
								end
							else
								begin
									DATA_R <= 8'b11111111;
									DATA_G <= 8'b11111111;
									DATA_B <= food_rgb;
								end
							// countdown timer
							bit_countdown = countdown % 10;
							seg = seg_map[9-bit_countdown];
							seg_com = 3'b110;	
						end

					// snake moves per half-sec
					if (timer % 500 == 0)				
						begin 
							tail_rgb[tail_y] <= 1'b1;
							tail_x = head_x;
							tail_y = head_y;
							tail_rgb[tail_y] <= 1'b0;
							case (direction)
								0: begin
									head_rgb[head_y] <= 1'b1;
									head_y = head_y - 1;
									if (head_y == -1) head_y = 7;
									head_rgb[head_y] <= 1'b0;
									end					
								1: begin
									head_rgb[head_y] <= 1'b1;
									head_y = head_y + 1;
									if (head_y == 8) head_y = 0;
									head_rgb[head_y] <= 1'b0;
									end					
								2: begin 
									head_x = head_x - 1;
									if (head_x == -1) head_x = 7;
									end
								3: begin 
									head_x = head_x + 1;
									if (head_x == 8) head_x = 0;
									end
							endcase
							
						// countdown timer
						if (timer % 1000 == 0) countdown -= 1;
					end
				end
			
			// update food position (fake random)
			if ((head_x == food_x & head_y == food_y) | food_timer == 4999)
				begin
				if (head_x == food_x & head_y == food_y) 
					begin
						if (food_color == 0) // red
							begin
								score -= 2;
								score_led[score] = 1'b0;
								score_led[score+1] = 1'b0;	
							end
						else if (food_color == 1) // green
							begin
								score_led[score] = 1'b1;
								score += 1;
							end
						else // blue
							begin
								score_led[score] = 1'b1;
								score_led[score+1] = 1'b1;
								score += 2;			
							end
					end
				// rand food color
				if (food_timer % 3 == 0) 
					begin
					if (score >= 2) food_color = 0;
					else food_color = 2;
					end
				else if (food_timer % 3 == 1) food_color = 1;
				else food_color = 2;
				
				// rand food pos
				food_rgb[food_y] <= 1'b1;
				temp = food_x;
				food_x = (timer *123) % 8; 
				food_y = (timer *121) % 8;
				if (food_x == temp) food_x = (food_x + 3) % 8;
				food_rgb[food_y] <= 1'b0;
				food_timer = 0;
				end
			
			// reset timer
			if (timer == 20000000) timer = 0;
		end
		
endmodule

// 1 ms clock
module divfreq(
	input CLK, 
	output reg CLK_div
);
	reg[24:0] Count = 25'b0;
	always @(posedge CLK)
		begin
			if(Count > 25000)
				begin
					Count <= 25'b0;
					CLK_div <= ~CLK_div;
				end
			else
				Count <= Count + 1'b1;
		end
endmodule