
module seg_controller (
	input 					clk,
	input 					rst,
	input						press,
	input 		[3:0] 	numb,
	
	/// Microcontroller output State///
	output reg 	[1:0] 	out_st,
	
	/// FPA Related Inputs/Outputs ///
	input 		[15:0]	result,
	output reg				en,
	output reg				scan,
	output reg 	[15:0] 	in1,
	output reg  [15:0]   in2,
	
	/// 7 Segment Displays ///
	output reg 	[7:0] 	Hex5,
	output reg 	[7:0] 	Hex4,
	output reg 	[7:0] 	Hex3,
	output reg 	[7:0] 	Hex2,
	output reg 	[7:0] 	Hex1,
	output reg 	[7:0] 	Hex0
);

	function [7:0] convert_hex; //Convert 4-bit input into 8-bit data for 7 segs
		input [3:0] binary_in;
		
		case (binary_in)
			4'b0000: convert_hex = zero; 
			4'b0001: convert_hex = one; 
			4'b0010: convert_hex = two; 
			4'b0011: convert_hex = three; 
			4'b0100: convert_hex = four; 
			4'b0101: convert_hex = five; 
			4'b0110: convert_hex = six; 
			4'b0111: convert_hex = seven; 
			4'b1000: convert_hex = eight; 
			4'b1001: convert_hex = nine; 
			4'b1010: convert_hex = a; 
			4'b1011: convert_hex = b; 
			4'b1100: convert_hex = c; 
			4'b1101: convert_hex = d; 
			4'b1110: convert_hex = e; 
			4'b1111: convert_hex = f; 
			default: convert_hex = null;
		endcase
	endfunction

	
	/// State Parameters ///
	parameter [3:0]	S0 = 		4'b0000,
							S1 = 		4'b0001,
							S2 = 		4'b0011,
							S3 = 		4'b0010,
							S4 = 		4'b0110,
							S5 = 		4'b0111,
							S6 = 		4'b0101,
							S7 = 		4'b0100,
							S8 = 		4'b1100,
							S9 = 		4'b1101,
							S10 = 	4'b1111,
							S11 = 	4'b1110;
	
	
	/// 7-Segment Display Parameters ///
	parameter [7:0]	null = 	8'hFF, //11111111
							zero = 	8'hC0, //11000000
							one = 	8'hF9, //11111001
							two = 	8'hA4, //10100100
							three = 	8'hB0, //10110000
							four = 	8'h99, //10011001
							five = 	8'h92, //10010010
							six = 	8'h82, //10000010
							seven = 	8'hF8, //11111000
							eight = 	8'h80, //10000000
							nine = 	8'h98, //10011000
							a = 		8'h88, //10001000
							b = 		8'h83, //10000011
							c = 		8'hA7, //10100111
							d = 		8'hA1, //10100001
							e = 		8'h86, //10000110
							f = 		8'h8E; //10001110
							
	reg 	[3:0] 	cur_state; //Current state in the calculator							
	reg 	[7:0] 	H5_data, H3_data, H2_data, H1_data, H0_data; //Data for each 7-seg

	initial begin
		H5_data = null;
		H3_data = null;
		H2_data = null;
		H1_data = null;
		H0_data = null;
		cur_state = S0;
		in1 = 16'h0000;
		in2 = 16'h0000;
		en = 1'b0;
		scan = 1'b0;
		out_st = 2'b00;
	end
	
	
	always @ (posedge clk) begin
		if (rst) begin //Reset
			H3_data <= null;
			H2_data <= null;
			H1_data <= null;
			H0_data <= null;
			cur_state <= S0;	
			in1 <= 16'h0000;
			in2 <= 16'h0000;
			en <= 1'b0;
			scan <= 1'b0;
		end
		
		else begin			
			case (cur_state)
				///// STATE 0: RESET /////
				S0: begin
					H5_data <= null;
					out_st <= 2'b00;
					if (press) cur_state <= S1;
				end
				
				
				///// STATE 1: INPUT 1ST NUMBER/////
				S1: begin
					out_st <= 2'b01;
					scan <= 1'b1;
					H5_data <= convert_hex(numb);
					
					if (press && (numb != null)) begin
						H5_data <= null;
						H0_data <= convert_hex(numb);
						cur_state <= S2;
						in1[15:12] <= numb;
					end
				end
				
				S2: begin
					H5_data <= convert_hex(numb);
					
					if (press && (numb != null)) begin
						H5_data <= null;
						H1_data <= convert_hex(in1[15:12]);
						H0_data <= convert_hex(numb);
						cur_state <= S3;
						in1[11:8] <= numb;
					end
				end
				
				S3: begin
					H5_data <= convert_hex(numb);
					
					if (press && (numb != null)) begin
						H5_data <= null;
						H2_data <= convert_hex(in1[15:12]);
						H1_data <= convert_hex(in1[11:8]);
						H0_data <= convert_hex(numb);
						cur_state <= S4;
						in1[7:4] <= numb;
					end
				end
				
				S4: begin 
					H5_data <= convert_hex(numb);
					
					if (press && (numb != null)) begin
						H5_data <= null;
						H3_data <= convert_hex(in1[15:12]);
						H2_data <= convert_hex(in1[11:8]);
						H1_data <= convert_hex(in1[7:4]);
						H0_data <= convert_hex(numb);
						cur_state <= S5;
						in1[3:0] <= numb;
					end
				end
				
				S5: begin //Clear 7 segs before inputting 2nd number
					scan <= 1'b0;
					
					if (press) begin
						H3_data <= null;
						H2_data <= null;
						H1_data <= null;
						H0_data <= null;
						cur_state <= S6;
					end
				end
				
				
				///// STATE 2: INPUT 2ND NUMBER/////
				S6: begin
					out_st <= 2'b10;
					scan <= 1'b1;
					H5_data <= convert_hex(numb);
					
					if (press && (numb != null)) begin
						H5_data <= null;
						H0_data <= convert_hex(numb);
						cur_state <= S7;
						in2[15:12] <= numb;
					end
				end
				
				S7: begin
					H5_data <= convert_hex(numb);
					
					if (press && (numb != null)) begin
						H5_data <= null;
						H1_data <= convert_hex(in2[15:12]);
						H0_data <= convert_hex(numb);
						cur_state <= S8;
						in2[11:8] <= numb;
					end
				end
				
				S8: begin
					H5_data <= convert_hex(numb);
					
					if (press && (numb != null)) begin
						H5_data <= null;
						H2_data <= convert_hex(in2[15:12]);
						H1_data <= convert_hex(in2[11:8]);
						H1_data <= convert_hex(numb);
						cur_state <= S9;
						in2[7:4] <= numb;
					end
				end
				
				S9: begin 
					H5_data <= convert_hex(numb);
					
					if (press && (numb != null)) begin
						H5_data <= null;
						H3_data <= convert_hex(in2[15:12]);
						H2_data <= convert_hex(in2[11:8]);
						H1_data <= convert_hex(in2[7:4]);
						H0_data <= convert_hex(numb);
						cur_state <= S10;
						in2[3:0] <= numb;
					end
				end				
				
				S10: begin //Clear 7 segs before calculating
					scan <= 1'b0;
					
					if (press) begin
						H3_data <= null;
						H2_data <= null;
						H1_data <= null;
						H0_data <= null;
						cur_state <= S11;
						en <= 1'b1;
					end
				end

				
				///// STATE 3: FLOATING POINT CALCULATION /////	
				S11: begin
					out_st <= 2'b11;
					
					H3_data <= convert_hex(result[15:12]);
					H2_data <= convert_hex(result[11:8]);
					H1_data <= convert_hex(result[7:4]);
					H0_data <= convert_hex(result[3:0]);
					
					if (press) begin
						H3_data <= null;
						H2_data <= null;
						H1_data <= null;
						H0_data <= null;
						cur_state <= S0;
					end
				end
				
				default: cur_state <= S0;
			endcase
		end
	end
	
endmodule