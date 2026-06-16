module traffic_controller(
    input wire clk, rst_n, ped_req,
    output reg [2:0] light_ns, light_ew,
    output reg ped_walk
);
    // State Encoding definition
    parameter S_NS_G = 3'd0, S_NS_Y = 3'd1, S_NS_P = 3'd2;
    parameter S_EW_G = 3'd3, S_EW_Y = 3'd4, S_EW_P = 3'd5;
    
    reg [2:0] state, next_state;
    reg [5:0] timer;
    reg ped_latch;

    // 1. Sequential State Transition Logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) state <= S_NS_G;
        else state <= next_state;
    end

    // 2. Pedestrian Request Latching Control
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) ped_latch <= 0;
        else if (state == S_NS_P || state == S_EW_P) ped_latch <= 0; // Clear after service
        else if (ped_req) ped_latch <= 1; // Catch pedestrian signal
    end

    // 3. Hardware Counter Module
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) timer <= 0;
        else timer <= (state != next_state) ? 0 : timer + 1'b1;
    end

    // 4. Next-State Logic Decoders
    always @(*) begin
        next_state = state;
        case (state)
            S_NS_G: next_state = (timer >= 30) ? S_NS_Y : state;
            S_NS_Y: next_state = (timer >= 5)  ? (ped_latch ? S_NS_P : S_EW_G) : state;
            S_NS_P: next_state = (timer >= 15) ? S_EW_G : state;
            S_EW_G: next_state = (timer >= 30) ? S_EW_Y : state;
            S_EW_Y: next_state = (timer >= 5)  ? (ped_latch ? S_EW_P : S_NS_G) : state;
            S_EW_P: next_state = (timer >= 15) ? S_NS_G : state;
            default: next_state = S_NS_G;
        endcase
    end

    // 5. Output Driver Combinational Logic (Red=3'b100, Yellow=3'b010, Green=3'b001)
    always @(*) begin
        light_ns = 3'b100; light_ew = 3'b100; ped_walk = 0;
        case (state)
            S_NS_G: light_ns = 3'b001;
            S_NS_Y: light_ns = 3'b010;
            S_EW_G: light_ew = 3'b001;
            S_EW_Y: light_ew = 3'b010;
            S_NS_P, S_EW_P: ped_walk = 1;
        endcase
    end
endmodule
