/* -----------------------------------------------------------------------------------
 * Module Name  :
 * Date Created : 12:02:16 IST, 29 March, 2021 [ Monday ]
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

`include "ip_amba_apb4_m_top_defines.vh"
`include "ip_amba_apb4_m_top_parameters.vh"

module ip_amba_apb4_m_top `IP_AMBA_APB4_MASTER_PARAM_DECL (  

    // APB Interface Side Signals
    // Global Inputs
    PCLK,
    PRESETn,
    
    // Master Inputs
    PREADY,
    PRDATA,
    PSLVERR,
    
    // Master Outputs
    PADDR,
    PPROT,
    PSELx,
    PENABLE,
    PWRITE,
    PWDATA,
    PSTRB,

    // Application Interface Signals
    rdy_ap,
    vld_ap,
    addr_ap,
    wdata_ap,
    wstrb_ap,
    rdata_ap,
    err_ap
);
    
    input wire                          PCLK;
    input wire                          PRESETn;
    
    input wire                          PREADY;
    input wire   [PRDATA_width-1:0]     PRDATA;
    input wire                          PSLVERR;
    
    output wire  [PADDR_width-1:0]      PADDR;
    output wire  [3-1:0]                PPROT;
    output wire  [PSELx_width-1:0]      PSELx;
    output wire                         PENABLE;
    output wire                         PWRITE;
    output wire  [PWDATA_width-1:0]     PWDATA;
    output wire  [PSTRB_width-1:0]      PSTRB;

    input wire                          vld_ap;
    input wire   [PADDR_width-1:0]      addr_ap;
    input wire   [PWDATA_width-1:0]     wdata_ap;
    input wire   [PSTRB_width-1:0]      wstrb_ap;

    output wire                         rdy_ap;                    
    output wire  [PRDATA_width-1:0]     rdata_ap;
    output wire                         err_ap;
    
endmodule
