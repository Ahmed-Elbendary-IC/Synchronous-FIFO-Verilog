module sync_fifo #(parameter data_width = 3,
				   parameter ptr_width = 3
				   )(
	
	input  wire clk, rst,
	input  wire wr_en, rd_en,
	input  wire [data_width - 1 :0] data_in,
	output reg 	[data_width - 1 :0] data_out,
	output reg  [ptr_width :0] fifo_counter,
	output reg  empty , full
);
localparam depth = 1 << ptr_width;

reg [data_width - 1 :0] mem [0: depth - 1];
reg [ptr_width - 1 :0] wr_ptr, rd_ptr;

//empty & full
always @(*)
	begin
		empty = (fifo_counter == 0)    ? 1'b1 : 1'b0;
		full  = (fifo_counter == depth) ? 1'b1 : 1'b0;
	end
	
//counter
always @(posedge clk or posedge rst)
	begin
		if(rst) 
			fifo_counter <= 0;
		// else if (wr_en && !full && rd_en && !empty)
			// fifo_counter <= fifo_counter;
		// else if(wr_en && !full)
			// fifo_counter <= fifo_counter + 1;
			else if (wr_en && (!full || (full && rd_en)))
				begin
					if(!rd_en) // just write
						fifo_counter <= fifo_counter + 1;
				end
			
		else if (rd_en && !empty)
			fifo_counter <= fifo_counter - 1;
		else 
			fifo_counter <= fifo_counter;
	end

//read
always @(posedge clk or posedge rst)
	begin
		if(rst) 
			data_out <= 0;
		else if (rd_en && !empty)
			data_out <= mem[rd_ptr];
		
		// else 
			// data_out <= data_out;
	end
	
//write
always @(posedge clk)
	begin
		// if (wr_en && !full)
		if(wr_en && (!full || (full && rd_en)))
			mem[wr_ptr] <= data_in;
	end

// pointers
always @(posedge clk or posedge rst)
	begin
		if(rst) 
			begin 
				wr_ptr <= 0;
				rd_ptr <= 0;
			end
		// else if(wr_en && !full)
			// wr_ptr <= wr_ptr + 1;
		// else if(rd_en && !empty)
			// rd_ptr <= rd_ptr + 1;
			
		else 
			begin
				// if (wr_en && !full)
				if(wr_en && (!full || (full && rd_en))) //pointer to write
					wr_ptr <= wr_ptr + 1;
		   
				if (rd_en && !empty)      //pointer to read
					rd_ptr <= rd_ptr + 1;
			end	
	end
endmodule