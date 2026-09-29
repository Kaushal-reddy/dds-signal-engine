module nco (
    input  wire        clk,
    input  wire        rst,
    input  wire [15:0] tuning_word,
    output reg  [7:0]  sinewave_output
);

    reg  [15:0] phase;
    wire [4:0]  phase_idx;
    reg  [7:0]  lookup_table_out;

    // 16-bit Phase Accumulator Core
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            phase <= 16'd0;
        end else begin
            phase <= phase + tuning_word;
        end
    end

    // Extract top 5 bits of phase for a 32-sample Lookup Table
    assign phase_idx = phase[15:11];

    // Explicit Synthesizable Sine Look-Up Table (LUT)
    // Map: 0 to 31 indices over a 2*pi cycle, scaled to 8-bit unsigned (0-255)
    always @(*) begin
        case(phase_idx)
            5'd0  : lookup_table_out = 8'd128; 5'd1  : lookup_table_out = 8'd153;
            5'd2  : lookup_table_out = 8'd177; 5'd3  : lookup_table_out = 8'd200;
            5'd4  : lookup_table_out = 8'd219; 5'd5  : lookup_table_out = 8'd234;
            5'd6  : lookup_table_out = 8'd245; 5'd7  : lookup_table_out = 8'd251;
            5'd8  : lookup_table_out = 8'd253; 5'd9  : lookup_table_out = 8'd251;
            5'd10 : lookup_table_out = 8'd245; 5'd11 : lookup_table_out = 8'd234;
            5'd12 : lookup_table_out = 8'd219; 5'd13 : lookup_table_out = 8'd200;
            5'd14 : lookup_table_out = 8'd177; 5'd15 : lookup_table_out = 8'd153;
            5'd16 : lookup_table_out = 8'd128; 5'd17 : lookup_table_out = 8'd103;
            5'd18 : lookup_table_out = 8'd79;  5'd19 : lookup_table_out = 8'd56;
            5'd20 : lookup_table_out = 8'd37;  5'd21 : lookup_table_out = 8'd22;
            5'd22 : lookup_table_out = 8'd11;  5'd23 : lookup_table_out = 8'd5;
            5'd24 : lookup_table_out = 8'd3;   5'd25 : lookup_table_out = 8'd5;
            5'd26 : lookup_table_out = 8'd11;  5'd27 : lookup_table_out = 8'd22;
            5'd28 : lookup_table_out = 8'd37;  5'd29 : lookup_table_out = 8'd56;
            5'd30 : lookup_table_out = 8'd79;  5'd31 : lookup_table_out = 8'd103;
            default: lookup_table_out = 8'd128;
        endcase
    end

    // Pipeline register stage to isolate memory lookup delay from system paths
    always @(posedge clk) begin 
        sinewave_output <= lookup_table_out;
    end

endmodule