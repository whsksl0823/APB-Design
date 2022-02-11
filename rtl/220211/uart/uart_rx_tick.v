

`timescale 1ns/10ps

module uart_rx_tick(
    input           iRESETn,
    input           iCLK,
    input           iUART_RX,
    input           iRX_STOP,
    input   [15:0]  iTICK_CNT,      //BAUD_RATE(BPS)? ??? 1BIT? ????? ??? ??, ? (1/baud_rate)/ clock period
    output          oRX_TICK
);


    reg             dly1_uart_rx;
    reg             dly2_uart_rx;
    wire            fedge_uart_rx;

    reg             tick_cnt_en;
    reg     [15:0]  tick_cnt;
    reg             rx_tick;



    always @(posedge iCLK or negedge iRESETn) begin
        if(!iRESETn) begin
            dly1_uart_rx    <= 0;
            dly2_uart_rx    <= 0;
        end
        else begin
            dly1_uart_rx    <= iUART_RX;
            dly2_uart_rx    <= dly1_uart_rx;
        end
    end

    assign  fedge_uart_rx   = !dly1_uart_rx & dly2_uart_rx;

    always @(posedge iCLK or negedge iRESETn) begin
        if(!iRESETn)
            tick_cnt_en <= 0;
        else if(fedge_uart_rx)
            tick_cnt_en <= 1;
        else if(iRX_STOP)
            tick_cnt_en <= 0;
        else
            tick_cnt_en <= tick_cnt_en;
    end

    always @(posedge iCLK or negedge iRESETn) begin
        if(!iRESETn)
            tick_cnt    <= 0;
        else if(tick_cnt_en)
            if(tick_cnt == iTICK_CNT)
                tick_cnt    <= 0;
            else
                tick_cnt    <= tick_cnt + 1;
        else
            tick_cnt    <= 0;
    end

    always @(posedge iCLK or negedge iRESETn) begin
        if(!iRESETn)
            rx_tick    <= 0;
        else if(tick_cnt == {1'b0,iTICK_CNT[15:1]})
            rx_tick    <= 1;
        else
            rx_tick    <= 0;
    end

    assign  oRX_TICK    = rx_tick;

endmodule
