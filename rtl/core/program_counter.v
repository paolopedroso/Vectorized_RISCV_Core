/*
 * Small Vector Floating Point RISC-V Core - Program Counter
 *
 * @copyright 2025 Paolo Pedroso
 *
 * @license Apache 2.0
 */

module program_counter (
    input               clk,      // Clock
    input               rst,      // Reset
    input               jump,     // Jump instruction (JAL, JALR)
    input               branch_en, // Branch taken (BEQ, BNE)
    input        [31:0] imm,      // Immediate (signed offset for jumps/branches)
    input        [31:0] rs1,      // Base register for JALR
    output reg   [31:0] pc_out,   // Current PC value
    output wire  [31:0] next_pc   // Next PC value
);

    reg [31:0] pc_q;

    /*
     * Compute Next PC:
     * - If branch taken → PC + imm (relative jump)
     * - If jump (JAL) → PC + imm
     * - If JALR → (rs1 + imm) & ~1
     * - Otherwise, increment PC by 4
     */
    assign next_pc = (jump)       ? (pc_q + imm) :  // JAL
                     (branch_en)  ? (pc_q + imm) :  // BEQ, BNE
                     (pc_q + 4);                    // Default: Increment PC

    // Handle Reset and Update PC
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            pc_q <= 32'b0;
        else
            pc_q <= next_pc;
    end

    assign pc_out = pc_q;

endmodule
