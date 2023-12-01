// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
//
// Author: Michael Schaffner <schaffner@iis.ee.ethz.ch>, ETH Zurich
// Date: 14.11.2018
// Description: Ariane chipset for OpenPiton that includes two bootroms
// (linux, baremetal, both with DTB), debug module, clint and plic.
//
// Note that direct system bus accesses are not yet possible due to a missing
// AXI-lite br_master <-> NOC converter module.
//
// The address bases for the individual peripherals are defined in the
// devices.xml file in OpenPiton, and should be set to
//
// Debug    0xfff1000000 <length 0x1000>
// Boot Rom 0xfff1010000 <length 0x10000>
// CLINT    0xfff1020000 <length 0xc0000>
// PLIC     0xfff1100000 <length 0x4000000>
//
`include "register_interface/assign.svh"
`include "register_interface/typedef.svh"

module polara_bootrom #(
    parameter int unsigned DataWidth       = 64,
    // parameter int unsigned NumHarts        =  1,
    // parameter int unsigned NumSources      =  1,
    parameter bit          SwapEndianess   =  0,
    parameter logic [63:0] RomBase         = 64'hfff1010000
) (
    input                               clk_i,
    input                               rst_ni,
    // connections to OpenPiton NoC filters
    // Bootrom
    input  [DataWidth-1:0]              buf_ariane_bootrom_noc2_data_i,
    input                               buf_ariane_bootrom_noc2_valid_i,
    output                              ariane_bootrom_buf_noc2_ready_o,
    output [DataWidth-1:0]              ariane_bootrom_buf_noc3_data_o,
    output                              ariane_bootrom_buf_noc3_valid_o,
    input                               buf_ariane_bootrom_noc3_ready_i,
    // This selects either the BM or linux bootrom
    input                               ariane_boot_sel_i
);

  localparam int unsigned AxiIdWidth    =  1;
  localparam int unsigned AxiAddrWidth  = 64;
  localparam int unsigned AxiDataWidth  = 64;
  localparam int unsigned AxiUserWidth  =  1;

  /////////////////////////////
  // Bootrom
  /////////////////////////////

  logic                    rom_req;
  logic [AxiAddrWidth-1:0] rom_addr;
  logic [AxiDataWidth-1:0] rom_rdata, rom_rdata_bm, rom_rdata_linux;

  AXI_BUS #(
    .AXI_ID_WIDTH   ( AxiIdWidth   ),
    .AXI_ADDR_WIDTH ( AxiAddrWidth ),
    .AXI_DATA_WIDTH ( AxiDataWidth ),
    .AXI_USER_WIDTH ( AxiUserWidth )
  ) br_master();

  axi2mem #(
    .AXI_ID_WIDTH   ( AxiIdWidth    ),
    .AXI_ADDR_WIDTH ( AxiAddrWidth  ),
    .AXI_DATA_WIDTH ( AxiDataWidth  ),
    .AXI_USER_WIDTH ( AxiUserWidth  )
  ) i_axi2rom (
    .clk_i                ,
    .rst_ni               ,
    .slave  ( br_master  ),
    .req_o  ( rom_req    ),
    .we_o   (            ),
    .addr_o ( rom_addr   ),
    .be_o   (            ),
    .data_o (            ),
    .data_i ( rom_rdata  )
  );

  bootrom i_bootrom_bm (
    .clk_i                   ,
    .req_i      ( rom_req   ),
    .addr_i     ( rom_addr  ),
    .rdata_o    ( rom_rdata_bm )
  );

  bootrom_linux i_bootrom_linux (
    .clk_i                   ,
    .req_i      ( rom_req   ),
    .addr_i     ( rom_addr  ),
    .rdata_o    ( rom_rdata_linux )
  );

  // we want to run in baremetal mode when using pitonstream
  assign rom_rdata = (ariane_boot_sel_i) ? rom_rdata_bm : rom_rdata_linux;

  noc_axilite_bridge #(
    .SLAVE_RESP_BYTEWIDTH   ( 0             ),
    .SWAP_ENDIANESS         ( SwapEndianess )
  ) i_bootrom_axilite_bridge (
    .clk                    ( clk_i                           ),
    .rst                    ( ~rst_ni                         ),
    // to/from NOC
    .splitter_bridge_val    ( buf_ariane_bootrom_noc2_valid_i ),
    .splitter_bridge_data   ( buf_ariane_bootrom_noc2_data_i  ),
    .bridge_splitter_rdy    ( ariane_bootrom_buf_noc2_ready_o ),
    .bridge_splitter_val    ( ariane_bootrom_buf_noc3_valid_o ),
    .bridge_splitter_data   ( ariane_bootrom_buf_noc3_data_o  ),
    .splitter_bridge_rdy    ( buf_ariane_bootrom_noc3_ready_i ),
    //axi lite signals
    //write address channel
    .m_axi_awaddr           ( br_master.aw_addr               ),
    .m_axi_awvalid          ( br_master.aw_valid              ),
    .m_axi_awready          ( br_master.aw_ready              ),
    //write data channel
    .m_axi_wdata            ( br_master.w_data                ),
    .m_axi_wstrb            ( br_master.w_strb                ),
    .m_axi_wvalid           ( br_master.w_valid               ),
    .m_axi_wready           ( br_master.w_ready               ),
    //read address channel
    .m_axi_araddr           ( br_master.ar_addr               ),
    .m_axi_arvalid          ( br_master.ar_valid              ),
    .m_axi_arready          ( br_master.ar_ready              ),
    //read data channel
    .m_axi_rdata            ( br_master.r_data                ),
    .m_axi_rresp            ( br_master.r_resp                ),
    .m_axi_rvalid           ( br_master.r_valid               ),
    .m_axi_rready           ( br_master.r_ready               ),
    //write response channel
    .m_axi_bresp            ( br_master.b_resp                ),
    .m_axi_bvalid           ( br_master.b_valid               ),
    .m_axi_bready           ( br_master.b_ready               ),
    // non-axi-lite signals
    .w_reqbuf_size          (                                 ),
    .r_reqbuf_size          (                                 )
  );

  // tie off signals not used by AXI-lite
  assign br_master.aw_id     = '0;
  assign br_master.aw_len    = '0;
  assign br_master.aw_size   = 3'b11;// 8byte
  assign br_master.aw_burst  = '0;
  assign br_master.aw_lock   = '0;
  assign br_master.aw_cache  = '0;
  assign br_master.aw_prot   = '0;
  assign br_master.aw_qos    = '0;
  assign br_master.aw_region = '0;
  assign br_master.aw_atop   = '0;
  assign br_master.w_last    = 1'b1;
  assign br_master.ar_id     = '0;
  assign br_master.ar_len    = '0;
  assign br_master.ar_size   = 3'b11;// 8byte
  assign br_master.ar_burst  = '0;
  assign br_master.ar_lock   = '0;
  assign br_master.ar_cache  = '0;
  assign br_master.ar_prot   = '0;
  assign br_master.ar_qos    = '0;
  assign br_master.ar_region = '0;
  
endmodule // riscv_peripherals

