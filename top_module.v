module top_module(
    input clk,
    input rst,
    
    input enterA,
    input enterB,
    input [2:0] letterIn,            
    
    output [7:0] led,
    output a_out,b_out,c_out,d_out,e_out,f_out,g_out,p_out,
    output [3:0] an
);

    // Clock Divider
    wire clk_50hz;
    clk_divider u_clk_divider (
        .clk_in(clk),
        .divided_clk(clk_50hz)
    );

    // Debouncers
    wire rst_db = ~rst; // Active high reset for internal logic if needed
    wire enterA_pulse, enterB_pulse;

    debouncer u_db_A (
        .clk(clk_50hz),
        .rst(rst_db),
        .noisy_in(~enterA), // Invert for active-low button
        .clean_out(enterA_pulse)
    );

    debouncer u_db_B (
        .clk(clk_50hz),
        .rst(rst_db),
        .noisy_in(~enterB),
        .clean_out(enterB_pulse)
    );

    //Mastermind Instance
    wire [7:0] game_leds;
    wire [7:0] disp0, disp1, disp2, disp3;

    mastermind u_mastermind (
        .clk(clk_50hz),
        .rst(rst),               
        .enterA(enterA_pulse),
        .enterB(enterB_pulse),
        .letterIn(letterIn),
        .LEDX(game_leds), 
        .SSD0(disp0),
        .SSD1(disp1),
        .SSD2(disp2),
        .SSD3(disp3)
    );

    // 4. SSD Driver
    wire [7:0] seven_bus;
    wire [3:0] segment_bus;
    
    ssd u_ssd (
        .clk(clk),
        .disp0(disp0),
        .disp1(disp1),
        .disp2(disp2),
        .disp3(disp3),
        .seven(seven_bus),
        .segment(segment_bus)
    );

    // Map SSD outputs
    assign a_out = seven_bus[0];
    assign b_out = seven_bus[1];
    assign c_out = seven_bus[2];
    assign d_out = seven_bus[3];
    assign e_out = seven_bus[4];
    assign f_out = seven_bus[5];
    assign g_out = seven_bus[6];
    assign p_out = seven_bus[7];
    assign an = segment_bus;


    assign led = game_leds;       

endmodule