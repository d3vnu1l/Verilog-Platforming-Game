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
        
     wire [9:0] ball_x_l, ball_x_r;// ball left, right boundary
     wire [9:0] ball_y_t, ball_y_b;// ball top, bottom boundary
     reg [9:0] ball_x_reg, ball_y_reg;// reg to track left, top position
     wire [9:0] ball_x_next, ball_y_next;
     
     reg [9:0] x_delta_reg, x_delta_next;// reg to track ball speed
     reg [9:0] y_delta_reg, y_delta_next;
     //round ball
     wire [3:0] rom_addr, rom_col;
     reg [15:0]  rom_x;
     wire rom_bit;
     localparam BALL_SIZE = 16;
     //object output signals
     wire wall_on, floor_on, l1_on, l2_on, l3_on, l4_on, l5_on, l6_on, l7_on, sq_ball_on, ball_on;
     wire [11:0] wall_rgb, floor_rgb, l1_rgb, l2_rgb, l3_rgb, l4_rgb, l5_rgb, l6_rgb, l7_rgb, ball_rgb;
     
     //directional movement reg
     reg [1:0] move;
     reg moving;
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
   
   //LEVELS
   // wall left, right boundary
   reg [3:0] walls_up_velocity;
   wire [9:0] wall_y_t_1, wall_y_b_1;  //80,90
   reg [9:0] wyt1_reg ,wyb1_reg;
   localparam WALL_X_L_1 = 0;
   localparam WALL_X_R_1 = 300;
   
   wire [9:0] wall_y_t_2, wall_y_b_2; //145,135
   reg [9:0] wyt2_reg ,wyb2_reg;
   localparam WALL_X_L_2 = 330;
   localparam WALL_X_R_2 = MAX_X-1;
   
   wire [9:0] wall_y_t_3, wall_y_b_3; //190,200
   reg [9:0] wyt3_reg ,wyb3_reg;
   localparam WALL_X_L_3 = 0;
   localparam WALL_X_R_3 = 300;
   
   wire [9:0] wall_y_t_4, wall_y_b_4; //245,255
   reg [9:0] wyt4_reg ,wyb4_reg;
   localparam WALL_X_L_4 = 250;
   localparam WALL_X_R_4 = MAX_X-1;
   
   wire [9:0] wall_y_t_5, wall_y_b_5; //300,310
   reg [9:0] wyt5_reg ,wyb5_reg;
   localparam WALL_X_L_5 = 0;
   localparam WALL_X_R_5 = 300;
   
   wire [9:0] wall_y_t_6, wall_y_b_6; //355,365
   reg [9:0] wyt6_reg ,wyb6_reg;
   localparam WALL_X_L_6 = 300;
   localparam WALL_X_R_6 = MAX_X-1;
   
   wire [9:0] wall_y_t_7, wall_y_b_7; //400,410
   reg [9:0] wyt7_reg ,wyb7_reg;
   localparam WALL_X_L_7 = 0;
   localparam WALL_X_R_7 = 300;
   
   localparam WALL_SIZE_Y = 20;
   //ENDLEVELS
   
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

   always @*
   case (rom_addr)
      4'h0: rom_x = 16'b0000001110000000; //   
      4'h1: rom_x = 16'b0000010001000000; // 
      4'h2: rom_x = 16'b0000101010100000; // 
      4'h3: rom_x = 16'b0000010001000000; // 
      4'h4: rom_x = 16'b0000001110000000; // 
      4'h5: rom_x = 16'b0000000100000000; // 
      4'h6: rom_x = 16'b0000011111000000; // 
      4'h7: rom_x = 16'b0000101110100000; //
      4'h8: rom_x = 16'b0000100100010000; //   
      4'h9: rom_x = 16'b0000100100010000; // 
      4'ha: rom_x = 16'b0000000100000000; // 
      4'hb: rom_x = 16'b0000001110000000; // 
      4'hc: rom_x = 16'b0000010001000000; // 
      4'hd: rom_x = 16'b0000010001000000; // 
      4'he: rom_x = 16'b0000010001000000; // 
      4'hf: rom_x = 16'b0000110001100000; //
   endcase

   // registers
   always @(posedge clk, posedge reset)
      if (reset)
         begin
            ball_x_reg <= 30;
            ball_y_reg <= wall_y_t_1-BALL_SIZE;
            x_delta_reg <= 10'h000;
            y_delta_reg <= 10'h000;
            walls_up_velocity <=2;
             wyt1_reg<=80; wyb1_reg<=90;  //80,90
             wyt2_reg<=145; wyb2_reg<=135; //145,135
             wyt3_reg<=245; wyb3_reg<=255; //245,255
             wyt4_reg<=190; wyb4_reg<=200; //190,200
             wyt5_reg<=300; wyb5_reg<=310; //300,310
             wyt6_reg<=355; wyb6_reg<=365; //355,365
             wyt7_reg<=400; wyb7_reg<=410; //400,410
         end
      else
         begin
            ball_x_reg <= ball_x_next;
            ball_y_reg <= ball_y_next;
            x_delta_reg <= x_delta_next;
            y_delta_reg <= y_delta_next;
            
            hit_reg <= hit;
            miss_reg <= miss;
            
            wyt1_reg <= wall_y_t_1;
            wyb1_reg <= wall_y_b_1;
            
            wyt2_reg <= wall_y_t_2;
            wyb2_reg <= wall_y_b_2;
            
            wyt3_reg <= wall_y_t_3;
            wyb3_reg <= wall_y_b_3;
            
            wyt4_reg <= wall_y_t_4;
            wyb4_reg <= wall_y_b_4;
            
            wyt5_reg <= wall_y_t_5;
            wyb5_reg <= wall_y_b_5;
            
            wyt6_reg <= wall_y_t_6;
            wyb6_reg <= wall_y_b_6;
            
            wyt7_reg <= wall_y_t_7;
            wyb7_reg <= wall_y_b_7;
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
   // levels wall on
   assign l1_on = (wall_y_t_1<=pix_y) && (pix_y<=wall_y_b_1) && (WALL_X_L_1<=pix_x) && (pix_x<=WALL_X_R_1);
   assign l2_on = (wall_y_t_2<=pix_y) && (pix_y<=wall_y_b_2) && (WALL_X_L_2<=pix_x) && (pix_x<=WALL_X_R_2);
   assign l3_on = (wall_y_t_3<=pix_y) && (pix_y<=wall_y_b_3) && (WALL_X_L_3<=pix_x) && (pix_x<=WALL_X_R_3);
   assign l4_on = (wall_y_t_4<=pix_y) && (pix_y<=wall_y_b_4) && (WALL_X_L_4<=pix_x) && (pix_x<=WALL_X_R_4);
   assign l5_on = (wall_y_t_5<=pix_y) && (pix_y<=wall_y_b_5) && (WALL_X_L_5<=pix_x) && (pix_x<=WALL_X_R_5);
   assign l6_on = (wall_y_t_6<=pix_y) && (pix_y<=wall_y_b_6) && (WALL_X_L_6<=pix_x) && (pix_x<=WALL_X_R_6);
   assign l7_on = (wall_y_t_7<=pix_y) && (pix_y<=wall_y_b_7) && (WALL_X_L_7<=pix_x) && (pix_x<=WALL_X_R_7);
  

   // boundary
   assign graph_on = l1_on | l2_on | l3_on | l4_on | l5_on | l6_on | l7_on | wall_on | ball_on;
   
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
   assign ball_on = sq_ball_on & rom_bit; // pixel within ball

   //new ball position
   assign ball_x_next = (refr_tick) ? ball_x_reg+x_delta_reg : ball_x_reg ; 
   assign ball_y_next = (refr_tick) ? ball_y_reg+y_delta_reg : ball_y_reg ;
   //new bar positions
   assign wall_y_t_1 = (refr_tick) ? wyt1_reg-walls_up_velocity : wyt1_reg ; 
   assign wall_y_t_2 = (refr_tick) ? wyt2_reg-walls_up_velocity : wyt2_reg ;
   assign wall_y_t_3 = (refr_tick) ? wyt3_reg-walls_up_velocity : wyt3_reg ; 
   assign wall_y_t_4 = (refr_tick) ? wyt4_reg-walls_up_velocity : wyt4_reg ;
   assign wall_y_t_5 = (refr_tick) ? wyt5_reg-walls_up_velocity : wyt5_reg ; 
   assign wall_y_t_6 = (refr_tick) ? wyt6_reg-walls_up_velocity : wyt6_reg ;
   assign wall_y_t_7 = (refr_tick) ? wyt7_reg-walls_up_velocity : wyt7_reg ; 
   
   assign wall_y_b_1 = (refr_tick) ? wyb1_reg-walls_up_velocity : wyb1_reg ; 
   assign wall_y_b_2 = (refr_tick) ? wyb2_reg-walls_up_velocity : wyb2_reg ;
   assign wall_y_b_3 = (refr_tick) ? wyb3_reg-walls_up_velocity : wyb3_reg ; 
   assign wall_y_b_4 = (refr_tick) ? wyb4_reg-walls_up_velocity : wyb4_reg ;
   assign wall_y_b_5 = (refr_tick) ? wyb5_reg-walls_up_velocity : wyb5_reg ; 
   assign wall_y_b_6 = (refr_tick) ? wyb6_reg-walls_up_velocity : wyb6_reg ;
   assign wall_y_b_7 = (refr_tick) ? wyb7_reg-walls_up_velocity : wyb7_reg ; 
   
   always @*
   begin
      x_delta_next = x_delta_reg;
      y_delta_next = y_delta_reg;
      
      miss = 0;
      hit = 0;
      
    if (refr_tick) begin
        if(btn!=btnLast && btn!=2'b11)
            move=btn;
        if (move[1]) begin
            x_delta_next=4;
        end
        else if (move[0]) begin
            x_delta_next=-4;
        end
        btnLast = btn;
     end
   end
   
   //rgb multiplexing
   always @* begin
      if (~video_on)
         graph_rgb = 12'h000; // blank
      else if (wall_on)
            graph_rgb = wall_rgb;
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
