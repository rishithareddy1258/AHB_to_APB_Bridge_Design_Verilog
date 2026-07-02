`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.06.2026 13:44:51
// Design Name: 
// Module Name: Bridge_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module Bridge_top (
    input  wire        hclk, 
    input  wire        hresetn, 
    input  wire        hwrite, 
    input  wire        hreadyin,
    input  wire [31:0] hwdata, 
    input  wire [31:0] haddr, 
    input  wire [31:0] prdata,
    input  wire [1:0]  htrans,
    
    output wire        pwrite, 
    output wire        penable, 
    output wire        hr_readyout,
    output wire [2:0]  psel,
    output wire [31:0] paddr, 
    output wire [31:0] pwdata, 
    output wire [31:0] hrdata,
    output wire [1:0]  hresp
);

    wire        valid;
    wire [31:0] hwdata_1,hwdata_2,haddr_1,haddr_2;
    wire [2:0]  temp_selx;
    wire        hwrite_reg1, hwrite_reg2;

    AHB_Slave ahb_s_interface (
        .Hclk(hclk), .Hresetn(hresetn), .Hwrite(hwrite), .Hreadyin(hreadyin),
        .Htrans(htrans),.Hwdata(hwdata), .Haddr(haddr), .Prdata(prdata),
        
        .Hresp(hresp), .valid(valid), .Hwritereg1(hwrite_reg1),.Hwritereg2(hwrite_reg2),
        .Haddr1(haddr_1), .Hwdata1(hwdata_1),.Haddr2(haddr_2), .Hwdata2(hwdata_2), 
       .tempselx(temp_selx), .Hrdata(hrdata)
    );
    
    APB_controller apb_peripherals (
    .hclk_i(hclk), .hreset_ni(hresetn), .hwrite_i(hwrite),
    .hwrite_reg_i(hwrite_reg1), .valid_o(valid), .prdata_i(prdata),
    .haddr_i(haddr),.hwdata_i(hwdata),
    .haddr_1_i(haddr_1) ,.haddr_2_i(haddr_2), 
    .hwdata_1_i(hwdata), .hwdata_2_i(hwdata_2),
    
    .temp_selx_o(temp_selx),
    
    .penable_o(penable), .pwrite_o(pwrite),
    .hr_readyout_o(hr_readyout), .paddr_o(paddr), .pwdata_o(pwdata), 
    .psel_o(psel)
);
endmodule