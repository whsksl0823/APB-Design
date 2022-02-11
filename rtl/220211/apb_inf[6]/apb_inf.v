

`timescale 1ns/10ps

module apb_inf(
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
    output          oPSLVERR,

    output          oWATCH_START,
    output          oWATCH_STOP,
    output          oWATCH_RESET,
    output          oWATCH_STORE,

    input   [31:0]  iCURR_TIME,
    input   [31:0]  iTIME_LAP0,
    input   [31:0]  iTIME_LAP1,
    input   [31:0]  iTIME_LAP2,
    input   [31:0]  iTIME_LAP3,
    input   [31:0]  iTIME_LAP4,
    input   [31:0]  iTIME_LAP5,
    input   [31:0]  iTIME_LAP6,
    input   [31:0]  iTIME_LAP7,
    input   [31:0]  iTIME_LAP8,
    input   [31:0]  iTIME_LAP9
);


    wire            apb_wen;
    wire            apb_ren;
    reg             watch_start;
    reg             watch_stop;
    reg             watch_reset;
    reg             watch_store;
    reg     [31:0]  prdata;


    parameter   WATCH_START = 16'h0000;
    parameter   WATCH_STOP  = 16'h0004;
    parameter   WATCH_RESET = 16'h0008;
    parameter   WATCH_STORE = 16'h000c;

    parameter   CURR_TIME   = 16'h0100;
    parameter   TIME_LAP0   = 16'h0110;
    parameter   TIME_LAP1   = 16'h0114;
    parameter   TIME_LAP2   = 16'h0118;
    parameter   TIME_LAP3   = 16'h011c;
    parameter   TIME_LAP4   = 16'h0120;
    parameter   TIME_LAP5   = 16'h0124;
    parameter   TIME_LAP6   = 16'h0128;
    parameter   TIME_LAP7   = 16'h012c;
    parameter   TIME_LAP8   = 16'h0130;
    parameter   TIME_LAP9   = 16'h0134;


    assign apb_wen = (iPSEL & iPENABLE & iPWRITE);
    assign apb_ren = (iPSEL & ~iPENABLE & ~iPWRITE);

    always @(posedge iPCLK or negedge iPRESETn) begin
        if(!iPRESETn) begin
                watch_start  <= 1'b0;
                watch_stop   <= 1'b0;
                watch_reset  <= 1'b0;
                watch_store  <= 1'b0;
        end
        else if(apb_wen) begin
            case(iPADDR)
                WATCH_START :   watch_start <= iPWDATA[0];
                WATCH_STOP  :   watch_stop  <= iPWDATA[0];
                WATCH_RESET :   watch_reset <= iPWDATA[0];
                WATCH_STORE :   watch_store <= iPWDATA[0];
                default     :   begin
                                    watch_start <= 1'b0;
                                    watch_stop  <= 1'b0;
                                    watch_reset <= 1'b0;
                                    watch_store <= 1'b0;
                                end
           endcase
        end
        else begin
            watch_start <= 1'b0;
            watch_stop  <= 1'b0;
            watch_reset <= 1'b0;
            watch_store <= 1'b0;
        end
    end

    always @(posedge iPCLK or negedge iPRESETn) begin
        if(!iPRESETn)
            prdata  <= 32'h0;
        else if(apb_ren)
            case(iPADDR)
                WATCH_START :   prdata  <= {31'b0,watch_start};
                WATCH_STOP  :   prdata  <= {31'b0,watch_stop};
                WATCH_RESET :   prdata  <= {31'b0,watch_reset};
                WATCH_STORE :   prdata  <= {31'b0,watch_store};
                CURR_TIME   :   prdata  <= iCURR_TIME;
                TIME_LAP0   :   prdata  <= iTIME_LAP0;
                TIME_LAP1   :   prdata  <= iTIME_LAP1;
                TIME_LAP2   :   prdata  <= iTIME_LAP2;
                TIME_LAP3   :   prdata  <= iTIME_LAP3;
                TIME_LAP4   :   prdata  <= iTIME_LAP4;
                TIME_LAP5   :   prdata  <= iTIME_LAP5;
                TIME_LAP6   :   prdata  <= iTIME_LAP6;
                TIME_LAP7   :   prdata  <= iTIME_LAP7;
                TIME_LAP8   :   prdata  <= iTIME_LAP8;
                TIME_LAP9   :   prdata  <= iTIME_LAP9;
                default     :   prdata  <= 32'h0;
            endcase
        else
            prdata  <= prdata;
    end


    assign  oPRDATA     = prdata;
    assign  oPREADY     = 1;
    assign  oPSLVERR    = 0;

    assign  oWATCH_START    = watch_start;
    assign  oWATCH_STOP     = watch_stop;
    assign  oWATCH_RESET    = watch_reset;
    assign  oWATCH_STORE    = watch_store;




endmodule
