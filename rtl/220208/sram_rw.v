
`timescale 1ns/10ps

module sram_rw  #(
    parameter       MEM_MSB_ADDR = 8'h01    )
(
    input           iPRESETn,
    input           iPCLK,
    input           iPSEL,
    input           iPENABLE,
    input           iPWRITE,
    input   [3:0]   iPSTRB,
    input   [15:0]  iPADDR,
    input   [31:0]  iPWDATA,
    output  [31:0]  oPRDATA,
    output          oPREADY,
    output          oPSLVERR );


    wire            mem_sel;
    wire            sram_ce;
    wire            sram_we;
    wire    [7:0]   sram_addr;
    wire    [31:0]  sram_wdata;
    wire    [31:0]  sram_rdata;

    wire    [31:0]  byte_acc;

    spsram_256x32       u_spsram_256x32(
    /*  input           */  .iCLK                   (iPCLK),
    /*  input           */  .iCE                    (sram_ce),
    /*  input           */  .iWE                    (sram_we),
    /*  input   [7:0]   */  .iADDR                  (sram_addr),
    /*  input   [31:0]  */  .iDATA_WR               (sram_wdata),
    /*  output  [31:0]  */  .oDATA_RD               (sram_rdata));


    assign  mem_sel     = (iPADDR[15:8] == MEM_MSB_ADDR) ? 1'b1 : 1'b0;

    assign  sram_ce     = mem_sel & iPSEL;
    assign  sram_we     = mem_sel & (iPSEL & iPENABLE & iPWRITE);
    assign  sram_addr   = iPADDR[7:0];
    assign  sram_wdata  = (iPSTRB == 4'b1111) ? iPWDATA : 
                                                (sram_rdata & ~byte_acc) | (iPWDATA & byte_acc);

    assign  byte_acc    = {{8{iPSTRB[3]}},{8{iPSTRB[2]}},{8{iPSTRB[1]}},{8{iPSTRB[0]}}};

    assign  oPRDATA     = sram_rdata;
    assign  oPREADY     = 1;
    assign  oPSLVERR    = 0;


endmodule

