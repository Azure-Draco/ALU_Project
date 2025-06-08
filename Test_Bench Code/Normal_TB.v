`timescale 1ns / 1ps

module alu_tb;
parameter Width =8;
parameter cmd_length =4;

  reg clk = 0;
  reg rst = 1;
  reg ce = 1;

  reg [7:0] opa, opb;
  reg [1:0] inp_valid;
  reg cin;
  reg mode;
  reg [3:0] cmd;

  wire [(2*Width)-1:0] res;
  wire err;
  wire cout, oflow, g, e, l ;

  // DUT instantiation
  ALU_design #(Width,cmd_length) dut(
    .CLK(clk),
    .RST(rst),
    .CE(ce),
    .OPA(opa),
    .OPB(opb),
    .INP_VALID(inp_valid),
    .CIN(cin),
    .MODE(mode),
    .CMD(cmd),
    .RES(res),
    .ERR(err),
    .COUT(cout),
    .OFLOW(oflow),
    .G(g),
    .E(e),
    .L(l)
  );

  // Clock generation
  always #5 clk = ~clk;

  initial begin
    $display("Starting ALU testbench...");
    // Initialize inputs to known state
opa = 0;
opb = 0;
inp_valid = 2'b00;
cmd = 4'b0000;
cin = 0;
mode = 0;


    // Reset
    #10 rst = 1; ce = 1;

    // Wait for reset deassertion
    #10;
    rst = 0; 
    #10;

    // Arithmetic Mode (MODE = 1)
    mode = 1;

    // ADD
    opa = 8'd15; opb = 8'd10; inp_valid = 2'b11; cin = 0; cmd = 4'b0000; #10;
    
    opa = 8'hff; opb = 8'hff; inp_valid = 2'b11; cin = 0; cmd = 4'b0000; #10;
    
    // SUB
    opa = 8'd20; opb = 8'd10; inp_valid = 2'b11; cin = 0; cmd = 4'b0001; #10;

    // ADD with carry-in
    opa = 8'd10; opb = 8'd15; inp_valid = 2'b11; cin = 1; cmd = 4'b0010; #10;

    // SUB with carry-in
    opa = 8'd25; opb = 8'd5; inp_valid = 2'b11; cin = 1; cmd = 4'b0011; #10;

    // INC A
    opa = 8'd10; opb = 8'd0; inp_valid = 2'b01; cin = 0; cmd = 4'b0100; #10;

    // DEC A
    opa = 8'd10; opb = 8'd0; inp_valid = 2'b01; cin = 0; cmd = 4'b0101; #10;

    // INC B
    opa = 8'd0; opb = 8'd20; inp_valid = 2'b10; cin = 0; cmd = 4'b0110; #10;

    // DEC B
    opa = 8'd0; opb = 8'd20; inp_valid = 2'b10; cin = 0; cmd = 4'b0111; #10;

    // CMP (Equal)
    opa = 8'd10; opb = 8'd10; inp_valid = 2'b11; cin = 0; cmd = 4'b1000; #10;

    // CMP (Greater)
    opa = 8'd20; opb = 8'd10; inp_valid = 2'b11; cin = 0; cmd = 4'b1000; #10;

    // CMP (Less)
    opa = 8'd10; opb = 8'd20; inp_valid = 2'b11; cin = 0; cmd = 4'b1000; #10;

    // (A+1)*(B+1)
    opa = 8'd4; opb = 8'd3; inp_valid = 2'b11; cin = 0; cmd = 4'b1001; #30;
    
    // (A+1)*(B+1)
    opa = 8'b11111110; opb = 8'b11111110; inp_valid = 2'b11; cin = 0; cmd = 4'b1001; #30;
    
    // (A+1)*(B+1)
    opa = 8'b11111111; opb = 8'b11111111; inp_valid = 2'b11; cin = 0; cmd = 4'b1001; #30;

    // (A<<1)*B
    opa = 8'd2; opb = 8'd2; inp_valid = 2'b11; cin = 0; cmd = 4'b1010; #30;
    
    // (A<<1)*B
    opa = 8'b11111111; opb = 8'b11111111; inp_valid = 2'b11; cin = 0; cmd = 4'b1010; #30;
    
    // (A<<1)*B
    opa = 8'b00000000; opb = 8'b11111111; inp_valid = 2'b11; cin = 0; cmd = 4'b1010; #30;

    // Signed  ADD with Overflow
    opa = 8'd127; opb = 8'd01; inp_valid = 2'b11; cin = 0; cmd = 4'b1011; #10;
    
    // Signed  ADD with Overflow
    opa = 8'd128; opb = 8'd128; inp_valid = 2'b11; cin = 0; cmd = 4'b1011; #10;
    
    // Signed  ADD with Overflow
    opa = 8'b10000001; opb = 8'd1; inp_valid = 2'b11; cin = 0; cmd = 4'b1011; #10;
    
    // Signed SUB with overflow
    opa = 8'd128; opb = 8'd127; inp_valid = 2'b11; cin = 0; cmd = 4'b1100; #10;
    
    // Signed SUB
    opa = 8'd127; opb = 8'd128; inp_valid = 2'b11; cin = 0; cmd = 4'b1100; #10;
    
    // Signed SUB
    opa = 8'd1; opb = 8'd1; inp_valid = 2'b11; cin = 0; cmd = 4'b1100; #10;

    // Logical Mode (MODE = 0)
    mode = 0;

    // AND
    opa = 8'hAA; opb = 8'h55; inp_valid = 2'b11; cin = 0; cmd = 4'b0000; #10;

    // NAND
    cmd = 4'b0001; #10;

    // OR
    cmd = 4'b0010; #10;

    // NOR
    cmd = 4'b0011; #10;

    // XOR
    cmd = 4'b0100; #10;

    // XNOR
    cmd = 4'b0101; #10;

    // NOT A
    cmd = 4'b0110; #10;

    // NOT B
    cmd = 4'b0111; #10;

    // SHR1 A
    opa = 8'hF0; cmd = 4'b1000; #10;

    // SHL1 A
    opa = 8'h0F; cmd = 4'b1001; #10;

    // SHR1 B
    opa = 8'd0; opb = 8'hF0; cmd = 4'b1010; #10;

    // SHL1 B
    opb = 8'h0F; cmd = 4'b1011; #10;

    // ROL A by B
    opa = 8'h96; opb = 8'd3; cmd = 4'b1100; #10;

    // ROR A by B
    opa = 8'h69; opb = 8'd2; cmd = 4'b1101; #10;

    // Invalid INP_VALID
    mode = 1; opa = 8'd10; opb = 8'd10; inp_valid = 2'b00; cin = 0; cmd = 4'b0000; #10;

    // Invalid CMD
    inp_valid = 2'b11; cmd = 4'b1111; #10;

    $display("ALU testbench complete.");
    $finish;
  end
  initial begin
  $monitor("time=%t |RST =%b | CE=%b | INP_VALID =%b | MODE =%d | CMD=%d | OPA = %d | OPB =%d | RES=%d | COUT=%b | OFLOW =%b",$time,rst,ce,inp_valid,mode,cmd,opa,opb,res,cout,oflow);
  end

endmodule
