
`timescale 1ns/10ps

module tb_sram_rw;

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


    sram_rw             #(
    /*  parameter       */  .MEM_MSB_ADDR           (8'h01))
                        u_sram_rw(
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

    //clkgen_10ms
    reg iCK_RUN;
    reg iCK_RST;
    wire oGEN_10MS;
    
    //stopwatch
    reg start, stop, reset;
    reg lap_store;

    clkgen_10ms         #(  .CLK_OFFSET             (100000)) u_clkgen_10ms(
                            .iRESETn                (presetn)
                            ,.iCLK                  (pclk)
                            ,.iCK_RUN               (iCK_RUN)
                            ,.iCK_RST               (iCK_RST)
                            ,.oGEN_10MS             (oGEN_10MS));
                            
    stopwatch           u_stopwatch(
                            .iPCLK                  (pclk)
                            ,.iRESETn               (presetn)
                            ,.gen_10ms              (oGEN_10MS)
                            ,.start                 (start)
                            ,.stop                  (stop)
                            ,.reset                 (reset)
                            ,.lap_store             (lap_store)
                            ,.lap                   (lap)
                            ,.lap_addr              (lap_addr));

    initial begin
        presetn   <= 0;
        pclk      <= 0;
        psel      <= 0;
        penable   <= 0;
        pwrite    <= 0;
        pstrb     <= 0;
        paddr     <= 0;
        pwdata    <= 0;
        
        //clkgen_10ms
        iCK_RUN   <= 0;
        iCK_RST   <= 0;
        
        //stopwatch
        start     <= 0;
        stop      <= 0;
        reset     <= 0;
        lap_store <= 0;
    end


    initial begin
        #(1000)
        presetn <= 1;
    end

    always #(PERIOD) begin
        pclk    <= ~pclk;
    end


    reg [31:0] cnt_10ms;
    always@(posedge pclk or negedge presetn) begin
      if(!presetn) begin
        cnt_10ms <= 0;
      end
      else begin
        if(oGEN_10MS == 1) begin
            if(cnt_10ms == 5) begin
                cnt_10ms <= 0;
            end
            else begin
              cnt_10ms <= cnt_10ms + 1;
            end
        end
       	else begin
          cnt_10ms <= cnt_10ms;
        end
      end
    end
    
    always@(posedge pclk or negedge presetn) begin
      if(!presetn) begin
        lap_store <= 0;
      end
      else begin
        if(cnt_10ms == 5) begin
          lap_store <= 1;
        end
        else begin
          lap_store <= 0;
        end
      end
    end
    
    
    
    initial begin
        wait(presetn);
        wait(100);
        clk_gen_10ms(1);
        
        //stopwatch op
        start <= 1;
        
//        apb_write(16'h1000,32'h12345678,4'b1111);
//        apb_write(16'h1004,32'hffffffff,4'b1111);
//        apb_write(16'h1008,32'h11111111,4'b1111);
//        apb_write(16'h100a,32'haaaaaaaa,4'b1111);
//        apb_write(16'h1010,32'h55555555,4'b1111);
//        apb_write(16'h1014,32'haaaa5555,4'b1111);
//        apb_write(16'h1018,32'h5555aaaa,4'b1111);
//        apb_read(16'h1000);
//        apb_read(16'h1004);
//        apb_read(16'h1008);
//        apb_read(16'h100a);
//        apb_read(16'h1010);
//        apb_read(16'h1014);
//        apb_read(16'h1018);

//        apb_write(16'h10f0,32'h12345678,4'b1111);
//        apb_write(16'h10f0,32'hffffffff,4'b0010);
//        apb_read(16'h10f0);
        #(1000)
        //$finish;
        wait(lap_addr);
        $stop;
    end

    task clk_gen_10ms;
        input run;
        begin
            if(run)
              iCK_RUN <= 1;
            else
              iCK_RUN <= 0;
        end
    endtask


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

