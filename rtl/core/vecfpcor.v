    /*
     * Small Vector Floating Point RISC-V Core
     *
     * @copyright 2025 Paolo Pedroso <paoloapedroso@gmail.com>
     *
     * @license Apache 2.0
     *
    */

module vecfpcor #(
    parameter int DATA_WIDTH = 32

) (
    input clk,
    input rst,

    // Instruction Memory
    input [DATA_WIDTH-1:0] instr_in,
    output [DATA_WIDTH-1:0] pc_out
);

    wire [6:0] opcode   = instr_in[6:0];          // Operation
    wire [3:0] rd       = instr_in[11:7];         // Reg Destination
    wire [2:0] funct3   = instr_in[14:12];        // SubOp Select
    wire [4:0] rs1      = instr_in[19:15];        // Src1 Reg Index
    wire [4:0] rs2      = instr_in[24:20];        // Src2 Reg Index
    wire [6:0] funct7   = instr_in[31:25];        // SubOp Select

    /* WIP:
     * IF
     * ID
     * EX
     * MEM
     * WB
    */

    // -- Program Counter
    program_counter program_counter (
        .clk(clk),
        .rst(rst),
        .jump(jump),
        .imm(imm),
        .pc_out(pc_out),
        .next_pc(next_pc)
    );


    // -- Instruction Fetch

    instr_fetch instr_fetch (
        .clk(clk),
        .rst(rst),
        .pc_in(pc_out),
        .instr_mem_data(instr_in), // Instruction comes from memory
        .instr_out(instr_out),     // Output to instruction decode
        .instr_addr(next_pc)       // Address for fetching next instruction
    );

    // -- Instruction Decode

    // -- Scalar and Vector ALU

    // -- Vector Reg File

    // -- Vector Mem Unit

    // -- Control Unit


endmodule
