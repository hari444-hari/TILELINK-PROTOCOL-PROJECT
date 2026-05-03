`timescale 1ns/1ps

module testbench;

    reg  [3:0] a, b;
    wire [7:0] p;

    cla_multiplier dut (.a(a), .b(b), .p(p));

    initial begin
        a = 4'd3;  b = 4'd4;  #10;
      $display("A=%d,B=%d,Product=%d", a, b, p);
        a = 4'd5;  b = 4'd6;  #10;
      $display("A=%d,B=%d,Product=%", a, b, p);
        a = 4'd7;  b = 4'd8;  #10;
      $display("A=%d,B=%d,Product=%", a, b, p);
        a = 4'd9;  b = 4'd3;  #10;
      $display("A=%d,B=%d,Product=%", a, b, p);
      $dumpfile("dump.vcd");
      $dumpvars(0, testbench);

        $finish;
    end

endmodule
