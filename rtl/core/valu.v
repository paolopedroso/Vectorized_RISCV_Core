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
    input   logic                     clk,
    input   logic [VLEN-1:0]          op1,          // Vector operand from VRF (v2)
    input   logic [VLEN-1:0]          op2,          // Vector operand from VRF (v3) or scalar
    input   logic [ELEM_SIZE-1:0]     imm,          // Immediate value **IMPLEMENT**
    input   logic [6:0]               funct7,       // Operation type
    input   logic [2:0]               funct3,       // VV, VX, VI subtype **IMPLEMENT**
    output  logic [VLEN-1:0]          result        // Output vector
);

    localparam int NUMELEMS = VLEN / ELEM_SIZE;

    logic [ELEM_SIZE-1:0] op1_elems [NUMELEMS-1];
    logic [ELEM_SIZE-1:0] op2_elems [NUMELEMS-1];
    logic [ELEM_SIZE-1:0] res_elems [NUMELEMS-1];

    // Multiplexer: Selects between op2 (R-Type) and immediate (I-Type)
    logic [ELEM_SIZE-1:0] op2_mux [NUMELEMS-1];

    genvar i;
    generate
        for(i = 0; i < NUMELEMS; i = i + 1) begin: gen_velems
            assign op1_elems[i] = op1[(i+1)*ELEM_SIZE-1 -: ELEM_SIZE];
            assign op2_elems[i] = op2[(i+1)*ELEM_SIZE-1 -: ELEM_SIZE];
        end
    endgenerate

    always_comb begin
        for (int i = 0; i < NUM_ELEMS; i++) begin
            case (funct3)
                3'b000: op2_mux[i] = op2_elems[i]; // Vector-Vector (vv)
                3'b100: op2_mux[i] = op2[(i+1)*DATA_WIDTH-1:0];
                3'b011: op2_mux[i] = imm;          // Vector-Immediate (vi)
                default: op2_mux[i] = 32'b0;
            endcase
        end
    end

    /*
     * Currently Operates
     *
     * Vector ADD
     * Vector SUB
     * Vector MUL
     * Vector DIV
    */

    always_ff @(posedge clk) begin
        case (funct7)
            7'b0000000: // Vector ADD
                for (int i = 0; i < NUMELEMS; i++) begin
                    res_elems[i] <= op1_elems[i] + op2_mux[i];
                end

            7'b0000100: // Vector SUB
                for (int i = 0; i < NUMELEMS; i++) begin
                    res_elems[i] <= op1_elems[i] - op2_mux[i];
                end

            7'b1001011: // Vector MUL
                for (int i = 0; i < NUMELEMS; i++) begin
                    res_elems[i] <= op1_elems[i] * op2_mux[i];
                end

            7'b1001100: // Vector DIV
                for (int i = 0; i < NUMELEMS; i++) begin
                    res_elems[i] <= op1_elems[i] / op2_mux[i];
                end

            default:
                for (int i = 0; i < NUMELEMS; i++)
                    res_elems[i] <= {ELEM_SIZE{1'b0}};
        endcase
    end

    generate
        for (i = 0; i < NUMELEMS; i = i + 1) begin: gen_vres
            assign result[(i+1)*ELEM_SIZE-1 -: ELEM_SIZE] = res_elems[i];
        end
    endgenerate

endmodule
