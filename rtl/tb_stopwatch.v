
`timescale 1ns/1ps

// STOPWATCH TEST OPERATION
`define STOP    0
`define START   1
`define NORESET 0
`define RESET   1
`define NOLAP   0
`define LAP     1

module tb_stopwatch;

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


    //clkgen_10ms
    reg iCK_RUN;
    reg iCK_RST;
    wire oGEN_10MS;
    
    reg [3:0] cnt_10ms;
    
    
    //stopwatch
    reg start, stop, reset;
    reg lap_store;
    wire [25:0] lap;
    wire [3:0] lap_addr;

    
    
    clkgen_10ms         #(  //.CLK_OFFSET             (100000)      //10ms
                            .CLK_OFFSET             (100))          //100ns
                        u_clkgen_10ms(
                            .iRESETn                (presetn)
                            ,.iCLK                  (pclk)
                            ,.iCK_RUN               (iCK_RUN)
                            ,.iCK_RST               (iCK_RST)
                            ,.oGEN_10MS             (oGEN_10MS));

////////////////////////////////////////////////////////////////////////
// COUNT 10MS 
////////////////////////////////////////////////////////////////////////

 always@(posedge pclk or negedge presetn) begin
  if(!presetn) begin
      cnt_10ms <= 0;
  end
  else begin
      if(iCK_RST== 1) begin
          cnt_10ms <= 0;
      end
      else begin
          if(oGEN_10MS == 1) begin
              if(cnt_10ms == 9) begin
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
end 
////////////////////////////////////////////////////////////////////////
// END COUNT
////////////////////////////////////////////////////////////////////////
                            
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

  wire [15:0] sram_lap_addr;
  assign sram_lap_addr = lap_addr*4; 
  wire [25:0] sram_lap;
  assign sram_lap = lap;
  
  
  reg [1:0] sram_psel_d2;
  always@(posedge pclk or negedge presetn) begin
      if(!presetn) begin
          sram_psel_d2 <= 0;
      end
      else begin
          sram_psel_d2[0] <= lap_store;
          sram_psel_d2[1] <= sram_psel_d2[0];
      end
  end
  
  
    sram_rw             #(
    /*  parameter       */  .MEM_MSB_ADDR           (8'h00))
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
    



 



////////////////////////////////////////////////////////////////////////
// TEST
////////////////////////////////////////////////////////////////////////
    initial begin
        wait(presetn);                                              //  t=1000ns
        #((PERIOD*2)*10);
        
        // Initialize clock generation - 10ms
        clk_gen_10ms(0);                                            //  t=2000ns
        #((PERIOD*2)*10);
        clk_gen_10ms(1);                                            //  t=3000ns
        #((PERIOD*2)*300);
        
        // Test Operation : (START/STOP, NORESET/RESET, NOLAP/LAP)
        // Initialize stopwatch
        start_sw(`STOP, `NORESET, `NOLAP);                          //  t=33000ns
        #((PERIOD*2)*10);
        
        
        //stopwatch op
        start_sw(`START, `NORESET, `NOLAP);                         //  t=34000ns
        wait(cnt_10ms==9); 
        start_sw(`START, `NORESET, `LAP);                           //  t=93000ns
        // ##LAP_STORE = 1                                          //  t=93100ns
        
        
        
        #(1000000);
        start_sw(`START, `NORESET, `LAP);                           //  t=1093100ns
        #((PERIOD*2)*10);
        start_sw(`STOP, `NORESET, `LAP);                            //  t=1094100ns
        
        
        
        /*
        start_sw(`START, `NORESET, `LAP);
        apb_write(sram_lap_addr,sram_lap,4'b1111);
        start_sw(`START, `NORESET, `NOLAP);
        
        wait(cnt_10ms==3);
        start_sw(`STOP, `NORESET, `NOLAP);
        #((PERIOD*2)*10);
        
        wait(cnt_10ms==3);
        start_sw(`START, `NORESET, `NOLAP);
        #((PERIOD*2)*10);
        
        wait(cnt_10ms==3);
        start_sw(`START, `NORESET, `LAP);
        #((PERIOD*2)*10);
        */
        #((PERIOD*2)*10);
        $stop;
    end
////////////////////////////////////////////////////////////////////////
// END TEST
////////////////////////////////////////////////////////////////////////
 

 



////////////////////////////////////////////////////////////////////////
// TASK 
////////////////////////////////////////////////////////////////////////     
    task start_sw;
        input op_start;
        input op_reset;
        input op_lap;
        begin
            start     <= op_start;
            stop      <= !op_start;
            reset     <= op_reset;
            lap_store <= 0;
            
            @(posedge pclk);
            if(op_lap == `LAP)
              lap_store <= 1;
        end
    endtask


    task clk_gen_10ms;
        input run;
        begin
            if(run) begin
              iCK_RUN <= 1;
              iCK_RST <= 0;
            end
            else begin
              iCK_RUN <= 0;
              iCK_RST <= 1;
            end
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
////////////////////////////////////////////////////////////////////////
// END TASK 
////////////////////////////////////////////////////////////////////////  

////////////////////////////////////////////////////////////////////////
// INITIALIZATION 
////////////////////////////////////////////////////////////////////////  
    initial begin
        
        presetn   <= 0;
        pclk      <= 1;
        psel      <= 0;
        penable   <= 0;
        pwrite    <= 0;
        pstrb     <= 0;
        paddr     <= 0;
        pwdata    <= 0;
        
        
        //clkgen_10ms
        iCK_RUN   <= 1;
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
////////////////////////////////////////////////////////////////////////
// END INITIALIZATION 
////////////////////////////////////////////////////////////////////////  
    
endmodule


