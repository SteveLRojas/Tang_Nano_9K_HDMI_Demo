module HDMI_demo(
        input wire inclk,  // 27MHz
        input sys_rst_n,        // reset input
        output reg [5:0] led,   // 6 LEDS pin

        output wire tmds_r_p,
        output wire tmds_r_n,
        output wire tmds_g_p,
        output wire tmds_g_n,
        output wire tmds_b_p,
        output wire tmds_b_n,
        output wire tmds_clk_p,
        output wire tmds_clk_n
    );

    wire clk_25;    //25MHz
    wire clk_250;  //250MHz
    wire draw_area;
    wire hsync;
    wire vsync;
    wire[7:0] red;
    wire[7:0] green;
    wire[7:0] blue;

    Gowin_rPLL pll_inst(.clkin(inclk),	.clkoutd(clk_25), .clkout(clk_250));

    reg rst;
    reg rst_s;

    initial
    begin
        rst = 1'b1;
        rst_s = 1'b1;
    end

    always @(posedge inclk)
    begin
        rst <= ~sys_rst_n;
        rst_s <= rst;
    end

    pattern_gen pattern_inst(
        .pixclk(clk_25),
        .rst(rst),
        .draw_area(draw_area),
        .hsync(hsync),  //active low
        .vsync(vsync),  //active low
        .red(red),
        .green(green),
        .blue(blue));

    vga_to_hdmi vga_to_hdmi_inst(
		.clk_25(clk_25),		// VGA clock
		.clk_250(clk_250),		// HDMI clock
		.vde(draw_area), 		// Active draw area
		.draw_vsync(vsync),
		.draw_hsync(hsync),
		.vga_r(red),
		.vga_g(green),
		.vga_b(blue),
		.tmds_r_p(tmds_r_p),
		.tmds_r_n(tmds_r_n),
		.tmds_g_p(tmds_g_p),
		.tmds_g_n(tmds_g_n),
		.tmds_b_p(tmds_b_p),
		.tmds_b_n(tmds_b_n),
		.tmds_clk_p(tmds_clk_p),
		.tmds_clk_n(tmds_clk_n));


    reg [23:0] counter;

    always @(posedge clk_25 or posedge rst)
    begin
        if(rst)
        begin
            counter <= 24'h000000;
            led <= 6'b111111;
        end
        else
        begin
            counter <= counter + 24'h000001;
            led <= counter[23:18];
        end
    end

endmodule
