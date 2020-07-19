`timescale 1ns / 1ps

module UART_Tx(
    input [7:0] data_in,
	 input start_sending,
	 input clk,
	 output reg data_out,
	 output reg busy,
	 output reg done);
	 

//CLKS_per_bit is calculated as clock freq / baud rate	 
parameter CLKs_per_bit = 2;
	 
// FSM states
parameter IDLE = 3'b000;
parameter START_BIT = 3'b001;
parameter DATA_BITS = 3'b010;
parameter STOP_BIT = 3'b011;
parameter PARITY_BIT = 3'b100;
parameter FINISHED = 3'b101;

wire parity;

reg [2:0] current_state = IDLE;
reg [7:0] data_to_send;
reg [7:0] number_of_clks;
reg [2:0] bit_index;

always @ (posedge clk)
begin

	case (current_state) 
	
		// Stay IDLE until start sending signal is received
		IDLE: begin
			data_out <= 1;
			done <= 0;
			if ( start_sending == 1'b1 )begin
				current_state <= START_BIT;
				busy <= 1;
				data_to_send <= data_in;
				number_of_clks <= 0;
			end
			else begin
				busy <= 0;
				current_state <= IDLE;
			end
			
		end
		
		// send Start Bit for the specified clocks per bit then enter 
		// sending data state
		START_BIT: begin
			data_out <= 0;
			if (number_of_clks < CLKs_per_bit - 1) begin
				number_of_clks <= number_of_clks + 1;
				current_state <= START_BIT;
			end
			else begin
			current_state <= DATA_BITS;
			number_of_clks <= 0;
			bit_index <= 0;
			end
		end
		
		
		
		DATA_BITS: begin
			data_out <= data_to_send[bit_index];
			
			//check if sending this bit still needs more clocks
			if (number_of_clks < CLKs_per_bit - 1) begin
				number_of_clks <= number_of_clks + 1;
				current_state <= DATA_BITS;
			end
			else begin
				number_of_clks <= 0;
				//if sending this bit ended then check if sending all bits is done
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
				
			
		// send Stop bit for specified clocks per bit then enter
		// finished state
		STOP_BIT: begin
			data_out <= 1;
			if (number_of_clks < CLKs_per_bit - 1) begin
				number_of_clks <= number_of_clks + 1;
				current_state <= STOP_BIT;
			end
			else begin
			current_state <= PARITY_BIT;
			number_of_clks <= 0;
			busy <= 0;
			done <= 0;
			end
		end
		
		PARITY_BIT: begin
			data_out <= parity;
			if (number_of_clks < CLKs_per_bit - 1) begin
				number_of_clks <= number_of_clks + 1;
				current_state <= PARITY_BIT;
			end
			else begin
			current_state <= FINISHED;
			number_of_clks <= 0;
			busy <= 0;
			done <= 1;
			end
		end
		
		FINISHED: begin
			current_state <= IDLE;
			busy <= 0;
			done <= 1;
		end
		
		default: begin
			current_state <= IDLE;
		end
		
	endcase


end

assign parity = ~^data_to_send; 

endmodule














