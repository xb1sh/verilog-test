`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   15:21:52 05/09/2022
// Design Name:   dystrybutor
// Module Name:   D:/wsc_dys/dystrybutor_test.v
// Project Name:  wsc_dys
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: dystrybutor
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module dystrybutor_test;

	// Inputs
	reg clk;
	reg reset;
	reg [1:0] paliwo;
	reg clk_pompa;
	// Outputs
	reg [7:0] czuj_paliwa;
	wire [7:0] koszty;
	wire [7:0] licznik_koszty1;
	wire [7:0] licznik_litry1;
	wire [7:0] litry;
	wire clockEn1;
	wire [1:0] data_out;
	
	wire postep;

	// Instantiate the Unit Under Test (UUT)
	dystrybutor uut (
		.clk(clk), 
		.reset(reset), 
		.paliwo(paliwo), 
		.koszty(koszty),
		.data_out(data_out),
		.licznik_litry1(licznik_litry1),
		.licznik_koszty1(licznik_koszty1),
		.czuj_paliwa(czuj_paliwa),
		.clk_pompa(clk_pompa),
		.litry(litry), 
		.clockEn1(clockEn1),
		.postep(postep)
	);

		
		
always @ (data_out,paliwo,litry,postep,czuj_paliwa)
begin

		if (data_out==4'b0011)
		begin
			if (postep==1'b1)
			begin
				case(paliwo)
				2'b01:
						if(litry==czuj_paliwa)
						begin
							$display("licznik dla LPG dziala dobrze");
						end
						else
							begin
							$display("licznik dla LPG nie dziala dobrze");
						end
				2'b10:
					if(litry==czuj_paliwa)
						begin
							$display("licznik dla benzyny dziala dobrze");
						end
					else
						begin
							$display("licznik dla benzyny nie dziala dobrze");
						end
				2'b11:
					if(litry==czuj_paliwa)
						begin
							$display("licznik dla diesla dziala dobrze");
						end
					else
					begin
						$display("licznik diesla nie dziala dobrze");
					end
			  default : $display("nie podano paliwa");
			endcase
			end
		end
	end

always @ (data_out,reset)
begin

			if (reset==1'b1)
			begin
				case(data_out)
				2'b00:
						if(2'b00)
						begin
							$display("Stan Czuwanie - nie dziala");
						end
						else
							begin
							$display("Stan czuwanie - dziala");
						end
				2'b01:
					if(2'b01)
						begin
							$display("Stan rodz_paliwa - dziala");
						end
					else
						begin
							$display("Stan rodz_paliwa - nie dziala");
						end
				2'b10:
					if(2'b10)
						begin
							$display("Stan tankowanie dzia³a");
						end
					else
					begin
						$display("Stan tankowanie nie dziala");
					end
				2'b11:
					if(2'b11)
						begin
							$display("Stan wydruk dzia³a");
						end
					else
					begin
						$display("Stan wydruk nie dziala");
					end
			  default : $display("Wylaczenie maszyny");
			endcase
			end
	end


integer file;
	initial begin
		// Initialize Inputds
		clk = 0;
	
		reset = 0;
		forever
			begin
			#10 clk=~clk;	
			end
	end;
	
	always //@(posedge clk)
	begin
		if(!clockEn1)
			begin
				#5 clk_pompa=0;	
			end
		else 
			begin
			#30 clk_pompa=1;
			#30 clk_pompa=0;
			end
	end
	
	
		initial begin
		file=$fopen("plik.txt","w");
		$fmonitor(file, "reset|paliwo||licznik_litry1,licznik_koszty1|postep|fsm_state");
		forever #10 $fmonitor(file, " |%b|   |%b|      |%d|         |%d|         |%b|       |%b|   ",reset,paliwo,licznik_litry1,licznik_koszty1,postep,data_out);
	end;
                      
		initial begin
		
		reset=0;
		#20;
		reset=1;
		paliwo=2'b00;
		czuj_paliwa=7'b00010110;
		paliwo = 2'b11;
		
		#1340;
		
		paliwo=2'b00;
		#40;
		
		czuj_paliwa=7'b00011111;
		paliwo = 2'b01;
		#960;
		
		reset=0;
		czuj_paliwa=7'b00000000;
		paliwo=2'b00;
		//paliwo = 2'b01;
		//#920;
		
		//paliwo = 2'b00;
		//#40
		
	//	reset=0;
	//	paliwo =2'b00;
		$finish;

		
      end
endmodule

