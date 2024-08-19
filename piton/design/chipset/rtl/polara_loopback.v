`include "define.tmp.h"
`include "piton_system.vh"

// Filename: polara_loopback.v
// Author: Raphael Rowley (2024-08)
// Contact: raphael.rowley@polymtl.ca
// Description: Chipset implementation that just sends
//              dummy packets into chip to test its NoC

module chipset_impl_polara_loopback(
    // Clocks and resets
    input chipset_clk,
    input chipset_rst_n,

    // Misc
    output test_start,

    // Main chip interface
    output [`NOC_DATA_WIDTH-1:0]                chipset_intf_data_noc1,
    output [`NOC_DATA_WIDTH-1:0]                chipset_intf_data_noc2,
    output [`NOC_DATA_WIDTH-1:0]                chipset_intf_data_noc3,
    output                                      chipset_intf_val_noc1,
    output                                      chipset_intf_val_noc2,
    output                                      chipset_intf_val_noc3,
    input                                       chipset_intf_rdy_noc1,
    input                                       chipset_intf_rdy_noc2,
    input                                       chipset_intf_rdy_noc3,

    input  [`NOC_DATA_WIDTH-1:0]                intf_chipset_data_noc1,
    input  [`NOC_DATA_WIDTH-1:0]                intf_chipset_data_noc2,
    input  [`NOC_DATA_WIDTH-1:0]                intf_chipset_data_noc3,
    input                                       intf_chipset_val_noc1,
    input                                       intf_chipset_val_noc2,
    input                                       intf_chipset_val_noc3,
    output                                      intf_chipset_rdy_noc1,
    output                                      intf_chipset_rdy_noc2,
    output                                      intf_chipset_rdy_noc3                                    

    // Just dummy signals
`ifdef PITONSYS_IOCTRL
`ifdef PITONSYS_UART
    ,
    output                                      uart_tx,
    input                                       uart_rx
`endif // endif PITONSYS_UART
`endif // endif PITONSYS_IOCTRL
);
   
///////////////////////
// Type declarations //
///////////////////////

// NoC power message header
// CHIPID: 14'd0
// XPOS: variable, depends on number of hops
// YPOS: variable, depends on number of hops
// FBITS: 4'd0
// PAYLOAD LENGTH: 8'd6 // Max accepted by L1.5
// MESSAGE TYPE: MSG_TYPE_INV_FWD // Causes dummy invalidations
// MSHR/TAG: 8'd0
// RESERVED: 6'd0
parameter                                       MSG_HEADER = {14'd0, 8'd0, 8'd0, 4'd0, 8'd6, 
                                                              `MSG_TYPE_INV_FWD, 8'd0, 6'd0};

parameter                                       STATE_RESET = 2'd0;
parameter                                       STATE_SEND_HEADER = 2'd1;
parameter                                       STATE_SEND_DATA_PATTERN_A = 2'd2;
parameter                                       STATE_SEND_DATA_PATTERN_B = 2'd3;

reg                                             rst_n;

reg  [1:0]                                      state_f;
reg  [1:0]                                      state_next;

reg  [7:0]                                      payload_count_f;
reg  [7:0]                                      payload_count_next;

reg  [`NOC_DATA_WIDTH-1:0]                      out_data;

//////////////////////
// Sequential Logic //
//////////////////////

always @ (posedge chipset_clk)
begin
    if (~rst_n)
    begin
        state_f <= STATE_RESET;
        payload_count_f <= 8'd0;
    end
    else
    begin
        state_f <= state_next;
        payload_count_f <= payload_count_next;
    end
end // always @ (posedge chipset_clk)

/////////////////////////
// Combinational Logic //
/////////////////////////

`ifdef PITONSYS_IOCTRL
`ifdef PITONSYS_UART
    assign uart_tx = 1'b0;
`endif // endif PITONSYS_UART
`endif // endif PITONSYS_IOCTRL

