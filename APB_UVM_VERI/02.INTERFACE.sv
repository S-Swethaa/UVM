
// // interface intf(input pclk);
// //   logic preset;
// //   logic swrite,ptransfer;
// //   logic [31:0]SADDR;
// //   logic [31:0]SWDATA;
// //   logic [31:0]f_data;
// //   logic pready;
  
// // //modport give the directionality for the signal
    
// //   modport driv(clocking drv_cb,input pclk);
// //     modport monit(clocking mon_cb,input pclk);
    
// //       //clocking block it advanced techniques for avoid race condition
    
// //   clocking drv_cb @(posedge pclk);
// //     default input #1 output #1;
// //      input  pready, f_data;
// //    output preset, swrite, ptransfer, SADDR, SWDATA;
// //   endclocking
  
// //   clocking mon_cb @(posedge pclk);
// //     default input #1 output #1;
// //       input preset,swrite,ptransfer,SADDR,SWDATA,   pready,f_data;
// //   endclocking

// // endinterface
interface intf(input pclk);

  logic preset;
  logic swrite, ptransfer;

  logic [31:0] SADDR;
  logic [31:0] SWDATA;

  logic [31:0] f_data;
  logic pready;


  // MODPORTS
  modport driv(clocking drv_cb, input pclk);

  modport monit(clocking mon_cb, input pclk);


  // CLOCKING BLOCK FOR DRIVER
  clocking drv_cb @(posedge pclk);

    default input #1 output #1;

    input  pready, f_data;

    output preset,
           swrite,
           ptransfer,
           SADDR,
           SWDATA;

  endclocking


  // CLOCKING BLOCK FOR MONITOR
  clocking mon_cb @(posedge pclk);

    default input #1 output #1;

    input preset,
          swrite,
          ptransfer,
          SADDR,
          SWDATA,
          pready,
          f_data;

  endclocking


  // ASSERTIONS

//   1. Transfer should complete with ready
  property p_transfer_complete;

    @(posedge pclk)
    ptransfer |-> ##[1:$] pready;

  endproperty

  A1 : assert property(p_transfer_complete)
       $info("ASSERT PASS : TRANSFER COMPLETE");
  else
       $error("ASSERT FAIL : PREADY NOT RECEIVED");


  // 2. Address stable during transfer
property p_addr_hold;
  @(posedge pclk)
  disable iff (!preset)
  ptransfer |=> (SADDR == $past(SADDR));
endproperty

  A2 : assert property(p_addr_hold)
       $info("ASSERT PASS : ADDRESS STABLE");
  else
       $error("ASSERT FAIL : ADDRESS CHANGED");


  // 3. Data stable during write
property p_data_hold;
  @(posedge pclk)
  disable iff (!preset)
  (ptransfer && swrite) |=> (SWDATA == $past(SWDATA));
endproperty

  A3 : assert property(p_data_hold)
       $info("ASSERT PASS : DATA STABLE");
  else
       $error("ASSERT FAIL : DATA CHANGED");


  // 4. Address range check
  property p_addr_range;

    @(posedge pclk)
    ptransfer |-> (SADDR inside {[33'h0000_0000 : 32'hffff_ffff]});

  endproperty

  A4 : assert property(p_addr_range)
       $info("ASSERT PASS : ADDRESS VALID");
  else
       $error("ASSERT FAIL : INVALID ADDRESS");


  // 5. No X/Z
//   property p_no_unknown;

    @(posedge pclk)
    disable iff (!preset)
    !$isunknown({
                 swrite,
                 ptransfer,
                 SADDR,
                 SWDATA});

  endproperty

  A5 : assert property(p_no_unknown)
       $info("ASSERT PASS : NO UNKNOWN");
  else
       $error("ASSERT FAIL : X/Z DETECTED");


  // 6. Read data valid
    
  property p_read_valid;

    @(posedge pclk)
    disable iff (!preset)
    (ptransfer && !swrite && pready)
      |-> !$isunknown(f_data);

  endproperty

  A6 : assert property(p_read_valid)
       $info("ASSERT PASS : READ VALID");
  else
       $error("ASSERT FAIL : INVALID READ DATA");


