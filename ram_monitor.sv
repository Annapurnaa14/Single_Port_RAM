class ram_monitor;
  mailbox #(ram_transaction) mon2sco;
  virtual ram_if vif;
  ram_transaction captured_trans;

  function new(virtual ram_if vif, mailbox #(ram_transaction) m2s);
    this.vif = vif; this.mon2sco = m2s;
  endfunction

task run();
    forever begin
      @(vif.mon_cb); 
      captured_trans = new();
      captured_trans.address      = vif.mon_cb.address;
      captured_trans.write_enable = vif.mon_cb.write_enb;
      captured_trans.read_enable  = vif.mon_cb.read_enb;
      captured_trans.write_data   = vif.mon_cb.data_in;
      captured_trans.read_data    = vif.mon_cb.data_out; 
      mon2sco.put(captured_trans);
    end
  endtask
endclass
