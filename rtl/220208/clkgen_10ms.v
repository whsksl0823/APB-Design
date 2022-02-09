

`timescale 1ns/10ps

module clkgen_10ms  #(
    parameter       CLK_OFFSET  = 100000)
(
    input           iRESETn,
    input           iCLK,
    input           iCK_RUN,
    input           iCK_RST,

    output          oGEN_10MS);


    reg     [16:0]  clkcnt;
    reg             gen_10ms;


    always @(posedge iCLK or negedge iRESETn) begin
        if(!iRESETn)
            clkcnt  <= 0;
        else if(iCK_RST)
            clkcnt  <= 0;
        else if(iCK_RUN)
            if(clkcnt == CLK_OFFSET-1)
                clkcnt  <= 0;
            else
                clkcnt  <= clkcnt + 1;
        else
            clkcnt  <= clkcnt;
    end

    always @(posedge iCLK or negedge iRESETn) begin
        if(!iRESETn)
            gen_10ms    <= 0;
        else if(gen_10ms)
            gen_10ms    <= 0;
        else if(clkcnt == CLK_OFFSET-1)
            gen_10ms    <= 1;
        else
            gen_10ms    <= 0;
    end

    assign  oGEN_10MS   = gen_10ms;



endmodule

