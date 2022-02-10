`timescale 1ns/1ps
`define tpd 1

module stopwatch(
        input iPCLK,
        input iRESETn,
        input gen_10ms,
        input start, stop, reset,
        input lap_store,
        output reg [25:0] lap,
        output reg [3:0] lap_addr
);


parameter IDLE = 0;
parameter RUN = 1;
parameter STOP = 2;
parameter LT_STORE = 3;
parameter RESET = 4;

parameter MAX_SUB_SEC = 99;
parameter MAX_SEC     = 59;
parameter MAX_MIN     = 59;
parameter MAX_HOUR    = 99;

reg [1:0] return_ps;
reg [6:0] sub_sec;
reg [5:0] sec;
reg [5:0] min;
reg [6:0] hour;


////////////////////////////////////////////////////////////////////////
// LAP INPUT
////////////////////////////////////////////////////////////////////////
reg   lap_store_d1;
wire  lap_in;

always@(posedge iPCLK or negedge iRESETn) begin
    if(!iRESETn) begin
        lap_store_d1 <= 0;
    end
    else begin
        lap_store_d1 <= lap_store;
    end
end

assign lap_in = lap_store & ~lap_store_d1;

////////////////////////////////////////////////////////////////////////
// STATE DIAGRAM - NEXT STATE
////////////////////////////////////////////////////////////////////////
reg     [2:0] curr_state, next_state;

always@(*) begin
        case(curr_state)
                IDLE : begin
                        if(start) next_state <= RUN;
                        else    next_state <= IDLE;
                end

                RUN : begin
                        if(stop) next_state <= STOP;
                        else if(lap_in) next_state <= LT_STORE;
                        else next_state <= RUN;
                end

                STOP : begin
                        if(reset) next_state <= RESET;
                        else if(start) next_state <= RUN;
                        else if(lap_in) next_state <= LT_STORE;
                        else next_state <= STOP;
                end

                LT_STORE : begin
                        next_state <= return_ps ? RUN : STOP;
                end

                RESET : begin
                        next_state <= IDLE;
                end

                default : next_state <= IDLE;
        endcase
end
////////////////////////////////////////////////////////////////////////
// END STATE DIAGRAM
////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////
// STATE DIAGRAM - CURRENT STATE
////////////////////////////////////////////////////////////////////////
always@(posedge iPCLK or negedge iRESETn) begin
        if(!iRESETn) begin
                curr_state <= IDLE;
        end
        else begin
                curr_state <= next_state;
        end
end
////////////////////////////////////////////////////////////////////////
// END STATE DIAGRAM - CURRENT STATE
////////////////////////////////////////////////////////////////////////




////////////////////////////////////////////////////////////////////////
// LAP STORE - PREVIOUS STATE
////////////////////////////////////////////////////////////////////////
always@(posedge iPCLK or negedge iRESETn) begin
        if(!iRESETn) begin
                return_ps <= RUN;
        end
        else begin
                if((curr_state == RUN) & (lap_in)) begin
                        #(`tpd) return_ps <= RUN;
                end
                else if((curr_state == STOP) & (lap_in)) begin
                        #(`tpd) return_ps <= STOP;
                end
        end
end





////////////////////////////////////////////////////////////////////////
// LAP STORE - LAP ADDRESS
////////////////////////////////////////////////////////////////////////
reg [3:0] stack;
always@(posedge iPCLK or negedge iRESETn) begin
        if(!iRESETn) begin
                stack <= 0;
        end
        else begin
                if(((curr_state == RUN) | (curr_state == STOP)) & lap_in) begin
                #(`tpd);
                        if(stack == 9) begin
                                stack <= 0;
                        end
                        else begin
                                stack <= stack + 1;
                        end
                end
                else begin
                        stack <= stack;
                end
        end
