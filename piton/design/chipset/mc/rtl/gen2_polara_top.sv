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
	input  logic  [`NOC_DATA_WIDTH-1:0]   mem_flit_in_data      ,
    input  logic                          mem_flit_in_val       ,
    output logic                          mem_flit_in_rdy       ,

    output logic  [`NOC_DATA_WIDTH-1:0]   mem_flit_out_data     ,
    output logic                          mem_flit_out_val      ,
    input  logic                          mem_flit_out_rdy     
);
