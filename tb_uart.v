`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   18:17:50 06/22/2020
// Design Name:   UART_Rx
// Module Name:   D:/Digital Projects/UART/tb_uart_2.v
// Project Name:  UART
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: UART_Rx
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_uart_2;

	// Inputs
	reg clk;
	reg start_sending;
	reg [7:0] Tx_input;

	// Outputs
	wire done;
	wire [7:0] data_out;
	wire data_line;
	
	// Operation Parameters
	parameter clk_period_ns = 10;
	// for baud rate of 1000 bits/sec we need 100K/1000 Clks_per_bit
	parameter CLKs_per_bit = 100;

	// Instantiate the Unit Under Test (UUT)
	UART_Tx #(.CLKs_per_bit(CLKs_per_bit)) uut_Tx(
		.clk(clk),
		.start_sending(start_sending),
		.data_in(Tx_input),
		.busy(),
		.data_out(data_line),
		.done(done)
	  );
	
	UART_Rx #(.CLKs_per_bit(CLKs_per_bit)) uut_Rx (
		.data_in(data_line), 
		.clk(clk), 
		.done(), 
		.data_out(data_out)
	);
	
	
	// Driving Clock
	always begin
		#(clk_period_ns / 2) 
		clk <= !clk;
	end
	
	task Send_Byte;
		input [7:0] data;
		begin
			Tx_input <= data;
			@(posedge clk);
			start_sending <= 1;
			@(posedge clk);
			start_sending <= 0;
		
			@(done);
			@(posedge clk);
			// Check that the correct byte was received
			if (data_out == data)
				$display("Test Passed - %b Received Correctly", data);
			else
				$display("Test Failed - %b Received Incorrectly", data);
		end
	endtask
		

	initial begin
		// Initialize Inputs
		Tx_input <= 0;
		start_sending <= 0;
		clk <= 0;

		// Wait 100 ns for global reset to finish
		#100;
		
		Send_Byte(8'b10100110);
		Send_Byte(8'b00000000);
		Send_Byte(8'b11111111);
		Send_Byte(8'b01010101);
		
		
       $finish;

	end
      
endmodule

