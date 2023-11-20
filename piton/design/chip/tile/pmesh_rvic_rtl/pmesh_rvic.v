// Copyright (c) 2020 Princeton University
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//     * Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above copyright
//       notice, this list of conditions and the following disclaimer in the
//       documentation and/or other materials provided with the distribution.
//     * Neither the name of Princeton University nor the
//       names of its contributors may be used to endorse or promote products
//       derived from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY PRINCETON UNIVERSITY "AS IS" AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL PRINCETON UNIVERSITY BE LIABLE FOR ANY
// DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

`include "l15.tmp.h"
`include "define.tmp.h"

module pmesh_rvic #(
    parameter  integer                  NUM_SOURCES = 16,
    parameter  integer                  NUM_HARTS = 4,
    parameter  integer                  MAX_PRIORITY = 7,
    parameter                           CLINT_BASE   = 64'he110500000, // north of the northeast tile
    parameter                           PLIC_BASE    = 64'he200000000, // north of the northwest tile
    parameter                           DEBUG_BASE   = 64'he110400000, // east of the northeast tile
    parameter                           SWAP_ENDIANESS = 1
) (
    input                               clk,
    input                               rst_n,

    // PLIC

    // Interrupt status is received from noc2
    input                               src_rvic_cr_noc2_val,
    input [`NOC_DATA_WIDTH-1:0]         src_rvic_cr_noc2_dat,
    output                              src_rvic_cr_noc2_yum,

    // input from noc1 (load/store to PLIC)
    input                               src_rvic_cr_noc1_val,
    input [`NOC_DATA_WIDTH-1:0]         src_rvic_cr_noc1_dat,
    output                              src_rvic_cr_noc1_yum,

    // output to noc2 (load/store PLIC response)
    output                              rvic_dst_cr_noc2_val,
    output [`NOC_DATA_WIDTH-1:0]        rvic_dst_cr_noc2_dat,
    input                               rvic_dst_cr_noc2_yum,

    // Interrupt targets go to core
    output   [NUM_HARTS*2-1:0]          irq_targets,

    // CLINT
    // input from noc1 (load/store to CLINT)
    input                               src_clint_cr_noc1_val,
    input [`NOC_DATA_WIDTH-1:0]         src_clint_cr_noc1_dat,
    output                              src_clint_cr_noc1_yum,

    // output to noc2 (load/store CLINT response)
    output                              clint_dst_cr_noc2_val,
    output [`NOC_DATA_WIDTH-1:0]        clint_dst_cr_noc2_dat,
    input                               clint_dst_cr_noc2_yum,

    input                               rtc_i,        // Real-time clock in (usually 32.768 kHz)
    output [NUM_HARTS-1:0]              timer_irq_o,  // Timer interrupts
    output [NUM_HARTS-1:0]              ipi_o,        // software interrupt (a.k.a inter-process-interrupt)

    // Debug unit
    // input from noc1 (load/store to debug unit)
    input                               src_debug_cr_noc1_val,
    input [`NOC_DATA_WIDTH-1:0]         src_debug_cr_noc1_dat,
    output                              src_debug_cr_noc1_yum,

    // output to noc2 (load/store debug unit response)
    output                              debug_dst_cr_noc2_val,
    output [`NOC_DATA_WIDTH-1:0]        debug_dst_cr_noc2_dat,
    input                               debug_dst_cr_noc2_yum,

    // Debug sigs to cores
    output                              ndmreset_o,    // non-debug module reset
    output                              dmactive_o,    // debug module is active
    output [NUM_HARTS-1:0]               debug_req_o,   // async debug request
    input  [NUM_HARTS-1:0]               unavailable_i, // communicate whether the hart is unavailable (e.g.: power down)

    // JTAG
    input                               tck_i,
    input                               tms_i,
    input                               trst_ni,
    input                               td_i,
    output                              td_o,
    output                              tdo_oe_o
);

// Interrupt status is received from noc2
wire                               src_rvic_vr_noc2_val;
wire [`NOC_DATA_WIDTH-1:0]         src_rvic_vr_noc2_dat;
wire                               src_rvic_vr_noc2_rdy;

// input from noc1 (load/store to PLIC)
wire                               src_rvic_vr_noc1_val;
wire [`NOC_DATA_WIDTH-1:0]         src_rvic_vr_noc1_dat;
wire                               src_rvic_vr_noc1_rdy;

// output to noc2 (load/store PLIC response)
wire                               rvic_dst_vr_noc2_val;
wire [`NOC_DATA_WIDTH-1:0]         rvic_dst_vr_noc2_dat;
wire                               rvic_dst_vr_noc2_rdy;

// CLINT
// input from noc1 (load/store to CLINT)
wire                               src_clint_vr_noc1_val;
wire [`NOC_DATA_WIDTH-1:0]         src_clint_vr_noc1_dat;
wire                               src_clint_vr_noc1_rdy;

// output to noc2 (load/store CLINT response)
wire                               clint_dst_vr_noc2_val;
wire [`NOC_DATA_WIDTH-1:0]         clint_dst_vr_noc2_dat;
wire                               clint_dst_vr_noc2_rdy;

// Debug unit
// input from noc1 (load/store to debug unit)
wire                               src_debug_vr_noc1_val;
wire [`NOC_DATA_WIDTH-1:0]         src_debug_vr_noc1_dat;
wire                               src_debug_vr_noc1_rdy;

// output to noc2 (load/store debug unit response)
wire                               debug_dst_vr_noc2_val;
wire [`NOC_DATA_WIDTH-1:0]         debug_dst_vr_noc2_dat;
wire                               debug_dst_vr_noc2_rdy;

credit_to_valrdy src_rvic_noc2_c2v(
    .clk        (clk),
    .reset      (~rst_n),
    .data_in    (src_rvic_cr_noc2_dat),
    .valid_in   (src_rvic_cr_noc2_val),
    .yummy_in   (src_rvic_cr_noc2_yum),

    .data_out   (src_rvic_vr_noc2_dat),
    .valid_out  (src_rvic_vr_noc2_val),
    .ready_out  (src_rvic_vr_noc2_rdy)
);

credit_to_valrdy src_rvic_noc1_c2v(
    .clk        (clk),
    .reset      (~rst_n),
    .data_in    (src_rvic_cr_noc1_dat),
    .valid_in   (src_rvic_cr_noc1_val),
    .yummy_in   (src_rvic_cr_noc1_yum),

    .data_out   (src_rvic_vr_noc1_dat),
    .valid_out  (src_rvic_vr_noc1_val),
    .ready_out  (src_rvic_vr_noc1_rdy)
);

valrdy_to_credit #(4, 3) rvic_dst_noc2_v2c(
    .clk        (clk),
    .reset      (~rst_n),
    .data_in    (rvic_dst_vr_noc2_dat),
    .valid_in   (rvic_dst_vr_noc2_val),
    .ready_in   (rvic_dst_vr_noc2_rdy),

    .data_out   (rvic_dst_cr_noc2_dat),
    .valid_out  (rvic_dst_cr_noc2_val),
    .yummy_out  (rvic_dst_cr_noc2_yum)
);

