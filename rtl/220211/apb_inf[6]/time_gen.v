

`timescale 1ns/10ps

module time_gen(
    input           iRESETn,
    input           iCLK,

    input           iGEN_10MS,
    input           iWATCH_START,
    input           iWATCH_STOP,
    input           iWATCH_RESET,
    input           iWATCH_STORE,

    output          oCLKGEN_RUN,
    output          oCLKGEN_RST,

    output  [31:0]  oCURR_TIME,

    output  [31:0]  oTIME_LAP0,
    output  [31:0]  oTIME_LAP1,
    output  [31:0]  oTIME_LAP2,
    output  [31:0]  oTIME_LAP3,
    output  [31:0]  oTIME_LAP4,
    output  [31:0]  oTIME_LAP5,
    output  [31:0]  oTIME_LAP6,
    output  [31:0]  oTIME_LAP7,
    output  [31:0]  oTIME_LAP8,
    output  [31:0]  oTIME_LAP9
);



    reg     [7:0]   sub_sec;
    reg     [7:0]   sec;
    reg     [7:0]   min;
    reg     [7:0]   hour;

    reg     [2:0]   curr_state;
    reg     [2:0]   next_state;
    reg     [2:0]   previous_state;

    reg     [3:0]   lap_no;
    reg     [31:0]  time_lap[9:0];

    reg             clkgen_run;
    reg             clkgen_rst;

    integer         i;


    parameter       IDLE        = 3'b000,
                    RUN         = 3'b001,
                    STOP        = 3'b010,
                    LAP_STORE   = 3'b011,
                    RESET       = 3'b100;

    parameter       MAX_SUB_SEC = 8'd100;
    parameter       MAX_SEC     = 8'd60;
    parameter       MAX_MIN     = 8'd60;
    parameter       MAX_HOUR    = 8'd100;



    always @(*) begin
        case(curr_state)
            IDLE        :   if(iWATCH_START)
                                next_state  <= RUN;
                            else
                                next_state  <= IDLE;
            RUN         :   if(iWATCH_STOP)
                                next_state  <= STOP;
                            else if(iWATCH_STORE)
                                next_state  <= LAP_STORE;
                            else
                                next_state  <= RUN;
            STOP        :   if(iWATCH_START)
                                next_state  <= RUN;
                            else if(iWATCH_STORE)
                                next_state  <= LAP_STORE;
                            else if(iWATCH_RESET)
                                next_state  <= RESET;
                            else
                                next_state  <= STOP;
            LAP_STORE   :   if(previous_state == RUN)
                                next_state  <= RUN;
                            else
                                next_state  <= STOP;
            RESET       :   next_state  <= IDLE;
            default     :   next_state  <= IDLE;
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
            previous_state  <= IDLE;
        else
            previous_state  <= curr_state;
    end

    always @(posedge iCLK or negedge iRESETn) begin
        if(!iRESETn)
            clkgen_run <= 0;
        else if((curr_state == RUN) | ((previous_state == RUN) & (curr_state == LAP_STORE)))
            clkgen_run <= 1;
        else
            clkgen_run <= 0;
    end

    always @(posedge iCLK or negedge iRESETn) begin
        if(!iRESETn)
            clkgen_rst  <= 0;
        else if(curr_state == RESET)
            clkgen_rst  <= 1;
        else
            clkgen_rst  <= 0;
    end

    always @(posedge iCLK or negedge iRESETn) begin
        if(!iRESETn)
            sub_sec <= 0;
        else if(curr_state == RESET)
            sub_sec <= 0;
        else if(((curr_state == RUN) | (curr_state == LAP_STORE)) & iGEN_10MS)
            if(sub_sec == MAX_SUB_SEC-1)
                sub_sec <= 0;
            else
                sub_sec <= sub_sec + 1;
        else
            sub_sec <= sub_sec;
    end

    always @(posedge iCLK or negedge iRESETn) begin
        if(!iRESETn)
            sec <= 0;
        else if(curr_state == RESET)
            sec <= 0;
        else if(iGEN_10MS)
            if(((curr_state == RUN) | (curr_state == LAP_STORE)) & (sub_sec == MAX_SUB_SEC-1))
                if(sec == MAX_SEC-1)
                    sec <= 0;
                else
                    sec <= sec + 1;
            else
                sec <= sec;
        else
            sec <= sec;
    end

    always @(posedge iCLK or negedge iRESETn) begin
        if(!iRESETn)
            min <= 0;
        else if(curr_state == RESET)
            min <= 0;
        else if(iGEN_10MS)
            if(((curr_state == RUN) | (curr_state == LAP_STORE)) & (sub_sec == MAX_SUB_SEC-1) & (sec == MAX_SEC-1))
                if(min == MAX_MIN-1)
                    min <= 0;
                else
                    min <= min + 1;
            else
                min <= min;
        else
            min <= min;
    end

    always @(posedge iCLK or negedge iRESETn) begin
        if(!iRESETn)
            hour <= 0;
        else if(curr_state == RESET)
            hour <= 0;
        else if(iGEN_10MS)
            if(((curr_state == RUN) | (curr_state == LAP_STORE)) & (sub_sec == MAX_SUB_SEC-1) & (sec == MAX_SEC-1) & (min == MAX_MIN-1))
                if(hour == MAX_HOUR-1)
                    hour <= 0;
                else
                    hour <= hour + 1;
            else
                hour <= hour;
        else
            hour <= hour;
    end

    always @(posedge iCLK or negedge iRESETn) begin
        if(!iRESETn)
            lap_no  <= 0;
        else if(curr_state == RESET)
            lap_no  <= 0;
        else if(curr_state == LAP_STORE)
            if(lap_no == 9)
                lap_no  <= 0;
            else
                lap_no  <= lap_no + 1;
        else
            lap_no  <= lap_no;
    end

    always @(posedge iCLK or negedge iRESETn) begin
        if(!iRESETn)
            for(i=0;i<10;i=i+1) begin
                time_lap[i] <= 0;
            end
        else if(curr_state == RESET) 
            for(i=0;i<10;i=i+1) begin
                time_lap[i] <= 0;
            end
        else if(curr_state == LAP_STORE)
            time_lap[lap_no] <= {hour,min,sec,sub_sec};
        else
            for(i=0;i<10;i=i+1) begin
                time_lap[i] <= time_lap[i];
            end
    end

    assign  oCLKGEN_RUN = clkgen_run;
    assign  oCLKGEN_RST = clkgen_rst;

    assign  oCURR_TIME  = {hour,min,sec,sub_sec};

    assign  oTIME_LAP0  = time_lap[0];
    assign  oTIME_LAP1  = time_lap[1];
    assign  oTIME_LAP2  = time_lap[2];
    assign  oTIME_LAP3  = time_lap[3];
    assign  oTIME_LAP4  = time_lap[4];
    assign  oTIME_LAP5  = time_lap[5];
    assign  oTIME_LAP6  = time_lap[6];
    assign  oTIME_LAP7  = time_lap[7];
    assign  oTIME_LAP8  = time_lap[8];
    assign  oTIME_LAP9  = time_lap[9];




// synopsys translate_off

    reg     [16*8-1:0]  MESSAGE;

    always @(*) begin
        case(curr_state)
            IDLE        :   MESSAGE <= "IDLE";
            RUN         :   MESSAGE <= "RUN";
            STOP        :   MESSAGE <= "STOP";
            LAP_STORE   :   MESSAGE <= "LAP_STORE";
            RESET       :   MESSAGE <= "RESET";
            default     :   MESSAGE <= "ERROR";
        endcase
    end

// synopsys translate_on


endmodule
