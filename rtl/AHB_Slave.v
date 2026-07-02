`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.06.2026 13:43:47
// Design Name: 
// Module Name: AHB_Slave
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
module AHB_Slave (
    input Hclk, Hresetn, Hwrite, Hreadyin,
    input [1:0] Htrans,
    input [31:0] Haddr, Hwdata, Prdata,
    
    output [1:0] Hresp,
    output reg [31:0] Haddr1,Haddr2, Hwdata1, Hwdata2,
    output reg [2:0] tempselx,
    output reg valid, Hwritereg1,Hwritereg2,
    output [31:0] Hrdata
);
    // Pipeline Logic for the Address
    always @(posedge Hclk) begin
        if (!Hresetn) begin
            Haddr1 <= 0;
            Haddr2 <= 0;
        end
        else begin
            Haddr1 <= Haddr;
            Haddr2 <= Haddr1;
        end
    end
    // Pipeline Logic for the Data
    always @(posedge Hclk) begin
        if (!Hresetn) begin
            Hwdata1 <= 0;
            Hwdata2 <= 0;
        end
        else begin
            Hwdata1 <= Hwdata;
            Hwdata2 <= Hwdata1;
        end
    end
    // Pipeline Logic for Write Control
    always @(posedge Hclk) begin
        if (!Hresetn) begin
            Hwritereg1 <= 0;
            Hwritereg2 <=0;
        end
        else begin
            Hwritereg1 <= Hwrite;
            Hwritereg2 <= Hwritereg1;
        end
    end
    // Select the Peripheral (Address Decoding)
    always @(*) begin
        if (Haddr >= 32'h8000_0000 && Haddr < 32'h8400_0000)
            tempselx = 3'b001;
        else if (Haddr >= 32'h8400_0000 && Haddr < 32'h8800_0000)
            tempselx = 3'b010;
        else if (Haddr >= 32'h8800_0000 && Haddr < 32'h8c00_0000)
            tempselx = 3'b100;
        else
            tempselx = 3'b000;
    end
    // Logic for the valid signal
    // Valid is high if address is in range, ready is high, and Htrans is NONSEQ or SEQ also for read valid is high
    always @(*) begin  
        if ((Haddr >= 32'h8000_0000 && Haddr < 32'h8c00_0000) &&
            ((Hreadyin == 1)||(!Hwrite))&&
            (Htrans == 2'b10 || Htrans == 2'b11))
            valid = 1'b1;
        else
            valid = 1'b0;
    end

    // Response and Data assignments
    assign Hresp  = 2'd0;   // OKAY response
    assign Hrdata = Prdata; // Pass peripheral data back to AHB
endmodule