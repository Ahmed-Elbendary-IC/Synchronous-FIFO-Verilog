`timescale 1ns / 1ps

module  tb_sync_fifo();

parameter data_width = 3;
parameter ptr_width  = 3;

reg clk, rst;
reg [data_width - 1 :0] data_in;
reg wr_en , rd_en;

wire [data_width - 1 :0] data_out;
wire empty , full;
wire [ptr_width :0] counter;

sync_fifo copy_fifo(
.clk(clk),
.rst(rst),
.data_in(data_in),
.wr_en(wr_en),
.rd_en(rd_en),
.data_out(data_out),
.empty(empty),
.full(full),
.fifo_counter(counter)
);


always #5 clk = ~clk;

initial 
	begin
		clk = 0;
		rst = 1; 
		data_in = 0 ; wr_en = 0 ; rd_en = 0; 
		#10;
		rst = 0;
	 $display("---starting write test---");
		
		wr_en = 1; rd_en = 0;
		data_in = 3'd1; //3
		@(posedge clk);
		#1;
		
		data_in = 3'd2; //3
		@(posedge clk);
		#1;
		
		data_in = 3'd3; //3
		@(posedge clk);
		#1;
		wr_en = 0;
		
		#10;
//----------------------------------------------------//		 
	 $display("---starting reading test---");
		 rd_en = 1;
		@(posedge clk);
		#1;
		
		@(posedge clk);
		#1;
		
		@(posedge clk);
		#1;
		rd_en = 0;
		
		#10;
//----------------------------------------------------//
	 $display("---filling fifo to check full flag---");
		data_in = 3'd0 ;
		wr_en = 1;
		repeat(8) 
			begin
				@(posedge clk);
				#1;
				data_in = data_in +1;
			end
		wr_en = 0;
	
		if(full == 1) 
			$display("success: fifo is full");
		else
			$display("error: fifo shoud be full");
			
//----------------------------------------------------//
	 $display("---simultaneous read&write together test---");		
		data_in = 3'd7;
		wr_en = 1;
		rd_en = 1;
		@(posedge clk); 
		#1;
		
		wr_en = 0;
		rd_en = 0;
		
		#10;
		if(counter == 8)
			$display("success: counter stayed 8 during simultaneous r/w when full");
		else 
			$display("error: counter change to %0d" , counter);

//----------------------------------------------------//
	 $display("---empty fifo first---");			
		rd_en = 1;
		repeat(8) 
			begin
				@(posedge clk);
				#1;
			end
		rd_en = 0;
	#10;
//----------------------------------------------------//
	 $display("---testing read from empty fifo---");			
		rd_en = 1;
		@(posedge clk);
		#1;
		rd_en =0;
		
		if(counter == 0 && empty == 1)
			$display("success: prevented reading from empty fifo");
		else
			$display("error: read from empty fifo changed the state!");
			
		$display("simulation finished");
		$finish;
	end
	
initial 
		begin
			$monitor("time = %0t| rst = %0b wr =%0b rd = %0b din = %0d| dout =%0d full = %0b empty = %0b count = %0d ",
					 $time, rst , wr_en , rd_en , data_in , data_out , full , empty , counter);
		end
	
endmodule	