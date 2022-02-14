
module uart_rx_con_my
  #(  parameter CLOCK_PERIOD = 10_000_000,
      parameter BAUD_RATE = 115_200,
      parameter BAUD_PERIOD_COUNT = CLOCK_PERIOD / BAUD_RATE)
  (
      input             iRESETn,
      input             iCLK,
      input             iUART_RX,
      input             iUART_RX_TICK,
      output  reg       oUART_RX_STOP,
      output  reg [7:0] oser2par
  );
  
    
  //////////////////////////////////////////////////////////
  // STATE DIAGRAM
  //////////////////////////////////////////////////////////
  parameter IDLE  = 0;
  parameter START = 1;
  parameter DATA  = 2;
  parameter STOP  = 3; 
  
  reg [1:0] curr_state, next_state;
  reg [6:0] rx_cnt_period;
  reg [2:0] rx_cnt_byte;
  
  //CURRENT STATE
  always@(*) begin
      case(curr_state)
          IDLE : begin
              if(iUART_RX_TICK == 1) begin
                  next_state <= START;
              end
              else begin
                  next_state <= IDLE;
              end
          end
          
          START : begin
              next_state <= DATA;
          end
          
          DATA : begin
              if(rx_cnt_byte == 7) begin
                  if(rx_cnt_period == BAUD_PERIOD_COUNT-1) begin
                      next_state <= STOP;
                  end
                  else begin
                      next_state <= DATA;
                  end
              end
              else begin
                  next_state <= DATA;
              end
          end
          
          STOP : begin
              next_state <= IDLE;
          end
          
          default : next_state <= IDLE;
      endcase
  end
  
  //NEXT STATE
  always@(posedge iCLK or negedge iRESETn) begin
      if(!iRESETn) begin
          curr_state <= IDLE;
      end
      else begin
          curr_state <= next_state;
      end
  end
  //////////////////////////////////////////////////////////
  // END STATE DIAGRAM
  //////////////////////////////////////////////////////////
  
  
  
  
  
  //////////////////////////////////////////////////////////
  // Count RX Period
  //////////////////////////////////////////////////////////
  always@(posedge iCLK or negedge iRESETn) begin
      if(!iRESETn) begin
          rx_cnt_period <= 0;
      end
      else begin
          if(curr_state == DATA) begin
              if(rx_cnt_period == BAUD_PERIOD_COUNT-1) begin
                  rx_cnt_period <= 0;
              end
              else begin
                  rx_cnt_period <= rx_cnt_period + 1;
              end
          end
          else begin
              rx_cnt_period <= 0;
          end
      end
  end
  //////////////////////////////////////////////////////////
  // END Count RX Period
  //////////////////////////////////////////////////////////
  
  //////////////////////////////////////////////////////////
  // Count RX BYTE
  //////////////////////////////////////////////////////////
  always@(posedge iCLK or negedge iRESETn) begin
      if(!iRESETn) begin
          rx_cnt_byte <= 0;
      end
      else begin
          if(curr_state == DATA) begin
              if(rx_cnt_period == BAUD_PERIOD_COUNT-1) begin
                  if(rx_cnt_byte == 7) begin
                      rx_cnt_byte <= 0;
                  end
                  else begin
                      rx_cnt_byte <= rx_cnt_byte + 1;
                  end
              end
              else begin
                  rx_cnt_byte <= rx_cnt_byte;
              end
          end
          else begin
              rx_cnt_byte <= 0;
          end
      end
  end
  //////////////////////////////////////////////////////////
  // END Count RX BYTE
  //////////////////////////////////////////////////////////
  
  
  //////////////////////////////////////////////////////////
  // RX STOP Flag
  //////////////////////////////////////////////////////////
  always@(posedge iCLK or negedge iRESETn) begin
      if(!iRESETn) begin
          oUART_RX_STOP <= 0;
      end
      else begin
          if(curr_state == DATA) begin
              if(rx_cnt_byte == 7) begin
                  if(rx_cnt_period == BAUD_PERIOD_COUNT-1) begin
                      oUART_RX_STOP <= 1;
                  end
                  else begin
                      oUART_RX_STOP <= 0;
                  end
              end
              else begin
                  oUART_RX_STOP <= 0;
              end
          end
        	 else begin
              oUART_RX_STOP <= 0;
          end
      end
  end
  //////////////////////////////////////////////////////////
  // END RX STOP Flag
  //////////////////////////////////////////////////////////
  
  
  //////////////////////////////////////////////////////////
  // Serial to Parallel
  //////////////////////////////////////////////////////////
  always@(posedge iCLK or negedge iRESETn) begin
      if(!iRESETn) begin
          oser2par <= 0;
      end
      else begin
          if(curr_state == DATA) begin
            if(rx_cnt_period == BAUD_PERIOD_COUNT-1) begin
                //oser2par <= (oser2par | (iUART_RX << (7-rx_cnt_byte)));
                oser2par <= (oser2par | (iUART_RX << rx_cnt_byte));
            end
            else begin
                oser2par <= oser2par;
            end
          end
          else begin
              oser2par <= 0;
          end
      end
  end
  //////////////////////////////////////////////////////////
  // END Serial to Parallel
  //////////////////////////////////////////////////////////
endmodule