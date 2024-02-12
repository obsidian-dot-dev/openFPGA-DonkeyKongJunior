//===============================================================================
// 
// Modified for Donkey Kong Junior by gaz68.
//
// FPGA DONKEY KONG V RAM
//
// Version : 4.00
//
// Copyright(c) 2003 - 2004 Katsumi Degawa , All rights reserved
//
// Important !
//
// This program is freeware for non-commercial use. 
// An author does no guarantee about this program.
// You can use this under your own risk.
//
// 2004- 8-24 V-RAM module changed .  K.Degawa
// 2005- 2- 9 The description of the ROM was changed.
//            Data on the ROM are initialized at the time of the start.   
//================================================================================

//-----------------------------------------------------------------------------------------
// H_CNT[0],H_CNT[1],H_CNT[2],H_CNT[3],H_CNT[4],H_CNT[5],H_CNT[6],H_CNT[7],H_CNT[8],H_CNT[9]  
//   1/2 H     1 H     2 H      4H       8H       16 H     32H      64 H     128 H   256 H
//-----------------------------------------------------------------------------------------
// V_CNT[0], V_CNT[1], V_CNT[2], V_CNT[3], V_CNT[4], V_CNT[5], V_CNT[6], V_CNT[7]  
//    1 V      2 V       4 V       8 V       16 V      32 V      64 V     128 V 
//-----------------------------------------------------------------------------------------
// VF_CNT[0],VF_CNT[1],VF_CNT[2],VF_CNT[3],VF_CNT[4],VF_CNT[5],VF_CNT[6],VF_CNT[7]  
//    1 VF     2 VF      4 VF      8 VF      16 VF     32 VF     64 VF    128 VF 
//-----------------------------------------------------------------------------------------

module dkongjr_vram(
    input         CLK_12M,
    input   [9:0] I_AB,
    input   [7:0] I_DB,
    input         I_VRAM_WRn,
    input         I_VRAM_RDn,
    input         I_FLIP,
    input   [9:0] I_H_CNT,
    input   [7:0] I_VF_CNT,
    input         I_CMPBLK,

    output [11:0] O_VRAM_AB,
    input   [7:0] I_VRAM_D1,I_VRAM_D2,

    input         I_CNF_EN,
    input   [7:0] I_CNF_A,
    input   [7:0] I_CNF_D,
    input         I_WE4,
    input         I_4H_Q0,

    //---- Debug ----
    //---------------
    output     [7:0] O_DB,
    output reg [3:0] O_COL,
    output     [1:0] O_VID,
    output           O_VRAMBUSYn,
    output           O_ESBLKn,

    input            hs_clock,
    input      [9:0] hs_address,
    output     [7:0] hs_data_out,
    input      [7:0] hs_data_in,
    input            hs_write,
    input            hs_access
);

//---- Debug ----
//---------------
wire   [7:0]WI_DB = I_VRAM_WRn ? 8'h00: I_DB;
wire   [7:0]WO_DB;

assign O_DB       = I_VRAM_RDn ? 8'h00: WO_DB;

wire   [4:0]W_HF_CNT  = I_H_CNT[8:4]^{5{I_FLIP}};
wire   [9:0]W_cnt_AB  = {I_VF_CNT[7:3],W_HF_CNT[4:0]};
wire   [9:0]W_vram_AB = I_CMPBLK ? W_cnt_AB : I_AB ;
wire        W_vram_CS = I_CMPBLK ? 1'b0     : I_VRAM_WRn & I_VRAM_RDn;
wire        W_2S4     = I_CMPBLK ? 1'b0     : 1'b1 ;

ram_1024_8_8 U_2PR(
    .I_CLKA(~CLK_12M),
    .I_ADDRA(W_vram_AB),
    .I_DA(WI_DB),
    .I_CEA(~W_vram_CS),
    .I_WEA(~I_VRAM_WRn),
    .O_DA(WO_DB),

    .I_CLKB(hs_clock),
    .I_ADDRB(hs_address),
    .I_DB(hs_data_in),
    .I_CEB(hs_access),
    .I_WEB(hs_write),
    .O_DB(hs_data_out)
);