end
////////////////////////////////////////////////////////////////////////
// LAP STORE - LAP ADDRESS
////////////////////////////////////////////////////////////////////////
always@(posedge iPCLK or negedge iRESETn) begin
        if(!iRESETn) begin
                lap_addr <= 0;
        end
        else begin
                if(((curr_state == RUN) | (curr_state == STOP)) & lap_in) begin
                    #(`tpd);
                    lap_addr <= stack;
                end
                else begin
                    lap_addr <= lap_addr;
                end
        end
end


////////////////////////////////////////////////////////////////////////
// LAP SOTRE - LAP SOTRE
////////////////////////////////////////////////////////////////////////

always@(posedge iPCLK or negedge iRESETn) begin
        if(!iRESETn) begin
                lap <= 0;
        end
        else begin
                if(((curr_state == RUN) | (curr_state == STOP)) & lap_in) begin
                        #(`tpd) lap <= {hour, min, sec, sub_sec};
                end
                else begin
                        lap <= lap;
                end
        end
end


////////////////////////////////////////////////////////////////////////
// TIMER
////////////////////////////////////////////////////////////////////////

// TIME COUNT - SUB-SECOND

always@(posedge iPCLK or negedge iRESETn) begin
        if(!iRESETn) begin
                sub_sec <= 0;
        end
        else begin
                if(curr_state == RESET) begin
                        sub_sec <= 0;
                end
                else begin
                        if(gen_10ms) begin
                                if((curr_state == RUN) | (curr_state == LT_STORE)) begin
                                      	 #(`tpd);
                                        if(sub_sec == MAX_SUB_SEC) begin
                                                sub_sec <= 0;
                                        end
                                        else begin
                                                sub_sec <= sub_sec + 1;
                                        end
                                end
                                else begin
                                        sub_sec <= sub_sec;
                                end
                        end
                        else begin
                                sub_sec <= sub_sec;
                        end
                end
        end
end

// TIME COUNT - SECOND


always@(posedge iPCLK or negedge iRESETn) begin
        if(!iRESETn) begin
                sec <= 0;
        end
        else begin
                if(curr_state == RESET) begin
                        sec <= 0;
                end
                else begin
                        if(gen_10ms) begin
                                if(((curr_state == RUN) | (curr_state == LT_STORE)) & sub_sec == MAX_SUB_SEC) begin
                                        #(`tpd);
                                        if(sec == MAX_SEC) begin
                                                sec <= 0;
                                        end
                                        else begin
                                                sec <= sec + 1;
                                        end
                                end
                                else begin
                                        sec <= sec;
                                end
                        end
                        else begin
                                sec <= sec;
                        end
                end
        end
end

// TIME COUNT - MINUTE


always@(posedge iPCLK or negedge iRESETn) begin
        if(!iRESETn) begin
                min <= 0;
        end
        else begin
                if(curr_state == RESET) begin
                        min <= 0;
                end
                else begin
                        if(gen_10ms) begin
                                if(((curr_state == RUN) | (curr_state == LT_STORE)) & (sec == MAX_SEC) & (sub_sec == MAX_SUB_SEC)) begin
                                        #(`tpd);
                                        if(min == MAX_MIN) begin
                                                min <= 0;
                                        end
                                        else begin
                                                min <= min + 1;
                                        end
                                end
                                else begin
                                        min <= min;
                                end
                        end
                        else begin
                                min <= min;
                        end
                end
        end
end


// TIME COUNT - HOUR 


always@(posedge iPCLK or negedge iRESETn) begin
        if(!iRESETn) begin
                hour <= 0;
        end
        else begin
                if(curr_state == RESET) begin
                        hour <= 0;
                end
                else begin
                        if(gen_10ms) begin
                                if(((curr_state == RUN) | (curr_state == LT_STORE)) & (min ==MAX_MIN) & (sec == MAX_SEC) & (sub_sec == MAX_SUB_SEC)) begin
                                        #(`tpd);
                                        if(hour == MAX_HOUR) begin
                                                hour <= 0;
                                        end
                                        else begin
                                                hour <= hour + 1;
                                        end
                                end
                                else begin
                                        hour <= hour;
                                end
                        end
                        else begin
                                hour <= hour;
                        end
                end
        end
end

endmodule
         