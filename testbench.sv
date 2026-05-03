`timescale 1ns/1ps
module tb_tilelink;
    reg clk;
    reg rst_n;
    // A Channel
    reg        a_valid;
    wire       a_ready;
    reg [7:0]  a_addr;
    reg [31:0] a_data;
    reg        a_opcode;
    // D Channel
    wire        d_valid;
    reg         d_ready;
    wire [31:0] d_data;
    wire        d_opcode;
    // Instantiate DUT
    tilelink_slave dut (
        .clk(clk),
        .rst_n(rst_n),
        .a_valid(a_valid),
        .a_ready(a_ready),
        .a_addr(a_addr),
        .a_data(a_data),
        .a_opcode(a_opcode),
        .d_valid(d_valid),
        .d_ready(d_ready),
        .d_data(d_data),
        .d_opcode(d_opcode)
    );
    // Clock generation
    always #5 clk = ~clk;
    integer timeout;
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_tilelink);
        // Initialize
        clk      = 0;
        rst_n    = 0;
        a_valid  = 0;
        a_addr   = 0;
        a_data   = 0;
        a_opcode = 0;
        d_ready  = 1;
        // Release reset
        #20 rst_n = 1;
        @(posedge clk);
        // WRITE 
        $display("Starting WRITE transaction...");
        a_addr   = 8'h10;
        a_data   = 32'hDEADBEEF;
        a_opcode = 1;  
        a_valid  = 1;
        // Wait for handshake (a_valid && a_ready)
        @(posedge clk);
        while (!a_ready) @(posedge clk);
        // Request accepted, deassert valid
        @(posedge clk);
        a_valid = 0;
        // Wait for response
        timeout = 0;
        while (!d_valid && timeout < 20) begin
            @(posedge clk);
            timeout = timeout + 1;
        end
        if (timeout == 20)
            $display("WRITE TIMEOUT");
        else
            $display("WRITE SUCCESS");
        // Wait for response to complete
        @(posedge clk);
        @(posedge clk);
        // ================= READ =================
        $display("Starting READ transaction...");
        a_addr   = 8'h10;
        a_data   = 32'h0;
        a_opcode = 0;  // READ
        a_valid  = 1;
        // Wait for handshake
        @(posedge clk);
        while (!a_ready) @(posedge clk);
        // Request accepted, deassert valid
        @(posedge clk);
        a_valid = 0;
        // Wait for response
        timeout = 0;
        while (!d_valid && timeout < 20) begin
            @(posedge clk);
            timeout = timeout + 1;
        end
        if (timeout == 20)
            $display("READ TIMEOUT");
        else begin
            $display("READ DATA = %h", d_data);
            if (d_data == 32'hDEADBEEF)
                $display("TEST PASSED: Data matches!");
            else
                $display("TEST FAILED: Expected DEADBEEF, got %h", d_data);
        end
        #50 $finish;
    end
endmodule
