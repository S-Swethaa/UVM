interface intf(input pclk);
  logic preset;
  logic swrite,ptransfer;
  logic [31:0]SADDR;
  logic [31:0]SWDATA;
  logic [31:0]f_data;
  logic pready;
  
//modport give the directionality for the signal
  modport driv(clocking drv_cb,input pclk);
    modport monit(clocking mon_cb,input pclk);

      
      //clocking block it advanced techniques for avoid race condition
  clocking drv_cb @(posedge pclk);
    default input #1 output #1;
     input  pready, f_data;
   output preset, swrite, ptransfer, SADDR, SWDATA;
  endclocking
  
  clocking mon_cb @(posedge pclk);
    default input #1 output #1;
      input preset,swrite,ptransfer,SADDR,SWDATA,   pready,f_data;
  endclocking
      
      
      
        // MODEL 1 WRITE LIKE THIS OR:
// modport driv (
//    input  pready, f_data,
//    output preset, swrite, ptransfer, SADDR, SWDATA
// );
  
//   modport monit(
//   input preset,swrite,ptransfer,SADDR,SWDATA,   pready,f_data
//   );
    

endinterface
  
