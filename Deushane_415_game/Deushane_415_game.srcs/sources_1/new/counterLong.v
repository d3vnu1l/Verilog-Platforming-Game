// Listing 14.8
module counterLong
   (
    input wire clk, reset,
    input wire d_inc, d_clr,
    output wire [31:0] dig
   );

   // signal declaration
   reg [31:0] dig_reg, dig_next;

   // registers
   always @(posedge clk, posedge reset)
      if (reset)
         begin
            dig_reg <= 0;
         end
      else
         begin
            dig_reg <= dig_next;
         end

   // next-state logic
   always @*
   begin
      dig_next = dig_reg;
      if (d_clr)
         begin
            dig_next = 0;
         end
      else if (d_inc)
         if (dig_reg== 2147483647)
            begin
               dig_next = 0;
            end
         else  // dig0 not 9
            dig_next = dig_reg + 1;
   end
   // output
   assign dig = dig_reg;

endmodule
