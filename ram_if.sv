interface ram_if(input bit clk, input bit reset);
  logic [4:0] address;
  logic [7:0] data_in;
  logic write_enb;
  logic read_enb;
  logic [7:0] data_out;

  // Clocking block to resolve design race conditions
  clocking drv_cb @(posedge clk);
    default input #1ns output #1ns;
    output address, data_in, write_enb, read_enb;
    input  data_out, reset;
  endclocking

  clocking mon_cb @(posedge clk);
    default input #1ns output #1ns;
    input address, data_in, write_enb, read_enb, data_out, reset;
  endclocking

  modport DRV (clocking drv_cb, input clk, reset);
  modport MON (clocking mon_cb, input clk, reset);
endinterface
