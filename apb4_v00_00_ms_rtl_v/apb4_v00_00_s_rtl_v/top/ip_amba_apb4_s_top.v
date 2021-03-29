/* -----------------------------------------------------------------------------------
 * Module Name  :
 * Date Created : 12:04:16 IST, 29 March, 2021 [ Monday ]
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

`include "ip_amba_apb4_s_top_defines.vh"
`include "ip_amba_apb4_s_top_parameters.vh"

module ip_amba_apb4_s_top `IP_AMBA_APB4_SLAVE_PARAM_DECL (  

    // APB Interface Side Signals
    // Global Inputs
    PCLK,
    PRESETn,
    
    // Slave Inputs
    PADDR,
    PPROT,
    PSELx,
    PENABLE,
    PWRITE,
    PWDATA,
    PSTRB,
    
    // Slave Outputs
    PREADY,
    PRDATA,
    PSLVERR

    // Memory Array Interface TODO
);

    input wire                          PCLK;
    input wire                          PRESETn;
    
    output reg                          PREADY;
    output reg   [PRDATA_width-1:0]     PRDATA;
    output reg                          PSLVERR;
    
    input wire  [PADDR_width-1:0]       PADDR;
    input wire  [3-1:0]                 PPROT;
    input wire  [PSELx_width-1:0]       PSELx;
    input wire                          PENABLE;
    input wire                          PWRITE;
    input wire  [PWDATA_width-1:0]      PWDATA;
    input wire  [PSTRB_width-1:0]       PSTRB;

    // Source Code
    
endmodule
