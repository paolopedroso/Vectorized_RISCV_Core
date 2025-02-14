/*
 * Small Vector Floating Point RISC-V Core - Instruction Fetch
 *
 * @copyright 2025 Paolo Pedroso <paoloapedroso@gmail.com>
 *
 * @license Apache 2.0
 */

module instr_fetch #(
    parameter int DATA_WIDTH = 32
) (
    input clk,
    input rst,
    input [DATA_WIDTH-1:0] pc_in,          // Current Prog Count
    input [DATA_WIDTH-1:0] instr_mem_data, // Instr from Mem
    output [DATA_WIDTH-1:0] instr_out,     // -> Decode stage
    output [DATA_WIDTH-1:0] instr_addr     // Mem addr for fetching
);

    assign instr_addr = pc_in;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            instr_out <= 32'b0;
        end else begin
            instr_out <= instr_mem_data;
        end
    end

endmodule
