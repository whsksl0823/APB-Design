
module uart_my(
  input           iRESETn,
  input           iCLK,
  input           iUART_RX,
  output          oUART_TX,
  output          oAPB_WRITE,
  output          oAPB_READ,
  output  [15:0]  oAPB_ADDR,
  output  [31:0]  oAPB_WDATA,
  input           iAPB_RDATA_EN,
  input   [31:0]  iAPB_RDATA
  );
  
  parameter CLOCK_PERIOD        = 10_000_000;
  parameter BAUD_RATE           = 115_200;
  parameter BAUD_PERIOD_COUNT   = CLOCK_PERIOD / BAUD_RATE;
  parameter RX_TICK             = BAUD_PERIOD_COUNT/2;
  
  
  
  uart_rx_my      #(  .CLOCK_PERIOD 	     (10_000_000)
                      ,.BAUD_RATE         (115_200)
                      ,.BAUD_PERIOD_COUNT (CLOCK_PERIOD / BAUD_RATE))
                  u_uart_rx_my(
                      .iRESETn            (iRESETn)
                      ,.iCLK              (iCLK)
                      ,.iUART_RX          (iUART_RX)
  );
  
  /*
  uart_tx         u_uart_tx(
  
  );
  */
endmodule
