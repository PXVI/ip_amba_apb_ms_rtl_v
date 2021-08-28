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
    rw_ap,
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

    input wire                          vld_ap;
    input wire                          rw_ap; // Write - 1, Read - 0
    input wire   [PADDR_width-1:0]      addr_ap;
    input wire   [PWDATA_width-1:0]     wdata_ap;
    input wire   [PSTRB_width-1:0]      wstrb_ap;
    
    output wire  [PADDR_width-1:0]      PADDR;
    output wire  [3-1:0]                PPROT;
    output wire                         PSELx;
    output wire                         PENABLE;
    output wire                         PWRITE;
    output wire  [PWDATA_width-1:0]     PWDATA;
    output wire  [PSTRB_width-1:0]      PSTRB;

    output wire                         rdy_ap;                    
    output wire  [PRDATA_width-1:0]     rdata_ap;
    output wire                         err_ap;
    
    reg                          PWRITE_r;
    reg  [PWDATA_width-1:0]      PWDATA_r;
    reg                          PENABLE_r;
    reg  [PSELx_width-1:0]       PSELx_r;
    reg  [3-1:0]                 PPROT_r;
    reg  [PSTRB_width-1:0]       PSTRB_r;
    reg  [PADDR_width-1:0]       PADDR_r;
    
    // State Names
    // -----------
    localparam  IDLE = 0,
                ACCESS = 1,
                TRANSFER = 2;

    // State Variables
    // ---------------
    reg [1:0] ps, ns;

    // Assignments
    // -----------
    assign PWRITE = PWRITE_r;
    assign PWDATA = PWDATA_r;
    assign PENABLE = PENABLE_r;
    assign PSELx = PSELx_r;
    assign PPROT = PPROT_r;
    assign PSTRB = PSTRB_r;
    assign PADDR = PADDR_r;

    assign rdy_ap = ( ps == ACCESS ) ? 1'b0 : 1'b1;
    assign rdata_ap = PRDATA;
    assign err_ap = PSLVERR;

    // State Machine
    // -------------
    always@( posedge PCLK or negedge PRESETn )
    begin
        ps <= ns;
        if( !PRESETn )
        begin
            ps <= IDLE;
        end
    end

    always@( * )
    begin
        ns = ps;
        case( ps )
            IDLE        :   begin
                                if( vld_ap && PREADY )
                                begin
                                    ns = ACCESS;
                                end
                            end
            ACCESS      :   begin
                                ns = TRANSFER;
                            end
            TRANSFER    :   begin
                                if( PREADY )
                                begin
                                    if( vld_ap )
                                    begin
                                        ns = ACCESS;
                                    end
                                    else
                                    begin
                                        ns = IDLE;
                                    end
                                end
                            end
        endcase
    end

    // Output Control
    always@( posedge PCLK or negedge PRESETn )
    begin
        PADDR_r <= PADDR_r;
        PWDATA_r <= PWDATA_r;
        PENABLE_r <= PENABLE_r;
        PWRITE_r <= PWRITE_r;
        PSTRB_r <= PSTRB_r;
        PSELx_r <= PSELx_r;

        if( !PRESETn )
        begin
            PENABLE_r <= 0;
            PSELx_r <= 0;
        end
        else
        begin
            if( ( ps == IDLE || ps == TRANSFER ) && ( ns == ACCESS ) )
            begin
                PADDR_r <= addr_ap;
                PWDATA_r <= wdata_ap;
                PWRITE_r <= rw_ap;
                PSTRB_r <= wstrb_ap;
                PSELx_r <= 1;
            end
            if( ( ps == ACCESS ) && ( ns == TRANSFER ) )
            begin
                PENABLE_r <= 1;
            end
            if( ps == TRANSFER && PREADY )
            begin
                PENABLE_r <= 0;
            end
            if( ps == TRANSFER && ns == IDLE )
            begin
                PSELx_r <= 0;
            end
        end
    end

endmodule
