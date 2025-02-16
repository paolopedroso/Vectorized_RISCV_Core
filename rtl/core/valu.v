    /*
     * Vector ALU
     *
     * @copyright 2025 Paolo Pedroso <paoloapedroso@gmail.com>
     *
     * @license Apache 2.0
     *
    */

module valu #(
    parameter int VLEN              = 256,         // Vector length in bits
    parameter int ELEM_SIZE         = 32,          // Element size in bits (e.g., 32-bit)
    parameter int DATA_WIDTH        = 32
)(
    input   logic                    clk,
    input   logic                    rst_n,        // Added reset signal
    input   logic [VLEN-1:0]         op1,          // Vector operand from VRF (v2)
    input   logic [VLEN-1:0]         op2,          // Vector operand from VRF (v3) or scalar
    input   logic [ELEM_SIZE-1:0]    imm,          // Immediate value
    input   logic                    is_scalar,    // Flag for scalar operation
    input   logic [6:0]              funct7,       // Operation type
    input   logic [2:0]              funct3,       // VV, VX, VI subtype
    output  logic [VLEN-1:0]         result,       // Output vector
    output  logic                    valid         // Result valid signal
);

    localparam int NUMELEMS = VLEN / ELEM_SIZE;

    // Registered inputs for better timing
    logic [VLEN-1:0] op1_reg, op2_reg;
    logic [ELEM_SIZE-1:0] imm_reg;
    logic [6:0] funct7_reg;
    logic [2:0] funct3_reg;
    logic is_scalar_reg;

    // Element arrays
    logic [ELEM_SIZE-1:0] op1_elems [NUMELEMS];
    logic [ELEM_SIZE-1:0] op2_elems [NUMELEMS];
    logic [ELEM_SIZE-1:0] res_elems [NUMELEMS];

    // Register inputs
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            op1_reg <= 1'b0;
            op2_reg <= 1'b0;
            imm_reg <= 1'b0;
            funct7_reg <= 1'b0;
            funct3_reg <= 1'b0;
            is_scalar_reg <= 1'b0;
        end else begin
            op1_reg <= op1;
            op2_reg <= op2;
            imm_reg <= imm;
            funct7_reg <= funct7;
            funct3_reg <= funct3;
            is_scalar_reg <= is_scalar;
        end
    end

    // Split vectors into elements
    genvar i;
    generate
        for(i = 0; i < NUMELEMS; i++) begin: gen_velems
            assign op1_elems[i] = op1_reg[i*ELEM_SIZE +: ELEM_SIZE];

            // Determine if scalar reg
            assign op2_elems[i] = is_scalar_reg ? op2_reg[ELEM_SIZE-1:0] :
                                                 op2_reg[i*ELEM_SIZE +: ELEM_SIZE];
        end
    endgenerate

    // Operation selection and execution
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < NUMELEMS; i++)
                res_elems[i] <= '0;
            valid <= 1'b0;
        end else begin
            valid <= 1'b1;
            case (funct7_reg)
                7'b0000000: // Vector ADD
                    for (int i = 0; i < NUMELEMS; i++)
                        res_elems[i] <= op1_elems[i] +
                                      (funct3_reg == 3'b011 ? imm_reg : op2_elems[i]);

                7'b0000100: // Vector SUB
                    for (int i = 0; i < NUMELEMS; i++)
                        res_elems[i] <= op1_elems[i] -
                                      (funct3_reg == 3'b011 ? imm_reg : op2_elems[i]);

                7'b1001011: // Vector MUL
                    for (int i = 0; i < NUMELEMS; i++)
                        res_elems[i] <= op1_elems[i] *
                                      (funct3_reg == 3'b011 ? imm_reg : op2_elems[i]);

                7'b1001100: // Vector DIV
                    for (int i = 0; i < NUMELEMS; i++)
                        res_elems[i] <= op2_elems[i] != '0 ?
                                      op1_elems[i] / (funct3_reg == 3'b011 ? imm_reg :
                                      op2_elems[i]) :
                                      {ELEM_SIZE{1'b1}}; // Division by zero handling

                default: begin
                    for (int i = 0; i < NUMELEMS; i++)
                        res_elems[i] <= '0;
                    valid <= 1'b0;
                end
            endcase
        end
    end

    // Combine elements back into result vector
    generate
        for (i = 0; i < NUMELEMS; i++) begin: gen_vres
            assign result[i*ELEM_SIZE +: ELEM_SIZE] = res_elems[i];
        end
    endgenerate

endmodule
