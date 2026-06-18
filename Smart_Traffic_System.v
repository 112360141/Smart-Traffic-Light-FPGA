module Smart_Traffic_System (
    input  wire        CLK_50M,      
    input  wire        RST_N,        
    input  wire [2:1]  PED_BTN,      
    input  wire [2:1]  CAR_SENSOR,   
    input  wire        NIGHT_MODE,   
    output wire [2:0]  LEDR,         
    output wire [2:0]  LEDG,         
    output wire [6:0]  HEX3, HEX2,   
    output wire [6:0]  HEX1, HEX0,   
    output wire [7:0]  LCD_DATA,
    output wire        LCD_RS, LCD_RW, LCD_EN, LCD_ON, LCD_BLON
);

    wire clk_1Hz, clk_100Hz;
    wire ped_main_clean, ped_side_clean;
    wire [2:0] traffic_state;
    wire [6:0] main_red_timer;
    wire [6:0] side_red_timer; 

// 防彈跳
    Clock_Debounce u_clk (
        .clk_in(CLK_50M), .rst_n(RST_N),
        .btn_m_in(~PED_BTN[2]), .btn_s_in(~PED_BTN[1]), 
        .clk_1Hz(clk_1Hz), .clk_100Hz(clk_100Hz),
        .btn_m_out(ped_main_clean), .btn_s_out(ped_side_clean)
    );

// 交通狀態機
    Traffic_FSM u_fsm (
        .clk_100Hz(clk_100Hz),
        .clk_1Hz(clk_1Hz), .rst_n(RST_N),
        .night_mode(NIGHT_MODE),
        .ped_main_btn(ped_main_clean), .ped_side_btn(ped_side_clean),
        .car_main(CAR_SENSOR[2]), .car_side(CAR_SENSOR[1]),
        .led_main(LEDR), .led_side(LEDG),
        .state_out(traffic_state),
        .main_red_timer(main_red_timer),
        .side_red_timer(side_red_timer) 
    );	


    // 七段顯示器

    wire [3:0] bcd_tens_main = (LEDR[2]) ? (main_red_timer / 10) : 4'hF;
    wire [3:0] bcd_ones_main = (LEDR[2]) ? (main_red_timer % 10) : 4'hF;
    HEX_Decoder dec_tens_main (.bcd(bcd_tens_main), .seg(HEX3)); 
    HEX_Decoder dec_ones_main (.bcd(bcd_ones_main), .seg(HEX2));

    // 支線道
    wire [3:0] bcd_tens_side = (LEDG[2]) ? (side_red_timer / 10) : 4'hF;
    wire [3:0] bcd_ones_side = (LEDG[2]) ? (side_red_timer % 10) : 4'hF;
    HEX_Decoder dec_tens_side (.bcd(bcd_tens_side), .seg(HEX1));
    HEX_Decoder dec_ones_side (.bcd(bcd_ones_side), .seg(HEX0));
	 
    LCD_Controller u_lcd (
        .clk_50M(CLK_50M), .rst_n(RST_N),
        .night_mode(NIGHT_MODE), .state(traffic_state),
        .lcd_data(LCD_DATA), .lcd_rs(LCD_RS), .lcd_rw(LCD_RW), 
        .lcd_en(LCD_EN), .lcd_on(LCD_ON), .lcd_blon(LCD_BLON)
    );

endmodule