module gf22_FLL (
    output FLLCLK,
    input  FLLOE,
    input  REFCLK,
    output LOCK,
    input  CFGREQ,
    output CFGACK,
    input  [1:0] CFGAD,
    input  [31:0] CFGD,
    output [31:0] CFGQ,
    input  CFGWEB,
    input  RSTB,
    input  PWD,
    input  RET,
    input  TM,
    input  TE,
    input  TD,
    output TQ,
    input  JTD,
    output JTQ
);

endmodule
