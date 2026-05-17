module seq_det_tb;

    logic clk;
    logic rst_n;
    logic din;
    logic detected;
    logic expected_detected;
    logic [2:0] history;

    int error_count;

    seq_det dut (
        .clk      (clk),
        .rst_n    (rst_n),
        .din      (din),
        .detected (detected)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    task automatic apply_reset;
        begin
            din   = 1'b0;
            rst_n = 1'b0;
            history = 3'b000;
            expected_detected = 1'b0;
            repeat (2) @(posedge clk);
            @(negedge clk);
            rst_n = 1'b1;
        end
    endtask

    task automatic check_detected(input logic bit_value);
        begin
            expected_detected = ({history, bit_value} == 4'b1011);

            if (detected !== expected_detected) begin
                $error("history=%03b din=%0b expected detected=%0b got detected=%0b at time %0t",
                       history, bit_value, expected_detected, detected, $time);
                error_count++;
            end
        end
    endtask

    task automatic drive_bit(input logic bit_value);
        begin
            @(negedge clk);
            din = bit_value;
            #1;

            check_detected(bit_value);

            @(posedge clk);
            #1;
            history = {history[1:0], bit_value};
        end
    endtask

    initial begin
        error_count = 0;
        apply_reset();

        // Directed sequence: 1011 should assert detected on the final bit.
        drive_bit(1'b1);
        drive_bit(1'b0);
        drive_bit(1'b1);
        drive_bit(1'b1);

        // Overlapping sequence: 1011011 should produce two detect pulses.
        apply_reset();
        drive_bit(1'b1);
        drive_bit(1'b0);
        drive_bit(1'b1);
        drive_bit(1'b1);
        drive_bit(1'b0);
        drive_bit(1'b1);
        drive_bit(1'b1);

        // Negative sequence: no 1011 pattern.
        apply_reset();
        drive_bit(1'b0);
        drive_bit(1'b0);
        drive_bit(1'b1);
        drive_bit(1'b0);
        drive_bit(1'b1);
        drive_bit(1'b0);

        if (error_count == 0) begin
            $display("TEST PASSED");
        end else begin
            $fatal(1, "TEST FAILED with %0d error(s)", error_count);
        end

        $finish;
    end

endmodule
