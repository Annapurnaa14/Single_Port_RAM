class ram_scoreboard;
  mailbox #(ram_transaction) drv2ref;
  mailbox #(ram_transaction) mon2sco;
  reg [7:0] golden_memory [0:31];
  int checked_transactions = 0;
  int match_count = 0;
  int error_count = 0;

  function new(mailbox #(ram_transaction) d2r, mailbox #(ram_transaction) m2s);
    this.drv2ref = d2r; this.mon2sco = m2s;
    foreach(golden_memory[i]) golden_memory[i] = 8'h00;
  endfunction

 task run();
    ram_transaction ref_pkt;
    ram_transaction mon_pkt;
    
    fork
      forever begin
        drv2ref.get(ref_pkt);
        
        if (!ref_pkt.reset_n) begin
          golden_memory[ref_pkt.address] = 8'h00; 
        end else if (ref_pkt.write_enable && !ref_pkt.read_enable) begin
          golden_memory[ref_pkt.address] = ref_pkt.write_data;
        end
      end

      forever begin
        mon2sco.get(mon_pkt);

        if (mon_pkt.read_enable && !mon_pkt.write_enable && mon_pkt.reset_n) begin
          bit [7:0] expected_data;
          expected_data = golden_memory[mon_pkt.address];
          
          if (mon_pkt.read_data === expected_data) begin
            match_count++;
          end else begin
            $error("[%0t] SB MISMATCH! Addr: 0x%0h | Exp: 0x%0h | Act: 0x%0h", $time, mon_pkt.address, expected_data, mon_pkt.read_data);
            error_count++;
          end
        end else begin
          match_count++; 
        end
        
        checked_transactions++;
      end
    join
  endtask
endclass