credit_to_valrdy src_clint_noc1_c2v(
    .clk        (clk),
    .reset      (~rst_n),
    .data_in    (src_clint_cr_noc1_dat),
    .valid_in   (src_clint_cr_noc1_val),
    .yummy_in   (src_clint_cr_noc1_yum),

    .data_out   (src_clint_vr_noc1_dat),
    .valid_out  (src_clint_vr_noc1_val),
    .ready_out  (src_clint_vr_noc1_rdy)
);

valrdy_to_credit #(4, 3) clint_dst_noc2_v2c(
    .clk        (clk),
    .reset      (~rst_n),
    .data_in    (clint_dst_vr_noc2_dat),
    .valid_in   (clint_dst_vr_noc2_val),
    .ready_in   (clint_dst_vr_noc2_rdy),

    .data_out   (clint_dst_cr_noc2_dat),
    .valid_out  (clint_dst_cr_noc2_val),
    .yummy_out  (clint_dst_cr_noc2_yum)
);

credit_to_valrdy src_debug_noc1_c2v(
    .clk        (clk),
    .reset      (~rst_n),
    .data_in    (src_debug_cr_noc1_dat),
    .valid_in   (src_debug_cr_noc1_val),
    .yummy_in   (src_debug_cr_noc1_yum),

    .data_out   (src_debug_vr_noc1_dat),
    .valid_out  (src_debug_vr_noc1_val),
    .ready_out  (src_debug_vr_noc1_rdy)
);

