class ram_env;
  ram_generator gen;
  ram_driver drv;
  ram_monitor mon; 
  ram_scoreboard sco;
  
  mailbox #(ram_transaction) gen2drv; mailbox #(ram_transaction) drv2ref; mailbox #(ram_transaction) mon2sco;
  virtual ram_if drv_vif; virtual ram_if mon_vif;
  event transaction_complete;

  function new(virtual ram_if drv_vif, virtual ram_if mon_vif);
    this.drv_vif = drv_vif; this.mon_vif = mon_vif;
  endfunction

  function void build(ram_generator target_gen);
    gen2drv = new(); drv2ref = new(); mon2sco = new();
    this.gen = target_gen; this.gen.connect(gen2drv);
    drv = new(drv_vif, gen2drv, drv2ref);
    mon = new(mon_vif, mon2sco);
    sco = new(drv2ref, mon2sco);
  endfunction

  task run();
    fork
      gen.run(); drv.run(); mon.run(); sco.run();
    join_none
    wait(gen.count > 0);
    wait(sco.checked_transactions == gen.count);
    #10ns;
    -> transaction_complete;
  endtask
endclass
