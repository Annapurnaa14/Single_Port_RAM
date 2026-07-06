class ram_driver;
  mailbox #(ram_transaction) gen2drv;
  mailbox #(ram_transaction) drv2ref;
  virtual ram_if vif;
  ram_transaction packet;

  covergroup drv_cvg;
    option.per_instance = 1;
    ADDR_BINS: coverpoint packet.address {
      bins lower_address[]  = {[0:15]};
      bins mid_address[]    = {[16:25]};
      bins higher_address[] = {[26:31]};
    }
    OP_BINS: coverpoint {packet.write_enable, packet.read_enable} {
      bins idle_mode   = {2'b00};
      bins write_mode  = {2'b10};
      bins read_mode   = {2'b01};
      bins illegal_sim = {2'b11};
    }
    RESET_BINS: coverpoint packet.reset_n {
      bins asserted    = {1'b0};
      bins deasserted  = {1'b1};
    }
    CROSS_OP_ADDR: cross ADDR_BINS, OP_BINS;
  endgroup

  function new(virtual ram_if vif, mailbox #(ram_transaction) g2d, mailbox #(ram_transaction) d2r);
    this.vif = vif; this.gen2drv = g2d; this.drv2ref = d2r;
    drv_cvg = new();
  endfunction

  task run();
    forever begin
      gen2drv.get(packet);
      drv_cvg.sample();
      @(vif.drv_cb);
      vif.drv_cb.address      <= packet.address;
      vif.drv_cb.write_enb    <= packet.write_enable;
      vif.drv_cb.read_enb     <= packet.read_enable;
      vif.drv_cb.data_in      <= (packet.write_enable && !packet.read_enable) ? packet.write_data : 8'h00;
      drv2ref.put(packet.copy());
    end
  endtask
endclass
