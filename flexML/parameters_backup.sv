package parameters;

////// ENABLE VERSION 2 OF THE DESIGN (stride, svm, deconv, upsampling)////////////////////////////////
`define DESIGN_V2
//////////////////// HARDWARE DESIGN VARIABLES //////////////////////////////////////////////////////
// Instruction Memory
	parameter integer INSTRUCTION_MEMORY_WIDTH=32;
	parameter integer INSTRUCTION_MEMORY_SIZE=16; //1024 instrunctions
	parameter integer INSTRUCTION_MEMORY_FIELDS=32;

//Mode variables
	parameter integer MODE_FC=0;
	parameter integer MODE_CNN=1;
	parameter integer MODE_ACTIVATION=2;
	parameter integer MODE_EWS=3;

// Design parameters
	parameter integer N_DIM_ARRAY=8;
	parameter integer N_DIM_ARRAY_LOG = $clog2(N_DIM_ARRAY);
	parameter integer SIZE_ARRAY= N_DIM_ARRAY*N_DIM_ARRAY;
//input channel memory
	parameter integer INPUT_CHANNEL_DATA_WIDTH=8;

        parameter integer TOTAL_ACTIVATION_MEMORY_SIZE=2**16; //
        parameter integer ACT_NUMBER_OF_WORDS_PER_BANK=2**12;
        parameter integer ACT_NUMBER_OF_WORDS_PER_ROW=4; //4 bytes (32 bits) per row of each SRAM macro 
 
	parameter integer PER_BUFFER_ACTIVATION_MEMORY_SIZE=TOTAL_ACTIVATION_MEMORY_SIZE/2; // assuming double buffering
	parameter ACT_MEMORY_SIZE_BANK=ACT_NUMBER_OF_WORDS_PER_BANK/ACT_NUMBER_OF_WORDS_PER_ROW;  // Minimal Block of memory

        parameter integer INPUT_CHANNEL_ADDR_SIZE=$clog2(TOTAL_ACTIVATION_MEMORY_SIZE);
	parameter ACT_MEM_SRAM_blocks_per_row = N_DIM_ARRAY;
	parameter ACT_MEM_SRAM_numBit=INPUT_CHANNEL_DATA_WIDTH;
	parameter ACT_MEM_SRAM_numWordAddr = $clog2(ACT_MEMORY_SIZE_BANK);
	parameter ACT_MEM_SRAM_blocks_per_column = (PER_BUFFER_ACTIVATION_MEMORY_SIZE/N_DIM_ARRAY)/(ACT_MEMORY_SIZE_BANK);
	parameter ACT_MEM_SRAM_blocks_per_row_log = $clog2(ACT_MEM_SRAM_blocks_per_row);
	parameter ACT_MEM_SRAM_totalWordAddr = ACT_MEM_SRAM_numWordAddr + ACT_MEM_SRAM_blocks_per_row_log + $clog2(ACT_MEM_SRAM_blocks_per_column);

//weight memory with double buffering
	parameter integer WEIGHT_DATA_WIDTH=8;
	
	parameter integer TOTAL_WEIGHT_MEMORY_SIZE = (2**17);   // Total memory for double buffering
        parameter integer W_NUMBER_OF_WORDS_PER_BANK=2**8; 
        parameter integer W_NUMBER_OF_WORDS_PER_ROW=4; //4 bytes (32 bits) per row of each SRAM macro
   
        parameter integer PER_BUFFER_WEIGHT_MEMORY_SIZE=TOTAL_WEIGHT_MEMORY_SIZE/2;  //  Total memory per buffer12	
	parameter W_MEMORY_SIZE_BANK=W_NUMBER_OF_WORDS_PER_BANK/W_NUMBER_OF_WORDS_PER_ROW; // Minimal Block of memory

        parameter integer WEIGHT_MEMORY_ADDR_SIZE=$clog2(TOTAL_WEIGHT_MEMORY_SIZE);
	parameter FC_W_MEM_SRAM_totalWordAddr =WEIGHT_MEMORY_ADDR_SIZE;
	parameter CNN_W_MEM_SRAM_totalWordAddr =WEIGHT_MEMORY_ADDR_SIZE;
	parameter SUBBLOCK_W_MEM_NUMBER_OF_SUBBLOCKS= N_DIM_ARRAY;
	parameter SUBBLOCK_W_MEM_NUMBER_OF_SUBBLOCKS_log = $clog2(SUBBLOCK_W_MEM_NUMBER_OF_SUBBLOCKS);
	parameter SUBBLOCK_W_MEM_SRAM_blocks_per_row = N_DIM_ARRAY;
	parameter SUBBLOCK_W_MEM_SRAM_numBit=WEIGHT_DATA_WIDTH;
	parameter SUBBLOCK_W_MEM_SRAM_numWordAddr = $clog2(W_MEMORY_SIZE_BANK);
	parameter WEIGHT_MEMORY_SIZE_PER_SUBBLOCK=PER_BUFFER_WEIGHT_MEMORY_SIZE/SUBBLOCK_W_MEM_NUMBER_OF_SUBBLOCKS;
	parameter SUBBLOCK_W_MEM_SRAM_blocks_per_column = (WEIGHT_MEMORY_SIZE_PER_SUBBLOCK/(SUBBLOCK_W_MEM_SRAM_blocks_per_row))/(W_MEMORY_SIZE_BANK);
	parameter SUBBLOCK_W_MEM_SRAM_totalWordAddr = WEIGHT_MEMORY_ADDR_SIZE;
	
//pe
	parameter integer ACC_DATA_WIDTH=32;  
//activations
	parameter integer ACT_DATA_WIDTH=8;
	parameter integer NUMBER_OF_NONLINEAR_FUNCTIONS_BITS=3;

// LUT
	parameter integer LUT_SIZE=128;
	parameter integer LUT_ADDR = $clog2(LUT_SIZE);
	parameter integer LUT_DATA_WIDTH=8;

// Control unit
	parameter integer NUMBER_OF_CR_SIGNALS=17;
	parameter LL_FSM_bits=6;
	parameter HL_FSM_bits =6;
	parameter MAXIMUM_DILATION_BITS=8;
// Writing ports
	parameter integer BIT_WIDTH_EXTERNAL_PORT=32;

/////////////////////////////////////// Configuration Registers //////////////////////////////////////////////
	parameter integer CONF_REGISTERS_SIZE=32;



/////////////////////////////////////// Structural Sparsity /////////////////////////////////////////////////////
        parameter integer STR_SP_MEMORY_SIZE=2**11;
        parameter integer STR_SP_MEMORY_WORD=32;
        parameter integer STR_SP_MEMORY_WORD_LOG=$clog2(STR_SP_MEMORY_WORD);
        parameter integer BLOCK_SPARSE=0;
endpackage
