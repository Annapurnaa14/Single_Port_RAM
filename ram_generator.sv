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
     repeat(`NUM_OF_TRANS * 3) begin
      packet = new();
      
         if (!packet.randomize() with {
          soft reset_n dist {1'b1 := 95, 1'b0 := 5}; 
      }) begin
        $fatal("Randomization failed!");
      end
      
      gen2drv.put(packet); 
      count++;
    end
  endtask
endclass
