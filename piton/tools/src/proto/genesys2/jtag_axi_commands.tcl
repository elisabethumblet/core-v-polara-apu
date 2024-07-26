# ####################################################################
#
# test_jtag_axi.tcl
#
# Author : Raphael Rowley (2024/07)
#
# Description :
# Useful commands for JTAG-AXI Xilinx IP on Genesys Chipset
#
# ####################################################################

# Inspired by: https://www.xilinx.com/video/software/jtag-to-axi-master-core.html

# Assumptions:
# core is named hw_axi_1
# DDR3 base address 0x0000_0000
# GPIO base address 0x4000_0000

# GPIO mapping
# 0 (LSB): chip_rst_n
# 1: chip_async_mux
# 2: chip_clk_en
# 3: chip_clk_mux_sel
# 4: fll_rst_n
# 5: fll_bypass
# 6: fll_opmode
# 7: fll_cfg_req
# 11-8: fll_range[3:0]

# 1. Reset the core
reset_hw_axi [get_hw_axis hw_axi_1]

# 2. Create a write transaction (16 word AXI burst write)
create_hw_axi_txn -force write0 [get_hw_axis hw_axi_1] -address 00000000 -data {FFFFFFFF_EEEEEEEE_DDDDDDDD_CCCCCCCC_BBBBBBBB_AAAAAAAA_99999999_88888888_77777777_66666666_55555555_44444444_33333333_22222222_11111111_00000000} -len 16 -type write

# 3. Run the write transaction
run_hw_axi [get_hw_axi_txns write0]

# 4. Create a read transaction (16 word AXI burst read)
create_hw_axi_txn -force read0 [get_hw_axis hw_axi_1] -address 00000000 -len 16 -type read

# 5. Run the read transaction
run_hw_axi [get_hw_axi_txns read0]

# 6. Assert chip reset
create_hw_axi_txn -force rston [get_hw_axis hw_axi_1] -address 40000000 -data {00000000} -len 1 -type write
# Run it
run_hw_axi [get_hw_axi_txns rston]

# 7. Deassert chip reset
create_hw_axi_txn -force rstoff [get_hw_axis hw_axi_1] -address 40000000 -data {00000001} -len 1 -type write
# Run it
run_hw_axi [get_hw_axi_txns rstoff]
