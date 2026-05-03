`timescale 1ns/1ps
module tilelink_slave (
    input clk,
    input rst_n,
    // A Channel (Request)
    input        a_valid,
    output reg   a_ready,
    input [7:0]  a_addr,
    input [31:0] a_data,
    input        a_opcode, // 0 = READ, 1 = WRITE
    // D Channel (Response)
    output reg        d_valid,
    input             d_ready,
    output reg [31:0] d_data,
    output reg        d_opcode
);
    reg [31:0] mem [0:255];
    localparam IDLE = 1'b0,
               RESP = 1'b1;     
    reg state;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            a_ready  <= 1'b1;
            d_valid  <= 1'b0;
            d_data   <= 32'b0;
            d_opcode <= 1'b0;
            state    <= IDLE;
        end else begin
          case (state)
                IDLE: begin
                    if (a_valid && a_ready) begin
                        // Capture request
                        if (a_opcode) begin
                            // WRITE
                            mem[a_addr] <= a_data;
                            d_opcode <= 1'b1;
                            d_data   <= 32'h0;
                        end else begin
                            // READ
                            d_data   <= mem[a_addr];
                            d_opcode <= 1'b0;
                        end
                        a_ready <= 1'b0;
                        d_valid <= 1'b1;
                        state   <= RESP;
                    end
                end
                RESP: begin
                    if (d_valid && d_ready) begin
                        // Response accepted
                        d_valid <= 1'b0;
                        a_ready <= 1'b1;
                        state   <= IDLE;
                    end
                end
            endcase
        end
    end
endmodule
