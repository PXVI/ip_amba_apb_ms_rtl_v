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

class apb4_md;

endclass

// Clock

`define clk_pw 10

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

initial
begin
    $display( "Stimulus generator is working" );
end

// Monitor

initial
begin
end

// Simulation End

initial
begin
    // $finish is call when the protocol interface is idle for 2000 clocks

    #3000 $finish;
end
