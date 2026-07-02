`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.06.2026 13:52:25
// Design Name: 
// Module Name: test_tb
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


module test_tb();

    // Internal signals for interconnection
    reg hclk, hresetn;
    wire [31:0] haddr, hwdata, hrdata;
    wire [1:0] hresp, htrans;
    wire [2:0] hsize,hburst;
    wire hreadyout, hwrite, hreadyin;
    
    wire pwrite,penable;
    wire [31:0] pwdata,paddr;
    wire [2:0] pselx;
    
    wire pwrite_out, penable_out;
    wire [2:0] psel_out;
    wire [31:0] pwdata_out, paddr_out,prdata;

    // Instantiate AHB Master
    AHB_Master ahb (
        .hclk(hclk),
        .hresetn(hresetn),
        .hreadyout(hreadyout),
        .hrdata(hrdata),
        .hresp(hresp),
        
        .hburst(hburst),
        .hsize(hsize),
        .haddr(haddr),
        .hwdata(hwdata),
        .hwrite(hwrite),
        .hreadyin(hreadyin),
        .htrans(htrans)
    );

    // Instantiate APB Interface (Peripheral)
    APB_interface_slave apb (
        .pwrite(pwrite),
        .penable(penable),
        .pselx(pselx),
        .paddr(paddr),
        .pwdata(pwdata),
        
        .pwrite_out(pwrite_out),      
        .penable_out(penable_out),
        .psel_out(psel_out),
        .paddr_out(paddr_out),
        .pwdata_out(pwdata_out),
        .prdata(prdata)
    );

    // Instantiate Bridge Top
    // Note: Ensure instance name matches your Bridge_top module name
    Bridge_top bridge (
        .hclk(hclk),
        .hresetn(hresetn),
        .hwrite(hwrite),
        .hreadyin(hreadyin),
        .hwdata(hwdata),
        .haddr(haddr),
        .prdata(prdata),
        .htrans(htrans),
        
        .pwrite(pwrite),
        .penable(penable),
        .hr_readyout(hreadyout),
        .psel(pselx),
        .paddr(paddr),
        .pwdata(pwdata),
        
        .hrdata(hrdata),
        .hresp(hresp)
    );

    // Clock Generation: 10 units half-period
    initial begin
        hclk = 1'b0;
        forever #10 hclk = ~hclk;
    end

    // Reset Task
    task reset();
        begin
            @(negedge hclk);
            hresetn = 1'b0;
            @(negedge hclk);
            hresetn = 1'b1;
        end
    endtask

    // Stimulus Block
    initial begin
        reset;    
        
        // Uncomment the sequence you wish to test
         // ahb.single_write(32'h8400_0000,32'h1234_5678); 
        ahb.burst_write(32'h8088_0128,3'b010,3'b010,4);   // Perform the 4-beat burst(WRAP4)
        //ahb.single_read(32'h8087_0000);  
        //ahb.burst_read(32'h8088_0128,3'b010,3'b010,4); // Perform the 4-beat burst(WRAP4)
        #60 $finish;        // End simulation
    end
  // -------------------------------------------------------
    // Simple pass/fail monitor (checks paddr tracks haddr_1)
    // -------------------------------------------------------
    always @(posedge hclk) begin
            $display("  t=%0t | paddr=%h | pwdata=%h | pwrite=%b | psel=%b",
                      $time, paddr, pwdata, pwrite, pselx);
    end
endmodule

