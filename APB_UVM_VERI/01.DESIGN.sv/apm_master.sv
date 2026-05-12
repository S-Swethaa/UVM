module apb_master(
    output reg  pwrite, psel, penable,
    output reg [31:0] paddr, pwdata,prdata,
    input  [31:0] SWDATA, SADDR,SRDATA,
    input preset, pclk,
    input swrite, ptransfer,
    input pready
);
 reg [1:0] state, nextstate;
 parameter idle=2'b00, setup=2'b01, access=2'b10;
 always @(posedge pclk) begin
 if(!preset) begin
    state   <= idle;
     psel    <= 0;
     penable <= 0;
     pwrite  <= 0;
     paddr   <= 32'b0;
     pwdata  <= 32'b0;
end else begin
     state <= nextstate;
end
end

always @(*) begin
 nextstate = state;
 psel = 0;
 penable = 0;
 pwrite = 0;
 paddr = 32'b0;
 pwdata  = 32'b0;

case(state)
   idle: begin
     if(ptransfer) begin
        nextstate = setup;
      end else begin
         nextstate = idle;
      end
         end
    
    setup: begin
      psel= 1;
      penable = 0;
      pwrite = swrite;
      paddr = SADDR;
      pwdata= SWDATA;
      nextstate = access;
      end
    
    access: begin
     psel= 1;
     penable = 1;
     pwrite  = swrite;
     paddr   = SADDR;
     pwdata  = SWDATA;
     //prdata  = SRDATA;
     if(pready) begin
         if(!swrite)
           prdata=SRDATA; 
        if(ptransfer)
           nextstate = setup;
        else
           nextstate = idle;
        end else begin
           nextstate = access;
        end
      end
endcase
end
endmodule
