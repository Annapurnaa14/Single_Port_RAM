typedef enum {lower_range, mid_range, upper_range} address_range;
typedef enum {IDLE, WRITE, READ, SIM_RW} ram_operation;

class ram_transaction;
  rand bit write_enable;
  rand bit read_enable;
  rand bit [`ADDR_WIDTH-1:0] address;
  rand bit [`DATA_WIDTH-1:0] write_data;
  rand bit reset_n;
  
  bit [`DATA_WIDTH-1:0] read_data;
  rand address_range addr_grp;
  rand ram_operation operation;

  static int address_history[$];

  constraint uniq_addr { !(address inside {address_history}); }
  constraint range_distribution {
    (addr_grp == lower_range) -> address inside {[0:15]};
    (addr_grp == mid_range)  -> address inside {[16:25]};
    (addr_grp == upper_range)-> address inside {[26:31]};
  }
  constraint addr_dist_weight { addr_grp dist { lower_range := 10, mid_range := 10, upper_range := 10 }; }
  constraint operation_mapping {
    (operation == IDLE)   -> (write_enable == 0 && read_enable == 0);
    (operation == WRITE)  -> (write_enable == 1 && read_enable == 0);
    (operation == READ)   -> (write_enable == 0 && read_enable == 1);
    (operation == SIM_RW) -> (write_enable == 1 && read_enable == 1);
  }
  constraint reset_default_c { soft reset_n == 1'b1; }

  function void post_randomize();
    address_history.push_back(address);
    if(address_history.size() >= `DATA_DEPTH) address_history.delete();
  endfunction

  function ram_transaction copy();
    copy = new();
    copy.write_enable = this.write_enable;
    copy.read_enable  = this.read_enable;
    copy.address      = this.address;
    copy.write_data   = this.write_data;
    copy.reset_n      = this.reset_n;
    copy.read_data    = this.read_data;
    copy.addr_grp     = this.addr_grp;
    copy.operation    = this.operation;
    return copy;
  endfunction
endclass

