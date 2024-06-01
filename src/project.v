/*
 * Copyright (c) 2024 Jason Kaufmann
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_example (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // Instantiate the rca8 module
  wire [7:0] sum;
  wire cout;

  rca8 adder (
      .A(ui_in),
      .B(uio_in),
      .cin(1'b0),    // Assuming no carry-in for simplicity
      .SUM(sum),
      .cout(cout)
  );

  // Assign the sum to the output
  assign uo_out = sum;

  // All other output pins must be assigned. If not used, assign to 0.
  assign uio_out = 0;
  assign uio_oe  = 0;

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, clk, rst_n, 1'b0};

endmodule

module halfadder(input wire a,
                 input wire b,
                 output wire s,
                 output wire cout);
    assign s = a ^ b;
    assign cout = a & b;
endmodule

module fulladder(input wire cin,
                 input wire a,
                 input wire b,
                 output wire s,
                 output wire cout);
    wire s_tmp, cout_tmp1, cout_tmp2; 
    halfadder h0(.a(a), .b(b), .s(s_tmp), .cout(cout_tmp1));
    halfadder h1(.a(s_tmp), .b(cin), .s(s), .cout(cout_tmp2));
    assign cout = cout_tmp1 | cout_tmp2; 
endmodule

module rca8(input wire [7:0] A,
            input wire [7:0] B,
            input wire       cin,
            output wire [7:0] SUM,
            output wire      cout);
    wire [7:0] carry;
    
    fulladder fa0 (.cin(cin),     .a(A[0]), .b(B[0]), .s(SUM[0]), .cout(carry[0]));
    fulladder fa1 (.cin(carry[0]), .a(A[1]), .b(B[1]), .s(SUM[1]), .cout(carry[1]));
    fulladder fa2 (.cin(carry[1]), .a(A[2]), .b(B[2]), .s(SUM[2]), .cout(carry[2]));
    fulladder fa3 (.cin(carry[2]), .a(A[3]), .b(B[3]), .s(SUM[3]), .cout(carry[3]));
    fulladder fa4 (.cin(carry[3]), .a(A[4]), .b(B[4]), .s(SUM[4]), .cout(carry[4]));
    fulladder fa5 (.cin(carry[4]), .a(A[5]), .b(B[5]), .s(SUM[5]), .cout(carry[5]));
    fulladder fa6 (.cin(carry[5]), .a(A[6]), .b(B[6]), .s(SUM[6]), .cout(carry[6]));
    fulladder fa7 (.cin(carry[6]), .a(A[7]), .b(B[7]), .s(SUM[7]), .cout(carry[7]));

    assign cout = carry[7];
endmodule
