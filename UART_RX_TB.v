`timescale 1us/1ns

module uart_rx_tb;

  // DUT ports
  reg        clk;
  reg        rst;
  reg        RX_IN;
  reg [5:0]  prescale;
  reg        PAR_EN;
  reg        PAR_TYP;   // 0=even, 1=odd
  wire [7:0] P_DATA;
  wire       Data_Valid;
  wire       Parity_Error;
  wire       Stop_Error;

  // Instantiate DUT
  UART_RX dut (
    .clk          (clk),
    .rst          (rst),
    .RX_IN        (RX_IN),
    .prescale     (prescale),
    .PAR_EN       (PAR_EN),
    .PAR_TYP      (PAR_TYP),
    .P_DATA       (P_DATA),
    .Data_Valid   (Data_Valid),
    .Parity_Error (Parity_Error),
    .Stop_Error   (Stop_Error)
  );




  // Clock generation
  initial clk = 0;
  always #(0.271) clk = ~clk; 

  // Task: wait exactly one bit time based on prescale
  task wait_bit_time;
    integer k;
    begin
      for (k = 0; k < prescale; k = k + 1) @(posedge clk);
    end
  endtask

  // Drive a single UART bit value for one bit time, aligned to negedge clk
  task drive_bit;
    input bit_val;
    integer k2;
    begin
      @(negedge clk);
      RX_IN = bit_val;
      for (k2 = 0; k2 < prescale; k2 = k2 + 1) @(posedge clk);
    end
  endtask

  // Task: Send UART Frame
  task send_frame;
    input [7:0] data;
    input       parity_en;
    input       parity_typ; // 0=even,1=odd
    input       inject_parity_err;
    input       inject_stop_err;
    integer i;
    reg parity_bit;
    begin
      // Idle
      drive_bit(1'b1);

      // Start Bit
      drive_bit(1'b0);

      // Data bits (LSB first)
      for(i=0;i<8;i=i+1) begin
        drive_bit(data[i]);
      end

      // Parity
      if(parity_en) begin
        parity_bit = ^data;          // even parity
        if(parity_typ) parity_bit = ~parity_bit; // odd
        if(inject_parity_err) parity_bit = ~parity_bit;
        drive_bit(parity_bit);
      end

      // Stop Bit
      drive_bit(inject_stop_err ? 1'b0 : 1'b1);

      // Return to idle
      drive_bit(1'b1);
    end
  endtask

  // Task: Check results
  task check_result;
    input [7:0] expected_data;
    input       expect_valid;
    input       expect_par_err;
    input       expect_stop_err;
    begin
      integer to;
      if (expect_valid) begin
        // wait for a pulse of Data_Valid within timeout
        Data_Valid === 1'b0;
        for (to = 0; to < prescale*24; to = to + 1) begin
          @(posedge clk);
          if (Data_Valid === 1'b1) disable fork;
        end
        if (Data_Valid !== 1'b1) begin
          $display("FAIL: Data_Valid did not assert within timeout");
        end
        // sample on next cycle for stable P_DATA and error flags
        @(posedge clk);
        if (P_DATA !== expected_data)
          $display("FAIL: Data mismatch. Got %h expected %h", P_DATA, expected_data);
        if (Parity_Error !== 1'b0)
          $display("FAIL: Parity_Error should be 0 on valid frame. Got %b", Parity_Error);
        if (Stop_Error !== 1'b0)
          $display("FAIL: Stop_Error should be 0 on valid frame. Got %b", Stop_Error);
        if ((P_DATA==expected_data) && (Parity_Error==1'b0) && (Stop_Error==1'b0))
          $display("PASS ✅ data=%h", expected_data);
      end else begin
        // expect no Data_Valid; wait timeout then check error flags
        for (to = 0; to < prescale*24; to = to + 1) @(posedge clk);
        if (Data_Valid !== 1'b0)
          $display("FAIL: Data_Valid asserted unexpectedly");
        if (Parity_Error !== expect_par_err)
          $display("FAIL: Parity_Error mismatch. Got %b expected %b", Parity_Error, expect_par_err);
        if (Stop_Error !== expect_stop_err)
          $display("FAIL: Stop_Error mismatch. Got %b expected %b", Stop_Error, expect_stop_err);
        if ((Data_Valid==1'b0) && (Parity_Error==expect_par_err) && (Stop_Error==expect_stop_err))
          $display("PASS ✅ error case data=%h", expected_data);
      end
    end
  endtask

  // Test Scenarios
  initial begin
    // Reset
    rst = 0;
    RX_IN = 1;
    prescale = 16;   
    PAR_EN = 1;
    PAR_TYP = 0;
    #(50);
    rst = 1;
    // idle a bit after reset
    drive_bit(1'b1);

    // 1) Correct frame
    $display("Test 1: Correct Frame");
    send_frame(8'hA5, 1, 0, 0, 0);
    check_result(8'hA5, 1, 0, 0);

    // 2) Parity error
    $display("Test 2: Parity Error");
    send_frame(8'h3C, 1, 0, 1, 0);
    check_result(8'h3C, 0, 1, 0);

    // 3) Stop error
    $display("Test 3: Stop Error");
    send_frame(8'h55, 1, 1, 0, 1);
    check_result(8'h55, 0, 0, 1);

    // 4) No parity
    $display("Test 4: No Parity");
    PAR_EN = 0;
    send_frame(8'hF0, 0, 0, 0, 0);
    check_result(8'hF0, 1, 0, 0);

    $stop;
  end

endmodule
