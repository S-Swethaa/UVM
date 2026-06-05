// Code your design here
`include "uvm_macros.svh"
import uvm_pkg::*;

class transac extends uvm_sequence_item;
  rand bit [7:0]data;
  
  `uvm_object_utils(transac)
  
  function new(string name = "transac");
    super.new(name);
  endfunction
  
  function string convert2string();
    return $sformatf("DATA=%0d",data);
  endfunction
endclass

class producer extends uvm_component;
  `uvm_component_utils(producer)
  
uvm_nonblocking_put_port #(transac) put_port;
  function new(string name = "producer",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    put_port=new("put_port",this);
  endfunction
  
 task run_phase(uvm_phase phase);
  transac trans;
  forever begin
    trans = transac::type_id::create("trans");
    assert(trans.randomize());

    if (put_port.can_put()) begin
      if (put_port.try_put(trans)) begin
        `uvm_info("PRODUCER",$sformatf("sent = %s",trans.convert2string()),UVM_MEDIUM)
      end else begin
        `uvm_info("PRODUCER","FIFO is full",UVM_MEDIUM)
      end
    end else begin
      `uvm_info("PRODUCER","FIFO cannot accept now",UVM_MEDIUM)
    end
    #5;
  end
endtask
endclass


class consumer extends uvm_component;
  `uvm_component_utils(consumer)

  uvm_nonblocking_get_port #(transac) get_port;

  function new(string name = "consumer", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    get_port = new("get_port", this);
  endfunction

  task run_phase(uvm_phase phase);
    transac trans;
    forever begin
      // Check if FIFO has data
      if (get_port.can_get()) begin
        if (get_port.try_get(trans)) begin
          `uvm_info("CONSUMER",
                    $sformatf("Received: %s", trans.convert2string()),
                    UVM_MEDIUM)
        end else begin
          `uvm_info("CONSUMER", "FIFO empty, try_get failed", UVM_MEDIUM)
        end
      end else begin
        `uvm_info("CONSUMER", "No data available now", UVM_MEDIUM)
      end
      #5; // polling delay
    end
  endtask
endclass


class environ extends uvm_env;
  producer p;
  consumer c;
  uvm_tlm_fifo #(transac)fifo;
  `uvm_component_utils(environ)
  
  function new(string name = "environ",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    p=producer::type_id::create("p",this);
    c=consumer::type_id::create("c",this);
    fifo=new("fifo",this,10);//fifo depth = 10;
  endfunction
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    p.put_port.connect(fifo.put_export);
    c.get_port.connect(fifo.get_export);
  endfunction
endclass

class test extends uvm_test;
  `uvm_component_utils(test)
  
  environ env;
  function new(string name = "test",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env=environ::type_id::create("env",this);
  endfunction
  
endclass

module m;
  initial
    begin
      run_test("test");
    end
endmodule

# UVM_INFO /usr/share/questa/questasim/verilog_src/questa_uvm_pkg-1.2/src/questa_uvm_pkg.sv(277) @ 0: reporter [Questa UVM] QUESTA_UVM-1.2.3
# UVM_INFO /usr/share/questa/questasim/verilog_src/questa_uvm_pkg-1.2/src/questa_uvm_pkg.sv(278) @ 0: reporter [Questa UVM]  questa_uvm::init(+struct)
# UVM_INFO @ 0: reporter [RNTST] Running test test...
# UVM_INFO design.sv(40) @ 0: uvm_test_top.env.p [PRODUCER] sent = DATA=184
# UVM_INFO design.sv(73) @ 0: uvm_test_top.env.c [CONSUMER] Received: DATA=184
# UVM_INFO /usr/share/questa/questasim/verilog_src/uvm-1.2/src/base/uvm_report_server.svh(847) @ 0: reporter [UVM/REPORT/SERVER] 
# --- UVM Report Summary ---
# 
# ** Report counts by severity
# UVM_INFO :    6
# UVM_WARNING :    0
# UVM_ERROR :    0
# UVM_FATAL :    0
# ** Report counts by id
# [CONSUMER]     1
# [PRODUCER]     1
# [Questa UVM]     2
# [RNTST]     1
# [UVM/RELNOTES]     1
# 
