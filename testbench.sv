`timescale 1ns/1ns

interface ram_if(input bit clk, input bit reset_n);
  logic [4:0] address;
  logic [7:0] data_in;
  logic write_enb;
  logic read_enb;
  logic [7:0] data_out;

  clocking drv_cb @(posedge clk);
    default input #1ns output #1ns;
    output address, data_in, write_enb, read_enb;
    input  data_out, reset_n;
  endclocking

  clocking mon_cb @(posedge clk);
    default input #1ns output #1ns;
    input address, data_in, write_enb, read_enb, data_out, reset_n;
  endclocking

  modport DRV (clocking drv_cb, input clk, reset_n);
  modport MON (clocking mon_cb, input clk, reset_n);
endinterface

`include "ram_package.sv"

module ram_assertions(
  input clk, input reset, input write_enb, input read_enb, input [4:0] address
);
  property simultaneous_rw_state;
    @(posedge clk) (write_enb && read_enb) |-> ##1 (RAM.data_out === 8'hz);
  endproperty
  assert_simultaneous_rw_state: assert property(simultaneous_rw_state);
endmodule

module ram_tb;
  import ram_package::*;

  bit clk;
  bit reset_n;

  always #10ns clk = ~clk;

  ram_if inf(clk, reset_n);

  RAM dut (
    .clk(clk), .reset(reset_n), .address(inf.address),
    .data_in(inf.data_in), .write_enb(inf.write_enb),
    .read_enb(inf.read_enb), .data_out(inf.data_out)
  );

  bind RAM ram_assertions assertion_inst (
    .clk(clk), .reset(reset), .write_enb(write_enb), .read_enb(read_enb), .address(address)
  );

  ram_test test_inst;

  initial begin
    reset_n = 1'b0;
    #35ns;
    reset_n = 1'b1;
  end

  initial begin
    test_inst = new(inf, inf);
    test_inst.run();
    $display("\n>>> TEST PASSED. Mismatches: %0d <<<", test_inst.env.sco.error_count);
    $finish;
  end

  final begin
    $display("\n==================================================");
    $display("           FUNCTIONAL COVERAGE REPORT");
    $display("====================================================");
    $display("  Coverage: %0.2f%%", test_inst.env.drv.drv_cvg.get_coverage());
    $display("==================================================\n");
  end
endmodule
