module fll_clk_div #(
    parameter NUM_FLOPS = 16
) (
    input   clk_in,
    output  clk_out
);

    reg [NUM_FLOPS-1:0] count = 0; 

    always @(posedge clk_in) begin
        count <= count + 1;
    end

    assign clk_out = count[NUM_FLOPS-1];

endmodule
