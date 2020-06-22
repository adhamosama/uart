`timescale 1ns / 1ps

module UART_Rx(
	input data_in,
	input clk,
	output reg done,
	output reg [7:0] data_out
    );

//CLKS_per_bit is calculated as clock freq / baud rate	 
parameter CLKs_per_bit = 2;
	 
// FSM states
parameter IDLE = 3'b000;
parameter START_BIT = 3'b001;
parameter DATA_BITS = 3'b010;
parameter STOP_BIT = 3'b011;
parameter FINISHED = 3'b100;

reg [2:0] current_state = IDLE;
reg [7:0] data_received;
reg [7:0] number_of_clks;
reg [2:0] bit_index;

always @(posedge clk)
begin
	case (current_state)
	
		// set done to 0 and wait for a start bit
		IDLE: begin
			done <= 0;
			if(data_in == 1'b0) begin
				current_state <= START_BIT;
				data_received <= 8'b00000000;
				number_of_clks <= 0;
			end
			else begin
				current_state <= IDLE;
			end
		end
		
		
		START_BIT: begin
			if (number_of_clks < CLKs_per_bit - 2) begin
				//if start bit is still not finished, check it's still found
				if (data_in == 1'b0) begin
					number_of_clks <= number_of_clks + 1;
					current_state <= START_BIT;
				end
				else begin
					// if the start bit is not found for the whole CLKs_per_bit period
					// then there is an error and return to IDLE state
					current_state <= IDLE;
				end
			end
			else begin
				if (data_in == 1'b0) begin
				//if the start bit is still present then there is error
					current_state <= DATA_BITS;
					number_of_clks <= 0;
					bit_index <= 0;
				end
				else begin
					// if the start bit is not found
					// then there is an error and return to IDLE state
					current_state <= IDLE;
				end
				
			end
		end
		
		
		DATA_BITS: begin
			//check if sending this bit still needs more clocks
			if (number_of_clks < CLKs_per_bit - 1) begin
				number_of_clks <= number_of_clks + 1;
				current_state <= DATA_BITS;
			end
			else begin
				data_received[bit_index] <= data_in;
				number_of_clks <= 0;
				//if sending this bit ended then check if all bits are done
				if (bit_index < 7) begin
					//if there is still data then send it
					bit_index <= bit_index + 1;
					current_state <= DATA_BITS;
				end
				else begin
					//if data sending is done go to sending stop bit
					current_state <= STOP_BIT;
				end	
			end
		end
		
		STOP_BIT: begin
			if (number_of_clks < CLKs_per_bit - 2) begin
				//if stop bit is still not finished, check it's still found
				if (data_in == 1'b1) begin
					number_of_clks <= number_of_clks + 1;
					current_state <= STOP_BIT;
				end
				else begin
					// if the stop bit is not found for the whole CLKs_per_bit period
					// then there is an error and return to IDLE state
					current_state <= IDLE;
				end
			end
			else begin
				current_state <= FINISHED;
				data_out <= data_received;
				done <= 1;
			end
		end
		
		
		FINISHED: begin
		// Extending done by one more clock period
			current_state <= IDLE;
		end
		
		default: begin
			current_state <= IDLE;
		end
		
	endcase

end

endmodule










