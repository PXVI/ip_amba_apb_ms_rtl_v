/* -----------------------------------------------------------------------------------
 * Module Name  :
 * Date Created : 01:13:41 IST, 26 August, 2021 [ Thursday ]
 *
 * Author       : pxvi
 * Description  : APB4 master stimulus generator and driver
 * -----------------------------------------------------------------------------------

   MIT License

   Copyright (c) 2021 k-sva

   Permission is hereby granted, free of charge, to any person obtaining a copy
   of this software and associated documentation files (the Software), to deal
   in the Software without restriction, including without limitation the rights
   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
   copies of the Software, and to permit persons to whom the Software is
   furnished to do so, subject to the following conditions:

   The above copyright notice and this permission notice shall be included in all
   copies or substantial portions of the Software.

   THE SOFTWARE IS PROVIDED AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
   SOFTWARE.

 * ----------------------------------------------------------------------------------- */

class apb_mp;
    rand bit [PWDATA_W-1:0] wdata;
    rand bit [PRDATA_W-1:0] rdata;
    rand bit [PADDR_W-1:0] addr;
    rand bit [PSTRB_W-1:0] strb;
    bit [PSTRB_W-1:0] strb_0;
    rand bit rw;
    rand bit [31:0] before_empty_cycles;
    rand bit [31:0] after_empty_cycles;

    constraint defaults {
                            soft before_empty_cycles == 0;
                            soft after_empty_cycles == 0;
    }
endclass

// Clock

`define clk_pw 10

// Scoreboard
// ----------
bit [PWDATA_W-1:0] scb[*];

// Stimulus Signals
// ----------------
reg                    vld_ap_r;
reg   [PADDR_W-1:0]    addr_ap_r;
reg   [PWDATA_W-1:0]   wdata_ap_r;
reg   [PSTRB_W-1:0]    wstrb_ap_r;
reg                     rw_ap_r;

assign vld_ap = vld_ap_r;
assign addr_ap = addr_ap_r;
assign wdata_ap = wdata_ap_r;
assign wstrb_ap = wstrb_ap_r;
assign rw_ap = rw_ap_r;

initial
begin
    PCLK_sr <= 0;
    forever
    begin
        #(`clk_pw/2) PCLK_sr <= ~PCLK_sr;
    end
end

assign PCLK_w = PCLK_sr;
assign PRESETn_w = PRESETn_sr;

// Stimulus

task transfer( apb_mp t );
    forever
    begin
        if( rdy_ap )
            begin
            repeat( t.before_empty_cycles )
            begin
                @( negedge PCLK_w );
            end
            vld_ap_r <= 1;
            addr_ap_r <= t.addr;
            wdata_ap_r <= t.wdata;
            wstrb_ap_r <= t.strb;
            rw_ap_r <= t.rw;
            forever
            begin
                @( negedge PCLK_w );
                if( !rdy_ap )
                begin
                    if( t.rw )
                    begin
                        fork
                        begin
                            time a;
                            a = $time;
                            @( negedge PCLK_w );
                            $display( "%8d - APB4 Master App Interface Transaction Driven ( Addr : %d, Data : %d, Strobe : %d, Mode : Write )", $time, PADDR_w, PWDATA_w, PSTRB_w );
                        end
                        join_none
                    end
                    else
                    begin
                        fork
                        begin
                            time a;
                            a = $time;
                            @( negedge PCLK_w );
                            $display( "%8d - APB4 Master App Interface Transaction Registered By APB Master ( Read : %d )", a, rdata_ap );
                        end
                        join_none
                    end
                    vld_ap_r <= 0;
                    break;
                end
            end
            repeat( t.after_empty_cycles )
            begin
                @( negedge PCLK_w );
            end
            break;
        end
        else
        begin
            @( negedge PCLK_w );
        end
    end
endtask

apb_mp txn = new;

initial
begin

    $display( "%8d - Stimulus generator started", $time );

    PRESETn_sr <= 1;
    PRESETn_sr <= 0;
    repeat( 5 )
    begin
        @( negedge PCLK_w );
    end
    PRESETn_sr <= 1;
    repeat( $urandom % 10 )
    begin
        bit [PWDATA_W-1:0] ad;
        txn = new;
        txn.randomize() with { addr < MEM_DEPTH; wdata == 16; rw == 1;  };
        transfer( txn );
        ad = txn.addr;
        txn.randomize() with { addr == ad; rw == 0; };
        transfer( txn );
    end

    repeat( $urandom % 50 )
    begin
        PRESETn_sr <= 1;
        PRESETn_sr <= 0;
        repeat( 5 )
        begin
            @( negedge PCLK_w );
        end
        PRESETn_sr <= 1;
        repeat( $urandom % 100 )
        begin
            bit [PWDATA_W-1:0] ad;
            txn = new;
            txn.randomize() with { addr < MEM_DEPTH; rw == 1; };
            transfer( txn );
            ad = txn.addr;
            txn.randomize() with { addr == ad; rw == 0; };
            transfer( txn );
        end
    end
end

// Monitor

initial
begin
end

// Simulation End

initial
begin
    // $finish is call when the protocol interface is idle for 2000 clocks
    fork
    begin
        #300000;
        $display( "%8d - Manual End Test Called", $time );
    end
    begin
        int counter;
        bit psel_temp;
        psel_temp = PSELx_w;

        forever
        begin
            @( posedge PCLK_w );
            if( psel_temp === PSELx_w )
            begin
                if( counter == 100 )
                begin
                    $display( "%8d - PSELx signal did not change for over 1000 clock cycles. End test is being raised.", $time );
                    break;
                end
                else
                begin
                    counter++;
                end
            end
            else
            begin
                counter = 0;
            end
        end
    end
    join_any
    $finish;
end