// State machine
always @ *
begin
    state_next = state_f;
    payload_count_next = payload_count_f;

    case (state_f)
        STATE_RESET:
        begin
            state_next = STATE_SEND_HEADER;
        end
        STATE_SEND_HEADER:
        begin
            if (chipset_intf_rdy_noc2)
                state_next = STATE_SEND_DATA_PATTERN_A;
        end
        STATE_SEND_DATA_PATTERN_A:
        begin
            if (chipset_intf_rdy_noc2)
            begin
                if (payload_count_f == 8'd5)
                begin
                    state_next = STATE_SEND_HEADER;
                    payload_count_next = 8'd0;
                end
                else
                begin
                    state_next = STATE_SEND_DATA_PATTERN_B;
                    payload_count_next = payload_count_f + 1'b1;
                end
            end
        end
        STATE_SEND_DATA_PATTERN_B:
        begin
            if (chipset_intf_rdy_noc2)
            begin
                if (payload_count_f == 8'd5)
                begin
                    state_next = STATE_SEND_HEADER;
                    payload_count_next = 8'd0;
                end
                else
                begin
                    state_next = STATE_SEND_DATA_PATTERN_A;
                    payload_count_next = payload_count_f + 1'b1;
                end    
            end 
        end
    endcase
end // always @ *

// Out data generation
always @ *
begin
    out_data = {`NOC_DATA_WIDTH{1'bx}};

    case (state_f)
        STATE_RESET:
        begin
            out_data = {`NOC_DATA_WIDTH{1'bx}};
        end
        STATE_SEND_HEADER:
        begin
            out_data = MSG_HEADER;
            case (noc_power_test_hop_count)
                4'd0:
                begin
                    out_data[`MSG_DST_X] = `MSG_DST_X_WIDTH'd0;
                    out_data[`MSG_DST_Y] = `MSG_DST_Y_WIDTH'd0;
                end
                4'd1:
                begin
                    out_data[`MSG_DST_X] = `MSG_DST_X_WIDTH'd1;
                    out_data[`MSG_DST_Y] = `MSG_DST_Y_WIDTH'd0;
                end
                4'd2:
                begin
                    out_data[`MSG_DST_X] = `MSG_DST_X_WIDTH'd2;
                    out_data[`MSG_DST_Y] = `MSG_DST_Y_WIDTH'd0;
                end
                4'd3:
                begin
                    out_data[`MSG_DST_X] = `MSG_DST_X_WIDTH'd3;
                    out_data[`MSG_DST_Y] = `MSG_DST_Y_WIDTH'd0;
                end
                4'd4:
                begin
                    out_data[`MSG_DST_X] = `MSG_DST_X_WIDTH'd4;
                    out_data[`MSG_DST_Y] = `MSG_DST_Y_WIDTH'd0;
                end
                4'd5:
                begin
                    out_data[`MSG_DST_X] = `MSG_DST_X_WIDTH'd4;
                    out_data[`MSG_DST_Y] = `MSG_DST_Y_WIDTH'd1;
                end
                4'd6:
                begin
                    out_data[`MSG_DST_X] = `MSG_DST_X_WIDTH'd4;
                    out_data[`MSG_DST_Y] = `MSG_DST_Y_WIDTH'd2;
                end
                4'd7:
                begin
                    out_data[`MSG_DST_X] = `MSG_DST_X_WIDTH'd4;
                    out_data[`MSG_DST_Y] = `MSG_DST_Y_WIDTH'd3;
                end
                4'd8:
                begin
                    out_data[`MSG_DST_X] = `MSG_DST_X_WIDTH'd4;
                    out_data[`MSG_DST_Y] = `MSG_DST_Y_WIDTH'd4;
                end
            endcase
        end
        STATE_SEND_DATA_PATTERN_A:
        begin
`ifdef NOC_POWER_TEST_0xA_0x5_PATTERN
            out_data = {`NOC_DATA_WIDTH/2{2'b01}};
`elsif NOC_POWER_TEST_0x0_0x0_PATTERN
            out_data = {`NOC_DATA_WIDTH{1'b0}};
`elsif NOC_POWER_TEST_0x0_0x3_PATTERN
            out_data = {`NOC_DATA_WIDTH/4{4'b0011}};
`else
            out_data = {`NOC_DATA_WIDTH{1'b1}};
`endif // endif NOC_POWER_TEST_0xA_0x5_PATTERN
        end
        STATE_SEND_DATA_PATTERN_B:
        begin
`ifdef NOC_POWER_TEST_0xA_0x5_PATTERN
            out_data = {`NOC_DATA_WIDTH/2{2'b10}};
`elsif NOC_POWER_TEST_0x0_0x0_PATTERN
            out_data = {`NOC_DATA_WIDTH{1'b0}};
`elsif NOC_POWER_TEST_0x0_0x3_PATTERN
            out_data = {`NOC_DATA_WIDTH{1'b0}};
`else
            out_data = {`NOC_DATA_WIDTH{1'b0}};
`endif // endif NOC_POWER_TEST_0xA_0x5_PATTERN
        end
    endcase
end   

assign test_start = 1'b1;

assign chipset_intf_data_noc1 = {`NOC_DATA_WIDTH{1'bx}};
assign chipset_intf_data_noc2 = out_data;
assign chipset_intf_data_noc3 = {`NOC_DATA_WIDTH{1'bx}};

assign chipset_intf_val_noc1 = 1'b0;
assign chipset_intf_val_noc2 = (state_f != STATE_RESET);
assign chipset_intf_val_noc3 = 1'b0;

assign intf_chipset_rdy_noc1 = 1'b0;
assign intf_chipset_rdy_noc2 = 1'b0;
assign intf_chipset_rdy_noc3 = 1'b0;

endmodule
