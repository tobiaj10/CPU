`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design Name: Tobi Ajayi
// Module Name: PC
// Project Name: Final Project
// Description: Begins implementation of a properly pipelined CPU

// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module PCreg(input [7:0] addOut, input clk, input start, output reg [7:0] pc);
    initial
        begin
            pc <= 8'b01100100;
        end
    always @ (posedge clk)
        begin
            if (start == 1) 
                begin
                    pc <= 8'b01100100;
            end
            else 
                begin
                    pc <= addOut;
            end
        end
endmodule

module IFAdder(input [7:0] pc, output reg [7:0] addOut);
    initial
        begin
            addOut <= 8'b01100100;
        end
    always @ (*)
        begin
            addOut <= pc + 8'b00000100;
        end
endmodule

module PCMemory(input [7:0] pc, output reg [31:00] pcOut);
    reg [31:00] IM [0:511];
    initial 
        begin
            IM[100] = 32'b10001100001000100000000000000000;
            IM[104] = 32'b10001100001000110000000000000100;
            IM[108] = 32'b10001100001001000000000000001000;
            IM[112] = 32'b10001100001001010000000000001100;
        end
    always @ (*)
        begin
            pcOut <= IM[pc];
        end
endmodule

module IFIDreg(input [31:00] pcOut, input clk, output reg [31:00] IFIDregOut);
    always @ (posedge clk)
        begin
            IFIDregOut <= pcOut;
    end
endmodule

module IDControl(input [31:00] IFIDregOut, input mrn, input mm2reg, input mwreg, input em2reg, input ewreg, input ewr, output reg regrt, output reg wreg, output reg m2reg, output reg wmem, output reg aluimm, output reg [3:0] aluc, output reg [1:0] fwdb, output reg [1:0] fwda);
    reg [5:0] op;
    reg [5:0] func;
    reg [4:0] rs;
    reg [4:0] rt;
    reg [4:0] rd;
    always @ (*)
        begin
            op <= IFIDregOut[31:26];
            func <= IFIDregOut[5:0];
            rd <= IFIDregOut[15:11];
            rs <= IFIDregOut[25:21];
            rt <= IFIDregOut[20:16];
            if ((ewr) && (rd != 0) && (rd == rs))
                begin
                    fwda <= 10;
                    fwdb <= 10;
            end
            else if ((ewr) && (rd != 0) && (rd == rt))
                begin
                    fwda <= 01;
                    fwdb <= 01;
            end
            else
                begin
                    fwda <= 00;
                    fwdb <= 00;
            end                
            if(op == 6'b000000) 
                begin
                    case(func)
                        6'b100000: begin
                            regrt = 0; wreg = 1; m2reg = 0; wmem = 0; aluimm = 0; aluc = 4'b0010;
                        end
                        6'b100010: begin
                            regrt = 0; wreg = 1; m2reg = 0; wmem = 0; aluimm = 0; aluc = 4'b0110;
                        end
                        6'b100100: begin
                            regrt = 0; wreg = 1; m2reg = 0; wmem = 0; aluimm = 0; aluc = 4'b0000;
                        end
                        6'b100101: begin
                            regrt = 0; wreg = 1; m2reg = 0; wmem = 0; aluimm = 0; aluc = 4'b0011;
                        end
                        6'b000000: begin
                        end
                        6'b000010: begin
                        end
                        6'b000011: begin
                        end
                        6'b001000: begin
                        end
                    endcase
               end
            else if (op == 6'b100011) 
                begin
                    regrt = 1; wreg = 1; m2reg = 1; wmem = 0; aluimm = 1; aluc = 4'b0010;
                end
        end
endmodule

module IDmux(input [31:00] IFIDregOut, input regrt, output reg [4:0] wr);
    reg [4:0] rd;
    reg [4:0] rt;
    always @ (*)
        begin
            rd <= IFIDregOut[15:11];
            rt <= IFIDregOut[20:16];
            if (regrt == 1)
                begin
                    wr <= rt;
            end
            else
                begin
                    wr <= rd;
            end
    end
endmodule

module IDmux2(input [31:00] IFIDregOut, input [4:0] qa, input [31:00] rALU, input [31:00] mrALU, input [31:00] mdo, input fwda, output reg [31:00] fqa);
    reg [31:00] qqa;
    reg [4:0] rd;
    always @ (*)
        begin
            rd <= IFIDregOut[15:11];
            if(qa)
                begin
                qqa = {27'b000000000000000000000000000,qa[4:0]};
            end
            else
                begin
                qqa = {27'b000000000000000000000000000,rd};
            end
            if (fwda == 0)
                begin
                    fqa <= qqa;
            end
            else if (fwda == 1)
                begin
                    fqa <= rALU;
            end
            else if (fwda == 2)
                begin
                    fqa <= mrALU;
            end
             else if(fwda == 3)
                begin
                    fqa <= mdo;
            end
    end  
endmodule

module IDmux3(input [31:00] IFIDregOut, input [4:0] qb, input [31:00] rALU, input [31:00] mrALU, input [31:00] mdo, input fwdb, output reg [31:00] fqb);
    reg [31:00] qqb;
    reg [4:0] rt;
    always @ (*)
        begin
            rt <= IFIDregOut[20:16];
            if(qb)
                begin
                    qqb = {27'b000000000000000000000000000,qb[4:0]};
            end
            else
                begin
                    qqb = {27'b000000000000000000000000000,rt};
            end
            if (fwdb == 0)
                begin
                    fqb <= qqb;
            end
            else if (fwdb == 1)
                begin
                    fqb <= rALU;
            end
            else if (fwdb == 2)
                begin
                    fqb <= mrALU;
            end
             else if(fwdb == 3)
                begin
                    fqb <= mdo;
            end
    end  
endmodule

module IDsignExt(input [31:00] IFIDregOut, output reg [31:00] extend);
    always @ (*)
        begin
            extend[31:00] = {15'b000000000000000,IFIDregOut[15:00]};
    end  
endmodule

module IDEXEreg(input clk, input wreg, input m2reg, input wmem, input [3:0] aluc, input aluimm, input [4:0] wr, input [31:00] fqa, input [4:0] fqb, input [31:00] extend, output reg ewreg, output reg em2reg, output reg ewmem, output reg [3:0] ealuc, output reg ealuimm, output reg [4:0] ewr, output reg [4:0] eqa, output reg [4:0] eqb, output reg [31:00] eextend);
    always @ (posedge clk)
            begin
                ewreg <= wreg;
                em2reg <= m2reg;
                ewmem <= wmem;
                ealuc <= aluc;
                ealuimm <= aluimm;
                ewr <= wr;
                eqa <= fqa;
                eqb <= fqb;
                eextend <= extend;
        end
endmodule

module EXEmux(input [31:00] eqb, input [31:00] eextend, input ealuimm, output reg [31:00] bALU);
    always @ (*)
        begin
            if (ealuimm == 1)
                begin
                    bALU <= eextend;
            end
            else
                begin
                    bALU <= eqb;
            end
        end
endmodule

module EXEaluc(input [31:00] eqa, input [31:00] bALU, input [3:0] ealuc, output reg [31:00] rALU);
    reg [31:00] aALU;
    always @ (*)
        begin
            aALU <= eqa;
            //0000 = And
            if (ealuc == 4'b0000)
                begin
                    rALU <= aALU & bALU;
            end
            //0001 = Or
            else if (ealuc == 4'b0001)
                begin
                    rALU <= aALU | bALU;
            end
            //0010 = Add
            else if (ealuc == 4'b0010)
                begin
                    rALU <= aALU + bALU;
            end
            //0110 = Subtract
            else if (ealuc == 4'b0010)
                begin
                    rALU <= aALU - bALU;
            end
            //0111 = Set-on-less-than
            else if (ealuc == 4'b0010)
                begin
                    rALU <= aALU < bALU;
            end
            //1100 = NOR
            else if (ealuc == 4'b0010)
                begin
                    rALU <= ~(aALU | bALU);
            end
        end
endmodule

module EXEMEMreg(input clk, input ewreg, input em2reg, input ewmem, input [4:0] ewr, input [31:00] eqb, input [31:00] rALU, output reg mwreg, output reg mm2reg, output reg mwmem, output reg [4:0] mwr, output reg [31:00] mqb, output reg [31:00] mrALU);
    always @ (posedge clk)
            begin
                mwreg <= ewreg;
                mm2reg <= em2reg;
                mwmem <= ewmem;
                mwr <= ewr;
                mqb <= eqb;
                mrALU <= (rALU - 1'b1);
        end
endmodule

module MEMdata(input mwmem, input [31:00] mrALU, input [31:00] mqb, output reg [31:00] mdo);
    reg [31:00] di;
    reg [31:00] dm [128:000];
    initial
        begin
            dm[0] = 'h00000000;
            dm[4] = 'hA00000AA;
            dm[8] = 'h10000011;
            dm[12] = 'h20000022;
            dm[16] = 'h30000033;
            dm[20] = 'h40000044;
            dm[24] = 'h50000055;
            dm[28] = 'h60000066;
            dm[32] = 'h70000077;
            dm[36] = 'h80000088;
            dm[40] = 'h90000099;
    end
    always @ (*)
        begin
            di <= mqb;
            if (mwmem == 0)
                begin
                    mdo <= dm[mrALU];
            end
            mdo <= dm[mrALU];
            if (mwmem == 1)
                begin
                    dm[di] = dm[mrALU];
            end
    end
endmodule

module MEMWBreg(input clk, input mwreg, input mm2reg, input [4:0] mwr, input [31:00] mrALU, input [31:00] mdo, output reg wwreg, output reg wm2reg, output reg [4:0] wwr, output reg [31:00] wrALU, output reg [31:00] wdo);
    always @ (posedge clk)
            begin
                wwreg <= mwreg;
                wm2reg <= mm2reg;
                wwr <= mwr;
                wrALU <= mrALU;
                wdo <= mdo;
        end
endmodule

module WBmux(input [31:00] wrALU, input [31:00] wdo, input wm2reg, output reg [31:00] d);
    always @ (*)
        begin
            if (wm2reg == 0)
                begin
                    d <= wrALU;
            end
            else
                begin 
                    d <= wdo;
            end
    end
endmodule

module IDregFile(input clk, input wwreg, input [31:00] wrALU, input [31:00] d, input [31:00] IFIDregOut, output reg [4:0] qa, output reg [4:0] qb);
    reg [4:0] rs;
    reg [4:0] rt;
    reg [31:00] rf [31:00];
    initial
        begin
            rf[0] = 'h00000000;
            rf[1] = 'hA00000AA;
            rf[2] = 'h10000011;
            rf[3] = 'h20000022;    
            rf[4] = 'h30000033;
            rf[5] = 'h40000044;
            rf[6] = 'h50000055;
            rf[7] = 'h60000066;
            rf[8] = 'h70000077;
            rf[9] = 'h80000088;
            rf[10] = 'h90000099;
    end
    always @ (clk == 0)
        begin
            rs <= IFIDregOut[25:21];
            rt <= IFIDregOut[20:16];
            if (wwreg == 1) 
                begin
                    rf[wwreg] = d;
            end
            qa <= rs;
            qb <= rt;
    end
endmodule