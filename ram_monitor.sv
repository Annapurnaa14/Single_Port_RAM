class ram_monitor;
  mailbox #(ram_transaction) mon2sco;
  virtual ram_if vif;
  ram_transaction captured_trans;

  function new(virtual ram_if vif, mailbox #(ram_transaction) m2s);
    this.vif = vif; this.mon2sco = m2s;
  endfunction

task run();
    forever begin
      // Wait for the posedge clk via the clocking block
      @(vif.mon_cb); 
      
      // Construct a new packet to capture the sampled values
      captured_trans = new();
      
      // Sample values strictly from the clocking block (vif.mon_cb.<signal>)
      captured_trans.address      = vif.mon_cb.address;
      captured_trans.write_enable = vif.mon_cb.write_enb;
      captured_trans.read_enable  = vif.mon_cb.read_enb;
      captured_trans.write_data   = vif.mon_cb.data_in;
      
      // This will now capture the steady data output properly aligned with the clock edge
      captured_trans.read_data    = vif.mon_cb.data_out; 
      
      // Push the clean transaction to the scoreboard
      mon2sco.put(captured_trans);
    end
  endtask
endclass
