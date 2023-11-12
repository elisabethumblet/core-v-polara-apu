module fll_clk_mux (
    input   clk1,
    input   clk2,
    input   clksel,
    output  clkout
);

    assign clkout = clksel ? clk2 : clk1;

endmodule
