`timescale 1ns/1ps

module nco_tb;
    reg         clk = 0;
    reg         rst;
    reg  [15:0] tuning_word;
    wire [7:0]  sinewave_output;

    // Device Under Test
    nco dut (
        .clk(clk),
        .rst(rst),
        .tuning_word(tuning_word),
        .sinewave_output(sinewave_output)
    );

    // 50 MHz clock (#10 half period = 20 ns period)
    always #10 clk = ~clk;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, nco_tb);

        // Reset
        rst         = 1;
        tuning_word = 16'd0;
        #20 rst = 0;

        // Scenario 1: low frequency, tuning word 300
        // f_out = 300 * 50 MHz / 65536 = ~229 kHz (period ~4.4 us)
        // 5 us shows a bit over one full cycle
        #10 tuning_word = 16'd300;
        #5000;

        // Scenario 2: higher frequency, tuning word 2000
        // f_out = 2000 * 50 MHz / 65536 = ~1.53 MHz (period ~655 ns)
        // 2 us shows about three full cycles
        $display("Switching tuning word to 2000 at %0t ns", $time);
        tuning_word = 16'd2000;
        #2000;

        $display("Simulation completed at %0t ns", $time);
        $finish;
    end

endmodule
