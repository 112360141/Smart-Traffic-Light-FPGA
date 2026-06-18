module Clock_Debounce(
    input clk_in, rst_n, btn_m_in, btn_s_in,
    output reg clk_1Hz, clk_100Hz, btn_m_out, btn_s_out
);
    reg [25:0] cnt_1Hz; reg [18:0] cnt_100Hz;
    always @(posedge clk_in or negedge rst_n) begin
        if(!rst_n) begin cnt_1Hz <= 0; clk_1Hz <= 0; cnt_100Hz <= 0; clk_100Hz <= 0; end
        else begin
            if(cnt_1Hz >= 24999999) begin cnt_1Hz <= 0; clk_1Hz <= ~clk_1Hz; end else cnt_1Hz <= cnt_1Hz + 1;
            if(cnt_100Hz >= 249999) begin cnt_100Hz <= 0; clk_100Hz <= ~clk_100Hz; end else cnt_100Hz <= cnt_100Hz + 1;
        end
    end
    reg [1:0] m_shift, s_shift;
    always @(posedge clk_100Hz or negedge rst_n) begin
        if(!rst_n) begin m_shift <= 0; s_shift <= 0; btn_m_out <= 0; btn_s_out <= 0; end
        else begin
            m_shift <= {m_shift[0], btn_m_in}; s_shift <= {s_shift[0], btn_s_in};
            btn_m_out <= (m_shift == 2'b01); btn_s_out <= (s_shift == 2'b01);
        end
    end
endmodule