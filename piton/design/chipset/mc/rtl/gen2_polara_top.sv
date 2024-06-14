// -------------------------------------------------------------------------------
// Project:       core-v-polara-apu
// File:          gen2_polara_top.sv
// Author:        Raphael Rowley
// Creation Date: 2024/06/12
//                                                                                
// Description:
// Memory controller top level for chipset on the genesys2 to communicate with
// the Polara ASIC.
//                                                                                
// -------------------------------------------------------------------------------

`include "mc_define.h"
`include "noc_axi4_bridge_define.vh"

module gen2_polara_top(

    input    logic                           chipset_clk,

	input    logic    [`NOC_DATA_WIDTH-1:0]  mem_flit_in_data ,
    input    logic                           mem_flit_in_val ,
    output   logic                           mem_flit_in_rdy ,

    output   logic    [`NOC_DATA_WIDTH-1:0]  mem_flit_out_data ,
    output   logic                           mem_flit_out_val ,
    input    logic                           mem_flit_out_rdy ,

    input    logic                           uart_boot_en
);
   // -------------------------------------------------------------------------------
   // Signal declarations
   // -------------------------------------------------------------------------------
   logic                                 trans_fifo_val;
   logic [`NOC_DATA_WIDTH-1:0]           trans_fifo_data;
   logic                                 trans_fifo_rdy;
   
   

   logic                                 fifo_trans_val;
   logic [`NOC_DATA_WIDTH-1:0]           fifo_trans_data;
   logic                                 fifo_trans_rdy;
   
   logic                                 ui_clk;
   logic                                 noc_axi4_bridge_rst;
   logic                                 noc_axi4_bridge_init_done;
   

   logic [`AXI4_ID_WIDTH     -1:0]       ddr3_axi_arid;
   logic [`AXI4_ADDR_WIDTH   -1:0]       ddr3_axi_araddr;
   logic [`AXI4_BURST_WIDTH  -1:0]       ddr3_axi_arburst;
   logic [`AXI4_CACHE_WIDTH  -1:0]       ddr3_axi_arcache;
   logic [`AXI4_LEN_WIDTH    -1:0]       ddr3_axi_arlen;
   logic                                 ddr3_axi_arlock;
   logic [`AXI4_PROT_WIDTH   -1:0]       ddr3_axi_arprot;
   logic [`AXI4_QOS_WIDTH    -1:0]       ddr3_axi_arqos;
   logic                                 ddr3_axi_arready;
   logic [`AXI4_SIZE_WIDTH   -1:0]       ddr3_axi_arsize;
   logic                                 ddr3_axi_arvalid;
   logic [`AXI4_QOS_WIDTH    -1:0]       ddr3_axi_arqos;
   logic [`AXI4_REGION_WIDTH -1:0]       m_axi_arregion; // not used
   logic [`AXI4_USER_WIDTH   -1:0]       m_axi_aruser; // not used
   
   
   
   logic [`AXI4_ADDR_WIDTH   -1:0]       ddr3_axi_awaddr;
   logic [`AXI4_BURST_WIDTH  -1:0]       ddr3_axi_awburst;
   logic [`AXI4_CACHE_WIDTH  -1:0]       ddr3_axi_awcache;
   logic [`AXI4_ID_WIDTH     -1:0]       ddr3_axi_awid;
   logic [`AXI4_LEN_WIDTH    -1:0]       ddr3_axi_awlen;
   logic                                 ddr3_axi_awlock;
   logic [`AXI4_PROT_WIDTH   -1:0]       ddr3_axi_awprot;
   logic [`AXI4_QOS_WIDTH    -1:0]       ddr3_axi_awqos;
   logic                                 ddr3_axi_awready;
   logic [`AXI4_SIZE_WIDTH   -1:0]       ddr3_axi_awsize;
   logic                                 ddr3_axi_awvalid;
   logic [`AXI4_REGION_WIDTH -1:0]       m_axi_awregion; // not used
   logic [`AXI4_USER_WIDTH   -1:0]       m_axi_awuser; // not used
   
   
   
   logic [`AXI4_ID_WIDTH     -1:0]       ddr3_axi_bid;
   logic                                 ddr3_axi_bready;
   logic [`AXI4_RESP_WIDTH   -1:0]       ddr3_axi_bresp;
   logic                                 ddr3_axi_bvalid;
   logic [`AXI4_USER_WIDTH   -1:0]       m_axi_buser; // not used
   

   logic [`AXI4_DATA_WIDTH   -1:0]       ddr3_axi_rdata;
   logic [`AXI4_ID_WIDTH     -1:0]       ddr3_axi_rid;
   logic                                 ddr3_axi_rlast;
   logic                                 ddr3_axi_rready;
   logic [`AXI4_RESP_WIDTH   -1:0]       ddr3_axi_rresp;
   logic                                 ddr3_axi_rvalid;
   logic [`AXI4_USER_WIDTH   -1:0]       m_axi_ruser; // not used
   

   logic [`AXI4_DATA_WIDTH   -1:0]       ddr3_axi_wdata;
   logic                                 ddr3_axi_wlast;
   logic                                 ddr3_axi_wready;
   logic [`AXI4_STRB_WIDTH   -1:0]       ddr3_axi_wstrb;
   logic                                 ddr3_axi_wvalid;
   logic [`AXI4_ID_WIDTH     -1:0]       m_axi_wid; // not used
   logic [`AXI4_USER_WIDTH   -1:0]       m_axi_wuser; // not used

   logic                                 mig_ddr3_ui_clk;
   

   // -------------------------------------------------------------------------------
   // Behavioral
   // -------------------------------------------------------------------------------
   
    noc_bidir_afifo  mig_afifo  (
        .clk_1           (chipset_clk),
        .rst_1           (       ), // for mc they do a complicated rst chain, Alveo comes from chipset_rst of chipset top level. Why this discrepency?

        .clk_2           (mig_ddr3_ui_clk), // ddr ui_clk
        .rst_2           (       ), // for mc they do a complicated rst chain, Alveo directly from c0_ddr4_ui_clk_sync_rst

        // CPU --> MIG
        .flit_in_val_1   (mem_flit_in_val),
        .flit_in_data_1  (mem_flit_in_data),
        .flit_in_rdy_1   (mem_flit_in_rdy),

        .flit_out_val_2  (fifo_trans_val), 
        .flit_out_data_2 (fifo_trans_data), 
        .flit_out_rdy_2  (fifo_trans_rdy),

        // MIG --> CPU
        .flit_in_val_2   (trans_fifo_val),
        .flit_in_data_2  (trans_fifo_data),
        .flit_in_rdy_2   (trans_fifo_rdyt),

        .flit_out_val_1  (mem_flit_out_val),
        .flit_out_data_1 (mem_flit_out_data),
        .flit_out_rdy_1  (mem_flit_out_rdy)
    );

    noc_axi4_bridge noc_axi4_bridge  (
		.clk                (mig_ddr3_ui_clk),  
		.rst_n              (~noc_axi4_bridge_rst), // mc uses a bit of logic and depends on defines, Alveo just a not from ddr
		.uart_boot_en       (uart_boot_en),
		.phy_init_done      (noc_axi4_bridge_init_done), // idem

		.src_bridge_vr_noc2_val (fifo_trans_val),
		.src_bridge_vr_noc2_dat (fifo_trans_data),
		.src_bridge_vr_noc2_rdy (fifo_trans_rdy),

		.bridge_dst_vr_noc3_val (trans_fifo_val),
		.bridge_dst_vr_noc3_dat (trans_fifo_data),
		.bridge_dst_vr_noc3_rdy (trans_fifo_rdy),

		.m_axi_awid    			(ddr3_axi_awid),
		.m_axi_awaddr    		(ddr3_axi_awaddr),
		.m_axi_awlen    		(ddr3_axi_awlen),
		.m_axi_awsize    		(ddr3_axi_awsize),
		.m_axi_awburst    		(ddr3_axi_awburst),
		.m_axi_awlock    		(ddr3_axi_awlock),
		.m_axi_awcache    		(ddr3_axi_awcache),
		.m_axi_awprot    		(ddr3_axi_awprot),
		.m_axi_awqos    		(ddr3_axi_awqos),
		.m_axi_awregion    		(m_axi_awregion), // not used
		.m_axi_awuser    		(m_axi_awuser), // not used
		.m_axi_awvalid    		(ddr3_axi_awvalid),
		.m_axi_awready    		(ddr3_axi_awready),

		.m_axi_wid    			(m_axi_wid), // not used
		.m_axi_wdata    		(ddr3_axi_wdata),
		.m_axi_wstrb    		(ddr3_axi_wstrb),
		.m_axi_wlast    		(ddr3_axi_wlast),
		.m_axi_wuser    		(m_axi_wuser), // not used
		.m_axi_wvalid    		(ddr3_axi_wvalid),
		.m_axi_wready    		(ddr3_axi_wready),

		.m_axi_bid    			(ddr3_axi_bid),
		.m_axi_bresp    		(ddr3_axi_bresp),
		.m_axi_buser    		(m_axi_buser),  // not used
		.m_axi_bvalid    		(ddr3_axi_bvalid),
		.m_axi_bready    		(ddr3_axi_bready),

		.m_axi_arid    		(ddr3_axi_arid),
		.m_axi_araddr    		(ddr3_axi_araddr),
		.m_axi_arlen    		(ddr3_axi_arlen),
		.m_axi_arsize    		(ddr3_axi_arsize),
		.m_axi_arburst    	(ddr3_axi_arburst),
		.m_axi_arlock    		(ddr3_axi_arlock),
		.m_axi_arcache    	(ddr3_axi_arcache),
		.m_axi_arprot    		(ddr3_axi_arprot),
		.m_axi_arqos    		(ddr3_axi_arqos),
		.m_axi_arregion    		(m_axi_arregion), // not used
		.m_axi_aruser    		(m_axi_aruser), // not used
		.m_axi_arvalid    		(ddr3_axi_arvalid),
		.m_axi_arready    		(ddr3_axi_arready),

		.m_axi_rid    			(ddr3_axi_rid),
		.m_axi_rdata    		(ddr3_axi_rdata),
		.m_axi_rresp    		(ddr3_axi_rresp),
		.m_axi_rlast    		(ddr3_axi_rlast),
		.m_axi_ruser    		(m_axi_ruser), // not used
		.m_axi_rvalid    		(ddr3_axi_rvalid),
		.m_axi_rready    		(ddr3_axi_rready)		
		
	);
    
    gen2_polara_fpga gen2_polara_fpga_i(
        // AXI Interface for NOC/Master
        .ddr3_axi_araddr(ddr3_axi_araddr),
        .ddr3_axi_arburst(ddr3_axi_arburst),
        .ddr3_axi_arcache(ddr3_axi_arcache),
        .ddr3_axi_arid(ddr3_axi_arid),
        .ddr3_axi_arlen(ddr3_axi_arlen),
        .ddr3_axi_arlock(ddr3_axi_arlock),
        .ddr3_axi_arprot(ddr3_axi_arprot),
        .ddr3_axi_arqos(ddr3_axi_arqos),
        .ddr3_axi_arready(ddr3_axi_arready),
        .ddr3_axi_arsize(ddr3_axi_arsize),
        .ddr3_axi_arvalid(ddr3_axi_arvalid),
        .ddr3_axi_awaddr(ddr3_axi_awaddr),
        .ddr3_axi_awburst(ddr3_axi_awburst),
        .ddr3_axi_awcache(ddr3_axi_awcache),
        .ddr3_axi_awid(ddr3_axi_awid),
        .ddr3_axi_awlen(ddr3_axi_awlen),
        .ddr3_axi_awlock(ddr3_axi_awlock),
        .ddr3_axi_awprot(ddr3_axi_awprot),
        .ddr3_axi_awqos(ddr3_axi_awqos),
        .ddr3_axi_awready(ddr3_axi_awready),
        .ddr3_axi_awsize(ddr3_axi_awsize),
        .ddr3_axi_awvalid(ddr3_axi_awvalid),
        .ddr3_axi_bid(ddr3_axi_bid),
        .ddr3_axi_bready(ddr3_axi_bready),
        .ddr3_axi_bresp(ddr3_axi_bresp),
        .ddr3_axi_bvalid(ddr3_axi_bvalid),
        .ddr3_axi_rdata(ddr3_axi_rdata),
        .ddr3_axi_rid(ddr3_axi_rid),
        .ddr3_axi_rlast(ddr3_axi_rlast),
        .ddr3_axi_rready(ddr3_axi_rready),
        .ddr3_axi_rresp(ddr3_axi_rresp),
        .ddr3_axi_rvalid(ddr3_axi_rvalid),
        .ddr3_axi_wdata(ddr3_axi_wdata),
        .ddr3_axi_wlast(ddr3_axi_wlast),
        .ddr3_axi_wready(ddr3_axi_wready),
        .ddr3_axi_wstrb(ddr3_axi_wstrb),
        .ddr3_axi_wvalid(ddr3_axi_wvalid),
        // DDR3 Physical Interface
        .ddr3_sdram_addr(ddr3_sdram_addr),
        .ddr3_sdram_ba(ddr3_sdram_ba),
        .ddr3_sdram_cas_n(ddr3_sdram_cas_n),
        .ddr3_sdram_ck_n(ddr3_sdram_ck_n),
        .ddr3_sdram_ck_p(ddr3_sdram_ck_p),
        .ddr3_sdram_cke(ddr3_sdram_cke),
        .ddr3_sdram_cs_n(ddr3_sdram_cs_n),
        .ddr3_sdram_dm(ddr3_sdram_dm),
        .ddr3_sdram_dq(ddr3_sdram_dq),
        .ddr3_sdram_dqs_n(ddr3_sdram_dqs_n),
        .ddr3_sdram_dqs_p(ddr3_sdram_dqs_p),
        .ddr3_sdram_odt(ddr3_sdram_odt),
        .ddr3_sdram_ras_n(ddr3_sdram_ras_n),
        .ddr3_sdram_reset_n(ddr3_sdram_reset_n),
        .ddr3_sdram_we_n(ddr3_sdram_we_n),
        // DDR3 memory ready
        .mig_ddr3_init_calib_complete(mig_ddr3_init_calib_complete),
        // Input Clock for MIG
        // Xilinx recommends an external clock as the input clock (low jitter)
        .mig_ddr3_sys_diff_clock_clk_n(mig_ddr3_sys_diff_clock_clk_n),
        .mig_ddr3_sys_diff_clock_clk_p(mig_ddr3_sys_diff_clock_clk_p),
        // Asynchronous reset for the MIG's sys_rst_n
        // also used as reset for the AXI bus (synced with ui_clk)
        .mig_ddr3_sys_rst_n(mig_ddr3_sys_rst_n),
        // MIG generated ui_clk and synchronized reset
        .mig_ddr3_ui_clk(mig_ddr3_ui_clk),
        .mig_ddr3_ui_clk_sync_rst(mig_ddr3_ui_clk_sync_rst)
    );
   
endmodule
