`timescale 1s/1ms

module tb_traffic_controller;
    reg clk;
    reg rst_n;
    reg ped_req;
    wire [2:0] light_ns;
    wire [2:0] light_ew;
    wire ped_walk;

    // Unit Under Test Instantiation
    traffic_controller dut (
        .clk(clk), .rst_n(rst_n), .ped_req(ped_req),
        .light_ns(light_ns), .light_ew(light_ew), .ped_walk(ped_walk)
    );

    // 1Hz Clock Loop Generator
    always #0.5 clk = ~clk;

    initial begin
        // Baseline Initialization
        clk = 0; rst_n = 0; ped_req = 0;
        #2 rst_n = 1; // Release reset flag

        // Observe baseline non-interrupted cyclic routines
        #80; 

        // Trigger dynamic pedestrian request interrupt
        #5 ped_req = 1; 
        #2 ped_req = 0; // Simulate button release action

        // Run out evaluation timelines
        #60 $finish;
    end

    initial begin
        $dumpfile("traffic_sim.vcd");
        $dumpvars(0, tb_traffic_controller);
    end
endmodule
