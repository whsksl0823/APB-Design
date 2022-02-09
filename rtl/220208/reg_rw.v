
`timescale 1ns/10ps

module reg_rw(

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
    output          oPSLVERR 

);


    reg     [31:0]  reg_test1;
    reg     [31:0]  reg_test2;
    reg     [31:0]  prdata;

    wire    [31:0]  byte_acc;

    parameter   REG_TEST1   = 16'h0000;
    parameter   REG_TEST2   = 16'h0004;


    assign apb_wen = (iPSEL & iPENABLE & iPWRITE);
    assign apb_ren = (iPSEL & ~iPENABLE & ~iPWRITE);

    assign byte_acc = {{8{iPSTRB[3]}},{8{iPSTRB[2]}},{8{iPSTRB[1]}},{8{iPSTRB[0]}}};

    always @(posedge iPCLK or negedge iPRESETn) begin
        if(!iPRESETn) begin
                reg_test1   <= 1'b0;
                reg_test2   <= 1'b0;
        end
        else if(apb_wen) begin
            case(iPADDR)
                REG_TEST1   :   reg_test1   <= (reg_test1 & ~byte_acc) | (iPWDATA & byte_acc);
                REG_TEST2   :   reg_test2   <= (reg_test2 & ~byte_acc) | (iPWDATA & byte_acc);
                default     :   begin
                                    reg_test1   <= reg_test1;
                                    reg_test2   <= reg_test2;
                                end
           endcase
        end
        else begin
            reg_test1   <= reg_test1;
            reg_test2   <= reg_test2;
        end
    end

    always @(posedge iPCLK or negedge iPRESETn) begin
        if(!iPRESETn)
            prdata  <= 32'h0;
        else if(apb_ren)
            case(iPADDR)
                REG_TEST1   :   prdata  <= reg_test1;
                REG_TEST2   :   prdata  <= reg_test2;
                default     :   prdata  <= 32'h0;
            endcase
        else
            prdata  <= prdata;
    end

    assign  oPRDATA     = prdata;
    assign  oPREADY     = 1;
    assign  oPSLVERR    = 0;


endmodule

