

`timescale 1ns/10ps

module spsram_256x32(   iCLK,
                        iCE,
                        iWE,
                        iADDR,
                        iDATA_WR,
                        oDATA_RD  );


    input           iCLK;
    input           iCE;
    input           iWE;
    input   [7:0]   iADDR;
    input   [31:0]  iDATA_WR;
    output  [31:0]  oDATA_RD;



    parameter   MEM_DEPTH   = 256;

    reg     [31:0]  mem[0:MEM_DEPTH-1];
    reg     [31:0]  data_rd;

    integer         i;

    initial begin
        for(i=0;i<=MEM_DEPTH-1;i=i+1) mem[i]  <= 0;
    end

    always @(posedge iCLK) begin
        if(iCE & |iWE) begin
            if(iWE) mem[iADDR][31:0]    <= iDATA_WR[31:0];
        end
    end

    always @(posedge iCLK) begin
        if(iCE)
            data_rd <= mem[iADDR];
    end

    assign  oDATA_RD    = data_rd;


endmodule
