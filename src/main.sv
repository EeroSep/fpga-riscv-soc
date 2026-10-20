module main  // Top-level module. Processor core + IO + memory + other stuff
import rv32i::*;
( input logic clk,
  output logic [5:0] led
);

    // Power-on reset: hold the core in reset for the first 16 clock cycles
    logic [3:0] por_count = 4'd0;
    logic rst_n;
    always_ff @(posedge clk) begin
        if (por_count != 4'hF) por_count <= por_count + 4'd1;
    end
    assign rst_n = (por_count == 4'hF);

    logic [31:0] io_addr, io_wdata;
    logic io_we;

    core core(
        .clk(clk),
        .rst_n(rst_n),
        .io_addr(io_addr),
        .io_wdata(io_wdata),
        .io_we(io_we)
    );

    // Memory-mapped LED register at 0x1000_0000
    localparam logic [31:0] LED_ADDR = 32'h1000_0000;
    logic [5:0] led_reg;
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            led_reg <= 6'b0;
        end else if (io_we && io_addr == LED_ADDR) begin
            led_reg <= io_wdata[5:0];
        end
    end

    assign led = ~led_reg; // LEDs are active low

endmodule
