
`timescale 1ns/10ps

module watch  (
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





    wire            gen_10ms;
    wire            clkgen_run;
    wire            clkgen_rst;

    wire            watch_start;
    wire            watch_stop;
    wire            watch_reset;
    wire            watch_store;
    wire    [31:0]  curr_time;
    wire    [31:0]  time_lap0;
    wire    [31:0]  time_lap1;
    wire    [31:0]  time_lap2;
    wire    [31:0]  time_lap3;
    wire    [31:0]  time_lap4;
    wire    [31:0]  time_lap5;
    wire    [31:0]  time_lap6;
    wire    [31:0]  time_lap7;
    wire    [31:0]  time_lap8;
    wire    [31:0]  time_lap9;


    clkgen_10ms         #(
    /*  parameter       */  .CLK_OFFSET         (5))
                        u_clkgen_10ms(
    /*  input           */  .iRESETn            (iPRESETn),
    /*  input           */  .iCLK               (iPCLK),
    /*  input           */  .iCK_RUN            (clkgen_run),
    /*  input           */  .iCK_RST            (clkgen_rst),
    /*  output          */  .oGEN_10MS          (gen_10ms));

    time_gen            u_time_gen(
    /*  input           */  .iRESETn            (iPRESETn),
    /*  input           */  .iCLK               (iPCLK),
    /*  input           */  .iGEN_10MS          (gen_10ms),
    /*  input           */  .iWATCH_START       (watch_start),
    /*  input           */  .iWATCH_STOP        (watch_stop),
    /*  input           */  .iWATCH_RESET       (watch_reset),
    /*  input           */  .iWATCH_STORE       (watch_store),
    /*  output          */  .oCLKGEN_RUN        (clkgen_run),
    /*  output          */  .oCLKGEN_RST        (clkgen_rst),
    /*  output  [31:0]  */  .oCURR_TIME         (curr_time),
    /*  output  [31:0]  */  .oTIME_LAP0         (time_lap0),
    /*  output  [31:0]  */  .oTIME_LAP1         (time_lap1),
    /*  output  [31:0]  */  .oTIME_LAP2         (time_lap2),
    /*  output  [31:0]  */  .oTIME_LAP3         (time_lap3),
    /*  output  [31:0]  */  .oTIME_LAP4         (time_lap4),
    /*  output  [31:0]  */  .oTIME_LAP5         (time_lap5),
    /*  output  [31:0]  */  .oTIME_LAP6         (time_lap6),
    /*  output  [31:0]  */  .oTIME_LAP7         (time_lap7),
    /*  output  [31:0]  */  .oTIME_LAP8         (time_lap8),
    /*  output  [31:0]  */  .oTIME_LAP9         (time_lap9));

    apb_inf             u_apb_inf(
    /*  input           */  .iPRESETn           (iPRESETn),
    /*  input           */  .iPCLK              (iPCLK),
    /*  input           */  .iPSEL              (iPSEL),
    /*  input           */  .iPENABLE           (iPENABLE),
    /*  input           */  .iPWRITE            (iPWRITE),
    /*  input   [3:0]   */  .iPSTRB             (iPSTRB),
    /*  input   [15:0]  */  .iPADDR             (iPADDR),
    /*  input   [31:0]  */  .iPWDATA            (iPWDATA),
    /*  output  [31:0]  */  .oPRDATA            (oPRDATA),
    /*  output          */  .oPREADY            (oPREADY),
    /*  output          */  .oPSLVERR           (oPSLVERR),
    /*  output          */  .oWATCH_START       (watch_start),
    /*  output          */  .oWATCH_STOP        (watch_stop),
    /*  output          */  .oWATCH_RESET       (watch_reset),
    /*  output          */  .oWATCH_STORE       (watch_store),
    /*  input   [31:0]  */  .iCURR_TIME         (curr_time),
    /*  input   [31:0]  */  .iTIME_LAP0         (time_lap0),
    /*  input   [31:0]  */  .iTIME_LAP1         (time_lap1),
    /*  input   [31:0]  */  .iTIME_LAP2         (time_lap2),
    /*  input   [31:0]  */  .iTIME_LAP3         (time_lap3),
    /*  input   [31:0]  */  .iTIME_LAP4         (time_lap4),
    /*  input   [31:0]  */  .iTIME_LAP5         (time_lap5),
    /*  input   [31:0]  */  .iTIME_LAP6         (time_lap6),
    /*  input   [31:0]  */  .iTIME_LAP7         (time_lap7),
    /*  input   [31:0]  */  .iTIME_LAP8         (time_lap8),
    /*  input   [31:0]  */  .iTIME_LAP9         (time_lap9));



endmodule

