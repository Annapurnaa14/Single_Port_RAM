virtual class ram_generator;
  mailbox #(ram_transaction) gen2drv;
  int count = 0;
  function void connect(mailbox #(ram_transaction) gen2drv);
    this.gen2drv = gen2drv;
  endfunction
  pure virtual task run();
endclass

class full_random_gen extends ram_generator;
  ram_transaction packet;
  
  virtual task run();
    // Instead of three isolated blocks, run a single unified loop 
    // that allows all variables to randomize together dynamically.
    repeat(`NUM_OF_TRANS * 3) begin
      packet = new();
      
      // Let SystemVerilog natively randomize operations, addresses, 
      // and data together. This naturally creates the back-to-back 
      // write/read transitions your structural coverage is looking for.
      if (!packet.randomize() with {
        // Soft constraint allows reset_n to be mostly 1, 
        // but occasionally drop to 0 to catch the reset bins.
        soft reset_n dist {1'b1 := 95, 1'b0 := 5}; 
      }) begin
        $fatal("Randomization failed!");
      end
      
      gen2drv.put(packet); 
      count++;
    end
  endtask
endclass
