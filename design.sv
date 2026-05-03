`timescale 1ns/1ps
module cla4 (
    input  [3:0] a,
    input  [3:0] b,
    input        cin,
    output [3:0] sum,
    output       cout
);
    wire [3:0] p, g;
    wire c1, c2, c3;

    assign p = a ^ b;   
    assign g = a & b;  

    assign c1 = g[0] | (p[0] & cin);
    assign c2 = g[1] | (p[1] & c1);
    assign c3 = g[2] | (p[2] & c2);
    assign cout = g[3] | (p[3] & c3);

    assign sum[0] = p[0] ^ cin;
    assign sum[1] = p[1] ^ c1;
    assign sum[2] = p[2] ^ c2;
    assign sum[3] = p[3] ^ c3;

endmodule

module cla_multiplier (
    input  [3:0] a,
    input  [3:0] b,
    output [7:0] p
);

    wire [3:0] pp0, pp1, pp2, pp3;

    assign pp0 = a & {4{b[0]}};
    assign pp1 = a & {4{b[1]}};
    assign pp2 = a & {4{b[2]}};
    assign pp3 = a & {4{b[3]}};

    wire [3:0] s1, s2, s3;
    wire c1, c2, c3;

    cla4 u1 (.a({1'b0,pp0[3:1]}), .b(pp1), .cin(1'b0), .sum(s1), .cout(c1));
    cla4 u2 (.a({c1,s1[3:1]}),    .b(pp2), .cin(1'b0), .sum(s2), .cout(c2));
    cla4 u3 (.a({c2,s2[3:1]}),    .b(pp3), .cin(1'b0), .sum(s3), .cout(c3));
    assign p[0] = pp0[0];
    assign p[1] = s1[0];
    assign p[2] = s2[0];
    assign p[3] = s3[0];
    assign p[7:4] = {c3, s3};

endmodule
