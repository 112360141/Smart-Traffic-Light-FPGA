Smart Traffic Light Control System

基於 FPGA (DE2-115) 設計與實作之數位邏輯智慧交通號誌系統。本專案跳脫傳統固定時序，結合動態車流調度、硬體防彈跳與 LCD 動態顯示技術，完美重現真實世界之智慧交通樞紐。

核心功能與亮點

動態綠燈延長 ：藉由硬體開關模擬車流，當綠燈倒數至 0 時若偵測到持續車流，狀態機將強迫扣留於綠燈狀態並重載秒數，實現無限次延長之智慧疏導。

行人優先強制中斷：結合時脈防彈跳技術，實體按鍵觸發後立即強行截斷當前綠燈時相，無縫切換至黃燈清道狀態。

硬體級絕對同步顯示：七段顯示器之致能直接綁定實體紅燈腳位，達成 0 延遲的物理級同步，徹底消除倒數卡頓感。

LCD 動態位移擷取顯示：捨棄耗費資源之 LUT 查表法，採用 128-bit 字串暫存器配合 Indexed Part-Select (+: 8) 語法，動態輸出 ASCII 碼至 16x2 LCD 螢幕，大幅精簡硬體資源。

 開發環境與工具

硬體平台：Terasic DE2-115 FPGA Development Board

開發軟體：Intel Quartus II (13.0sp1)

硬體描述語言：Verilog HDL

模擬工具：Quartus University Program VWF / ModelSim




檔案結構說明

Smart_Traffic_System.v頂層模組。

Traffic_FSM.v：核心交通狀態機。

EP4.qpf / .qsf：Quartus 專案檔與腳位綁定設定。

