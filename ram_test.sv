class ram_test;
  ram_env env;
  virtual ram_if drv_vif;
  virtual ram_if mon_vif;
  full_random_gen random_scenario;

  function new(virtual ram_if drv_vif, virtual ram_if mon_vif);
    this.drv_vif = drv_vif;
    this.mon_vif = mon_vif;
  endfunction

  task run();
    env = new(drv_vif, mon_vif);
    random_scenario = new();
    
    env.build(random_scenario);
    env.run();
    
    wait(env.transaction_complete.triggered);
    $display("\n>>> TEST PASSED: Executed %0d Transactions Successfully. Mismatches: %0d <<<", 
             env.sco.checked_transactions, env.sco.error_count);
  endtask
endclass
