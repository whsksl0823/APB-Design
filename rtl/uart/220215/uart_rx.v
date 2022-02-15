module uart_rx_my
  #(  parameter CLOCK_PERIOD = 10_000_000,
      parameter BAUD_RATE = 115_200,
      parameter BAUD_PERIOD_COUNT = CLOCK_PERIOD / BAUD_RATE)
  (
      input           iRESETn,
      input           iCLK,
      input           iUART_RX
  );
  
 
  wire  oUART_RX_STOP;
  wire  oUART_RX_TICK;
  wire  oUART_RX_EN;
  wire  [7:0] oser2par;
  
  uart_rx_tick_my     #(  .CLOCK_PERIOD 	     (CLOCK_PERIOD)
                          ,.BAUD_RATE         (BAUD_RATE)
                          ,.BAUD_PERIOD_COUNT (BAUD_PERIOD_COUNT))
                          
                      u_uart_rx_tick_my(
        	                 .iRESETn            (iRESETn)
                          ,.iCLK              (iCLK)
                          ,.iUART_RX          (iUART_RX)
                          ,.iUART_RX_STOP     (oUART_RX_STOP)
                          ,.oUART_RX_TICK     (oUART_RX_TICK)
                          ,.oUART_RX_EN       (oUART_RX_EN));
  
  uart_rx_con_my     #(   .CLOCK_PERIOD 	     (CLOCK_PERIOD)
                          ,.BAUD_RATE         (BAUD_RATE)
                          ,.BAUD_PERIOD_COUNT (BAUD_PERIOD_COUNT))
                          
                      u_uart_rx_con_my(
  	                       .iRESETn            (iRESETn)
                          ,.iCLK              (iCLK)
                          ,.iUART_RX          (iUART_RX)
                          ,.iUART_RX_TICK     (oUART_RX_TICK)
                          ,.oUART_RX_STOP     (oUART_RX_STOP)
                          ,.oser2par          (oser2par));
  
  /*uart_rx_com_int     u_uart_rx_com_int(
  	                       .iRESETn            (iRESETn)
                          ,.iCLK              (iCLK)
                          ,.iUART_RX          (iUART_RX)
                          ,.iUART_RX_TICK     (oUART_RX_TICK)
                          ,.iUART_RX_STOP     (oUART_RX_STOP)
                          ,.iUART_RX_EN       (oUART_RX_EN)
                          ,.iser2par          (oser2par));
  */
  
  
  
  /*
  uart_rx_int       u_uart_rx_int(
  
  );
  */
endmodule