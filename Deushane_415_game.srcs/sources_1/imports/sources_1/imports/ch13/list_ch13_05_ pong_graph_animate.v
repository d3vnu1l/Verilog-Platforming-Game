// Listing 13.5
module pong_graph_st
   (
    input wire clk, reset, video_on,
    input wire [1:0] btn,
    input wire [9:0] pix_x, pix_y,
    output reg point, loss,
    output reg [11:0] graph_rgb,
    output wire graph_on
   );
     wire refr_tick;
     wire [9:0] bar_x_l, bar_x_r;
     reg [9:0] bar_x_reg, bar_x_next;
        
     wire [9:0] ball_x_l, ball_x_r;// ball left, right boundary
     wire [9:0] ball_y_t, ball_y_b;// ball top, bottom boundary
     reg [9:0] ball_x_reg, ball_y_reg;// reg to track left, top position
     wire [9:0] ball_x_next, ball_y_next;
     
     reg [9:0] x_delta_reg, x_delta_next;// reg to track ball speed
     reg [9:0] y_delta_reg, y_delta_next;
     //round ball
     wire [2:0] rom_addr, rom_col;
     reg [7:0] rom_data, rom_x;
     wire rom_bit;
     //object output signals
     wire wall_on, bar_on, sq_ball_on, rd_ball_on;
     wire [11:0] wall_rgb, bar_rgb, ball_rgb;
     reg [11:0] ball_strobe;
     
     //directional movement reg
     reg [1:0] move;
     reg moving;
     reg [3:0] bar_velocity;
     localparam body_acceleration = 1'b1;
     reg [1:0] btnLast;
     reg last_m, last_h;
     reg point, loss;
     reg hit, miss, miss_reg, hit_reg;
     
   
   // constant and signal declaration
   // x, y coordinates (0,0) to (639,479)
   localparam MAX_X = 640;
   localparam MAX_Y = 480;

   // wall left, right boundary
   localparam WALL_Y_T = 32;
   localparam WALL_Y_B = 35;

   // bar left, right boundary
   localparam BAR_Y_T = 440;
   localparam BAR_Y_B = 445;
   // bar top, bottom boundary
   localparam BAR_X_SIZE = 72;
   // register to track top boundary  (x position is fixed)
   // bar moving velocity when a button is pressed
   localparam BAR_V_MAX = 8;

   //square ball
   localparam BALL_SIZE = 8;
  
   // ball velocity can be pos or neg)
   localparam BALL_V_P = 2;
   localparam BALL_V_N = -2;
   
    // wall rgb output
     assign wall_rgb = 12'h06F; // blue
     assign ball_rgb = 12'hE62;   // red, ball rgb output
     //assign ball_rgb = ball_strobe;   // red, ball rgb output
     assign bar_rgb = 12'h362; // green

   always @*
   case (rom_addr)
      3'h0: rom_data = 8'b10011001; //   
      3'h1: rom_data = 8'b01000010; // 
      3'h2: rom_data = 8'b00100100; // 
      3'h3: rom_data = 8'b10011001; // 
      3'h4: rom_data = 8'b10011001; // 
      3'h5: rom_data = 8'b00100100; // 
      3'h6: rom_data = 8'b01000010; // 
      3'h7: rom_data = 8'b10011001; //  
      
      3'h0: rom_x = 8'b10000001; //   
      3'h1: rom_x = 8'b01000010; // 
      3'h2: rom_x = 8'b00100100; // 
      3'h3: rom_x = 8'b00011000; // 
      3'h4: rom_x = 8'b00011000; // 
      3'h5: rom_x = 8'b00100100; // 
      3'h6: rom_x = 8'b01000010; // 
      3'h7: rom_x = 8'b10000001; //
   endcase

   // registers
   always @(posedge clk, posedge reset)
      if (reset)
         begin
            bar_x_reg <= 0;
            ball_x_reg <= 0;
            ball_y_reg <= 0;
            x_delta_reg <= 10'h004;
            y_delta_reg <= 10'h004;
            bar_velocity <= 0;
         end
      else
         begin
            bar_x_reg <= bar_x_next;
            ball_x_reg <= ball_x_next;
            ball_y_reg <= ball_y_next;
            x_delta_reg <= x_delta_next;
            y_delta_reg <= y_delta_next;
         end
         
     //button debouncing
    always @(posedge clk) begin   
          hit_reg <= hit;
          miss_reg <= miss;
          
          //debonunce circuithit for hit miss
          if(miss_reg==1 && last_m == 1)
              loss <= 0;
          else loss <= miss_reg;
          last_m <= miss_reg;
          
          if(hit_reg==1 && last_h == 1)
                  point <= 0;
          else point <= hit_reg;
          last_h <= hit_reg;
          
     end

   // refr_tick: 1-clock tick asserted at start of v-sync
   //            i.e., when the screen is refreshed (60 Hz)
   assign refr_tick = (pix_y==481) && (pix_x==0);


   // pixel within wall
   assign wall_on = (WALL_Y_T<=pix_y) && (pix_y<=WALL_Y_B);
  

   // boundary
   assign bar_x_l = bar_x_reg;
   assign bar_x_r = bar_x_l + BAR_X_SIZE - 1;
   // pixel within bar
   assign bar_on = (BAR_Y_T<=pix_y) && (pix_y<=BAR_Y_B) &&
                   (bar_x_l<=pix_x) && (pix_x<=bar_x_r);
   assign graph_on = wall_on | bar_on | rd_ball_on;
   
   // new bar y-position
   always @* begin
      bar_x_next = bar_x_reg; // no move
      if (refr_tick) begin
        if(btn!=btnLast && btn!=2'b11)
            move=btn;
        if (move[1] & (bar_x_r < ((MAX_X-1)-BAR_V_MAX))) begin
            if(bar_velocity<BAR_V_MAX)
                bar_velocity=bar_velocity+body_acceleration;
            bar_x_next = bar_x_reg + bar_velocity; // move right
        end
        else if (move[0] & (bar_x_l > BAR_V_MAX)) begin
            if(bar_velocity>(-BAR_V_MAX))
                bar_velocity=bar_velocity-body_acceleration;
            bar_x_next = bar_x_reg + bar_velocity; // move left
        end
        btnLast = btn;
     end
   end

   //square ball
   // boundary
   assign ball_x_l = ball_x_reg;
   assign ball_y_t = ball_y_reg;
   assign ball_x_r = ball_x_l + BALL_SIZE - 1;
   assign ball_y_b = ball_y_t + BALL_SIZE - 1;
   // pixel within ball
   assign sq_ball_on = (ball_x_l<=pix_x) && (pix_x<=ball_x_r) && (ball_y_t<=pix_y) && (pix_y<=ball_y_b);
   // map current pixel location to ROM addr/col
   assign rom_addr = pix_y[2:0] - ball_y_t[2:0];
   assign rom_col = pix_x[2:0] - ball_x_l[2:0];
   assign rom_bit = rom_data[rom_col];
   assign rd_ball_on = sq_ball_on & rom_bit; // pixel within ball

  
   assign ball_x_next = (refr_tick) ? ball_x_reg+x_delta_reg : ball_x_reg ; // new ball position
   assign ball_y_next = (refr_tick) ? ball_y_reg+y_delta_reg : ball_y_reg ;
   
   always @*
   begin
      x_delta_next = x_delta_reg;
      y_delta_next = y_delta_reg;
      
      miss = 0;
      hit = 0;
      
      if (ball_x_l < 1) // reach left
         x_delta_next = BALL_V_P;
      else if (ball_x_r > (MAX_X-1)) // reach right
         x_delta_next = BALL_V_N;
      else if (ball_y_t <= WALL_Y_B) // reach wall
         y_delta_next = BALL_V_P;    // bounce back
      else if ((BAR_Y_T<=ball_y_b) && (ball_y_t<=BAR_Y_B) &&
               (bar_x_l<=ball_x_l) && (ball_x_r<=bar_x_r)) begin
         // reach x of right bar and hit, ball bounce back
         y_delta_next = BALL_V_N;
         hit = 1'b1;
      end
      else if ((BAR_Y_T<=ball_y_b) && (ball_y_t<=BAR_Y_B) && (
                     (bar_x_l>=ball_x_r) || (ball_x_l>=bar_x_r)))
        miss = 1'b1;
   end
   
   //rgb multiplexing
   always @* begin
      if (~video_on)
         graph_rgb = 12'h000; // blank
      else if (wall_on)
            graph_rgb = wall_rgb;
         else if (bar_on)
            graph_rgb = bar_rgb;
         else if (rd_ball_on)
            graph_rgb = ball_rgb;
         else
           graph_rgb = 12'h000;  // black
       
    end
endmodule