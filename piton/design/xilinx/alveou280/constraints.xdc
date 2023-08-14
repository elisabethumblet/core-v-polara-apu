# Bitstream generation
# ---------------------------------------------------------------------
set_property CONFIG_VOLTAGE 1.8 [current_design]
set_property BITSTREAM.CONFIG.CONFIGFALLBACK Enable [current_design]               ;# Golden image is the fall back image if  new bitstream is corrupted.
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property CONFIG_MODE SPIx4 [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 63.8          [current_design] 
#set_property BITSTREAM.CONFIG.CONFIGRATE 85.0          [current_design]                 ;# Customer can try but may not be reliable over all conditions.
set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN disable [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE YES [current_design]
set_property BITSTREAM.CONFIG.UNUSEDPIN Pullup [current_design]                    ;# Choices are pullnone, pulldown, and pullup.
set_property BITSTREAM.CONFIG.SPI_32BIT_ADDR Yes [current_design]
# ---------------------------------------------------------------------

# Don't time the GPIO reset signals
set_false_path -from [get_pins -hier *Not_Dual.gpio_Data_Out_reg*/C]

# 156.25MHz General purpose system clock
set_property PACKAGE_PIN F30              [get_ports {chipset_clk_osc_n}]     
set_property PACKAGE_PIN G30              [get_ports {chipset_clk_osc_p}]     
set_property IOSTANDARD LVDS              [get_ports {chipset_clk*}]     

# Reset, connects SW1 push button On the top edge of the PCB Assembly, also connects to Satellite Controller
set_property PACKAGE_PIN L30              [get_ports resetn]
set_property IOSTANDARD LVCMOS18          [get_ports resetn]

# UART
set_property PACKAGE_PIN A28              [get_ports uart_rx]
set_property PACKAGE_PIN B33              [get_ports uart_tx]
set_property IOSTANDARD LVCMOS18          [get_ports uart_*]

# PCIe MGTY Interface
set_property PACKAGE_PIN BH26             [get_ports pcie_perstn]                                  ;# Bank  67 VCCO - VCC1V8   - IO_L13P_T2L_N0_GC_QBC_67
set_property IOSTANDARD  LVCMOS18         [get_ports pcie_perstn]                	           ;# Bank  67 VCCO - VCC1V8   - IO_L13P_T2L_N0_GC_QBC_67

set_property PACKAGE_PIN BC1              [get_ports {pci_express_x16_rxn[15]} ]                   ;# Bank 224 - MGTYRXN0_224
set_property PACKAGE_PIN BB3              [get_ports {pci_express_x16_rxn[14]} ]                   ;# Bank 224 - MGTYRXN1_224
set_property PACKAGE_PIN BA1              [get_ports {pci_express_x16_rxn[13]} ]                   ;# Bank 224 - MGTYRXN2_224
set_property PACKAGE_PIN BA5              [get_ports {pci_express_x16_rxn[12]} ]                   ;# Bank 224 - MGTYRXN3_224
set_property PACKAGE_PIN BC2              [get_ports {pci_express_x16_rxp[15]} ]                   ;# Bank 224 - MGTYRXP0_224
set_property PACKAGE_PIN BB4              [get_ports {pci_express_x16_rxp[14]} ]                   ;# Bank 224 - MGTYRXP1_224
set_property PACKAGE_PIN BA2              [get_ports {pci_express_x16_rxp[13]} ]                   ;# Bank 224 - MGTYRXP2_224
set_property PACKAGE_PIN BA6              [get_ports {pci_express_x16_rxp[12]} ]                   ;# Bank 224 - MGTYRXP3_224
set_property PACKAGE_PIN BC6              [get_ports {pci_express_x16_txn[15]} ]                   ;# Bank 224 - MGTYTXN0_224
set_property PACKAGE_PIN BC10             [get_ports {pci_express_x16_txn[14]} ]                   ;# Bank 224 - MGTYTXN1_224
set_property PACKAGE_PIN BB8              [get_ports {pci_express_x16_txn[13]} ]                   ;# Bank 224 - MGTYTXN2_224
set_property PACKAGE_PIN BA10             [get_ports {pci_express_x16_txn[12]} ]                   ;# Bank 224 - MGTYTXN3_224
set_property PACKAGE_PIN BC7              [get_ports {pci_express_x16_txp[15]} ]                   ;# Bank 224 - MGTYTXP0_224
set_property PACKAGE_PIN BC11             [get_ports {pci_express_x16_txp[14]} ]                   ;# Bank 224 - MGTYTXP1_224
set_property PACKAGE_PIN BB9              [get_ports {pci_express_x16_txp[13]} ]                   ;# Bank 224 - MGTYTXP2_224
set_property PACKAGE_PIN BA11             [get_ports {pci_express_x16_txp[12]} ]                   ;# Bank 224 - MGTYTXP3_224
# Clock
set_property PACKAGE_PIN AR14             [get_ports pcie_refclk_clk_n ]                           ;# Bank 225 - MGTREFCLK0N_225
set_property PACKAGE_PIN AR15             [get_ports pcie_refclk_clk_p ]                           ;# Bank 225 - MGTREFCLK0P_225

set_property PACKAGE_PIN AY3              [get_ports {pci_express_x16_rxn[11]} ]                   ;# Bank 225 - MGTYRXN0_225
set_property PACKAGE_PIN AW1              [get_ports {pci_express_x16_rxn[10]} ]                   ;# Bank 225 - MGTYRXN1_225
set_property PACKAGE_PIN AW5              [get_ports {pci_express_x16_rxn[9]} ]                    ;# Bank 225 - MGTYRXN2_225
set_property PACKAGE_PIN AV3              [get_ports {pci_express_x16_rxn[8]} ]                    ;# Bank 225 - MGTYRXN3_225
set_property PACKAGE_PIN AY4              [get_ports {pci_express_x16_rxp[11]} ]                   ;# Bank 225 - MGTYRXP0_225
set_property PACKAGE_PIN AW2              [get_ports {pci_express_x16_rxp[10]} ]                   ;# Bank 225 - MGTYRXP1_225
set_property PACKAGE_PIN AW6              [get_ports {pci_express_x16_rxp[9]} ]                    ;# Bank 225 - MGTYRXP2_225
set_property PACKAGE_PIN AV4              [get_ports {pci_express_x16_rxp[8]} ]                    ;# Bank 225 - MGTYRXP3_225
set_property PACKAGE_PIN AY8              [get_ports {pci_express_x16_txn[11]} ]                   ;# Bank 225 - MGTYTXN0_225
set_property PACKAGE_PIN AW10             [get_ports {pci_express_x16_txn[10]} ]                   ;# Bank 225 - MGTYTXN1_225
set_property PACKAGE_PIN AV8              [get_ports {pci_express_x16_txn[9]} ]                    ;# Bank 225 - MGTYTXN2_225
set_property PACKAGE_PIN AU6              [get_ports {pci_express_x16_txn[8]} ]                    ;# Bank 225 - MGTYTXN3_225
set_property PACKAGE_PIN AY9              [get_ports {pci_express_x16_txp[11]} ]                   ;# Bank 225 - MGTYTXP0_225
set_property PACKAGE_PIN AW11             [get_ports {pci_express_x16_txp[10]} ]                   ;# Bank 225 - MGTYTXP1_225
set_property PACKAGE_PIN AV9              [get_ports {pci_express_x16_txp[8]} ]                    ;# Bank 225 - MGTYTXP2_225
set_property PACKAGE_PIN AU7              [get_ports {pci_express_x16_txp[9]} ]                    ;# Bank 225 - MGTYTXP3_225
set_property PACKAGE_PIN AU1              [get_ports {pci_express_x16_rxn[7]} ]                    ;# Bank 226 - MGTYRXN0_226
set_property PACKAGE_PIN AT3              [get_ports {pci_express_x16_rxn[6]} ]                    ;# Bank 226 - MGTYRXN1_226
set_property PACKAGE_PIN AR1              [get_ports {pci_express_x16_rxn[5]} ]                    ;# Bank 226 - MGTYRXN2_226
set_property PACKAGE_PIN AP3              [get_ports {pci_express_x16_rxn[4]} ]                    ;# Bank 226 - MGTYRXN3_226
set_property PACKAGE_PIN AU2              [get_ports {pci_express_x16_rxp[7]} ]                    ;# Bank 226 - MGTYRXP0_226
set_property PACKAGE_PIN AT4              [get_ports {pci_express_x16_rxp[6]} ]                    ;# Bank 226 - MGTYRXP1_226
set_property PACKAGE_PIN AR2              [get_ports {pci_express_x16_rxp[5]} ]                    ;# Bank 226 - MGTYRXP2_226
set_property PACKAGE_PIN AP4              [get_ports {pci_express_x16_rxp[4]} ]                    ;# Bank 226 - MGTYRXP3_226
set_property PACKAGE_PIN AU10             [get_ports {pci_express_x16_txn[7]} ]                    ;# Bank 226 - MGTYTXN0_226
set_property PACKAGE_PIN AT8              [get_ports {pci_express_x16_txn[6]} ]                    ;# Bank 226 - MGTYTXN1_226
set_property PACKAGE_PIN AR6              [get_ports {pci_express_x16_txn[5]} ]                    ;# Bank 226 - MGTYTXN2_226
set_property PACKAGE_PIN AR10             [get_ports {pci_express_x16_txn[4]} ]                    ;# Bank 226 - MGTYTXN3_226
set_property PACKAGE_PIN AU11             [get_ports {pci_express_x16_txp[7]} ]                    ;# Bank 226 - MGTYTXP0_226
set_property PACKAGE_PIN AT9              [get_ports {pci_express_x16_txp[6]} ]                    ;# Bank 226 - MGTYTXP1_226
set_property PACKAGE_PIN AR7              [get_ports {pci_express_x16_txp[5]} ]                    ;# Bank 226 - MGTYTXP2_226
set_property PACKAGE_PIN AR11             [get_ports {pci_express_x16_txp[4]} ]                    ;# Bank 226 - MGTYTXP3_226
#set_property PACKAGE_PIN AL14             [get_ports {pcie_clk0_n} ]                       ;# Bank 227 - MGTREFCLK0N_227
#set_property PACKAGE_PIN AL15             [get_ports {pcie_clk0_n} ]                       ;# Bank 227 - MGTREFCLK0P_227
#set_property PACKAGE_PIN AK12             [get_ports {sys_clk2_n} ]                        ;# Bank 227 - MGTREFCLK1N_227
#set_property PACKAGE_PIN AK13             [get_ports {sys_clk2_n} ]                        ;# Bank 227 - MGTREFCLK1P_227
set_property PACKAGE_PIN AN1              [get_ports {pci_express_x16_rxn[3]} ]                    ;# Bank 227 - MGTYRXN0_227
set_property PACKAGE_PIN AN5              [get_ports {pci_express_x16_rxn[2]} ]                    ;# Bank 227 - MGTYRXN1_227
set_property PACKAGE_PIN AM3              [get_ports {pci_express_x16_rxn[1]} ]                    ;# Bank 227 - MGTYRXN2_227
set_property PACKAGE_PIN AL1              [get_ports {pci_express_x16_rxn[0]} ]                    ;# Bank 227 - MGTYRXN3_227
set_property PACKAGE_PIN AN2              [get_ports {pci_express_x16_rxp[3]} ]                    ;# Bank 227 - MGTYRXP0_227
set_property PACKAGE_PIN AN6              [get_ports {pci_express_x16_rxp[2]} ]                    ;# Bank 227 - MGTYRXP1_227
set_property PACKAGE_PIN AM4              [get_ports {pci_express_x16_rxp[1]} ]                    ;# Bank 227 - MGTYRXP2_227
set_property PACKAGE_PIN AL2              [get_ports {pci_express_x16_rxp[0]} ]                    ;# Bank 227 - MGTYRXP3_227
set_property PACKAGE_PIN AP8              [get_ports {pci_express_x16_txn[3]} ]                    ;# Bank 227 - MGTYTXN0_227
set_property PACKAGE_PIN AN10             [get_ports {pci_express_x16_txn[2]} ]                    ;# Bank 227 - MGTYTXN1_227
set_property PACKAGE_PIN AM8              [get_ports {pci_express_x16_txn[1]} ]                    ;# Bank 227 - MGTYTXN2_227
set_property PACKAGE_PIN AL10             [get_ports {pci_express_x16_txn[0]} ]                    ;# Bank 227 - MGTYTXN3_227
set_property PACKAGE_PIN AP9              [get_ports {pci_express_x16_txp[3]} ]                    ;# Bank 227 - MGTYTXP0_227
set_property PACKAGE_PIN AN11             [get_ports {pci_express_x16_txp[2]} ]                    ;# Bank 227 - MGTYTXP1_227
set_property PACKAGE_PIN AM9              [get_ports {pci_express_x16_txp[1]} ]                    ;# Bank 227 - MGTYTXP2_227
set_property PACKAGE_PIN AL11             [get_ports {pci_express_x16_txp[0]} ]                    ;# Bank 227 - MGTYTXP3_227

create_clock -period 10.000 -name  pcie_refclk [get_ports pcie_refclk_clk_p]

# 100MHz DDR0 System clock
set_property PACKAGE_PIN BJ44             [get_ports  {mc_clk_n}]             ;# Bank  65 VCCO - VCC1V2 Net "SYSCLK0_N"          - IO_L12N_T1U_N11_GC_A09_D25_65
set_property PACKAGE_PIN BJ43             [get_ports  {mc_clk_p}]             ;# Bank  65 VCCO - VCC1V2 Net "SYSCLK0_P"          - IO_L12P_T1U_N10_GC_A08_D24_65


# DDR4 RDIMM Controller 0, 72-bit Data Interface, x4 Componets, Single Rank
#     <<<NOTE>>> DQS Clock strobes have been swapped from JEDEC standard to match Xilinx MIG Clock order:
#                JEDEC Order   DQS ->  0  9  1 10  2 11  3 12  4 13  5 14  6 15  7 16  8 17
#                Xil MIG Order DQS ->  0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17
#
set_property -dict {PACKAGE_PIN BH44 IOSTANDARD SSTL12_DCI}              [ get_ports  {ddr_addr[16]} ]        ;# Bank  65 VCCO - VCC1V2 Net "DDR4_C0_ADR16"   - IO_L14P_T2L_N2_GC_A04_D20_65
set_property -dict {PACKAGE_PIN BL46 IOSTANDARD SSTL12_DCI}              [ get_ports  {ddr_addr[15]} ]        ;# Bank  65 VCCO - VCC1V2 Net "DDR4_C0_ADR15"   - IO_L8N_T1L_N3_AD5N_A17_65
#set_property -dict {PACKAGE_PIN BE46 IOSTANDARD SSTL12_DCI}              [ get_ports  {c0_ddr4_odt[1]} ]         ;# Bank  65 VCCO - VCC1V2 Net "DDR4_C0_ODT1"    - IO_L22N_T3U_N7_DBC_AD0N_D05_65
#set_property -dict {PACKAGE_PIN BK44 IOSTANDARD SSTL12_DCI}              [ get_ports  {#NA} ]                    ;# Bank  65 VCCO - VCC1V2 Net "DDR4_C0_CS_B3"   - IO_L11N_T1U_N9_GC_A11_D27_65
set_property -dict {PACKAGE_PIN BK46 IOSTANDARD SSTL12_DCI}              [ get_ports  {ddr_cs_n[0]} ]         ;# Bank  65 VCCO - VCC1V2 Net "DDR4_C0_CS_B0"   - IO_L10N_T1U_N7_QBC_AD4N_A13_D29_65
set_property -dict {PACKAGE_PIN BE44 IOSTANDARD SSTL12_DCI}              [ get_ports  {ddr_addr[13]} ]        ;# Bank  65 VCCO - VCC1V2 Net "DDR4_C0_ADR13"   - IO_L24N_T3U_N11_DOUT_CSO_B_65
#set_property -dict {PACKAGE_PIN BL47 IOSTANDARD SSTL12_DCI}              [ get_ports  {ddr_addr[17]} ]           ;# Bank  65 VCCO - VCC1V2 Net "DDR4_C0_ADR17"   - IO_L7P_T1L_N0_QBC_AD13P_A18_65
set_property -dict {PACKAGE_PIN BE43 IOSTANDARD SSTL12_DCI}              [ get_ports  {ddr_addr[14]} ]        ;# Bank  65 VCCO - VCC1V2 Net "DDR4_C0_ADR14"   - IO_L24P_T3U_N10_EMCCLK_65
set_property -dict {PACKAGE_PIN BG44 IOSTANDARD SSTL12_DCI}              [ get_ports  {ddr_odt[0]} ]          ;# Bank  65 VCCO - VCC1V2 Net "DDR4_C0_ODT0"    - IO_L18P_T2U_N10_AD2P_D12_65
#set_property -dict {PACKAGE_PIN BE45 IOSTANDARD SSTL12_DCI}              [ get_ports  {c0_ddr4_cs_n[1]} ]        ;# Bank  65 VCCO - VCC1V2 Net "DDR4_C0_CS_B1"   - IO_L22P_T3U_N6_DBC_AD0P_D04_65
#set_property -dict {PACKAGE_PIN BD42 IOSTANDARD SSTL12_DCI}              [ get_ports  {c0_ddr4_cs_n[2]} ]        ;# Bank  65 VCCO - VCC1V2 Net "DDR4_C0_CS_B2"   - IO_L23N_T3U_N9_PERSTN1_I2C_SDA_65
set_property -dict {PACKAGE_PIN BH45 IOSTANDARD SSTL12_DCI}              [ get_ports  {ddr_ba[0]} ]           ;# Bank  65 VCCO - VCC1V2 Net "DDR4_C0_BA0"     - IO_L14N_T2L_N3_GC_A05_D21_65
set_property -dict {PACKAGE_PIN BG45 IOSTANDARD SSTL12_DCI}              [ get_ports  {ddr_addr[10]} ]        ;# Bank  65 VCCO - VCC1V2 Net "DDR4_C0_ADR10"   - IO_L18N_T2U_N11_AD2N_D13_65
set_property -dict {PACKAGE_PIN BJ46 IOSTANDARD DIFF_SSTL12_DCI}         [ get_ports  {ddr_ck_n[0]} ]         ;# Bank  65 VCCO - VCC1V2 Net "DDR4_C0_CK_C0"   - IO_L16N_T2U_N7_QBC_AD3N_A01_D17_65
set_property -dict {PACKAGE_PIN BH46 IOSTANDARD DIFF_SSTL12_DCI}         [ get_ports  {ddr_ck_p[0]} ]         ;# Bank  65 VCCO - VCC1V2 Net "DDR4_C0_CK_T0"   - IO_L16P_T2U_N6_QBC_AD3P_A00_D16_65
#set_property -dict {PACKAGE_PIN BK41 IOSTANDARD DIFF_SSTL12_DCI}         [ get_ports  {ddr_ck_n[1]} ]        ;# Bank  65 VCCO - VCC1V2 Net "DDR4_C0_CK_C1"   - IO_L15N_T2L_N5_AD11N_A03_D19_65
#set_property -dict {PACKAGE_PIN BJ41 IOSTANDARD DIFF_SSTL12_DCI}         [ get_ports  {ddr_ck_p[1]} ]        ;# Bank  65 VCCO - VCC1V2 Net "DDR4_C0_CK_T1"   - IO_L15P_T2L_N4_AD11P_A02_D18_65
set_property -dict {PACKAGE_PIN BM47 IOSTANDARD SSTL12_DCI}              [ get_ports  {ddr_ba[1]} ]           ;# Bank  65 VCCO - VCC1V2 Net "DDR4_C0_BA1"     - IO_L7N_T1L_N1_QBC_AD13N_A19_65
set_property -dict {PACKAGE_PIN BF45 IOSTANDARD SSTL12_DCI}              [ get_ports  {ddr_parity} ]          ;# Bank  65 VCCO - VCC1V2 Net "DDR4_C0_PAR"     - IO_L20P_T3L_N2_AD1P_D08_65
set_property -dict {PACKAGE_PIN BF46 IOSTANDARD SSTL12_DCI}              [ get_ports  {ddr_addr[0]} ]         ;# Bank  65 VCCO - VCC1V2 Net "DDR4_C0_ADR0"    - IO_L20N_T3L_N3_AD1N_D09_65
set_property -dict {PACKAGE_PIN BK45 IOSTANDARD SSTL12_DCI}              [ get_ports  {ddr_addr[2]} ]         ;# Bank  65 VCCO - VCC1V2 Net "DDR4_C0_ADR2"    - IO_L10P_T1U_N6_QBC_AD4P_A12_D28_65
set_property -dict {PACKAGE_PIN BG43 IOSTANDARD SSTL12_DCI}              [ get_ports  {ddr_addr[1]} ]         ;# Bank  65 VCCO - VCC1V2 Net "DDR4_C0_ADR1"    - IO_L17N_T2U_N9_AD10N_D15_65
set_property -dict {PACKAGE_PIN BL45 IOSTANDARD SSTL12_DCI}              [ get_ports  {ddr_addr[4]} ]         ;# Bank  65 VCCO - VCC1V2 Net "DDR4_C0_ADR4"    - IO_L8P_T1L_N2_AD5P_A16_65
set_property -dict {PACKAGE_PIN BF42 IOSTANDARD SSTL12_DCI}              [ get_ports  {ddr_addr[3]} ]         ;# Bank  65 VCCO - VCC1V2 Net "DDR4_C0_ADR3"    - IO_L21P_T3L_N4_AD8P_D06_65
#set_property -dict {PACKAGE_PIN BC42 IOSTANDARD LVCMOS12}                [ get_ports  {c0_ddr4_alert_n} ]        ;# Bank  65 VCCO - VCC1V2 Net "DDR4_C0_ALERT_B" - IO_L23P_T3U_N8_I2C_SCLK_65
set_property -dict {PACKAGE_PIN BK43 IOSTANDARD SSTL12_DCI}              [ get_ports  {ddr_addr[8]} ]         ;# Bank  65 VCCO - VCC1V2 Net "DDR4_C0_ADR8"    - IO_L11P_T1U_N8_GC_A10_D26_65
set_property -dict {PACKAGE_PIN BL43 IOSTANDARD SSTL12_DCI}              [ get_ports  {ddr_addr[7]} ]         ;# Bank  65 VCCO - VCC1V2 Net "DDR4_C0_ADR7"    - IO_L9N_T1L_N5_AD12N_A15_D31_65
set_property -dict {PACKAGE_PIN BD41 IOSTANDARD SSTL12_DCI}              [ get_ports  {ddr_addr[11]} ]        ;# Bank  65 VCCO - VCC1V2 Net "DDR4_C0_ADR11"   - IO_L19P_T3L_N0_DBC_AD9P_D10_65
set_property -dict {PACKAGE_PIN BM42 IOSTANDARD SSTL12_DCI}              [ get_ports  {ddr_addr[9]} ]         ;# Bank  65 VCCO - VCC1V2 Net "DDR4_C0_ADR9"    - IO_T1U_N12_SMBALERT_65
set_property -dict {PACKAGE_PIN BF43 IOSTANDARD SSTL12_DCI}              [ get_ports  {ddr_addr[5]} ]         ;# Bank  65 VCCO - VCC1V2 Net "DDR4_C0_ADR5"    - IO_L21N_T3L_N5_AD8N_D07_65
set_property -dict {PACKAGE_PIN BG42 IOSTANDARD SSTL12_DCI}              [ get_ports  {ddr_addr[6]} ]         ;# Bank  65 VCCO - VCC1V2 Net "DDR4_C0_ADR6"    - IO_L17P_T2U_N8_AD10P_D14_65
#set_property -dict {PACKAGE_PIN BJ42 IOSTANDARD SSTL12_DCI}              [ get_ports  {c0_ddr4_cke[1]} ]         ;# Bank  65 VCCO - VCC1V2 Net "DDR4_C0_CKE1"    - IO_L13N_T2L_N1_GC_QBC_A07_D23_65
set_property -dict {PACKAGE_PIN BE41 IOSTANDARD SSTL12_DCI}              [ get_ports  {ddr_bg[1]} ]           ;# Bank  65 VCCO - VCC1V2 Net "DDR4_C0_BG1"     - IO_L19N_T3L_N1_DBC_AD9N_D11_65
set_property -dict {PACKAGE_PIN BL42 IOSTANDARD SSTL12_DCI}              [ get_ports  {ddr_addr[12]} ]        ;# Bank  65 VCCO - VCC1V2 Net "DDR4_C0_ADR12"   - IO_L9P_T1L_N4_AD12P_A14_D30_65
set_property -dict {PACKAGE_PIN BH41 IOSTANDARD SSTL12_DCI}              [ get_ports  {ddr_act_n} ]           ;# Bank  65 VCCO - VCC1V2 Net "DDR4_C0_ACT_B"   - IO_T2U_N12_CSI_ADV_B_65
set_property -dict {PACKAGE_PIN BH42 IOSTANDARD SSTL12_DCI}              [ get_ports  {ddr_cke[0]} ]          ;# Bank  65 VCCO - VCC1V2 Net "DDR4_C0_CKE0"    - IO_L13P_T2L_N0_GC_QBC_A06_D22_65
set_property -dict {PACKAGE_PIN BF41 IOSTANDARD SSTL12_DCI}              [ get_ports  {ddr_bg[0]} ]           ;# Bank  65 VCCO - VCC1V2 Net "DDR4_C0_BG0"     - IO_T3U_N12_PERSTN0_65
set_property -dict {PACKAGE_PIN BE53 IOSTANDARD POD12_DCI}               [ get_ports  {ddr_dq[66]} ]          ;# Bank  66 VCCO - VCC1V2 Net "DDR4_C0_DQ66"    - IO_L18P_T2U_N10_AD2P_66
set_property -dict {PACKAGE_PIN BE54 IOSTANDARD POD12_DCI}               [ get_ports  {ddr_dq[67]} ]          ;# Bank  66 VCCO - VCC1V2 Net "DDR4_C0_DQ67"    - IO_L18N_T2U_N11_AD2N_66
set_property -dict {PACKAGE_PIN BJ54 IOSTANDARD DIFF_POD12_DCI}          [ get_ports  {ddr_dqs_n[16]} ]       ;# Bank  66 VCCO - VCC1V2 Net "DDR4_C0_DQS_C8"  - IO_L16N_T2U_N7_QBC_AD3N_66
set_property -dict {PACKAGE_PIN BH54 IOSTANDARD DIFF_POD12_DCI}          [ get_ports  {ddr_dqs_p[16]} ]       ;# Bank  66 VCCO - VCC1V2 Net "DDR4_C0_DQS_T8"  - IO_L16P_T2U_N6_QBC_AD3P_66
set_property -dict {PACKAGE_PIN BG54 IOSTANDARD POD12_DCI}               [ get_ports  {ddr_dq[64]} ]          ;# Bank  66 VCCO - VCC1V2 Net "DDR4_C0_DQ64"    - IO_L17N_T2U_N9_AD10N_66
set_property -dict {PACKAGE_PIN BG53 IOSTANDARD POD12_DCI}               [ get_ports  {ddr_dq[65]} ]          ;# Bank  66 VCCO - VCC1V2 Net "DDR4_C0_DQ65"    - IO_L17P_T2U_N8_AD10P_66
set_property -dict {PACKAGE_PIN BK53 IOSTANDARD POD12_DCI}               [ get_ports  {ddr_dq[71]} ]          ;# Bank  66 VCCO - VCC1V2 Net "DDR4_C0_DQ71"    - IO_L15P_T2L_N4_AD11P_66
set_property -dict {PACKAGE_PIN BK54 IOSTANDARD POD12_DCI}               [ get_ports  {ddr_dq[70]} ]          ;# Bank  66 VCCO - VCC1V2 Net "DDR4_C0_DQ70"    - IO_L15N_T2L_N5_AD11N_66
set_property -dict {PACKAGE_PIN BH52 IOSTANDARD POD12_DCI}               [ get_ports  {ddr_dq[68]} ]          ;# Bank  66 VCCO - VCC1V2 Net "DDR4_C0_DQ68"    - IO_L14N_T2L_N3_GC_66
set_property -dict {PACKAGE_PIN BG52 IOSTANDARD POD12_DCI}               [ get_ports  {ddr_dq[69]} ]          ;# Bank  66 VCCO - VCC1V2 Net "DDR4_C0_DQ69"    - IO_L14P_T2L_N2_GC_66
set_property -dict {PACKAGE_PIN BJ53 IOSTANDARD DIFF_POD12_DCI}          [ get_ports  {ddr_dqs_n[17]} ]       ;# Bank  66 VCCO - VCC1V2 Net "DDR4_C0_DQS_C17" - IO_L13N_T2L_N1_GC_QBC_66
set_property -dict {PACKAGE_PIN BJ52 IOSTANDARD DIFF_POD12_DCI}          [ get_ports  {ddr_dqs_p[17]} ]       ;# Bank  66 VCCO - VCC1V2 Net "DDR4_C0_DQS_T17" - IO_L13P_T2L_N0_GC_QBC_66
set_property -dict {PACKAGE_PIN BL52 IOSTANDARD POD12_DCI}               [ get_ports  {ddr_dq[34]} ]          ;# Bank  66 VCCO - VCC1V2 Net "DDR4_C0_DQ34"    - IO_L6P_T0U_N10_AD6P_66
set_property -dict {PACKAGE_PIN BL51 IOSTANDARD POD12_DCI}               [ get_ports  {ddr_dq[35]} ]          ;# Bank  66 VCCO - VCC1V2 Net "DDR4_C0_DQ35"    - IO_L5P_T0U_N8_AD14P_66
set_property -dict {PACKAGE_PIN BM50 IOSTANDARD DIFF_POD12_DCI}          [ get_ports  {ddr_dqs_n[8]} ]        ;# Bank  66 VCCO - VCC1V2 Net "DDR4_C0_DQS_C4"  - IO_L4N_T0U_N7_DBC_AD7N_66
set_property -dict {PACKAGE_PIN BM49 IOSTANDARD DIFF_POD12_DCI}          [ get_ports  {ddr_dqs_p[8]} ]        ;# Bank  66 VCCO - VCC1V2 Net "DDR4_C0_DQS_T4"  - IO_L4P_T0U_N6_DBC_AD7P_66
#set_property -dict {PACKAGE_PIN BK29 IOSTANDARD LVCMOS12}                [ get_ports  {c0_ddr4_event_n} ]        ;# Bank  64 VCCO - VCC1V2 Net "DDR4_C0_EVENT_B" - IO_T3U_N12_64
set_property -dict {PACKAGE_PIN BL53 IOSTANDARD POD12_DCI}               [ get_ports  {ddr_dq[33]} ]          ;# Bank  66 VCCO - VCC1V2 Net "DDR4_C0_DQ33"    - IO_L6N_T0U_N11_AD6N_66
set_property -dict {PACKAGE_PIN BM52 IOSTANDARD POD12_DCI}               [ get_ports  {ddr_dq[32]} ]          ;# Bank  66 VCCO - VCC1V2 Net "DDR4_C0_DQ32"    - IO_L5N_T0U_N9_AD14N_66
set_property -dict {PACKAGE_PIN BN49 IOSTANDARD POD12_DCI}               [ get_ports  {ddr_dq[38]} ]          ;# Bank  66 VCCO - VCC1V2 Net "DDR4_C0_DQ38"    - IO_L3N_T0L_N5_AD15N_66
set_property -dict {PACKAGE_PIN BM48 IOSTANDARD POD12_DCI}               [ get_ports  {ddr_dq[39]} ]          ;# Bank  66 VCCO - VCC1V2 Net "DDR4_C0_DQ39"    - IO_L3P_T0L_N4_AD15P_66
set_property -dict {PACKAGE_PIN BN51 IOSTANDARD POD12_DCI}               [ get_ports  {ddr_dq[37]} ]          ;# Bank  66 VCCO - VCC1V2 Net "DDR4_C0_DQ37"    - IO_L2N_T0L_N3_66
set_property -dict {PACKAGE_PIN BN50 IOSTANDARD POD12_DCI}               [ get_ports  {ddr_dq[36]} ]          ;# Bank  66 VCCO - VCC1V2 Net "DDR4_C0_DQ36"    - IO_L2P_T0L_N2_66
set_property -dict {PACKAGE_PIN BP49 IOSTANDARD DIFF_POD12_DCI}          [ get_ports  {ddr_dqs_n[9]} ]        ;# Bank  66 VCCO - VCC1V2 Net "DDR4_C0_DQS_C13" - IO_L1N_T0L_N1_DBC_66
set_property -dict {PACKAGE_PIN BP48 IOSTANDARD DIFF_POD12_DCI}          [ get_ports  {ddr_dqs_p[9]} ]        ;# Bank  66 VCCO - VCC1V2 Net "DDR4_C0_DQS_T13" - IO_L1P_T0L_N0_DBC_66
set_property -dict {PACKAGE_PIN BH35 IOSTANDARD POD12_DCI}               [ get_ports  {ddr_dq[25]} ]          ;# Bank  64 VCCO - VCC1V2 Net "DDR4_C0_DQ25"    - IO_L18N_T2U_N11_AD2N_64
set_property -dict {PACKAGE_PIN BH34 IOSTANDARD POD12_DCI}               [ get_ports  {ddr_dq[24]} ]          ;# Bank  64 VCCO - VCC1V2 Net "DDR4_C0_DQ24"    - IO_L18P_T2U_N10_AD2P_64
set_property -dict {PACKAGE_PIN BK35 IOSTANDARD DIFF_POD12_DCI}          [ get_ports  {ddr_dqs_n[6]} ]        ;# Bank  64 VCCO - VCC1V2 Net "DDR4_C0_DQS_C3"  - IO_L16N_T2U_N7_QBC_AD3N_64
set_property -dict {PACKAGE_PIN BK34 IOSTANDARD DIFF_POD12_DCI}          [ get_ports  {ddr_dqs_p[6]} ]        ;# Bank  64 VCCO - VCC1V2 Net "DDR4_C0_DQS_T3"  - IO_L16P_T2U_N6_QBC_AD3P_64
set_property -dict {PACKAGE_PIN BG33 IOSTANDARD LVCMOS12}                [ get_ports  {ddr_reset_n} ]         ;# Bank  64 VCCO - VCC1V2 Net "DDR4_C0_RESET_N" - IO_T2U_N12_64
set_property -dict {PACKAGE_PIN BF36 IOSTANDARD POD12_DCI}               [ get_ports  {ddr_dq[27]} ]          ;# Bank  64 VCCO - VCC1V2 Net "DDR4_C0_DQ27"    - IO_L17N_T2U_N9_AD10N_64
set_property -dict {PACKAGE_PIN BF35 IOSTANDARD POD12_DCI}               [ get_ports  {ddr_dq[26]} ]          ;# Bank  64 VCCO - VCC1V2 Net "DDR4_C0_DQ26"    - IO_L17P_T2U_N8_AD10P_64
set_property -dict {PACKAGE_PIN BJ34 IOSTANDARD POD12_DCI}               [ get_ports  {ddr_dq[29]} ]          ;# Bank  64 VCCO - VCC1V2 Net "DDR4_C0_DQ29"    - IO_L14N_T2L_N3_GC_64
set_property -dict {PACKAGE_PIN BJ33 IOSTANDARD POD12_DCI}               [ get_ports  {ddr_dq[28]} ]          ;# Bank  64 VCCO - VCC1V2 Net "DDR4_C0_DQ28"    - IO_L14P_T2L_N2_GC_64
set_property -dict {PACKAGE_PIN BG34 IOSTANDARD POD12_DCI}               [ get_ports  {ddr_dq[30]} ]          ;# Bank  64 VCCO - VCC1V2 Net "DDR4_C0_DQ30"    - IO_L15P_T2L_N4_AD11P_64
set_property -dict {PACKAGE_PIN BG35 IOSTANDARD POD12_DCI}               [ get_ports  {ddr_dq[31]} ]          ;# Bank  64 VCCO - VCC1V2 Net "DDR4_C0_DQ31"    - IO_L15N_T2L_N5_AD11N_64
set_property -dict {PACKAGE_PIN BJ32 IOSTANDARD DIFF_POD12_DCI}          [ get_ports  {ddr_dqs_n[7]} ]        ;# Bank  64 VCCO - VCC1V2 Net "DDR4_C0_DQS_C12" - IO_L13N_T2L_N1_GC_QBC_64
set_property -dict {PACKAGE_PIN BH32 IOSTANDARD DIFF_POD12_DCI}          [ get_ports  {ddr_dqs_p[7]} ]        ;# Bank  64 VCCO - VCC1V2 Net "DDR4_C0_DQS_T12" - IO_L13P_T2L_N0_GC_QBC_64
set_property -dict {PACKAGE_PIN BL31 IOSTANDARD POD12_DCI}               [ get_ports  {ddr_dq[17]} ]          ;# Bank  64 VCCO - VCC1V2 Net "DDR4_C0_DQ17"    - IO_L11N_T1U_N9_GC_64
set_property -dict {PACKAGE_PIN BK31 IOSTANDARD POD12_DCI}               [ get_ports  {ddr_dq[16]} ]          ;# Bank  64 VCCO - VCC1V2 Net "DDR4_C0_DQ16"    - IO_L11P_T1U_N8_GC_64
set_property -dict {PACKAGE_PIN BM35 IOSTANDARD DIFF_POD12_DCI}          [ get_ports  {ddr_dqs_n[4]} ]        ;# Bank  64 VCCO - VCC1V2 Net "DDR4_C0_DQS_C2"  - IO_L10N_T1U_N7_QBC_AD4N_64
set_property -dict {PACKAGE_PIN BL35 IOSTANDARD DIFF_POD12_DCI}          [ get_ports  {ddr_dqs_p[4]} ]        ;# Bank  64 VCCO - VCC1V2 Net "DDR4_C0_DQS_T2"  - IO_L10P_T1U_N6_QBC_AD4P_64
set_property -dict {PACKAGE_PIN BL33 IOSTANDARD POD12_DCI}               [ get_ports  {ddr_dq[19]} ]          ;# Bank  64 VCCO - VCC1V2 Net "DDR4_C0_DQ19"    - IO_L12N_T1U_N11_GC_64
set_property -dict {PACKAGE_PIN BK33 IOSTANDARD POD12_DCI}               [ get_ports  {ddr_dq[18]} ]          ;# Bank  64 VCCO - VCC1V2 Net "DDR4_C0_DQ18"    - IO_L12P_T1U_N10_GC_64
set_property -dict {PACKAGE_PIN BM33 IOSTANDARD POD12_DCI}               [ get_ports  {ddr_dq[21]} ]          ;# Bank  64 VCCO - VCC1V2 Net "DDR4_C0_DQ21"    - IO_L9N_T1L_N5_AD12N_64
set_property -dict {PACKAGE_PIN BL32 IOSTANDARD POD12_DCI}               [ get_ports  {ddr_dq[20]} ]          ;# Bank  64 VCCO - VCC1V2 Net "DDR4_C0_DQ20"    - IO_L9P_T1L_N4_AD12P_64
set_property -dict {PACKAGE_PIN BP34 IOSTANDARD POD12_DCI}               [ get_ports  {ddr_dq[23]} ]          ;# Bank  64 VCCO - VCC1V2 Net "DDR4_C0_DQ23"    - IO_L8N_T1L_N3_AD5N_64
set_property -dict {PACKAGE_PIN BN34 IOSTANDARD POD12_DCI}               [ get_ports  {ddr_dq[22]} ]          ;# Bank  64 VCCO - VCC1V2 Net "DDR4_C0_DQ22"    - IO_L8P_T1L_N2_AD5P_64
set_property -dict {PACKAGE_PIN BN35 IOSTANDARD DIFF_POD12_DCI}          [ get_ports  {ddr_dqs_n[5]} ]        ;# Bank  64 VCCO - VCC1V2 Net "DDR4_C0_DQS_C11" - IO_L7N_T1L_N1_QBC_AD13N_64
set_property -dict {PACKAGE_PIN BM34 IOSTANDARD DIFF_POD12_DCI}          [ get_ports  {ddr_dqs_p[5]} ]        ;# Bank  64 VCCO - VCC1V2 Net "DDR4_C0_DQS_T11" - IO_L7P_T1L_N0_QBC_AD13P_64
set_property -dict {PACKAGE_PIN BM44 IOSTANDARD POD12_DCI}               [ get_ports  {ddr_dq[58]} ]          ;# Bank  65 VCCO - VCC1V2 Net "DDR4_C0_DQ58"    - IO_L5P_T0U_N8_AD14P_A22_65
set_property -dict {PACKAGE_PIN BN45 IOSTANDARD POD12_DCI}               [ get_ports  {ddr_dq[57]} ]          ;# Bank  65 VCCO - VCC1V2 Net "DDR4_C0_DQ57"    - IO_L6N_T0U_N11_AD6N_A21_65
set_property -dict {PACKAGE_PIN BP46 IOSTANDARD DIFF_POD12_DCI}          [ get_ports  {ddr_dqs_n[14]} ]       ;# Bank  65 VCCO - VCC1V2 Net "DDR4_C0_DQS_C7"  - IO_L4N_T0U_N7_DBC_AD7N_A25_65
set_property -dict {PACKAGE_PIN BN46 IOSTANDARD DIFF_POD12_DCI}          [ get_ports  {ddr_dqs_p[14]} ]       ;# Bank  65 VCCO - VCC1V2 Net "DDR4_C0_DQS_T7"  - IO_L4P_T0U_N6_DBC_AD7P_A24_65
set_property -dict {PACKAGE_PIN BM45 IOSTANDARD POD12_DCI}               [ get_ports  {ddr_dq[59]} ]          ;# Bank  65 VCCO - VCC1V2 Net "DDR4_C0_DQ59"    - IO_L6P_T0U_N10_AD6P_A20_65
set_property -dict {PACKAGE_PIN BN44 IOSTANDARD POD12_DCI}               [ get_ports  {ddr_dq[56]} ]          ;# Bank  65 VCCO - VCC1V2 Net "DDR4_C0_DQ56"    - IO_L5N_T0U_N9_AD14N_A23_65
set_property -dict {PACKAGE_PIN BP44 IOSTANDARD POD12_DCI}               [ get_ports  {ddr_dq[61]} ]          ;# Bank  65 VCCO - VCC1V2 Net "DDR4_C0_DQ61"    - IO_L3N_T0L_N5_AD15N_A27_65
set_property -dict {PACKAGE_PIN BP43 IOSTANDARD POD12_DCI}               [ get_ports  {ddr_dq[60]} ]          ;# Bank  65 VCCO - VCC1V2 Net "DDR4_C0_DQ60"    - IO_L3P_T0L_N4_AD15P_A26_65
set_property -dict {PACKAGE_PIN BP47 IOSTANDARD POD12_DCI}               [ get_ports  {ddr_dq[63]} ]          ;# Bank  65 VCCO - VCC1V2 Net "DDR4_C0_DQ63"    - IO_L2N_T0L_N3_FWE_FCS2_B_65
set_property -dict {PACKAGE_PIN BN47 IOSTANDARD POD12_DCI}               [ get_ports  {ddr_dq[62]} ]          ;# Bank  65 VCCO - VCC1V2 Net "DDR4_C0_DQ62"    - IO_L2P_T0L_N2_FOE_B_65
set_property -dict {PACKAGE_PIN BP42 IOSTANDARD DIFF_POD12_DCI}          [ get_ports  {ddr_dqs_n[15]} ]       ;# Bank  65 VCCO - VCC1V2 Net "DDR4_C0_DQS_C16" - IO_L1N_T0L_N1_DBC_RS1_65
set_property -dict {PACKAGE_PIN BN42 IOSTANDARD DIFF_POD12_DCI}          [ get_ports  {ddr_dqs_p[15]} ]       ;# Bank  65 VCCO - VCC1V2 Net "DDR4_C0_DQS_T16" - IO_L1P_T0L_N0_DBC_RS0_65
set_property -dict {PACKAGE_PIN BE50 IOSTANDARD POD12_DCI}               [ get_ports  {ddr_dq[40]} ]          ;# Bank  66 VCCO - VCC1V2 Net "DDR4_C0_DQ40"    - IO_L23N_T3U_N9_66
set_property -dict {PACKAGE_PIN BE49 IOSTANDARD POD12_DCI}               [ get_ports  {ddr_dq[41]} ]          ;# Bank  66 VCCO - VCC1V2 Net "DDR4_C0_DQ41"    - IO_L23P_T3U_N8_66
set_property -dict {PACKAGE_PIN BF48 IOSTANDARD DIFF_POD12_DCI}          [ get_ports  {ddr_dqs_n[10]} ]       ;# Bank  66 VCCO - VCC1V2 Net "DDR4_C0_DQS_C5"  - IO_L22N_T3U_N7_DBC_AD0N_66
set_property -dict {PACKAGE_PIN BF47 IOSTANDARD DIFF_POD12_DCI}          [ get_ports  {ddr_dqs_p[10]} ]       ;# Bank  66 VCCO - VCC1V2 Net "DDR4_C0_DQS_T5"  - IO_L22P_T3U_N6_DBC_AD0P_66
set_property -dict {PACKAGE_PIN BE51 IOSTANDARD POD12_DCI}               [ get_ports  {ddr_dq[42]} ]          ;# Bank  66 VCCO - VCC1V2 Net "DDR4_C0_DQ42"    - IO_L24N_T3U_N11_66
set_property -dict {PACKAGE_PIN BD51 IOSTANDARD POD12_DCI}               [ get_ports  {ddr_dq[43]} ]          ;# Bank  66 VCCO - VCC1V2 Net "DDR4_C0_DQ43"    - IO_L24P_T3U_N10_66
set_property -dict {PACKAGE_PIN BF50 IOSTANDARD POD12_DCI}               [ get_ports  {ddr_dq[47]} ]          ;# Bank  66 VCCO - VCC1V2 Net "DDR4_C0_DQ47"    - IO_L20P_T3L_N2_AD1P_66
set_property -dict {PACKAGE_PIN BG50 IOSTANDARD POD12_DCI}               [ get_ports  {ddr_dq[46]} ]          ;# Bank  66 VCCO - VCC1V2 Net "DDR4_C0_DQ46"    - IO_L20N_T3L_N3_AD1N_66
set_property -dict {PACKAGE_PIN BF52 IOSTANDARD POD12_DCI}               [ get_ports  {ddr_dq[44]} ]          ;# Bank  66 VCCO - VCC1V2 Net "DDR4_C0_DQ44"    - IO_L21N_T3L_N5_AD8N_66
set_property -dict {PACKAGE_PIN BF51 IOSTANDARD POD12_DCI}               [ get_ports  {ddr_dq[45]} ]          ;# Bank  66 VCCO - VCC1V2 Net "DDR4_C0_DQ45"    - L21_T3L_N4_AD8  P_66
set_property -dict {PACKAGE_PIN BG49 IOSTANDARD DIFF_POD12_DCI}          [ get_ports  {ddr_dqs_n[11]} ]       ;# Bank  66 VCCO - VCC1V2 Net "DDR4_C0_DQS_C14" - IO_L19N_T3L_N1_DBC_AD9N_66
set_property -dict {PACKAGE_PIN BG48 IOSTANDARD DIFF_POD12_DCI}          [ get_ports  {ddr_dqs_p[11]} ]       ;# Bank  66 VCCO - VCC1V2 Net "DDR4_C0_DQS_T14" - IO_L19P_T3L_N0_DBC_AD9P_66
set_property -dict {PACKAGE_PIN BJ51 IOSTANDARD POD12_DCI}               [ get_ports  {ddr_dq[49]} ]          ;# Bank  66 VCCO - VCC1V2 Net "DDR4_C0_DQ49"    - IO_L11N_T1U_N9_GC_66
set_property -dict {PACKAGE_PIN BH51 IOSTANDARD POD12_DCI}               [ get_ports  {ddr_dq[50]} ]          ;# Bank  66 VCCO - VCC1V2 Net "DDR4_C0_DQ50"    - IO_L11P_T1U_N8_GC_66
set_property -dict {PACKAGE_PIN BJ47 IOSTANDARD DIFF_POD12_DCI}          [ get_ports  {ddr_dqs_n[12]} ]       ;# Bank  66 VCCO - VCC1V2 Net "DDR4_C0_DQS_C6"  - IO_L10N_T1U_N7_QBC_AD4N_66
set_property -dict {PACKAGE_PIN BH47 IOSTANDARD DIFF_POD12_DCI}          [ get_ports  {ddr_dqs_p[12]} ]       ;# Bank  66 VCCO - VCC1V2 Net "DDR4_C0_DQS_T6"  - IO_L10P_T1U_N6_QBC_AD4P_66
set_property -dict {PACKAGE_PIN BH50 IOSTANDARD POD12_DCI}               [ get_ports  {ddr_dq[48]} ]          ;# Bank  66 VCCO - VCC1V2 Net "DDR4_C0_DQ48"    - IO_L12N_T1U_N11_GC_66
set_property -dict {PACKAGE_PIN BH49 IOSTANDARD POD12_DCI}               [ get_ports  {ddr_dq[51]} ]          ;# Bank  66 VCCO - VCC1V2 Net "DDR4_C0_DQ51"    - IO_L12P_T1U_N10_GC_66
set_property -dict {PACKAGE_PIN BK50 IOSTANDARD POD12_DCI}               [ get_ports  {ddr_dq[52]} ]          ;# Bank  66 VCCO - VCC1V2 Net "DDR4_C0_DQ52"    - IO_L8P_T1L_N2_AD5P_66
set_property -dict {PACKAGE_PIN BJ48 IOSTANDARD POD12_DCI}               [ get_ports  {ddr_dq[55]} ]          ;# Bank  66 VCCO - VCC1V2 Net "DDR4_C0_DQ55"    - IO_L9P_T1L_N4_AD12P_66
set_property -dict {PACKAGE_PIN BK51 IOSTANDARD POD12_DCI}               [ get_ports  {ddr_dq[53]} ]          ;# Bank  66 VCCO - VCC1V2 Net "DDR4_C0_DQ53"    - IO_L8N_T1L_N3_AD5N_66
set_property -dict {PACKAGE_PIN BJ49 IOSTANDARD POD12_DCI}               [ get_ports  {ddr_dq[54]} ]          ;# Bank  66 VCCO - VCC1V2 Net "DDR4_C0_DQ54"    - IO_L9N_T1L_N5_AD12N_66
set_property -dict {PACKAGE_PIN BK49 IOSTANDARD DIFF_POD12_DCI}          [ get_ports  {ddr_dqs_n[13]} ]       ;# Bank  66 VCCO - VCC1V2 Net "DDR4_C0_DQS_C15" - IO_L7N_T1L_N1_QBC_AD13N_66
set_property -dict {PACKAGE_PIN BK48 IOSTANDARD DIFF_POD12_DCI}          [ get_ports  {ddr_dqs_p[13]} ]       ;# Bank  66 VCCO - VCC1V2 Net "DDR4_C0_DQS_T15" - IO_L7P_T1L_N0_QBC_AD13P_66
set_property -dict {PACKAGE_PIN BL30 IOSTANDARD POD12_DCI}               [ get_ports  {ddr_dq[2]} ]           ;# Bank  64 VCCO - VCC1V2 Net "DDR4_C0_DQ2"     - IO_L5P_T0U_N8_AD14P_64
set_property -dict {PACKAGE_PIN BM30 IOSTANDARD POD12_DCI}               [ get_ports  {ddr_dq[3]} ]           ;# Bank  64 VCCO - VCC1V2 Net "DDR4_C0_DQ3"     - IO_L5N_T0U_N9_AD14N_64
set_property -dict {PACKAGE_PIN BN30 IOSTANDARD DIFF_POD12_DCI}          [ get_ports  {ddr_dqs_n[0]} ]        ;# Bank  64 VCCO - VCC1V2 Net "DDR4_C0_DQS_C0"  - IO_L4N_T0U_N7_DBC_AD7N_64
set_property -dict {PACKAGE_PIN BN29 IOSTANDARD DIFF_POD12_DCI}          [ get_ports  {ddr_dqs_p[0]} ]        ;# Bank  64 VCCO - VCC1V2 Net "DDR4_C0_DQS_T0"  - IO_L4P_T0U_N6_DBC_AD7P_64
set_property -dict {PACKAGE_PIN BP32 IOSTANDARD POD12_DCI}               [ get_ports  {ddr_dq[1]} ]           ;# Bank  64 VCCO - VCC1V2 Net "DDR4_C0_DQ1"     - IO_L6N_T0U_N11_AD6N_64
set_property -dict {PACKAGE_PIN BN32 IOSTANDARD POD12_DCI}               [ get_ports  {ddr_dq[0]} ]           ;# Bank  64 VCCO - VCC1V2 Net "DDR4_C0_DQ0"     - IO_L6P_T0U_N10_AD6P_64
set_property -dict {PACKAGE_PIN BP31 IOSTANDARD POD12_DCI}               [ get_ports  {ddr_dq[6]} ]           ;# Bank  64 VCCO - VCC1V2 Net "DDR4_C0_DQ6"     - IO_L3N_T0L_N5_AD15N_64
set_property -dict {PACKAGE_PIN BN31 IOSTANDARD POD12_DCI}               [ get_ports  {ddr_dq[7]} ]           ;# Bank  64 VCCO - VCC1V2 Net "DDR4_C0_DQ7"     - IO_L3P_T0L_N4_AD15P_64
set_property -dict {PACKAGE_PIN BP29 IOSTANDARD POD12_DCI}               [ get_ports  {ddr_dq[4]} ]           ;# Bank  64 VCCO - VCC1V2 Net "DDR4_C0_DQ4"     - IO_L2N_T0L_N3_64
set_property -dict {PACKAGE_PIN BP28 IOSTANDARD POD12_DCI}               [ get_ports  {ddr_dq[5]} ]           ;# Bank  64 VCCO - VCC1V2 Net "DDR4_C0_DQ5"     - IO_L2P_T0L_N2_64
set_property -dict {PACKAGE_PIN BM29 IOSTANDARD DIFF_POD12_DCI}          [ get_ports  {ddr_dqs_n[1]} ]        ;# Bank  64 VCCO - VCC1V2 Net "DDR4_C0_DQS_C9"  - IO_L1N_T0L_N1_DBC_64
set_property -dict {PACKAGE_PIN BM28 IOSTANDARD DIFF_POD12_DCI}          [ get_ports  {ddr_dqs_p[1]} ]        ;# Bank  64 VCCO - VCC1V2 Net "DDR4_C0_DQS_T9"  - IO_L1P_T0L_N0_DBC_64
set_property -dict {PACKAGE_PIN BH31 IOSTANDARD POD12_DCI}               [ get_ports  {ddr_dq[9]} ]           ;# Bank  64 VCCO - VCC1V2 Net "DDR4_C0_DQ9"     - IO_L24P_T3U_N10_64
set_property -dict {PACKAGE_PIN BJ31 IOSTANDARD POD12_DCI}               [ get_ports  {ddr_dq[8]} ]           ;# Bank  64 VCCO - VCC1V2 Net "DDR4_C0_DQ8"     - IO_L24N_T3U_N11_64
set_property -dict {PACKAGE_PIN BK30 IOSTANDARD DIFF_POD12_DCI}          [ get_ports  {ddr_dqs_n[2]} ]        ;# Bank  64 VCCO - VCC1V2 Net "DDR4_C0_DQS_C1"  - IO_L22N_T3U_N7_DBC_AD0N_64
set_property -dict {PACKAGE_PIN BJ29 IOSTANDARD DIFF_POD12_DCI}          [ get_ports  {ddr_dqs_p[2]} ]        ;# Bank  64 VCCO - VCC1V2 Net "DDR4_C0_DQS_T1"  - IO_L22P_T3U_N6_DBC_AD0P_64
set_property -dict {PACKAGE_PIN BF32 IOSTANDARD POD12_DCI}               [ get_ports  {ddr_dq[10]} ]          ;# Bank  64 VCCO - VCC1V2 Net "DDR4_C0_DQ10"    - IO_L23P_T3U_N8_64
set_property -dict {PACKAGE_PIN BF33 IOSTANDARD POD12_DCI}               [ get_ports  {ddr_dq[11]} ]          ;# Bank  64 VCCO - VCC1V2 Net "DDR4_C0_DQ11"    - IO_L23N_T3U_N9_64
set_property -dict {PACKAGE_PIN BH29 IOSTANDARD POD12_DCI}               [ get_ports  {ddr_dq[12]} ]          ;# Bank  64 VCCO - VCC1V2 Net "DDR4_C0_DQ12"    - IO_L20P_T3L_N2_AD1P_64
set_property -dict {PACKAGE_PIN BH30 IOSTANDARD POD12_DCI}               [ get_ports  {ddr_dq[13]} ]          ;# Bank  64 VCCO - VCC1V2 Net "DDR4_C0_DQ13"    - IO_L20N_T3L_N3_AD1N_64
set_property -dict {PACKAGE_PIN BF31 IOSTANDARD POD12_DCI}               [ get_ports  {ddr_dq[14]} ]          ;# Bank  64 VCCO - VCC1V2 Net "DDR4_C0_DQ14"    - IO_L21P_T3L_N4_AD8P_64
set_property -dict {PACKAGE_PIN BG32 IOSTANDARD POD12_DCI}               [ get_ports  {ddr_dq[15]} ]          ;# Bank  64 VCCO - VCC1V2 Net "DDR4_C0_DQ15"    - IO_L21N_T3L_N5_AD8N_64
set_property -dict {PACKAGE_PIN BG30 IOSTANDARD DIFF_POD12_DCI}          [ get_ports  {ddr_dqs_n[3]} ]        ;# Bank  64 VCCO - VCC1V2 Net "DDR4_C0_DQS_C10" - IO_L19N_T3L_N1_DBC_AD9N_64
set_property -dict {PACKAGE_PIN BG29 IOSTANDARD DIFF_POD12_DCI}          [ get_ports  {ddr_dqs_p[3]} ]        ;# Bank  64 VCCO - VCC1V2 Net "DDR4_C0_DQS_T10" - IO_L19P_T3L_N0_DBC_AD9P_64

set_property -dict {PACKAGE_PIN D32 IOSTANDARD LVCMOS18}                 [get_ports hbm_cattrip]
set_property PULLTYPE PULLDOWN                                           [get_ports hbm_cattrip]