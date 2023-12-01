// ========== Copyright Header Begin ============================================
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
// ========== Copyright Header End ============================================

module plic_top #(
  parameter int N_SOURCE    = 128,
  parameter int N_TARGET    = 60,
  parameter int MAX_PRIO    = 7,
  parameter int SRCW        = $clog2(N_SOURCE+1)
) (
  input  logic clk_i,    // Clock
  input  logic rst_ni,  // Asynchronous reset active low
  // Bus Interface
  input  reg_intf::reg_intf_req_a32_d32 req_i,
  output reg_intf::reg_intf_resp_d32    resp_o,
  input logic [N_SOURCE-1:0] le_i, // 0:level 1:edge
  // Interrupt Sources
  input  logic [N_SOURCE-1:0] irq_sources_i,
  // Interrupt notification to targets
  output logic [N_TARGET-1:0] eip_targets_o
);
  localparam PRIOW = $clog2(MAX_PRIO+1);

  logic [N_SOURCE-1:0] ip;

	// These 3 kinds of registers are set in the plic_regmap
  logic [N_SOURCE-1:0][PRIOW-1:0]    prio_q;
  logic [N_TARGET-1:0][N_SOURCE-1:0] ie_q;
  logic [N_TARGET-1:0][PRIOW-1:0]    threshold_q;

  logic [N_TARGET-1:0]               claim_re; //Target read indicator
  logic [N_TARGET-1:0][SRCW-1:0]     claim_id;
  logic [N_SOURCE-1:0]               claim; //Converted from claim_re/claim_id

  logic [N_TARGET-1:0]               complete_we; //Target write indicator
  logic [N_TARGET-1:0][SRCW-1:0]     complete_id;
  logic [N_SOURCE-1:0]               complete; //Converted from complete_re/complete_id

  always_comb begin
    claim = '0;
    complete = '0;
    for (int i = 0 ; i < N_TARGET ; i++) begin
      if (claim_re[i] && claim_id[i] != 0) claim[claim_id[i]-1] = 1'b1;
      if (complete_we[i] && complete_id[i] != 0) complete[complete_id[i]-1] = 1'b1;
    end
  end

  // Gateways
  rv_plic_gateway #(
    .N_SOURCE (N_SOURCE)
  ) i_rv_plic_gateway (
    .clk_i,
    .rst_ni,
    .src(irq_sources_i),
    .le(le_i),
    .claim(claim),
    .complete(complete),
    .ip(ip)
  );

  // Target interrupt notification
  for (genvar i = 0 ; i < N_TARGET; i++) begin : gen_target
    rv_plic_target #(
      .N_SOURCE  ( N_SOURCE ),
      .MAX_PRIO  ( MAX_PRIO )
    ) i_target (
      .clk_i,
      .rst_ni,
      .ip(ip),
      .ie(ie_q[i]),
      .prio(prio_q),
      .threshold(threshold_q[i]),
      .irq(eip_targets_o[i]),
      .irq_id(claim_id[i])
    );
  end

  plic_regs #(
    .N_SOURCE   ( N_SOURCE ),
    .N_TARGET   ( N_TARGET ),
    .MAX_PRIO   ( MAX_PRIO )
  ) i_plic_regs (
    .clk_i(clk_i),    // Clock
    .rst_ni(rst_ni),  // Asynchronous reset active low
    .prio_q(prio_q),
    .prio_re_o(), // don't care
    // source zero is always zero
    .ip_i({ip, 1'b0}),
    .ip_re_o(), // don't care
    .ie_q(ie_q),
    .ie_re_o(), // don't care
    .threshold_q(threshold_q),
    .threshold_re_o(), // don't care
    .cc_i(claim_id),
    .cc_o(complete_id),
    .cc_we_o(complete_we),
    .cc_re_o(claim_re),
    .req_i,
    .resp_o
  );

endmodule
