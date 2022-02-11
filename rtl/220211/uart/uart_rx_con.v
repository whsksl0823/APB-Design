

`timescale 1ns/10ps

module uart_rx_con(
    input           iRESETn,
    input           iCLK,

    input           iUART_RX,
    input           iRX_TICK,

    output  [7:0]   oRX_DATA,
    output          oRX_DATA_EN,
    output          oRX_STOP

);



    reg     [1:0]   curr_state;
    reg     [1:0]   next_state;
    reg     [3:0]   data_cnt;
    reg     [1:0]   stop_cnt;

    reg             dly_rx_tick;
    reg     [7:0]   rx_data;
    reg             rx_data_en;
    reg             rx_stop;


    parameter       IDLE    = 2'b00,
                    START   = 2'b01,
                    DATA    = 2'b10,
                    STOP    = 2'b11;

    always @(*) begin
        case(curr_state)
            IDLE    :   if(iRX_TICK & ~iUART_RX)
                            next_state  <= START;
                        else
                            next_state  <= IDLE;
            START   :   if(iRX_TICK)
                            next_state  <= DATA;
                        else
                            next_state  <= START;
            DATA    :   if(iRX_TICK)
                            if(data_cnt == 4'd8)
                                next_state  <= STOP;
                            else
                                next_state  <= DATA;
                        else
                            next_state  <= DATA;
            STOP    :   if(iRX_TICK)
                            if(stop_cnt == 2'd1)
                                next_state  <= IDLE;
                            else
                                next_state  <= STOP;
                        else
                            next_state  <= STOP;
            default :   next_state  <= IDLE;
        endcase
    end

    always @(posedge iCLK or negedge iRESETn) begin
        if(!iRESETn)
            curr_state  <= IDLE;
        else
            curr_state  <= next_state;
    end

    always @(posedge iCLK or negedge iRESETn) begin
        if(!iRESETn)
            dly_rx_tick <= 0;
        else
            dly_rx_tick <= iRX_TICK;
    end

    always @(posedge iCLK or negedge iRESETn) begin
        if(!iRESETn)
            data_cnt    <= 0;
        else if(curr_state == DATA)
            if(dly_rx_tick)
                data_cnt    <= data_cnt + 1;
            else
                data_cnt    <= data_cnt;
        else
            data_cnt    <= 0;
    end

    always @(posedge iCLK or negedge iRESETn) begin
        if(!iRESETn)
            stop_cnt    <= 0;
        else if(curr_state == STOP)
            if(dly_rx_tick)
                stop_cnt    <= stop_cnt + 1;
            else
                stop_cnt    <= stop_cnt;
        else
            stop_cnt    <= 0;
    end

    always @(posedge iCLK or negedge iRESETn) begin
        if(!iRESETn)
            rx_data    <= 0;
        else if((curr_state == DATA) & dly_rx_tick)
            rx_data[data_cnt]  <= iUART_RX;
        else
            rx_data    <= rx_data;
    end

    always @(posedge iCLK or negedge iRESETn) begin
        if(!iRESETn)
            rx_data_en  <= 0;
        else if((curr_state == STOP) & dly_rx_tick)
            rx_data_en  <= 1;
        else
            rx_data_en  <= 0;
    end

    always @(posedge iCLK or negedge iRESETn) begin
        if(!iRESETn)
            rx_stop <= 0;
        else if((curr_state == IDLE) * dly_rx_tick)
            rx_stop <= 1;
        else
            rx_stop <= 0;
    end

    assign  oRX_DATA    = rx_data;
    assign  oRX_DATA_EN = rx_data_en;

    assign  oRX_STOP    = rx_stop;




// synopsys translate_off

    reg     [15*8-1:0]  MESSAGE;

    always @(*) begin
        case(curr_state)
            IDLE    :   MESSAGE <= "IDLE";
            START   :   MESSAGE <= "START";
            DATA    :   MESSAGE <= "DATA";
            STOP    :   MESSAGE <= "STOP";
            default :   MESSAGE = "ERROR";
        endcase
    end

// synopsys translate_on

endmodule
