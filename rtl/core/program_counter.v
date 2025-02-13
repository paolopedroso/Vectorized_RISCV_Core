/*
 * Small Vector Floating Point RISC-V Core - Program Counter
 *
 * @copyright 2025 Paolo Pedroso <paoloapedroso@gmail.com>
 *
 * @license Apache 2.0
 */

module program_counter (
    input               clk,
    input               rst,
    input               jump,
    input        [31:0] imm,
    output reg   [31:0] pc_out,
    output wire  [31:0] next_pc
);

    reg [31:0] pc_q;

    assign next_pc = (jump) ? imm : (pc_q + 4); // Jump Instruction (JAL, JALR)

    // Implement BEQ and BNE //

    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            pc_q <= 32'b0;
        else
            pc_q <= next_pc;
    end

    assign pc_out = pc_q;

endmodule
