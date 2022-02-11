
`timescale 1ns/10ps

module tb_watch;

    reg             presetn;
    reg             pclk;
    reg             psel;
    reg             penable;
    reg             pwrite;
    reg     [3:0]   pstrb;
    reg     [15:0]  paddr;
    reg     [31:0]  pwdata;
    wire    [31:0]  prdata;
    wire            pready;
    wire            pslverr;

    parameter       PERIOD  = (1000.0/10.0)/2;


    watch               u_watch(
    /*  input           */  .iPRESETn               (presetn),
    /*  input           */  .iPCLK                  (pclk),
    /*  input           */  .iPSEL                  (psel),
    /*  input           */  .iPENABLE               (penable),
    /*  input           */  .iPWRITE                (pwrite),
    /*  input   [3:0]   */  .iPSTRB                 (pstrb),
    /*  input   [15:0]  */  .iPADDR                 (paddr),
    /*  input   [31:0]  */  .iPWDATA                (pwdata),
    /*  output  [31:0]  */  .oPRDATA                (prdata),
    /*  output          */  .oPREADY                (pready),
    /*  output          */  .oPSLVERR               (pslverr));

    apb_monitor         u_apb_monitor(
    /*  input           */  .iPRESETn               (presetn),
    /*  input           */  .iPCLK                  (pclk),
    /*  input           */  .iPSEL                  (psel),
    /*  input           */  .iPENABLE               (penable),
    /*  input           */  .iPWRITE                (pwrite),
    /*  input   [3:0]   */  .iPSTRB                 (pstrb),
    /*  input   [15:0]  */  .iPADDR                 (paddr),
    /*  input   [31:0]  */  .iPWDATA                (pwdata),
    /*  input   [31:0]  */  .iPRDATA                (prdata),
    /*  input           */  .iPREADY                (pready),
    /*  input           */  .iPSLVERR               (pslverr));


    initial begin
        presetn <= 0;
        pclk    <= 0;
        psel    <= 0;
        penable <= 0;
        pwrite  <= 0;
        pstrb   <= 0;
        paddr   <= 0;
        pwdata  <= 0;
    end


    initial begin
        #(1000)
        presetn <= 1;
    end

    always #(PERIOD) begin
        pclk    <= ~pclk;
    end

    initial begin
        wait(presetn);
        wait(10000);
        apb_write(16'h0000,32'h00000001,4'b1111);
        #(10000000)
        apb_write(16'h0004,32'h00000001,4'b1111);
        #(100000)
        apb_write(16'h0008,32'h00000001,4'b1111);
        #(100000)

        apb_write(16'h0000,32'h00000001,4'b1111);
        #(100000)
        apb_write(16'h000c,32'h00000001,4'b1111);
        #(100100)
        apb_write(16'h000c,32'h00000001,4'b1111);
        #(100100)
        apb_write(16'h000c,32'h00000001,4'b1111);
        #(100100)
        apb_write(16'h000c,32'h00000001,4'b1111);
        #(100100)
        apb_write(16'h000c,32'h00000001,4'b1111);
        #(100100)
        apb_write(16'h000c,32'h00000001,4'b1111);
        #(100100)
        apb_write(16'h000c,32'h00000001,4'b1111);
        #(100100)
        apb_write(16'h000c,32'h00000001,4'b1111);
        #(100100)
        apb_write(16'h000c,32'h00000001,4'b1111);
        #(100100)
        apb_write(16'h000c,32'h00000001,4'b1111);
        #(100100)
        apb_write(16'h000c,32'h00000001,4'b1111);
        #(100100)
        apb_read(16'h0110);
        apb_read(16'h0114);
        apb_read(16'h0118);
        apb_read(16'h011c);
        apb_read(16'h0120);
        apb_read(16'h0124);
        apb_read(16'h0128);
        apb_read(16'h012c);
        apb_read(16'h0130);
        apb_read(16'h0134);
        #(100000)
        apb_read(16'h0100);
        #(100000)
        apb_write(16'h0004,32'h00000001,4'b1111);
        apb_write(16'h0008,32'h00000001,4'b1111);
        #(1000000)
        //$finish;
        $stop;
    end




    task apb_write;
        input   [15:0]  ts_addr;
        input   [31:0]  ts_wdata;
        input   [3:0]   ts_pstrb;

        begin
            //$display("APB Write Operation");
            @(posedge pclk) psel    <= 1;
                            pwrite  <= 1;
                            paddr   <= ts_addr;
                            pwdata  <= ts_wdata;
                            pstrb   <= ts_pstrb;
            @(posedge pclk) penable <= 1;
            @(posedge pclk)
            while(!pready)  @(posedge pclk);
            psel    <= 0;
            penable <= 0;
        end
    endtask

    task apb_read;
        input   [15:0]  ts_addr;

        begin
            //$display("APB Read Operation");
            @(posedge pclk) psel    <= 1;
                            pwrite  <= 0;
                            paddr   <= ts_addr;
            @(posedge pclk) penable <= 1;
            @(posedge pclk)
            while(!pready)  @(posedge pclk);
            psel    <= 0;
            penable <= 0;
        end
    endtask


endmodule
