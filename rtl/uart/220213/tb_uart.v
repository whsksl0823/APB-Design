
`timescale 1ns/10ps

module tb_uart;

    reg             resetn;
    reg             clk;

    reg             uart_tx;
    wire            uart_rx;


    parameter       PERIOD  = (1000.0/10.0)/2;

    integer         baud_period;


//    assign  uart_rx = uart_tx;

    initial begin
        resetn  <= 0;
        clk     <= 0;
        uart_tx <= 1;
    end


    initial begin
        #(1000)
        resetn <= 1;
    end

    always #(PERIOD) begin
        clk    <= ~clk;
    end



    uart                u_uart(
    /*  input           */  .iRESETn                (resetn),
    /*  input           */  .iCLK                   (clk),
    /*  input           */  .iUART_RX               (uart_tx),
    /*  output          */  .oUART_TX               (uart_rx),
    /*  output          */  .oAPB_WRITE				(),
    /*  output          */  .oAPB_READ				(),
    /*  output  [15:0]  */  .oAPB_ADDR				(),
    /*  output  [31:0]  */  .oAPB_WDATA				(),
    /*  input           */  .iAPB_RDATA_EN          (1'b0),
    /*  input   [31:0]  */  .iAPB_RDATA             (32'b0));



    initial begin
        wait(resetn);
        repeat (10) @(posedge clk);
        baud_period = 1000000000/115200;
        transmit("w 1234 5a5a5a5a");
        transmit("w 4321 a5a5a5a5");
        transmit("r f000");
        transmit("r f004");
        #(5000000)
        $stop;
    end

    initial begin
        wait(resetn);
        repeat (10) @(posedge clk);
        while(1) receive;
    end

    task transmit;
        input   [8*15-1:0]  data;

        begin
            if((data[8*15-1 -: 8] == "w") | (data[8*15-1 -: 8] == "W") | (data[8*15-1 -: 8] == "s") | (data[8*15-1 -: 8] == "S")) begin
                uart_txd(data[8*15-1 -: 8]);
                uart_txd(data[8*14-1 -: 8]);
                uart_txd(data[8*13-1 -: 8]);
                uart_txd(data[8*12-1 -: 8]);
                uart_txd(data[8*11-1 -: 8]);
                uart_txd(data[8*10-1 -: 8]);
                uart_txd(data[8*9-1  -: 8]);
                uart_txd(data[8*8-1  -: 8]);
                uart_txd(data[8*7-1  -: 8]);
                uart_txd(data[8*6-1  -: 8]);
                uart_txd(data[8*5-1  -: 8]);
                uart_txd(data[8*4-1  -: 8]);
                uart_txd(data[8*3-1  -: 8]);
                uart_txd(data[8*2-1  -: 8]);
                uart_txd(data[8*1-1  -: 8]);
                uart_txd(8'h0a);
            end
            else if((data[8*6-1 -: 8] == "r") | (data[8*6-1 -: 8] == "R")) begin
                uart_txd(data[8*6-1 -: 8]);
                uart_txd(data[8*5-1 -: 8]);
                uart_txd(data[8*4-1 -: 8]);
                uart_txd(data[8*3-1 -: 8]);
                uart_txd(data[8*2-1 -: 8]);
                uart_txd(data[8*1-1 -: 8]);
                uart_txd(8'h0a);
            end
            else
                $display("Transmit Parameter Error");
        end
    endtask

    task uart_txd;
        input   [7:0]   data;

        begin
            uart_tx = 1;
            #(baud_period);
            uart_tx = 0;
            #(baud_period);
            uart_tx = data[0];
            #(baud_period);
            uart_tx = data[1];
            #(baud_period);
            uart_tx = data[2];
            #(baud_period);
            uart_tx = data[3];
            #(baud_period);
            uart_tx = data[4];
            #(baud_period);
            uart_tx = data[5];
            #(baud_period);
            uart_tx = data[6];
            #(baud_period);
            uart_tx = data[7];
            #(baud_period);
            uart_tx = 1;
            #(baud_period);
        end
    endtask


    task receive;
        reg     [7:0]   rx_data;
        begin
            @(negedge uart_rx);
            #(baud_period/2);
            #(baud_period);
            rx_data[0]  = uart_rx;
            #(baud_period);
            rx_data[1]  = uart_rx;
            #(baud_period);
            rx_data[2]  = uart_rx;
            #(baud_period);
            rx_data[3]  = uart_rx;
            #(baud_period);
            rx_data[4]  = uart_rx;
            #(baud_period);
            rx_data[5]  = uart_rx;
            #(baud_period);
            rx_data[6]  = uart_rx;
            #(baud_period);
            rx_data[7]  = uart_rx;
            #(baud_period);
            $write("%c",rx_data);
        end
    endtask

endmodule

