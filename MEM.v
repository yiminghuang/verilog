`include "config.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:17:07 10/18/2013 
// Design Name: 
// Module Name:    MEM2 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module MEM(
    input CLK,
    input RESET,
    //Currently executing instruction [debug only]
    input [31:0] Instr1_IN,
    //PC of executing instruction [debug only]
    input [31:0] Instr1_PC_IN,
    //Output of ALU (contains address to access, or data enroute to writeback)
    input [31:0] ALU_result1_IN,
    //What register will get our ultimate outputs
    input [4:0] WriteRegister1_IN,
    //What data gets written to memory
    input [31:0] MemWriteData1_IN,
    //This instruction is a register write?
    input RegWrite1_IN,
    //ALU control value (used to also specify the type of memory operation)
    input [5:0] ALU_Control1_IN,
    //The instruction requests a load
    input MemRead1_IN,
    //The instruction requests a store
    input MemWrite1_IN,
    //What register we are writing to
    output reg [4:0] WriteRegister1_OUT,
    //Actually do the write
    output reg RegWrite1_OUT,
    //And what data
    output reg [31:0] WriteData1_OUT,
	 
    output reg [31:0] data_write_2DM,
    output [31:0] data_address_2DM,
	 output reg [1:0] data_write_size_2DM,
    input [31:0] data_read_fDM,
	 output MemRead_2DM,
	 output MemWrite_2DM


    );
	 
	 //Variables for Memory Module Inputs/Outputs:
	 //ALU_result == Memory Address to access
	 //MemRead (obvious)
	 //MemWrite (obvious)
	 //ALU_control (obvious)
	 wire [31:0] MemoryData1;	//Used for LWL, LWR (existing content in register) and for writing (data to write)
	 wire [31:0] MemoryData;
	 //wire [31:0] MemoryReadData;	//Data read in from memory (and merged appropriate if LWL, LWR)
	 reg [31:0]	 data_read_aligned;
	 
	 //Word-aligned address for reads
     wire [31:0] MemReadAddress;
     //Not always word-aligned address for writes (SWR has issues with this)
     reg [31:0] MemWriteAddress;

	 wire MemWrite;
	 wire MemRead;
	 
	 wire [31:0] ALU_result;
	 
	 wire [5:0] ALU_Control;
	 
    assign MemWrite = MemWrite1_IN;
    assign MemRead = MemRead1_IN;
    assign ALU_result = ALU_result1_IN;
    assign ALU_Control = ALU_Control1_IN;
    assign MemoryData = MemoryData1;
 
	 assign MemReadAddress = {ALU_result[31:2],2'b00};
	 
	 assign data_address_2DM = MemWrite?MemWriteAddress:MemReadAddress;	//Reads are always aligned; writes may be unaligned
	 
	 assign MemRead_2DM = MemRead;
    assign MemWrite_2DM = MemWrite;
	 
	 
     reg [31:0]WriteData1;
     
	 wire comment1;
	 assign comment1 = 1;
	 

always @(data_read_fDM) begin
	//$display("MEM Received:data_read_fDM=%x",data_read_fDM);
	data_read_aligned = MemoryData;
	//$display("Updated DRA");
	MemWriteAddress = ALU_result;
	case(ALU_Control)
		6'b101101: begin
            //TODO:LWL
		end
		6'b101110: begin
            //TODO:LWR
		end
		6'b100001: begin
            //TODO:LB
		end
		6'b101011: begin
            //TODO:LH
		end
		6'b101010: begin
            //TODO:LBU
		end
		6'b101100: begin
            //TODO:LHU
		end
		6'b111101, 6'b101000, 6'd0, 6'b110101: begin	//LW, LL, NOP, LWC1
			data_read_aligned = data_read_fDM;
			data_write_size_2DM=0;
		end
		6'b101111: begin	//SB
			data_write_size_2DM=1;
            //TODO:SB
            //Set data_write_2DM appropriately
		end
		6'b110000: begin	//SH
			data_write_size_2DM=2;
            //TODO:SH
            //Set data_write_2DM appropriately
		end
		6'b110001, 6'b110110: begin	//SW/SC
			data_write_size_2DM=0;
            //TODO:SW
            //Set data_write_2DM appropriately
		end
		6'b110010: begin	//SWL
            //TODO:SWL
            //Set MemWriteAddress, data_write_2DM and data_write_size_2DM appropriately
		end
		6'b110011: begin	//SWR
            //TODO:SWR
            //Set MemWriteAddress, data_write_2DM and data_write_size_2DM appropriately
		end
		default: begin
		  //If it's not a real memory istruction, do something somewhat related?
			data_read_aligned = data_read_fDM;
			data_write_size_2DM=0;
		end
	endcase
    WriteData1 = MemRead1_IN?data_read_aligned:ALU_result1_IN;
    //Since it's not set elsewhere (that's your job), we'll set a dummy value here:
    data_write_2DM=32'hCAFEDEAD;
end

assign MemoryData1 = MemWriteData1_IN;
	 
	 /* verilator lint_off UNUSED */
	 reg [31:0] Instr1_OUT;
	 reg [31:0] Instr1_PC_OUT;
     /* verilator lint_on UNUSED */

always @(posedge CLK or negedge RESET) begin
	if(!RESET) begin
		Instr1_OUT <= 0;
		Instr1_PC_OUT <= 0;
		WriteRegister1_OUT <= 0;
		RegWrite1_OUT <= 0;
		WriteData1_OUT <= 0;
		$display("MEM:RESET");
	end else if(CLK) begin
			Instr1_OUT <= Instr1_IN;
			Instr1_PC_OUT <= Instr1_PC_IN;
			WriteRegister1_OUT <= WriteRegister1_IN;
			RegWrite1_OUT <= RegWrite1_IN;
			WriteData1_OUT <= WriteData1;
			if(comment1) begin
				$display("MEM:Instr1_OUT=%x,Instr1_PC_OUT=%x,WriteData1=%x; Write?%d to %d",Instr1_IN,Instr1_PC_IN,WriteData1, RegWrite1_IN, WriteRegister1_IN);
				$display("MEM:data_address_2DM=%x; data_write_2DM(%d)=%x(%d); data_read_fDM(%d)=%x",data_address_2DM,MemWrite_2DM,data_write_2DM,data_write_size_2DM,MemRead_2DM,data_read_fDM);
			end
	end
end

endmodule