//   // 7. Reset disables transfer
//   property p_reset_disable;

//     @(posedge pclk)
//     !preset |-> !ptransfer;

//   endproperty

//   A7 : assert property(p_reset_disable)
//        $info("ASSERT PASS : RESET OK");
//   else
//        $error("ASSERT FAIL : TRANSFER ACTIVE DURING RESET");


  // 8. Write implies transfer
  property p_write_transfer;

    @(posedge pclk)
    disable iff (!preset)
    swrite |-> ptransfer;

  endproperty

  A8 : assert property(p_write_transfer)
       $info("ASSERT PASS : WRITE VALID");
  else
       $error("ASSERT FAIL : WRITE WITHOUT TRANSFER");


//   // 9. Read response
//   property p_read_response;

//     @(posedge pclk)
//     (ptransfer && !swrite)
//       |-> ##[1:5] pready;

//   endproperty

//   A9 : assert property(p_read_response)
//        $info("ASSERT PASS : READ RESPONSE");
//   else
//        $error("ASSERT FAIL : READ TIMEOUT");


  // 10. Write response
  property p_write_response;

    @(posedge pclk)
    (ptransfer && swrite)
    |-> ##[1:$] pready;

  endproperty

  A10 : assert property(p_write_response)
        $info("ASSERT PASS : WRITE RESPONSE");
  else
        $error("ASSERT FAIL : WRITE TIMEOUT");
  // COVERAGE

  covergroup apb_cg @(posedge pclk);

    option.per_instance = 1;

    // RESET COVERAGE
    RESET_CP : coverpoint preset {

      bins reset_on  = {1};
      bins reset_off = {0};

    }

    // WRITE/READ COVERAGE
    WRITE_READ_CP : coverpoint swrite {

      bins write = {1};
      bins read  = {0};

    }

    // TRANSFER COVERAGE
    TRANSFER_CP : coverpoint ptransfer {

      bins transfer_enable  = {1};
      bins transfer_disable = {0};

    }

    // READY COVERAGE
    READY_CP : coverpoint pready {

      bins ready_high = {1};
      bins ready_low  = {0};

    }

    // ADDRESS COVERAGE
    ADDR_CP : coverpoint SADDR {

      bins low_addr[]  = {[0:10]};
      bins mid_addr[]  = {[11:20]};
      bins high_addr[] = {[21:31]};

    }

    // BOUNDARY ADDRESS
    BOUNDARY_CP : coverpoint SADDR {

      bins zero_addr = {0};
      bins max_addr  = {31};

    }

    // WRITE DATA COVERAGE
    DATA_CP : coverpoint SWDATA {

      bins zero_data  = {32'h0};
      bins max_data   = {32'hFFFFFFFF};
      bins other_data = default;

    }

    // READ DATA COVERAGE
    FDATA_CP : coverpoint f_data {

      bins zero_fdata = {0};
      bins non_zero[] = {[1:1000]};

    }

    // TRANSFER SEQUENCE
    TRANS_SEQ_CP : coverpoint ptransfer {

      bins back_to_back = (1 => 1);

    }

    // WRITE SEQUENCE
    WRITE_SEQ_CP : coverpoint swrite {

      bins write_seq = (1 => 1);

    }

    // READ SEQUENCE
    READ_SEQ_CP : coverpoint swrite {

      bins read_seq = (0 => 0);

    }

    // CROSSES
    ADDR_X_WR : cross ADDR_CP, WRITE_READ_CP;

    RESET_X_TRANSFER : cross RESET_CP, TRANSFER_CP;

    WR_X_READY : cross WRITE_READ_CP, READY_CP;

    ADDR_X_READY : cross ADDR_CP, READY_CP;

    TRANSFER_X_RESET : cross TRANSFER_CP, RESET_CP;

  endgroup


  // COVERGROUP OBJECT
  apb_cg cg = new();

endinterface

  

