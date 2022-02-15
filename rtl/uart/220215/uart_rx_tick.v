
module uart_rx_tick_my(
  input           iRESETn,
  input           iCLK,
  input           iUART_RX,
  input           iUART_RX_STOP,
  output          oUART_RX_TICK,
  output          oUART_RX_EN
  );
  
  parameter CLOCK_PERIOD        = 10_000_000;
  parameter BAUD_RATE           = 115_200;
  parameter BAUD_PERIOD_COUNT   = CLOCK_PERIOD / BAUD_RATE;
  parameter RX_TICK             = BAUD_PERIOD_COUNT/2;
  
  // UART_RX START EVENT
  reg uart_rx_d1;
  wire uart_start;
  always@(posedge iCLK or negedge iRESETn) begin
      if(!iRESETn) begin
          uart_rx_d1 <= 1;
      end
      else begin
          uart_rx_d1 <= iUART_RX;
      end
  end
  
  assign uart_start = !iUART_RX & uart_rx_d1;
  
  
  reg rx_tick_en;
   always@(posedge iCLK or negedge iRESETn) begin
      if(!iRESETn) begin
          rx_tick_en <= 0;
      end
      else begin
        	 if(uart_start) begin
        	     rx_tick_en <= 1;
      	   end
      	   else begin
      	       if(iUART_RX_STOP) begin
      	           rx_tick_en <= 0;
    	         end
    	         else begin
    	             rx_tick_en <= rx_tick_en;
  	           end
    	     end
      end
  end
  
  
  
  reg [6:0] rx_tick_cnt;
  always@(posedge iCLK or negedge iRESETn) begin
      if(!iRESETn) begin
          rx_tick_cnt <= 0;
      end
      else begin
          if(rx_tick_en) begin
              if(rx_tick_cnt == RX_TICK-1) begin
                  rx_tick_cnt <= 0;
              end
              else begin
                  rx_tick_cnt <= rx_tick_cnt + 1;
              end
          end
          else begin
              rx_tick_cnt <= 0;
          end
      end
  end
  
  reg rx_tick;  
  always@(posedge iCLK or negedge iRESETn) begin
      if(!iRESETn) begin
          rx_tick <= 0;
      end
      else begin
          if(rx_tick_cnt == RX_TICK-1) begin
              rx_tick <= 1;
          end
          else begin
              rx_tick <= 0;
          end
      end
  end
  
  assign oUART_RX_TICK  = rx_tick;
  assign oUART_RX_EN    = rx_tick_en;
endmodule