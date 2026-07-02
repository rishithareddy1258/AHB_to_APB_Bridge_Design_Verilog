`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.06.2026 13:44:05
// Design Name: 
// Module Name: APB_controller
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
module APB_controller(
    input hclk_i,
    input hreset_ni, 
    input hwrite_i,
    input hwrite_reg_i,
    input valid_o,
    input [31:0] haddr_i,haddr_1_i, haddr_2_i,hwdata_i,hwdata_1_i, hwdata_2_i, prdata_i,
    input [2:0] temp_selx_o,
    
    output reg penable_o, 
    output reg pwrite_o, 
    output reg hr_readyout_o,
    output reg [31:0] paddr_o, 
    output reg [31:0] pwdata_o,
    output reg [2:0] psel_o
);

    // Internal temporary registers for combinational logic
    reg penable_temp, pwrite_temp, hr_readyout_temp;
    reg [2:0] psel_temp;
    reg [31:0] paddr_temp, pwdata_temp;

    // State Parameters
    parameter ST_IDLE     = 3'b000,
              ST_WWAIT    = 3'b001,
              ST_WRITEP   = 3'b010,
              ST_WRITE    = 3'b011,
              ST_WENABLE  = 3'b100,
              ST_WENABLEP = 3'b101,
              ST_READ     = 3'b110,
              ST_RENABLE  = 3'b111;

    reg [2:0] present, next;

    //-------------------------------------------------------
    // 1. Present State Logic (Sequential)
    //-------------------------------------------------------
    always @(posedge hclk_i) begin
        if (!hreset_ni) begin
            present <= ST_IDLE;
        end else begin
            present <= next;
        end
    end

    //-------------------------------------------------------
    // 2. Next State Logic (Combinational)
    //-------------------------------------------------------
    always @(*) begin
        next = ST_IDLE; // Default
        case (present)
            ST_IDLE: begin
                if (valid_o == 1 && hwrite_i == 1)
                    next = ST_WWAIT;
                else if (valid_o == 1 && hwrite_i == 0)
                    next = ST_READ;
                else
                    next = ST_IDLE;
            end

            ST_WWAIT: begin
                if (valid_o)
                    next = ST_WRITEP;
                else
                    next = ST_WRITE;
            end

            ST_WRITEP: begin
                next = ST_WENABLEP;
            end

            ST_WRITE: begin
                if (valid_o)
                    next = ST_WENABLEP;
                else
                    next = ST_WENABLE;
            end

            ST_WENABLE: begin
                if (valid_o && hwrite_i)
                    next = ST_WWAIT;
                else if (valid_o && !hwrite_i)
                    next = ST_READ;
                else
                    next = ST_IDLE;
            end

            ST_WENABLEP: begin
                if (valid_o && hwrite_reg_i)
                    next = ST_WRITEP;
                else if (!valid_o && hwrite_reg_i )
                    next = ST_WRITE;
                else
                    next = ST_READ;
            end

            ST_READ: begin
                next = ST_RENABLE;
            end

            ST_RENABLE: begin
                if (valid_o && !hwrite_i)
                    next = ST_READ;
                else if (valid_o && hwrite_i)
                    next = ST_WWAIT;
                else if (!valid_o)
                    next = ST_IDLE;
            end
            
            default: next = ST_IDLE;
        endcase
    end

    //-------------------------------------------------------
    // 3. Output Combinational Logic
    //-------------------------------------------------------
    always @(*) begin
        // Default assignments to prevent latches
        paddr_temp = 0; pwdata_temp = 0; pwrite_temp = 0;
        psel_temp = 0; penable_temp = 0; hr_readyout_temp = 1;

        case(present)
            ST_IDLE: begin
                if(valid_o == 1 && hwrite_i == 0) begin
                    paddr_temp = haddr_i;
                    pwrite_temp = hwrite_i;
                    psel_temp = temp_selx_o;
                    penable_temp = 0;
                    hr_readyout_temp = 0;
                end else if (valid_o == 1 && hwrite_i == 1) begin
                    psel_temp = 0;
                    penable_temp = 0;
                    hr_readyout_temp = 1;
                end else begin
                    hr_readyout_temp = 1;
                    psel_temp = 0;
                    penable_temp = 0;
                end
            end
            ST_WWAIT: if(valid_o) begin
                paddr_temp = haddr_1_i;
                pwdata_temp = hwdata_i;
                pwrite_temp = hwrite_i;
                psel_temp = temp_selx_o;
                penable_temp = 0;
                hr_readyout_temp = 0;
            end else begin
                paddr_temp = haddr_i;
                pwdata_temp = hwdata_i;
                pwrite_temp = hwrite_i;
                hr_readyout_temp = 1'b0;
            end
            
            ST_WRITE: begin
               pwrite_temp = hwrite_i;
                psel_temp   = psel_o;
                penable_temp = 1;
                hr_readyout_temp = 1;
            end
            
            ST_WRITEP: begin
                paddr_temp = haddr_1_i;
                pwdata_temp = hwdata_i;
                psel_temp   = psel_o;
                hr_readyout_temp = 1;
                penable_temp = 1;
                pwrite_temp = hwrite_i;
            end
            ST_WENABLEP: begin
                paddr_temp = haddr_1_i;
                pwdata_temp = hwdata_i;
                pwrite_temp = hwrite_i;
                psel_temp = temp_selx_o;
                penable_temp = 0;
                hr_readyout_temp = 0;
            end
            ST_READ: begin
                paddr_temp = paddr_o;
                pwrite_temp = hwrite_i;
                psel_temp = temp_selx_o;
                penable_temp = 1;
                hr_readyout_temp = 1;
            end

            ST_RENABLE: if(valid_o == 1 && hwrite_i == 0) begin
                paddr_temp = haddr_1_i;
                pwrite_temp = hwrite_i;
                psel_temp = temp_selx_o;
                penable_temp = 0;
                hr_readyout_temp = 0;
            end else if (valid_o == 1 && hwrite_i == 1) begin
                psel_temp = temp_selx_o;
                penable_temp = 0;
                hr_readyout_temp = 1;
            end
            else begin
                 psel_temp=0;
                 penable_temp = 0;
                hr_readyout_temp = 1;
            end
        endcase
    end

    //-------------------------------------------------------
    // 4. Output Registering (Sequential)
    //-------------------------------------------------------
    always @(posedge hclk_i) begin
        if(!hreset_ni) begin
            paddr_o <= 0;
            pwdata_o <= 0;
            pwrite_o <= 0;
            psel_o <= 0;
            penable_o <= 0;
            hr_readyout_o <= 1;
        end else begin
            paddr_o <= paddr_temp;
            pwdata_o <= pwdata_temp;
            pwrite_o <= pwrite_temp;
            psel_o <= psel_temp;
            penable_o <= penable_temp;
            hr_readyout_o <= hr_readyout_temp;
        end
    end

endmodule
