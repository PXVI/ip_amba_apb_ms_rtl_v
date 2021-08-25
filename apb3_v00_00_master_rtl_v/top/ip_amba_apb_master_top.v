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

`include "ip_amba_apb_top_defines.vh"
`include "ip_amba_apb_top_parameters.vh"

module ip_amba_apb_master_top `IP_AMBA_APB_PARAM_DECL (  

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
    
    // CPU End's Control Signals
    // TODO
    // To CPU ( Outputs )
    apb_ready_for_txn,
    to_cpu_RDATA,
    to_cpu_RDATA_valid_WDATA_done,
    to_cpu_txn_err,
    to_cpu_txn_timeout,
    
    // From CPU ( Inputs )
    from_cpu_resetn,
    from_cpu_valid_txn,
    from_cpu_rd_wr,
    from_cpu_address,
    from_cpu_wr_STRB,
    from_cpu_wr_WDATA,
    from_cpu_slave_sel
);

    output wire                         apb_ready_for_txn;
    output wire   [PRDATA_width-1:0]    to_cpu_RDATA;
    output wire                         to_cpu_RDATA_valid_WDATA_done;
    output wire                         to_cpu_txn_err;
    output wire                         to_cpu_txn_timeout;
    
    input wire                          from_cpu_resetn;
    input wire                          from_cpu_valid_txn;
    input wire                          from_cpu_rd_wr;
    input wire   [PADDR_width-1:0]      from_cpu_address;
    input wire   [PSTRB_width-1:0]      from_cpu_wr_STRB;
    input wire   [PWDATA_width-1:0]     from_cpu_wr_WDATA;
    input wire                          from_cpu_slave_sel;
    
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
    
    
    
    // APB FSM States Declaration
    // --------------------------
    localparam reg [2:0]                IDLE = 3'b000,
                                        SETUP = 3'b010,
                                        ACCESS = 3'b100;
    
    // APB FSM State Variable Declaration
    // ----------------------------------
    reg [2:0]                           STATE;
    
    // Registers and Wires Declaration
    // -------------------------------
    reg  [PADDR_width-1:0]              PADDR_r;
    reg  [3-1:0]                        PPROT_r;
    reg  [PSELx_width-1:0]              PSELx_r;
    reg                                 PENABLE_r;
    reg                                 PWRITE_r;
    reg  [PWDATA_width-1:0]             PWDATA_r;
    reg  [PSTRB_width-1:0]              PSTRB_r;
    
    reg                                 apb_ready_for_txn_r;
    reg                                 to_cpu_txn_err_r;
    reg                                 to_cpu_txn_timeout_r;

    // Timeout Counter
    // ---------------
    reg  [32-1:0]                       pselx_timeout_counter_r;

    // Register Space : TODO Make this Programmable
    // --------------------------------------------
    reg  [32-1:0]                       pselx_timeout_reg;
    reg  [1-1:0]                        pselx_timeout_flag_reg;
    
    // FSM Design
    // ----------
    always@( posedge PCLK or negedge PRESETn or negedge from_cpu_resetn )
    begin : APB_FSM
        
        // Register to Register Assignment to avoid Latch formation
        PADDR_r <= PADDR_r;
        PPROT_r <= PPROT_r;
        PSELx_r <= PSELx;
        PENABLE_r <= PENABLE_r;
        PWRITE_r <= PWRITE_r;
        PWDATA_r <= PWDATA_r;
        PSTRB_r <= PSTRB_r;

        STATE <= SETUP;

        if( ~PRESETn || ~from_cpu_resetn )
        begin : RESET_STATE
            PSELx_r <= 0;
            PPROT_r <= 0;
            PENABLE_r <= 0;
            
            STATE <= IDLE;
        end : RESET_STATE
        else
        begin
            case( STATE )
                IDLE        :   begin
                                    if( from_cpu_valid_txn && from_cpu_slave_sel ) // Transaction Bus Values may or may not be latched here
                                    begin
                                        STATE <= SETUP;
                                        PADDR_r <= from_cpu_address;
                                        PPROT_r <= 0; //TODO
                                        PSELx_r <= from_cpu_slave_sel;
                                        PWRITE_r <= from_cpu_rd_wr;
                                        if( from_cpu_rd_wr )
                                        begin
                                            PWDATA_r <= from_cpu_wr_WDATA;
                                            PSTRB_r <= from_cpu_wr_STRB;
                                        end
                                        else if( !from_cpu_rd_wr )
                                        begin
                                            PSTRB_r <= 0;
                                        end
                                    end
                                end
                SETUP      :   begin // NOTE : Slave samples the DATA at the posedge of PCLK in this state while the needed sel is enabled
                                    if( from_cpu_valid_txn && from_cpu_slave_sel ) // Transaction Bus Values must be latched here
                                    begin
                                        PADDR_r <= from_cpu_address;
                                        PPROT_r <= 0; //TODO
                                        PSELx_r <= from_cpu_slave_sel;
                                        PWRITE_r <= from_cpu_rd_wr;
                                        if( from_cpu_rd_wr )
                                        begin
                                            PWDATA_r <= from_cpu_wr_WDATA;
                                            PSTRB_r <= from_cpu_wr_STRB;
                                        end
                                        else if( !from_cpu_rd_wr )
                                        begin
                                            PSTRB_r <= 0;
                                        end
                                    end
                                    PENABLE_r <= 1;
                                    STATE <= ACCESS;
                                end
                ACCESS      :   begin
                                    if( PSLVERR == 1 )
                                    begin
                                        STATE <= IDLE;
                                        PENABLE_r <= 0;
                                        PSELx_r <= 0;
                                    end
                                    /* The STATE moves into SETUP only when
                                     * the Slave select signal is set to a non
                                     * zero value indicating that the CPU
                                     * intends to send a back to back transfer
                                     * */
                                    else if( PREADY == 1 && from_cpu_slave_sel && from_cpu_valid_txn ) // In case of consecutive transfers
                                    begin
                                        STATE <= SETUP;
                                        PENABLE_r <= 0;

                                        PADDR_r <= from_cpu_address;
                                        PPROT_r <= 0; //TODO
                                        PSELx_r <= from_cpu_slave_sel;
                                        PWRITE_r <= from_cpu_rd_wr;
                                        if( from_cpu_rd_wr )
                                        begin
                                            PWDATA_r <= from_cpu_wr_WDATA;
                                            PSTRB_r <= from_cpu_wr_STRB;
                                        end
                                        else if( !from_cpu_rd_wr )
                                        begin
                                            PSTRB_r <= 0;
                                        end
                                    end
                                    /* STATE transition happens only when the
                                     * slave select signal is zero and then
                                     * the from_cpu_valid_txn bit is checked.
                                     * */
                                    else if( PREADY == 1 && ~from_cpu_valid_txn )
                                    begin
                                        STATE <= IDLE;
                                        PENABLE_r <= 0;
                                        PSELx_r <= 0;
                                    end
                                end
                default     :   begin
                                    // Do nothing, because the register values are already getting updated at the top
                                end
            endcase

            if( pselx_timeout_flag_reg )
            begin
                PSELx_r <= 0;
                PENABLE_r <= 0;
                STATE <= IDLE; // TODO It is possible to move into SETUP ( Maybe :] ) -> Implementation Pending
            end
        end
    end : APB_FSM

    // APB Port Signal Assignents
    // --------------------------
    assign PADDR = PADDR_r;
    assign PPROT = PPROT_r;
    assign PSELx = PSELx_r;
    assign PENABLE = PENABLE_r;
    assign PWRITE = PWRITE_r;
    assign PWDATA = PWDATA_r;
    assign PSTRB = PSTRB_r;

    // CPU Signals Ouput Assignments
    // -----------------------------
    always@( posedge PCLK or negedge PRESETn or negedge from_cpu_resetn )
    begin : CPU_SIGNALS_ASSIGNMENT
        
        // Register to Register Assignment to avoid Latch Formation
        // --------------------------------------------------------
        to_cpu_txn_err_r <= to_cpu_txn_err_r;

        if( ~from_cpu_resetn || ~PRESETn )
        begin : RESET_STATE
            to_cpu_txn_err_r <= 0;
        end : RESET_STATE
        else
        begin
            case( STATE )
                IDLE        :   begin
                                end
                SETUP       :   begin
                                    if( from_cpu_valid_txn )
                                    begin
                                        to_cpu_txn_err_r <= 0;
                                    end
                                end
                ACCESS      :   begin
                                    if( PSLVERR == 1 )
                                    begin
                                        to_cpu_txn_err_r <= 1; 
                                    end
                                end
                default     :   begin
                                    // Do nothing because the default value is already begin assigned at the top
                                end
            endcase
        end
    end : CPU_SIGNALS_ASSIGNMENT

    // Combinational State Dependent Output Signal Assignment
    // ------------------------------------------------------
    assign apb_ready_for_txn_r = ( STATE == IDLE || STATE == SETUP );
    assign to_cpu_RDATA = PRDATA;
    assign to_cpu_RDATA_valid_WDATA_done = PREADY;

    // CPU Port Signal Assignents
    // --------------------------
    assign apb_ready_for_txn = ( apb_ready_for_txn_r || ( PSELx_r && PENABLE_r && PREADY ) );
    assign to_cpu_txn_err = to_cpu_txn_err_r;
    assign to_cpu_txn_timeout = to_cpu_txn_timeout_r;

    // APB PSELx Timeout Counter FSM
    // -----------------------------
    always@( posedge PCLK or negedge PRESETn )
    begin
        pselx_timeout_counter_r <= pselx_timeout_counter_r;
        pselx_timeout_reg <= pselx_timeout_reg;
        pselx_timeout_flag_reg <= pselx_timeout_flag_reg;
        to_cpu_txn_timeout_r <= 1'b0;

        if( !PRESETn )
        begin
            pselx_timeout_counter_r <= 'd0;
            pselx_timeout_reg <= `ifdef PSELx_TIMEOUT_VAL `PSELx_TIMEOUT_VAL-1 `else 'd20-1 `endif;
            pselx_timeout_flag_reg <= 1'b0;
        end
        else if( PSELx_r && PENABLE_r && PREADY )
        begin
            pselx_timeout_flag_reg <= 1'b0;
            pselx_timeout_counter_r <= 'd0;
        end
        else if( PSELx_r )
        begin
            if( pselx_timeout_counter_r == pselx_timeout_reg )
            begin
                pselx_timeout_counter_r <= 'd0;
                pselx_timeout_flag_reg <= 1'b1;
                to_cpu_txn_timeout_r <= 1'b1;
            end
            else
            begin
                pselx_timeout_counter_r <= pselx_timeout_counter_r + 1'b1;
            end
        end
        else if( !PSELx_r )
        begin
            pselx_timeout_flag_reg <= 1'b0;
            pselx_timeout_counter_r <= 'd0;
        end
    end
    
endmodule
