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

    input                        chipset_clk,

	input [`NOC_DATA_WIDTH-1:0]  mem_flit_in_data ,
    input                        mem_flit_in_val ,
    output                       mem_flit_in_rdy ,

    output [`NOC_DATA_WIDTH-1:0] mem_flit_out_data ,
    output                       mem_flit_out_val ,
    input                        mem_flit_out_rdy ,

    input                        uart_boot_en
);

// Signal declarations
wire                                trans_fifo_val;
wire    [`NOC_DATA_WIDTH-1:0]       trans_fifo_data;
wire                                trans_fifo_rdy;

wire                                fifo_trans_val;
wire    [`NOC_DATA_WIDTH-1:0]       fifo_trans_data;
wire                                fifo_trans_rdy;

wire                                ui_clk;
wire                                noc_axi4_bridge_rst;
wire                                noc_axi4_bridge_init_done;

// Behavioral
    noc_bidir_afifo  mig_afifo  (
        .clk_1           (chipset_clk),
        .rst_1           (       ), // for mc they do a complicated rst chain, Alveo comes from chipset_rst of chipset top level. Why this discrepency?

        .clk_2           (            ), // ddr ui_clk
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
		.clk                (ui_clk),  
		.rst_n              (~noc_axi4_bridge_rst), // mc uses a bit of logic and depends on defines, Alveo just a not from ddr
		.uart_boot_en       (uart_boot_en),
		.phy_init_done      (noc_axi4_bridge_init_done), // idem

		.src_bridge_vr_noc2_val (fifo_trans_val),
		.src_bridge_vr_noc2_dat (fifo_trans_data),
		.src_bridge_vr_noc2_rdy (fifo_trans_rdy),

		.bridge_dst_vr_noc3_val (trans_fifo_val),
		.bridge_dst_vr_noc3_dat (trans_fifo_data),
		.bridge_dst_vr_noc3_rdy (trans_fifo_rdy),

		.m_axi_awid    			( 		),
		.m_axi_awaddr    		( 		),
		.m_axi_awlen    		( 		),
		.m_axi_awsize    		( 		),
		.m_axi_awburst    		( 		),
		.m_axi_awlock    		( 		),
		.m_axi_awcache    		( 		),
		.m_axi_awprot    		( 		),
		.m_axi_awqos    		( 		),
		.m_axi_awregion    		( 	),
		.m_axi_awuser    		( 		),
		.m_axi_awvalid    		( 		),
		.m_axi_awready    		( 		),

		.m_axi_wid    			( 			),
		.m_axi_wdata    		( 		),
		.m_axi_wstrb    		( 		),
		.m_axi_wlast    		( 		),
		.m_axi_wuser    		( 		),
		.m_axi_wvalid    		( 		),
		.m_axi_wready    		( 		),

		.m_axi_bid    			( 			),
		.m_axi_bresp    		( 		),
		.m_axi_buser    		( 		),
		.m_axi_bvalid    		( 		),
		.m_axi_bready    		( 		),

		.m_axi_arid    			( 		),
		.m_axi_araddr    		( 		),
		.m_axi_arlen    		( 		),
		.m_axi_arsize    		( 		),
		.m_axi_arburst    		( 		),
		.m_axi_arlock    		( 		),
		.m_axi_arcache    		( 		),
		.m_axi_arprot    		( 		),
		.m_axi_arqos    		( 		),
		.m_axi_arregion    		( 	),
		.m_axi_aruser    		( 		),
		.m_axi_arvalid    		( 		),
		.m_axi_arready    		( 		),

		.m_axi_rid    			( ),
		.m_axi_rdata    		( 		),
		.m_axi_rresp    		( 		),
		.m_axi_rlast    		( 		),
		.m_axi_ruser    		( 		),
		.m_axi_rvalid    		( 		),
		.m_axi_rready    		( )		
		
	);
   
endmodule
