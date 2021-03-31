/* -----------------------------------------------------------------------------------
 * Module Name  :
 * Date Created : 15:20:14 IST, 29 March, 2021 [ Monday ]
 *
 * Author       : pxvi
 * Description  :
 * -----------------------------------------------------------------------------------

   MIT License

   Copyright (c) 2020 k-sva

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

`include "ip_amba_apb4_m_top.v"
`include "ip_amba_apb4_s_top.v"

module ip_amba_apb4_ms_integration_top;

    parameter   PRDATA_W = 32,
                PWDATA_W = 32,
                PSTRB_W = 4,
                PADDR_W = 32,
                PPROT_W = 3,
                PSELX_W = 3;
 
    parameter   WORD_LENGTH = 32,
                MEM_DEPTH = 128,
                DEV_BASE_ADDRESS = 0;

    // Interfacing Signals
    // -------------------

    wire PCLK_w;
    wire PRESETn_w;
    
    wire PREADY_w;
    wire [PRDATA_W-1:0] PRDATA_w;
    wire PSLVERR_w;
    
    wire [PADDR_W-1:0] PADDR_w;
    wire [PPROT_W-1:0] PPROT_w;
    wire [PSELX_W-1:0] PSELx_w;
    wire PENABLE_w;
    wire PWRITE_w;
    wire [PWDATA_W-1:0] PWDATA_w;
    wire [PSTRB_W-1:0] PSTRB_w;

    // Integration of the two IPs
    // --------------------------
    
    ip_amba_apb4_m_top  #(
                            .PRDATA_width(PRDATA_W),
                            .PWDATA_width(PWDATA_W),
                            .PSTRB_width(PSTRB_W),
                            .PADDR_width(PADDR_W),
                            .PSELx_width(PSELX_W)
                        )
                        master
                        (
                            // Protocol Signals
                            .PCLK(PCLK_w),
                            .PRESETn(PRESETn_w),
                            
                            .PREADY(PREADY_w),
                            .PRDATA(PRDATA_w),
                            .PSLVERR(PSLVERR_w),
                            
                            .PADDR(PADDR_w),
                            .PPROT(PPROT_w),
                            .PSELx(PSELx_w),
                            .PENABLE(PENABLE_w),
                            .PWRITE(PWRITE_w),
                            .PWDATA(PWDATA_w),
                            .PSTRB(PSTRB_w)

                            // App Interface Signals

                        );
    
    ip_amba_apb4_s_top  #(
                            .PRDATA_width(PRDATA_W),
                            .PWDATA_width(PWDATA_W),
                            .PSTRB_width(PSTRB_W),
                            .PADDR_width(PADDR_W),
                            .PSELx_width(PSELX_W),
                            .WORD_LENGTH(WORD_LENGTH),
                            .MEM_DEPTH(MEM_DEPTH),
                            .DEV_BASE_ADDRESS(DEV_BASE_ADDRESS)
                        )
                        slave
                        (
                            // Protocol Signals
                            .PCLK(PCLK_w),
                            .PRESETn(PRESETn_w),
                            
                            .PREADY(PREADY_w),
                            .PRDATA(PRDATA_w),
                            .PSLVERR(PSLVERR_w),
                            
                            .PADDR(PADDR_w),
                            .PPROT(PPROT_w),
                            .PSELx(PSELx_w),
                            .PENABLE(PENABLE_w),
                            .PWRITE(PWRITE_w),
                            .PWDATA(PWDATA_w),
                            .PSTRB(PSTRB_w)

                        );
    
    // Stimulus Generation ( And Monitoring )
    // --------------------------------------

    `ifdef TESTBENCH_STIMULUS_ENABLED



        // Dump Generation
        // ---------------

        initial
        begin
            $dumpfile( "apb_dump.vcd" );
            $dumpvars( 0,ip_amba_apb4_ms_integration_top );
        end

    `endif

endmodule