wire   [3:0]W_2N_DO;
//-----  ROM 2N  -----
wire   [7:0]W_2N_AD = I_CNF_EN ? I_CNF_A : {W_vram_AB[9:7],W_vram_AB[4:0]};
wire   [3:0]W_2N_DI = I_CNF_EN ? I_CNF_D[3:0] : 4'h0 ;

ram_2N U_2N(
    .I_CLK(CLK_12M),
    .I_ADDR(W_2N_AD),
    .I_D(W_2N_DI),
    .I_CE(1'b1),
    .I_WE(I_WE4),
    .O_D(W_2N_DO)
);

//    Parts  2M
reg    CLK_2M;
always@(negedge CLK_12M) CLK_2M <= ~(&I_H_CNT[3:1]);

// Delay added to colour output. Temporary fix for colour timing issue.
// Further investigation needed.
//always@(negedge CLK_2M) O_COL[3:0] <= W_2N_DO[3:0];
always@(negedge I_H_CNT[0]) begin

	reg prev;

	prev <= CLK_2M;

	if (prev & ~CLK_2M) begin
		O_COL[3:0] <= W_2N_DO[3:0];
	end

end


wire   [7:0]W_3P_DO,W_3N_DO;
wire   ROM_3PN_CE = ~I_H_CNT[9];

assign O_VRAM_AB = {I_4H_Q0,WO_DB[7:0],I_VF_CNT[2:0]};
assign W_3P_DO   = I_VRAM_D1;
assign W_3N_DO   = I_VRAM_D2;

wire   [3:0]W_4M_a,W_4M_b;
wire   [3:0]W_4M_Y;
wire   W_4P_Qa,W_4P_Qh,W_4N_Qa,W_4N_Qh;

wire   CLK_4PN = I_H_CNT[0];

//------  PARTS 4P  ---------------------------------------------- 
wire   [1:0]C_4P = W_4M_Y[1:0];
wire   [7:0]I_4P = W_3P_DO;
reg    [7:0]reg_4P;

assign W_4P_Qa = reg_4P[7];
assign W_4P_Qh = reg_4P[0];
always@(posedge CLK_4PN)
begin
   case(C_4P)
      2'b00: reg_4P <= reg_4P;
      2'b10: reg_4P <= {reg_4P[6:0],1'b0};
      2'b01: reg_4P <= {1'b0,reg_4P[7:1]};
      2'b11: reg_4P <= I_4P;
   endcase
end
//------  PARTS 4N  ---------------------------------------------- 
wire   [1:0]C_4N = W_4M_Y[1:0];
wire   [7:0]I_4N = W_3N_DO;
reg    [7:0]reg_4N;

assign W_4N_Qa = reg_4N[7];
assign W_4N_Qh = reg_4N[0];
always@(posedge CLK_4PN)
begin
   case(C_4N)
      2'b00: reg_4N <= reg_4N;
      2'b10: reg_4N <= {reg_4N[6:0],1'b0};
      2'b01: reg_4N <= {1'b0,reg_4N[7:1]};
      2'b11: reg_4N <= I_4N;
   endcase
end

assign W_4M_a = {W_4P_Qa,W_4N_Qa,1'b1,~(CLK_2M|W_2S4)};
assign W_4M_b = {W_4P_Qh,W_4N_Qh,~(CLK_2M|W_2S4),1'b1};

assign W_4M_Y = I_FLIP ? W_4M_b:W_4M_a;

assign O_VID[0] = W_4M_Y[2];
assign O_VID[1] = W_4M_Y[3];

//------  PARTS 2K1 ----------------------------------------------
reg    W_VRAMBUSY;
assign O_VRAMBUSYn = ~W_VRAMBUSY;
always@(posedge I_H_CNT[2] or negedge I_H_CNT[9])
begin
   if(I_H_CNT[9] == 1'b0)
      W_VRAMBUSY <= 1'b1;
   else
      W_VRAMBUSY <= &I_H_CNT[7:4];
end

//------  PARTS 2K2 ----------------------------------------------
reg    W_ESBLK;
assign O_ESBLKn = ~W_ESBLK;
always@(posedge I_H_CNT[6] or negedge I_H_CNT[9])
begin
   if(I_H_CNT[9] == 1'b0)
      W_ESBLK <= 1'b0;
   else
      W_ESBLK <= ~I_H_CNT[7];
end


endmodule

