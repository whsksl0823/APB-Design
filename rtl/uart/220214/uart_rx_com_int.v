
module uart_rx_com_int(
  input           iRESETn,
  input           iCLK,
  input           iUART_RX,
  input           iUART_RX_TICK,
  input           iUART_RX_STOP,
  input           iUART_RX_EN,
  input   [7:0]   iser2par
  );
  
  parameter IDLE        = 0;
  parameter WR_COM      = 1;
  parameter RD_COM      = 2;
  parameter SPACE_CHK_0 = 3;
  parameter ADDR        = 4;
  parameter SPACE_CHK_1 = 5;
  parameter DATA        = 6;
  parameter CR_CODE     = 7;
  parameter ERROR       = 8;
  
  
  reg [3:0] curr_state, next_state;
  
  //CURRENT STATE
  always@(posedge iCLK or negedge iRESETn) begin
      if(!iRESETn) begin
          curr_state <= IDLE;
      end
      else begin
          curr_state <= next_state;
     	end
 	end
 	
  //NEXT STATE
  always@(*) begin
      case(curr_state)
          IDLE : begin
              if(iUART_RX_STOP == 1) begin
                  if(iser2par == 8'h77) begin
                      next_state <= WR_COM;
                  end
                  else if(iser2par == 8'h72) begin
                      next_state <= RD_COM;
                  end
                  else begin
                      next_state <= IDLE;
                  end
              end
          end
          
          WR_COM : begin
              if(iUART_RX_STOP == 1) begin
          end
          RD_COM : begin
              
          end
          SPACE_CHK_0 : begin
              
          end
          ADDR : begin
              
          end
          SPACE_CHK_1 : begin
              
          end
          DATA : begin
              
          end
          CR_CODE : begin
              
          end
          ERROR : begin
              
          end
          default : 
      endcase
  end
  
  
  always@(posedge iCLK or negedge iRESETn) begin
      if(!iRESETn) begin
          
      end
      else begin
          if(
     	end
  end
endmodule

