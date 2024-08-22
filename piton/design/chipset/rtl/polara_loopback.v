`include "define.tmp.h"
`include "piton_system.vh"

// Filename: polara_loopback.v
// Author: Raphael Rowley (2024-08)
// Contact: raphael.rowley@polymtl.ca
// Description: Chipset implementation that just sends
//              dummy packets into chip to test its NoC

module chipset_impl_polara_loopback(
    // Clocks and resets
    input                        chipset_clk,
    input                        chipset_rst_n,

    // Main chip interface
    output [`NOC_DATA_WIDTH-1:0] chipset_intf_data_noc1,
    output [`NOC_DATA_WIDTH-1:0] chipset_intf_data_noc2,
    output [`NOC_DATA_WIDTH-1:0] chipset_intf_data_noc3,
    output                       chipset_intf_val_noc1,
    output                       chipset_intf_val_noc2,
    output                       chipset_intf_val_noc3,
    input                        chipset_intf_rdy_noc1,
    input                        chipset_intf_rdy_noc2,
    input                        chipset_intf_rdy_noc3,

    input [`NOC_DATA_WIDTH-1:0]  intf_chipset_data_noc1,
    input [`NOC_DATA_WIDTH-1:0]  intf_chipset_data_noc2,
    input [`NOC_DATA_WIDTH-1:0]  intf_chipset_data_noc3,
    input                        intf_chipset_val_noc1,
    input                        intf_chipset_val_noc2,
    input                        intf_chipset_val_noc3,
    output                       intf_chipset_rdy_noc1,
    output                       intf_chipset_rdy_noc2,
    output                       intf_chipset_rdy_noc3,

    // Chip and other BD signals
    input                        mc_clk, // not sure if needed
    input                        mig_ddr3_sys_se_clock_clk,
    output                       chip_async_mux,
    output                       chip_clk_en,
    output                       chip_clk_mux_sel,
    output                       chip_rst_n,
    output                       init_calib_complete,
    output                       test_start,

    // FLL
    input                        fll_clkdiv,
    input                        fll_lock,
    output                       fll_bypass,
    output                       fll_cfg_req,
    output                       fll_opmode,
    output [3:0]                 fll_range,
    output                       fll_rst_n, 
                                    
    // Just dummy signals
    output                       uart_tx,
    input                        uart_rx,
    input                        uart_boot_en,
    input                        uart_timeout_en
);
   
///////////////////////
// Type declarations //
///////////////////////

// /////////////////////////////////////////////////////////////////
// NoC message for polara loopback
// CHIPID: 14'd1
// XPOS: 8'd0
// YPOS: 8'd0
// FBITS: 4'd0
// PAYLOAD LENGTH: 8'd0
// MESSAGE TYPE: MSG_TYPE_INV_FWD // Causes dummy invalidations
// MSHR/TAG: 8'd0
// RESERVED: 6'd0
// /////////////////////////////////////////////////////////////////

   wire [1:0]                           polara_gen2chipset_bus_i;
   wire [11:0]                          polara_gen2chipset_bus_o;
   wire                                 chip_rst_n_inter;

   parameter STATE_RESET = 2'b00;
   parameter STATE_SEND  = 2'b01;
   parameter STATE_WAIT  = 2'b10;

   reg [1:0]                            CurrentState, NextState;
   
   wire [`NOC_DATA_WIDTH-1:0]            out_data;
   
   
//////////////////////
// Sequential Logic //
//////////////////////

   always @ (posedge chipset_clk)
     begin: SEQ
        if (~chip_rst_n_inter)
          begin
             CurrentState <= STATE_RESET;
          end
        else
          begin
             CurrentState <= NextState;
          end
     end
   
/////////////////////////
// Combinational Logic //
/////////////////////////

   // Output data
   assign out_data = {14'd1, 8'd0, 8'd0, 4'd0, 8'd0, `MSG_TYPE_INV_FWD, 8'd0, 6'd0};
   
   // State machine
   always @ (*)
     begin: COMB
        case (CurrentState)
          STATE_RESET:
            begin
               if (chip_rst_n_inter)
                 begin
                    NextState = STATE_SEND;
                 end
               else
                 begin
                    NextState = STATE_RESET;
                 end
            end // case: STATE_RESET
          STATE_SEND:
            begin
               if (chipset_intf_rdy_noc2)
                 begin
                    NextState = STATE_WAIT;
                 end
            end 
          default: // STATE_WAIT
            begin
               NextState = STATE_WAIT;
            end
        endcase // case (CurrentState)
     end
   
   
   // Instantiate the block design
   gen2_polara_fpga_loopback gen2_polara_fpga_i
       (.bd_clk(chipset_clk),
        .mig_ddr3_sys_rst_n(chipset_rst_n),
        .polara_gen2chipset_bus_i_tri_i(polara_gen2chipset_bus_i),
        .polara_gen2chipset_bus_o_tri_o(polara_gen2chipset_bus_o));

   // Route polara_gen2chipset_bus signals
   assign chip_rst_n = chip_rst_n_inter;
   assign chip_rst_n_inter = polara_gen2chipset_bus_o[0];
   assign chip_async_mux = polara_gen2chipset_bus_o[1];
   assign chip_clk_en = polara_gen2chipset_bus_o[2];
   assign chip_clk_mux_sel = polara_gen2chipset_bus_o[3];

   assign fll_rst_n = polara_gen2chipset_bus_o[4];
   assign fll_bypass = polara_gen2chipset_bus_o[5];
   assign fll_opmode = polara_gen2chipset_bus_o[6];
   assign fll_cfg_req = polara_gen2chipset_bus_o[7];

   assign fll_range[3:0] = polara_gen2chipset_bus_o[11:8];
   
   assign polara_gen2chipset_bus_i[0] = fll_lock;
   assign polara_gen2chipset_bus_i[1] = fll_clkdiv;

   // Assign network I/Os
   assign test_start = 1'b1;

   assign chipset_intf_data_noc1 = {`NOC_DATA_WIDTH{1'bx}};
   assign chipset_intf_data_noc2 = out_data;
   assign chipset_intf_data_noc3 = {`NOC_DATA_WIDTH{1'bx}};

   assign chipset_intf_val_noc1 = 1'b0;
   assign chipset_intf_val_noc2 = (CurrentState != STATE_RESET);
   assign chipset_intf_val_noc3 = 1'b0;

   assign intf_chipset_rdy_noc1 = 1'b0;
   assign intf_chipset_rdy_noc2 = 1'b0;
   assign intf_chipset_rdy_noc3 = 1'b0;
   
endmodule
