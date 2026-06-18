module Traffic_FSM(
    input clk_100Hz, 
    input clk_1Hz, rst_n, night_mode, 
    input ped_main_btn, ped_side_btn, 
    input car_main, car_side,         
    output reg [2:0] led_main, led_side,
    output wire [2:0] state_out,
    output reg [6:0] main_red_timer,
    output reg [6:0] side_red_timer 
);
    parameter S_MG_SR = 3'd0; 
    parameter S_MY_SR = 3'd1; 
    parameter S_MR_SG = 3'd2; 
    parameter S_MR_SY = 3'd3; 
    
    reg [2:0] state;
    reg [3:0] timer; 
    reg flash_tog, extended;
    reg req_ped_main, req_ped_side; 

    assign state_out = state;

    always @(*) begin
        // 主幹道
        if (state == S_MR_SG) main_red_timer = timer + 5;      
        else if (state == S_MR_SY) main_red_timer = timer + 1; 
        else main_red_timer = 0;

        // 支線道
        if (state == S_MG_SR) side_red_timer = timer + 5;      
        else if (state == S_MY_SR) side_red_timer = timer + 1; 
        else side_red_timer = 0;
    end

    reg clk_1Hz_d;
    wire tick_1Hz = (clk_1Hz == 1'b1 && clk_1Hz_d == 1'b0);

    always @(posedge clk_100Hz or negedge rst_n) begin
        if(!rst_n) begin
            state <= S_MG_SR; timer <= 10; 
            flash_tog <= 0; extended <= 0;
            req_ped_main <= 0; req_ped_side <= 0;
            clk_1Hz_d <= 0;
        end else begin
            clk_1Hz_d <= clk_1Hz; 
            
            if (ped_main_btn) req_ped_main <= 1;
            if (ped_side_btn) req_ped_side <= 1;

            if (tick_1Hz) begin
                if (night_mode) begin
                    flash_tog <= ~flash_tog;
                    led_main <= flash_tog ? 3'b010 : 3'b000; 
                    led_side <= flash_tog ? 3'b010 : 3'b000; 
                    req_ped_main <= 0; req_ped_side <= 0; 
                end else begin
                    flash_tog <= 0;
                    if (timer > 0) timer <= timer - 1;
                    
                    case(state)
                        S_MG_SR: begin
                            led_main <= 3'b001; led_side <= 3'b100;
                            if (req_ped_main) begin
                                state <= S_MY_SR; timer <= 3; req_ped_main <= 0;
                            end else if (req_ped_side) begin
                                timer <= 10; req_ped_side <= 0;
                            end else if (timer == 0) begin
                                if (car_main) begin
                                    timer <= 5;       
                                    state <= S_MG_SR; 
                                end else begin
                                    state <= S_MY_SR; timer <= 3; 
                                end
                            end
                        end
                        S_MY_SR: begin
                            led_main <= 3'b010; led_side <= 3'b100;
                            if (timer == 0) begin
                                state <= S_MR_SG; timer <= 10;
                            end
                        end
                        S_MR_SG: begin
                            led_main <= 3'b100; led_side <= 3'b001;
                            if (req_ped_side) begin
                                state <= S_MR_SY; timer <= 3; req_ped_side <= 0;
                            end else if (req_ped_main) begin
                                timer <= 10; req_ped_main <= 0;
                            end else if (timer == 0) begin
                                if (car_side) begin
                                    timer <= 5;       
                                    state <= S_MR_SG; 
                                end else begin
                                    state <= S_MR_SY; timer <= 3; 
                                end
                            end
                        end
                        S_MR_SY: begin
                            led_main <= 3'b100; led_side <= 3'b010;
                            if (timer == 0) begin
                                state <= S_MG_SR; timer <= 10;
                            end
                        end
                    endcase
                end
            end
        end
    end
endmodule