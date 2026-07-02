`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: AHB_Master
// -------------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////////////////
module AHB_Master(
    input  wire        hclk,
    input  wire        hresetn,
    input  wire        hreadyout,
    input  wire [31:0] hrdata,
    input  wire [1:0]  hresp,

    output reg  [31:0] haddr,
    output reg  [31:0] hwdata,
    output reg         hwrite,
    output reg         hreadyin,
    output reg  [1:0]  htrans,
    output reg  [2:0]  hburst,
    output reg  [2:0]  hsize,

    output reg         transfer_error 
);

    // Response constants (HRESP is 2 bits per AMBA spec: OKAY/ERROR/RETRY/SPLIT)
    localparam [1:0] OKAY  = 2'b00;
    localparam [1:0] ERROR = 2'b01;
    reg        prev_xfer_valid;
    reg [1:0]  prev_htrans;

    always @(posedge hclk or negedge hresetn) begin
        if (!hresetn) begin
            prev_xfer_valid <= 1'b0;
            prev_htrans     <= 2'b00;
        end else begin
            prev_xfer_valid <= (htrans == 2'b10 || htrans == 2'b11); // NONSEQ or SEQ
            prev_htrans     <= htrans;
        end
    end

    always @(posedge hclk or negedge hresetn) begin
        if (!hresetn) begin
            transfer_error <= 1'b0;
        end
        else if (hreadyout && prev_xfer_valid) begin
            if (hresp == ERROR) begin
                transfer_error <= 1'b1;
                $display("[%0t] --- AHB Bus Error Detected! (addr phase was valid, HRESP=ERROR) ---", $time);
            end else begin
                transfer_error <= 1'b0;
            end
        end
    end

    integer i;

    task single_write(input [31:0] addr, input [31:0] data);
        begin
            @(posedge hclk);
            #1;
            hwrite   = 1'b1;
            htrans   = 2'd2; // NONSEQ
            hsize    = 3'd2; // 32-bit transfer
            hburst   = 3'd0; // SINGLE
            hreadyin = 1'b1;
            haddr    = addr;

            @(posedge hclk);
            #1;
            htrans = 2'd0; // IDLE
            hwdata = data;
            hreadyin = 1'b0;
        end
    endtask

    task single_read(input [31:0] addr);
        begin
            @(posedge hclk);
            #1;
            hwrite   = 1'b0;
            htrans   = 2'd2; // NONSEQ
            hsize    = 3'd0;
            hburst   = 3'd0; // SINGLE
            hreadyin = 1'b1;
            haddr    = addr;

            @(posedge hclk);
            #1;
            htrans = 2'd0; // IDLE
            hreadyin = 1'b0;
        end
    endtask

    task burst_write(
        input [31:0] start_addr,
        input [2:0]  transfer_size,
        input [2:0]  burst_type,
        input integer num_beats
    );
        integer j;
        reg [31:0] addr_offset;
        reg [31:0] total_bytes;
        reg [31:0] wrap_lower;
        reg [31:0] wrap_upper;
        reg        is_wrap;
        begin
            addr_offset = 1 << transfer_size;
            total_bytes = num_beats * addr_offset;

            wrap_lower = start_addr & ~(total_bytes - 1);
            wrap_upper = wrap_lower + total_bytes;

            is_wrap = (burst_type == 3'd2) || (burst_type == 3'd4) || (burst_type == 3'd6);

            @(posedge hclk);
            #1;
            hwrite = 1'b1;
            htrans = 2'd2; // NONSEQ
            hsize  = transfer_size;
            hburst = burst_type;
            haddr  = start_addr;
            hreadyin = 1'b1;

            for (j = 1; j < num_beats; j = j + 1) begin
                @(posedge hclk);
                #1;

                haddr = haddr + addr_offset;

                if (is_wrap && (haddr == wrap_upper)) begin
                    haddr = wrap_lower;
                end

                hwdata = $random;
                htrans = 2'd3; // SEQ
            end

            @(posedge hclk);
            #1;
            hwdata = $random;
            htrans = 2'd0; // IDLE
            hwrite = 1'b1;
            hreadyin = 1'b0;
        end
    endtask
    task burst_read(
        input [31:0] start_addr,
        input [2:0]  transfer_size,
        input [2:0]  burst_type,
        input integer num_beats
    );
        integer j;
        reg [31:0] addr_offset;
        reg [31:0] total_bytes;
        reg [31:0] wrap_lower;
        reg [31:0] wrap_upper;
        reg        is_wrap;
        begin
            addr_offset = 1 << transfer_size;
            total_bytes = num_beats * addr_offset;

            wrap_lower = start_addr & ~(total_bytes - 1);
            wrap_upper = wrap_lower + total_bytes;

            is_wrap = (burst_type == 3'd2) || (burst_type == 3'd4) || (burst_type == 3'd6);

            @(posedge hclk);
            #1;
            hwrite = 1'b0;       
            htrans = 2'd2;       // NONSEQ
            hsize  = transfer_size;
            hburst = burst_type;
            haddr  = start_addr;

            for (j = 1; j < num_beats; j = j + 1) begin
                @(posedge hclk);
                #1;
                haddr = haddr + addr_offset;

                if (is_wrap && (haddr == wrap_upper)) begin
                    haddr = wrap_lower;
                end
                htrans = 2'd3; // SEQ
                @(posedge hclk);
            end

            @(posedge hclk); 
            #1;
            htrans = 2'd2; // NONSEQ
            hwrite = 1'b0; 
        end
    endtask
endmodule