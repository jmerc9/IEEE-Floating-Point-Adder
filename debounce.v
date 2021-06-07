
module debounce(
    input clk,
    input button,  
	 
    output pressed
);

	wire 				PB_idle = (PB_state==PB_sync_1);
	wire 				PB_cnt_max = &PB_cnt;	
	reg 	[15:0] 	PB_cnt;
	reg 				PB_state, PB_sync_0, PB_sync_1;  

	assign pressed = ~PB_idle & PB_cnt_max & ~PB_state;	
	
	always @(posedge clk) begin
		PB_sync_0 <= ~button; 
		PB_sync_1 <= PB_sync_0;	
	end

	always @(posedge clk) begin
		if(PB_idle) PB_cnt <= 0;
		
		else begin
			PB_cnt <= PB_cnt + 16'd1;
			if(PB_cnt_max) PB_state <= ~PB_state;  
		end
	end

endmodule