valrdy_to_credit #(4, 3) debug_dst_noc2_v2c(
    .clk        (clk),
    .reset      (~rst_n),
    .data_in    (debug_dst_vr_noc2_dat),
    .valid_in   (debug_dst_vr_noc2_val),
    .ready_in   (debug_dst_vr_noc2_rdy),

    .data_out   (debug_dst_cr_noc2_dat),
    .valid_out  (debug_dst_cr_noc2_val),
    .yummy_out  (debug_dst_cr_noc2_yum)
);


wire [511:0] noc2_data;
wire noc2_data_val;
wire noc2_data_ack;

simplenocbuffer simplenocbuffer(
    .clk(clk),
    .rst_n(rst_n),
    .noc_in_val(src_rvic_vr_noc2_val),
    .noc_in_data(src_rvic_vr_noc2_dat),
    .msg_ack(noc2_data_ack),
    .noc_in_rdy(src_rvic_vr_noc2_rdy),
    .msg(noc2_data),
    .msg_val(noc2_data_val)
);

wire l15_noc2decoder_ack;
wire l15_noc2decoder_header_ack;
wire noc2decoder_l15_val;
wire [`L15_MSHR_ID_WIDTH-1:0] noc2decoder_l15_mshrid;
wire noc2decoder_l15_l2miss;
wire noc2decoder_l15_icache_type;
wire noc2decoder_l15_f4b;
wire [`MSG_TYPE_WIDTH-1:0] noc2decoder_l15_reqtype;
wire [`L15_MESI_STATE_WIDTH-1:0] noc2decoder_l15_ack_state;
wire [63:0] noc2decoder_l15_data_0;
wire [63:0] noc2decoder_l15_data_1;
wire [63:0] noc2decoder_l15_data_2;
wire [63:0] noc2decoder_l15_data_3;
wire [`L15_PADDR_HI:0] noc2decoder_l15_address;
wire [3:0] noc2decoder_l15_fwd_subcacheline_vector;
wire [`PACKET_HOME_ID_WIDTH-1:0] noc2decoder_l15_src_homeid;

wire [`L15_CSM_NUM_TICKETS_LOG2-1:0] noc2decoder_l15_csm_mshrid;
wire [`L15_THREADID_MASK] noc2decoder_l15_threadid;
wire noc2decoder_l15_hmc_fill;

/*
    noc2decoder takes the data from the buffer and decode it to meaningful signals
    to the l15
*/
noc2decoder noc2decoder(
    .clk(clk),
    .rst_n(rst_n),
    .noc2_data(noc2_data),
    .noc2_data_val(noc2_data_val),
    .l15_noc2decoder_ack(l15_noc2decoder_ack),
    .l15_noc2decoder_header_ack(l15_noc2decoder_header_ack),
    .noc2_data_ack(noc2_data_ack),
    .noc2decoder_l15_val(noc2decoder_l15_val),
    .noc2decoder_l15_mshrid(noc2decoder_l15_mshrid),
    .noc2decoder_l15_l2miss(noc2decoder_l15_l2miss),
    .noc2decoder_l15_icache_type(noc2decoder_l15_icache_type),
    .noc2decoder_l15_f4b(noc2decoder_l15_f4b),
    .noc2decoder_l15_reqtype(noc2decoder_l15_reqtype),
    .noc2decoder_l15_ack_state(noc2decoder_l15_ack_state),
    .noc2decoder_l15_data_0(noc2decoder_l15_data_0),
    .noc2decoder_l15_data_1(noc2decoder_l15_data_1),
    .noc2decoder_l15_data_2(noc2decoder_l15_data_2),
    .noc2decoder_l15_data_3(noc2decoder_l15_data_3),
    .noc2decoder_l15_address(noc2decoder_l15_address),
    .noc2decoder_l15_fwd_subcacheline_vector(noc2decoder_l15_fwd_subcacheline_vector),
    .noc2decoder_l15_src_homeid(noc2decoder_l15_src_homeid),
    .noc2decoder_l15_csm_mshrid(noc2decoder_l15_csm_mshrid),
    .noc2decoder_l15_threadid(noc2decoder_l15_threadid),
    .noc2decoder_l15_hmc_fill(noc2decoder_l15_hmc_fill),
    .l15_dmbr_l2missIn(l15_dmbr_l2missIn),
    .l15_dmbr_l2missTag(l15_dmbr_l2missTag),
    .l15_dmbr_l2responseIn(l15_dmbr_l2responseIn)
);

reg                     new_edge_irq;
reg                     new_edge_irq_next;

reg  [NUM_SOURCES:0]  lev_or_edge;
reg  [NUM_SOURCES:0]  lev_or_edge_next;
reg  [NUM_SOURCES:0]  irq_sources;
reg  [NUM_SOURCES:0]  irq_sources_next;

reg  [6:0]              most_recent_source;
reg  [6:0]              most_recent_source_next;

reg  [9:0]            source_id_field;

// flit2: 
//     63    1
//     59:56 source id bit [9:6], for decades, only use bit[6:0]
//     33:26 ypos
//     25:18 xpos
//     17:16 type
//     15:9  0
//     8     threadid
//     7     0:level, 1:edge
//     6     0:rising, 1:falling
//     5:0   source id bit [5:0]
// Read from the l15 message
// for edge-sensitive or rising edge of level-sensitive,
// the next cycle of that interrupt should be high.
// The edge sensitive interrupt will automatically return to 0 after 1 cycle
always @* begin
    new_edge_irq_next = 1'b0;
    most_recent_source_next = most_recent_source;
    irq_sources_next = irq_sources;
    lev_or_edge_next = lev_or_edge;
    source_id_field  = 10'b0;
    if (noc2decoder_l15_val && (noc2decoder_l15_reqtype == `MSG_TYPE_INTERRUPT) && ~new_edge_irq && (noc2decoder_l15_data_0[17:16] == 2'b0)) begin
        // Comebine the source id together
	source_id_field = {noc2decoder_l15_data_0[59:56], noc2decoder_l15_data_0[5:0]};
        // Either level sensitive edge or rising edge of edge sensitive pulse
        new_edge_irq_next = noc2decoder_l15_data_0[7];
        most_recent_source_next = source_id_field[6:0];
	irq_sources_next[source_id_field[6:0]] = noc2decoder_l15_data_0[7] | (~noc2decoder_l15_data_0[7] & ~noc2decoder_l15_data_0[6]); // edge-sensitive or rising edge of level-sensitive
	lev_or_edge_next[source_id_field[6:0]] = noc2decoder_l15_data_0[7];
    end else if (new_edge_irq) begin
        // Edge sensitive automatic falling edge of pulse
        most_recent_source_next = 7'b0;
	irq_sources_next[most_recent_source] = 1'b0;
    end
end

always @(posedge clk) begin
    if (~rst_n) begin
        new_edge_irq <= 1'b0;
        most_recent_source <= 7'b0;
    end else begin
        new_edge_irq <= new_edge_irq_next;
        most_recent_source <= most_recent_source_next;
    end
end

always @(posedge clk) begin
    if (~rst_n) begin
        irq_sources <= {NUM_SOURCES+1{1'b0}};
        lev_or_edge <= {NUM_SOURCES+1{1'b0}};
    end else  begin
        irq_sources <= irq_sources_next;
	lev_or_edge <= lev_or_edge_next;
    end
end

wire [63:0]            aw_addr;
wire                   aw_valid;
wire                   aw_ready;
wire [63:0]            w_data;
wire [7:0]             w_strb;
wire                   w_valid;
wire                   w_ready;
wire [63:0]            ar_addr;
wire                   ar_valid;
wire                   ar_ready;
wire [63:0]            r_data;  
wire [1:0]             r_resp; 
wire                   r_valid; 
wire                   r_ready; 
wire [1:0]             b_resp;  
wire                   b_valid; 
wire                   b_ready; 
wire [2:0]             aw_size; 
wire [2:0]             ar_size; 

wire [63:0]            clint_aw_addr;
wire                   clint_aw_valid;
wire                   clint_aw_ready;
wire [63:0]            clint_w_data;  
wire [7:0]             clint_w_strb;  
wire                   clint_w_valid; 
wire                   clint_w_ready; 
wire [63:0]            clint_ar_addr; 
wire                   clint_ar_valid;
wire                   clint_ar_ready;
wire [63:0]            clint_r_data; 
wire [1:0]             clint_r_resp;  
wire                   clint_r_valid; 
wire                   clint_r_ready;
wire [1:0]             clint_b_resp;  
wire                   clint_b_valid; 
wire                   clint_b_ready; 

// Fake int for testing
// parameter OK_INT_CNT = 40000;
// reg [63:0]                   int_cnt;
// wire                         int_sent;
// reg                          fake_int;
// assign  int_sent = int_cnt == OK_INT_CNT;
// 
// always @(posedge clk) begin
//     if (~rst_n) begin
//         int_cnt <= 32'b0;
// 	fake_int <= 1'b0;
//     end
//     else begin
//         int_cnt <= int_sent ? int_cnt : int_cnt + 1'b1 ;
// 	//fake_int <= ( (int_cnt == OK_INT_CNT-2) || (int_cnt == OK_INT_CNT-1) ) ? ~fake_int : fake_int;
// 	fake_int <= (int_cnt == OK_INT_CNT-1) ? ~fake_int : fake_int;
//     end
// end



noc_axilite_bridge #(
    // this enables variable width accesses
    // note that the accesses are still 64bit, but the
    // write-enables are generated according to the access size
    .SLAVE_RESP_BYTEWIDTH   ( 0             ),
    .SWAP_ENDIANESS         ( SWAP_ENDIANESS ),
    // this disables shifting of unaligned read data
    .ALIGN_RDATA            ( 0             )
) rvic_axilite_bridge (
    .clk                    ( clk                   ),
    .rst                    ( ~rst_n                ),
    // to/from NOC
    .splitter_bridge_val    ( src_rvic_vr_noc1_val  ),
    .splitter_bridge_data   ( src_rvic_vr_noc1_dat  ),
    .bridge_splitter_rdy    ( src_rvic_vr_noc1_rdy  ),
    .bridge_splitter_val    ( rvic_dst_vr_noc2_val  ),
    .bridge_splitter_data   ( rvic_dst_vr_noc2_dat  ),
    .splitter_bridge_rdy    ( rvic_dst_vr_noc2_rdy  ),
    //axi lite signals
    //write address channel
    .m_axi_awaddr           ( aw_addr               ),
    .m_axi_awvalid          ( aw_valid              ),
    .m_axi_awready          ( aw_ready              ),
    //write data channel
    .m_axi_wdata            ( w_data                ),
    .m_axi_wstrb            ( w_strb                ),
    .m_axi_wvalid           ( w_valid               ),
    .m_axi_wready           ( w_ready               ),
    //read address channel
    .m_axi_araddr           ( ar_addr               ),
    .m_axi_arvalid          ( ar_valid              ),
    .m_axi_arready          ( ar_ready              ),
    //read data channel
    .m_axi_rdata            ( r_data                ),
    .m_axi_rresp            ( r_resp                ),
    .m_axi_rvalid           ( r_valid               ),
    .m_axi_rready           ( r_ready               ),
    //write response channel
    .m_axi_bresp            ( b_resp                ),
    .m_axi_bvalid           ( b_valid               ),
    .m_axi_bready           ( b_ready               ),
    // non-axi-lite signals
    .w_reqbuf_size          ( aw_size               ),
    .r_reqbuf_size          ( ar_size               )
);

// CLINT 
noc_axilite_bridge #(
    .SLAVE_RESP_BYTEWIDTH   ( 8             ),
    .SWAP_ENDIANESS         ( SWAP_ENDIANESS )
) i_clint_axilite_bridge (
    .clk                    ( clk                           ),
    .rst                    ( ~rst_n                        ),
    // to/from NOC
    .splitter_bridge_val    ( src_clint_vr_noc1_val            ),
    .splitter_bridge_data   ( src_clint_vr_noc1_dat            ),
    .bridge_splitter_rdy    ( src_clint_vr_noc1_rdy            ),
    .bridge_splitter_val    ( clint_dst_vr_noc2_val            ),
    .bridge_splitter_data   ( clint_dst_vr_noc2_dat            ),
    .splitter_bridge_rdy    ( clint_dst_vr_noc2_rdy            ),
    //axi lite signals
    //write address channel
    .m_axi_awaddr           ( clint_aw_addr         ),
    .m_axi_awvalid          ( clint_aw_valid        ),
    .m_axi_awready          ( clint_aw_ready        ),
    //write data channel
    .m_axi_wdata            ( clint_w_data          ),
    .m_axi_wstrb            ( clint_w_strb          ),
    .m_axi_wvalid           ( clint_w_valid         ),
    .m_axi_wready           ( clint_w_ready         ),
    //read address channel
    .m_axi_araddr           ( clint_ar_addr         ),
    .m_axi_arvalid          ( clint_ar_valid        ),
    .m_axi_arready          ( clint_ar_ready        ),
    //read data channel
    .m_axi_rdata            ( clint_r_data          ),
    .m_axi_rresp            ( clint_r_resp          ),
    .m_axi_rvalid           ( clint_r_valid         ),
    .m_axi_rready           ( clint_r_ready         ),
    //write response channel
    .m_axi_bresp            ( clint_b_resp          ),
    .m_axi_bvalid           ( clint_b_valid         ),
    .m_axi_bready           ( clint_b_ready         ),
    // non-axi-lite signals
    .w_reqbuf_size          (                               ),
    .r_reqbuf_size          (                               )
  );


rvic_wrap #(
    .NumSources        ( NUM_SOURCES   ),
    .NumHarts          ( NUM_HARTS     ),
    .PlicMaxPriority   ( MAX_PRIORITY  ),
    .ClintBase         ( CLINT_BASE    ),
    .PlicBase          ( PLIC_BASE     ),
    .DmBase            ( DEBUG_BASE    )
) rvic_wrap (
    .clk            ( clk           ),
    .rst_n          ( rst_n         ),
    //axi lite signals
    .axi_awaddr     ( aw_addr       ),
    .axi_awvalid    ( aw_valid      ),
    .axi_awready    ( aw_ready      ),
    .axi_wdata      ( w_data        ),
    .axi_wstrb      ( w_strb        ),
    .axi_wvalid     ( w_valid       ),
    .axi_wready     ( w_ready       ),
    .axi_araddr     ( ar_addr       ),
    .axi_arvalid    ( ar_valid      ),
    .axi_arready    ( ar_ready      ),
    .axi_rdata      ( r_data        ),
    .axi_rresp      ( r_resp        ),
    .axi_rvalid     ( r_valid       ),
    .axi_rready     ( r_ready       ),
    .axi_bresp      ( b_resp        ),
    .axi_bvalid     ( b_valid       ),
    .axi_bready     ( b_ready       ),
    .w_reqbuf_size  ( aw_size       ),
    .r_reqbuf_size  ( ar_size       ),

    // clint axi lite signals
    .clint_axi_awaddr     ( clint_aw_addr       ),
    .clint_axi_awvalid    ( clint_aw_valid      ),
    .clint_axi_awready    ( clint_aw_ready      ),
    .clint_axi_wdata      ( clint_w_data        ),
    .clint_axi_wstrb      ( clint_w_strb        ),
    .clint_axi_wvalid     ( clint_w_valid       ),
    .clint_axi_wready     ( clint_w_ready       ),
    .clint_axi_araddr     ( clint_ar_addr       ),
    .clint_axi_arvalid    ( clint_ar_valid      ),
    .clint_axi_arready    ( clint_ar_ready      ),
    .clint_axi_rdata      ( clint_r_data        ),
    .clint_axi_rresp      ( clint_r_resp        ),
    .clint_axi_rvalid     ( clint_r_valid       ),
    .clint_axi_rready     ( clint_r_ready       ),
    .clint_axi_bresp      ( clint_b_resp        ),
    .clint_axi_bvalid     ( clint_b_valid       ),
    .clint_axi_bready     ( clint_b_ready       ),

    .irq_sources_i  ( irq_sources[NUM_SOURCES:1]   ), // already synchronized
    .irq_le_i       ( lev_or_edge_next[NUM_SOURCES:1]   ), // 0:level 1:edge, bypass from reg
    .irq_o          ( irq_targets   ),

    .testmode_i     ( 1'b0          ),       // Not Sure: tie this to 1'b0 for using clint

    .rtc_i          ( rtc_i         ),       // Real-time clock in (usually 32.768 kHz)
    .timer_irq_o    ( timer_irq_o   ),       // Timer interrupts
    .ipi_o          ( ipi_o         )        // software interrupt (a.k.a inter-process-interrupt)
);

endmodule
