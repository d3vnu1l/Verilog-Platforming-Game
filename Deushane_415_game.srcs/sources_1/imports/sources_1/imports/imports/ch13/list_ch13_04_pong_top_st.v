// Listing 13.4
module pong_top_st
   (
    input wire clk, reset, reset_clk,
    input wire ps2d, ps2c,
    output wire hsync, vsync,
    output wire [3:0] red,
    output wire [3:0] grn,
    output wire [3:0] blu,
    output wire [3:0] scr0, scr1, los0, los1,
    output wire [1:0] btn
   );

   // signal declaration
   wire [9:0] pixel_x, pixel_y;
   wire video_on, pixel_tick, clk_50m, hit, miss, graph_on, scan_done_tick;
   wire [3:0] text_on;
   reg [15:0] count_reg;
   reg [11:0] rgb_reg, rgb_next;
   wire [11:0] graph_rgb, text_rgb;
   wire point, loss;
   reg [1:0] btnreg;
   wire [7:0] scan_data;
   reg scan_last;
   reg dc;
   
   localparam backgroundColor = 12'hFB3;

   // body
   // instantiate vga sync circuit
   clk_50m_generator myclk(clk, reset_clk, clk_50m);
   // instantiate ps2 receiver
   ps2RX ps2_rx_unit(.clk(clk), .reset(reset), .rx_en(1'b1), .ps2d(ps2d), .ps2c(ps2c),
    .rx_done_tick(scan_done_tick), .dout(scan_data));
   //vga sync unit
   vga_sync vsync_unit(.clk(clk_50m), .reset(reset), .hsync(hsync), .vsync(vsync),
       .video_on(video_on), .p_tick(pixel_tick), .pixel_x(pixel_x), .pixel_y(pixel_y));
   // instantiate graphic generator
   pong_graph_st pong_grf_unit(.clk(clk_50m), .reset(reset), .video_on(video_on), 
   .btn(btn), .pix_x(pixel_x), .pix_y(pixel_y), .point(point), .loss(loss), 
   .graph_rgb(graph_rgb), .graph_on(graph_on));
   //text unit
   pong_text text_unit(.clk(clk_50m), .pix_x(pixel_x), .pix_y(pixel_y), 
    .backgroundColor(backgroundColor), .dig0(los0), .dig1(los1), .ball(), 
    .text_on(text_on), .text_rgb(text_rgb));
   //counter    
   counter score(.clk(clk_50m), .reset(reset), .d_inc(point), .d_clr(loss), .dig0(scr0), .dig1(scr1));
   counter losses(.clk(clk_50m), .reset(reset), .d_inc(loss), .d_clr(reset), .dig0(los0), .dig1(los1));

   always @(posedge scan_done_tick) 
            //decode keyboard
            case(dc)
                1'b1: begin case(scan_data)
                    8'h1C: btnreg[0] <= 0;
                    8'h23: btnreg[1] <= 0;
                endcase
                dc <= 0;
                end
                1'b0 : begin case(scan_data)
                    8'h1C: btnreg[0] <= 1;
                    8'h23: btnreg[1] <= 1;
                    8'hF0: dc <= 1;
                    endcase  
                end   
            endcase
            
   always @(posedge clk_50m)
      if (pixel_tick)
         rgb_reg <= rgb_next;
   //=======================================================
   // rgb multiplexing circuit
   //=======================================================
   always @* 
      if (~video_on)
         rgb_next <= 12'h000; // blank the edge/retrace
      else
         // display score, rule, or game over
         if (text_on[3])
            rgb_next = text_rgb;
         else if (graph_on)  // display graph
           rgb_next = graph_rgb;
         else if (text_on[2]) // display logo
           rgb_next = text_rgb;
         else
           rgb_next = backgroundColor; // black background
 
   //buttons
   assign btn[0] = btnreg[0];
   assign btn[1] = btnreg[1];

   // output   
   assign red = (video_on&&rgb_reg[11:8]) ? rgb_reg[11:8] : 4'b0000;
   assign grn = (video_on&&rgb_reg[7:4]) ? rgb_reg[7:4] : 4'b0000;
   assign blu = (video_on&&rgb_reg[3:0]) ? rgb_reg[3:0] : 4'b0000;
   
endmodule
