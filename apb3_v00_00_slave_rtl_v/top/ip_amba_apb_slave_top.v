/* -----------------------------------------------------------------------------------
 * Module Name  :
 * Date Created : 10:27:43 IS, 14 January, 2020 [ Tuesday ] 
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

`include "ip_amba_apb_slave_top_defines.vh"
`include "ip_amba_apb_slave_top_parameters.vh"

// ++++++++++++++++++
// Module Description
// ++++++++++++++++++
// This primarily is an APB3 Compliant Slave.
// Additionally, this slave acts like a simple memory storage device.
// The depth and the Work Length are decided by the passed parameters.
// Features :
// - Provided a base_address register which makes the data access to memory array in terms of offset.
//   This provides the advantage of, being able to access the memory space with respect to the address rogrammed in the 'h0 register location rather than using memory offsets directly on the address bus.
//   After reset, the default base_address register value is 'b1
// - PSLVERR is triggered for any address out of bounds errors in terms of base_address register.
//
// + RLT Tested Againt A Stable VIP. Bug Free as of 14 January, 2020 [11:25:38 AM IST]
// ++++++++++++++++++

module ip_amba_apb_slave_top `IP_AMBA_APB_SLAVE_PARAM_DECL (  

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

    // Memory Array Pins
    // TODO : Need to add external memory interfacing access
    //        This is needed because the internally declared memory cannot be always symmetrical in architecture. Plus external memory design will give a better control over it's instantiation wherever needed.
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

    // Memory Array Declaration
    // ------------------------
    reg [WORD_LENGTH-1:0] mem_arr[2**MEM_DEPTH];

    // Internal Programmable Register Declaration.
    // This will become the base addresss for DATA Access.
    // In short this will act as the lower address boundary of the module.
    // Accesses which are out of bounds will result in a PSLVERR.
    // ------------------------------------------
    reg [PWDATA_width-1:0]               base_address;

    // Synchronous Read/Write Block For APB
    // ------------------------------------
    always@( posedge PCLK or negedge PRESETn )
    begin
        mem_arr <= mem_arr;
        PRDATA <= PRDATA;
        PREADY <= PREADY;
        PSLVERR <= 1'b0;

        if( !PRESETn )
        begin
            //reset_task(); // TODO : Need to look for an alternative
            PRDATA <= {PRDATA_width{1'b0}};
            PREADY <= 1'b0;
            PSLVERR <= 1'b0;

            // Setting the Default Base Address Value to 'h1
            base_address <= {PWDATA_width{ 1'b0 }};
            base_address[0] <= 1'b1;
        end
        else
        begin
            if( PSELx[0] && !PREADY && !PENABLE && ( ( PADDR < base_address )|| ( PADDR > ( base_address + 2**MEM_DEPTH - 1'b1 ) ) ) )
            begin
                PSLVERR <= 1'b1;
                PRDATA <= {PRDATA_width{1'b0}};
                PREADY <= 1'b1;
            end
            else if( PSELx[0]&& !PWRITE )
            begin
                if( !PREADY && !PENABLE )
                begin
                    PRDATA <= mem_arr[(PADDR-base_address)/PSTRB_width];                          
                    PREADY <= 1'b1;
                end
                else if( PREADY && PENABLE )
                begin
                    PREADY <= 1'b0;
                end
            end
            else if( PSELx[0] && PWRITE )
            begin
                if( PREADY && PENABLE )
                begin
                    int i;

                    if( ( PADDR / PSTRB_width ) == {PWDATA_width{ 1'b0 }} )
                    begin
                        for( i = 0; i < PSTRB_width; i++ )
                        begin
                            if( PSTRB[i] )
                            begin
                                base_address[(i*8)+:8] <= PWDATA[(i*8)+:8];
                            end
                        end
                    end
                    else
                    begin
                        for( i = 0; i < PSTRB_width; i++ )
                        begin
                            if( PSTRB[i] )
                            begin
                                mem_arr[(PADDR-base_address)/PSTRB_width][(i*8)+:8] <= PWDATA[(i*8)+:8];
                            end
                        end
                    end

                    PREADY <= 1'b0;
                end
                else if( !PREADY && !PENABLE )
                begin
                    PREADY <= 1'b1;
                end
            end
        end
    end


    // Memory Re-Initialize Task
    // -------------------------
    task reset_task();
        int i;

        for( i = 0; i < 2**MEM_DEPTH; i++ )
        begin
            mem_arr[i] <= {WORD_LENGTH {1'b0}};
        end
    endtask
    
endmodule
