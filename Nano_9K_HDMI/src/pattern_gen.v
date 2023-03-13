module pattern_gen(
        input wire pixclk,
        input wire rst,
        output reg draw_area,
        output reg hsync,  //active low
        output reg vsync,  //active low
        output reg[7:0] red,
        output reg[7:0] green,
        output reg[7:0] blue);

    reg[9:0] counter_x;
    reg[9:0] counter_y;

    always @(posedge pixclk or posedge rst)
    begin
        if(rst)
        begin
            draw_area <= 1'b1;
            counter_x <= 10'h000;
            counter_y <= 10'h000;
            hsync <= 1'b1;
            vsync <= 1'b1;
        end
        else
        begin
            draw_area <= (counter_x < 640) && (counter_y < 480);
            counter_x <= (counter_x == 799) ? 0 : counter_x + 1;
            if(counter_x == 799)
                counter_y <= (counter_y == 524) ? 0 : counter_y + 1;
            hsync <= ~((counter_x >= 656) && (counter_x < 752));
            vsync <= ~((counter_y >= 490) && (counter_y < 492));
        end
    end

    wire[7:0] sig_W;
    wire[7:0] sig_A;

    assign sig_W = {8{counter_x[7:0] == counter_y[7:0]}};
    assign sig_A = {8{counter_x[7:5] == 3'h2 && counter_y[7:5] == 3'h2}};

    always @(posedge pixclk or posedge rst)
    begin
        if(rst)
        begin
            red <= 8'h00;
            green <= 8'h00;
            blue <= 8'h00;
        end
        else
        begin
            red <= ({counter_x[5:0] & {6{counter_y[4:3] == ~counter_x[4:3]}}, 2'b00} | sig_W) & ~sig_A;
            green <= (counter_x[7:0] & {8{counter_y[6]}} | sig_W) & ~sig_A;
            blue <= counter_y[7:0] | sig_W | sig_A;
        end
    end

endmodule
