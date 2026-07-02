`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.06.2026 13:44:28
// Design Name: 
// Module Name: APB_interface_slave
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
// ---------------------------------------------------------------------
`timescale 1ns / 1ps

module APB_interface_slave(
    input  wire        pwrite,
    input  wire        penable,
    input  wire [2:0]  pselx,
    input  wire [31:0] paddr,
    input  wire [31:0] pwdata,
    
    output wire        pwrite_out,
    output wire        penable_out,
    output wire [2:0]  psel_out,
    output wire [31:0] paddr_out,
    output wire [31:0] pwdata_out,
    output reg  [31:0] prdata
);

    assign pwrite_out  = pwrite;
    assign psel_out    = pselx;
    assign paddr_out   = paddr;
    assign pwdata_out  = pwdata;
    assign penable_out = penable;

    reg [31:0] memory_array [0:255]; 
    
    wire [7:0] mem_index = paddr[9:2];
    // 3. WRITE operation: Triggered when penable goes HIGH
    always @(posedge penable) begin
        if (pwrite && pselx != 3'b000) begin
            memory_array[mem_index] <= pwdata;
        end
    end
    //4. Read operation 
    always @(*) begin
        prdata = 32'd0; // Default
        if (!pwrite && penable && pselx != 3'b000) begin
            prdata = memory_array[mem_index]; 
        end
    end

endmodule