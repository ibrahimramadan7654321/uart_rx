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




  // Clock generation (prescale = 16)
  initial clk = 0;
  always #(0.271) clk = ~clk; 
  // prescale=16 → RX_CLK ≈ 1.843 MHz

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
      RX_IN = 1; #(prescale*10);

      // Start Bit
      RX_IN = 0; #(prescale*10);

      // Data bits (LSB first)
      for(i=0;i<8;i=i+1) begin
        RX_IN = data[i];
        #(prescale*10);
      end

      // Parity
      if(parity_en) begin
        parity_bit = ^data;          // even parity
        if(parity_typ) parity_bit = ~parity_bit; // odd
        if(inject_parity_err) parity_bit = ~parity_bit;
        RX_IN = parity_bit;
        #(prescale*10);
      end

      // Stop Bit
      RX_IN = inject_stop_err ? 0 : 1;
      #(prescale*10);
    end
  endtask

  // Task: Check results
  task check_result;
    input [7:0] expected_data;
    input       expect_valid;
    input       expect_par_err;
    input       expect_stop_err;
    begin
      // wait for DUT to assert Data_Valid
      #(prescale*12);
      if (Data_Valid !== expect_valid) 
        $display("FAIL: Data_Valid mismatch. Got %b expected %b", Data_Valid, expect_valid);
      if (P_DATA !== expected_data && expect_valid)
        $display("FAIL: Data mismatch. Got %h expected %h", P_DATA, expected_data);
      if (Parity_Error !== expect_par_err)
        $display("FAIL: Parity_Error mismatch. Got %b expected %b", Parity_Error, expect_par_err);
      if (Stop_Error !== expect_stop_err)
        $display("FAIL: Stop_Error mismatch. Got %b expected %b", Stop_Error, expect_stop_err);
      if ((Data_Valid==expect_valid) &&
          (P_DATA==expected_data || !expect_valid) &&
          (Parity_Error==expect_par_err) &&
          (Stop_Error==expect_stop_err))
        $display("PASS ✅ data=%h", expected_data);
    end
  endtask

  // Test Scenarios
  initial begin
    // Reset
    rst = 1;
    RX_IN = 1;
    prescale = 16;   
    PAR_EN = 1;
    PAR_TYP = 0;
    #(50);
    rst = 0;

    // 1) Correct frame
    $display("Test 1: Correct Frame");
    send_frame(8'hA5, 1, 0, 0, 0);
    check_result(8'hA5, 1, 0, 0);

    // 2) Parity error
    $display("Test 2: Parity Error");
    send_frame(8'h3C, 1, 0, 1, 0);
    check_result(8'h3C, 1, 1, 0);

    // 3) Stop error
    $display("Test 3: Stop Error");
    send_frame(8'h55, 1, 1, 0, 1);
    check_result(8'h55, 1, 0, 1);

    // 4) No parity
    $display("Test 4: No Parity");
    PAR_EN = 0;
    send_frame(8'hF0, 0, 0, 0, 0);
    check_result(8'hF0, 1, 0, 0);

    $stop;
  end

endmodule
