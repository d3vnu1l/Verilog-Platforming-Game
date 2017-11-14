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
     wire [3:0] rom_addr, rom_col;
     reg [7:0]  rom_x;
     wire rom_bit;
     //object output signals
     wire wall_on, floor_on, l1_on, l2_on, l3_on, l4_on, l5_on, l6_on, l7_on, bar_on, sq_ball_on, rd_ball_on;
     wire [11:0] wall_rgb, floor_rgb, l1_rgb, l2_rgb, l3_rgb, l4_rgb, l5_rgb, l6_rgb, l7_rgb, bar_rgb, ball_rgb;
     reg [11:0] ball_strobe;
     
     //directional movement reg
     reg [1:0] move;
     reg moving;
     reg [3:0] bar_velocity;
     localparam body_acceleration = 1'b1;
     reg [1:0] btnLast;
     reg last_m, last_h;
     reg point, loss;
     reg hit, miss, miss_reg, hit_reg;;
     
   
   // constant and signal declaration
   // x, y coordinates (0,0) to (639,479)
   localparam MAX_X = 640;
   localparam MAX_Y = 480;

   // wall left, right boundary
   localparam WALL_Y_T = 32;
   localparam WALL_Y_B = 35;
   
   localparam FLOOR_Y_T = 450;
   localparam FLOOR_Y_B = 480-1;
   
   //LEVELS
   // wall left, right boundary
   localparam WALL_Y_T_1 = 80;
   localparam WALL_Y_B_1 = 90;
   localparam WALL_X_L_1 = 0;
   localparam WALL_X_R_1 = 300;
   
   localparam WALL_Y_T_2 = 135;
   localparam WALL_Y_B_2 = 145;
   localparam WALL_X_L_2 = 330;
   localparam WALL_X_R_2 = MAX_X-1;
   
   localparam WALL_Y_T_3 = 190;
   localparam WALL_Y_B_3 = 200;
   localparam WALL_X_L_3 = 0;
   localparam WALL_X_R_3 = 300;
   
   localparam WALL_Y_T_4 = 245;
   localparam WALL_Y_B_4 = 255;
   localparam WALL_X_L_4 = 250;
   localparam WALL_X_R_4 = MAX_X-1;
   
   localparam WALL_Y_T_5 = 300;
   localparam WALL_Y_B_5 = 310;
   localparam WALL_X_L_5 = 0;
   localparam WALL_X_R_5 = 300;
   
   localparam WALL_Y_T_6 = 355;
   localparam WALL_Y_B_6 = 365;
   localparam WALL_X_L_6 = 300;
   localparam WALL_X_R_6 = MAX_X-1;
   
   localparam WALL_Y_T_7 = 400;
   localparam WALL_Y_B_7 = 410;
   localparam WALL_X_L_7 = 0;
   localparam WALL_X_R_7 = 300;
   //ENDLEVELS
   
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
     assign wall_rgb = 12'h000; // blue
     assign floor_rgb = 12'h090;
     assign l1_rgb = 12'hFFF; // white
     assign l2_rgb = 12'hF00; // blue
     assign l3_rgb = 12'hF30; // blue
     assign l4_rgb = 12'hF60; // blue
     assign l5_rgb = 12'hF90;// blue
     assign l6_rgb = 12'hFC0;// blue
     assign l7_rgb = 12'hFF0;// blue
     assign ball_rgb = 12'hE62;   // red, ball rgb output
     //assign ball_rgb = ball_strobe;   // red, ball rgb output
     assign bar_rgb = 12'h362; // green

   always @*
   case (rom_addr)
      4'h0: rom_x = 16'b0000000100000000; //   
      4'h1: rom_x = 16'b0000001010000000; // 
      4'h2: rom_x = 16'b0000010001000000; // 
      4'h3: rom_x = 16'b0000010010000000; // 
      4'h4: rom_x = 16'b0000001010000000; // 
      4'h5: rom_x = 16'b0000000100000000; // 
      4'h6: rom_x = 16'b0000011111000000; // 
      4'h7: rom_x = 16'b0000010101000000; //
      4'h8: rom_x = 16'b0000010101000000; //   
      4'h9: rom_x = 16'b0000010101000000; // 
      4'ha: rom_x = 16'b0000000100000000; // 
      4'hb: rom_x = 16'b0000001010000000; // 
      4'hc: rom_x = 16'b0000010001000000; // 
      4'hd: rom_x = 16'b0000010001000000; // 
      4'he: rom_x = 16'b0000010001000000; // 
      4'hf: rom_x = 16'b0000010001000000; //
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
   // pixel for floor
  //assign floor_on = (FLOOR_Y_T<=pix_y) && (pix_y<=FLOOR_Y_B);
   // levels wall on
   assign l1_on = (WALL_Y_T_1<=pix_y) && (pix_y<=WALL_Y_B_1) && (WALL_X_L_1<=pix_x) && (pix_x<=WALL_X_R_1);
   assign l2_on = (WALL_Y_T_2<=pix_y) && (pix_y<=WALL_Y_B_2) && (WALL_X_L_2<=pix_x) && (pix_x<=WALL_X_R_2);
   assign l3_on = (WALL_Y_T_3<=pix_y) && (pix_y<=WALL_Y_B_3) && (WALL_X_L_3<=pix_x) && (pix_x<=WALL_X_R_3);
   assign l4_on = (WALL_Y_T_4<=pix_y) && (pix_y<=WALL_Y_B_4) && (WALL_X_L_4<=pix_x) && (pix_x<=WALL_X_R_4);
   assign l5_on = (WALL_Y_T_5<=pix_y) && (pix_y<=WALL_Y_B_5) && (WALL_X_L_5<=pix_x) && (pix_x<=WALL_X_R_5);
   assign l6_on = (WALL_Y_T_6<=pix_y) && (pix_y<=WALL_Y_B_6) && (WALL_X_L_6<=pix_x) && (pix_x<=WALL_X_R_6);
   assign l7_on = (WALL_Y_T_7<=pix_y) && (pix_y<=WALL_Y_B_7) && (WALL_X_L_7<=pix_x) && (pix_x<=WALL_X_R_7);
  

   // boundary
   assign bar_x_l = bar_x_reg;
   assign bar_x_r = bar_x_l + BAR_X_SIZE - 1;
   // pixel within bar
   assign bar_on = (BAR_Y_T<=pix_y) && (pix_y<=BAR_Y_B) && (bar_x_l<=pix_x) && (pix_x<=bar_x_r);
   assign graph_on = l1_on | l2_on | l3_on | l4_on | l5_on | l6_on | l7_on | wall_on | floor_on | bar_on | rd_ball_on;
   
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
   assign rom_addr = pix_y[3:0] - ball_y_t[3:0];
   assign rom_col = pix_x[3:0] - ball_x_l[3:0];
   assign rom_bit = rom_x[rom_col];
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
      else if (floor_on)
            graph_rgb = floor_rgb;
      else if (l1_on)
            graph_rgb = l1_rgb;
      else if (l2_on)
            graph_rgb = l2_rgb;
      else if (l3_on)
           graph_rgb = l3_rgb;
      else if (l4_on)
           graph_rgb = l4_rgb;
      else if (l5_on)
           graph_rgb = l5_rgb;
      else if (l6_on)
          graph_rgb = l6_rgb;
      else if (l7_on)
          graph_rgb = l7_rgb;
      else
           graph_rgb = 12'h000;  // black
       
    end
endmodule
