
`timescale 1ns/10ps

module apb_monitor(

    input           iPRESETn,
    input           iPCLK,
    input           iPSEL,
    input           iPENABLE,
    input           iPWRITE,
    input   [3:0]   iPSTRB,
    input   [15:0]  iPADDR,
    input   [31:0]  iPWDATA,
    input   [31:0]  iPRDATA,
    input           iPREADY,
    input           iPSLVERR 

);

    wire            apb_wen;
    wire            apb_ren;

    integer         i;


    assign apb_wen = (iPSEL & iPENABLE & iPWRITE);
    assign apb_ren = (iPSEL & iPENABLE & ~iPWRITE);


    always @(posedge iPCLK or negedge iPRESETn) begin
        if(apb_wen & iPREADY)
            if(iPSLVERR) begin
                $display("APB Write Error");
                $display("Slave Error is asserted");
            end
            else begin
                $write("[APB WR] Address = %4h    Data = ",iPADDR);
                for(i=3;i>=0;i=i-1) begin
                    if(iPSTRB[i])
                        $write("%2h",iPWDATA[8*(i+1)-1 -: 8]);
                        //$write("%2h",iPWDATA[31:24]);
                    else
                        $write("--");
                end
                $write("\n");
            end
    end

    always @(posedge iPCLK or negedge iPRESETn) begin
        if(apb_ren & iPREADY)
            if(iPSLVERR) begin
                $display("APB Read Error");
                $display("Slave Error is asserted");
            end
            else begin
                $display("[APB RD] Address = %4h    Data = %8h",iPADDR, iPRDATA);
            end
    end

endmodule
