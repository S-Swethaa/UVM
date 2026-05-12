module apb_slave(
  input pwrite,
  input psel,
  input penable,
  input pclk,
  input preset,

  input  [31:0] paddr,
  input  [31:0] pwdata,

  output reg pready,
  output reg [31:0] prdata
);

  reg [31:0] mem [0:31];

  integer i;

  // memory initialization
  initial begin
    for(i=0; i<32; i=i+1)
      mem[i] = 0;
  end

  always @(posedge pclk) begin

    // reset
    if(!preset) begin

      pready <= 0;
      prdata <= 0;

    end

    else begin

      // APB transaction
      if(psel && penable) begin

        pready <= 1;

        // WRITE
        if(pwrite) begin

          mem[paddr[4:0]] <= pwdata;

        end

        // READ
        else begin

          prdata <= mem[paddr[4:0]];

        end

      end

      // no transfer
      else begin

        pready <= 0;

      end

    end

  end

endmodule
