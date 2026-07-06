module ram_assertions(
  input clk,
  input reset_n,
  input write_enb,
  input read_enb,
  input [4:0] address
);

  // Assertion 1: Prevent memory writing during active-low system resets
  property no_write_on_reset;
    @(posedge clk) !reset_n |-> (RAM.memory[address] === 8'hzz);
  endproperty
  assert_no_write_on_reset: assert property(no_write_on_reset);

  // Assertion 2: Ensure data output clears on conflicting multi-requests
  property simultaneous_rw_state;
    @(posedge clk) (write_enb && read_enb) |-> ##1 (RAM.data_out === 8'hz);
  endproperty
  assert_simultaneous_rw_state: assert property(simultaneous_rw_state);

endmodule
