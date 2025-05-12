LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.math_real.ALL;
USE std.textio.ALL;
USE work.dwt2_hdl_fixpt_pkg.ALL;

ENTITY dwt2_hdl_fixpt_tb IS
END dwt2_hdl_fixpt_tb;

ARCHITECTURE behavior OF dwt2_hdl_fixpt_tb IS
    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT dwt2_hdl_fixpt
    PORT(
        img : IN matrix_of_std_logic_vector14(0 TO 7, 0 TO 7);  -- Changed to 8x8
        cA : OUT matrix_of_std_logic_vector14(0 TO 3, 0 TO 3);  -- Changed to 4x4
        cH : OUT matrix_of_std_logic_vector14(0 TO 3, 0 TO 3);  -- Changed to 4x4
        cV : OUT matrix_of_std_logic_vector14(0 TO 3, 0 TO 3);  -- Changed to 4x4
        cD : OUT matrix_of_std_logic_vector14(0 TO 3, 0 TO 3)   -- Changed to 4x4
    );
    END COMPONENT;

    -- Inputs
    SIGNAL img : matrix_of_std_logic_vector14(0 TO 7, 0 TO 7) := (OTHERS => (OTHERS => (OTHERS => '0')));
    
    -- Outputs
    SIGNAL cA : matrix_of_std_logic_vector14(0 TO 3, 0 TO 3);
    SIGNAL cH : matrix_of_std_logic_vector14(0 TO 3, 0 TO 3);
    SIGNAL cV : matrix_of_std_logic_vector14(0 TO 3, 0 TO 3);
    SIGNAL cD : matrix_of_std_logic_vector14(0 TO 3, 0 TO 3);

    -- Clock period definitions
    CONSTANT clk_period : TIME := 10 ns;
    SIGNAL clk : STD_LOGIC := '0';
    SIGNAL sim_done : BOOLEAN := FALSE;

    -- Image processing signals
    SIGNAL image_loaded : BOOLEAN := FALSE;
    SIGNAL processing_started : BOOLEAN := FALSE;
    SIGNAL processing_done : BOOLEAN := FALSE;

BEGIN
    -- Instantiate the Unit Under Test (UUT)
    uut: dwt2_hdl_fixpt PORT MAP (
        img => img,
        cA => cA,
        cH => cH,
        cV => cV,
        cD => cD
    );

    -- Clock process definitions
    clk_process : PROCESS
    BEGIN
        WHILE NOT sim_done LOOP
            clk <= '0';
            WAIT FOR clk_period/2;
            clk <= '1';
            WAIT FOR clk_period/2;
        END LOOP;
        WAIT;
    END PROCESS;

    -- Stimulus process
    stim_proc: PROCESS
        FILE image_file : TEXT;
        VARIABLE line_in : LINE;
        VARIABLE pixel_val : INTEGER;
        VARIABLE space : CHARACTER;
        VARIABLE img_temp : matrix_of_unsigned14(0 TO 7, 0 TO 7) := (OTHERS => (OTHERS => (OTHERS => '0')));

        -- Function to convert image pixel to fixed-point format
        IMPURE FUNCTION pixel_to_fixed(pixel : INTEGER) RETURN STD_LOGIC_VECTOR IS
            VARIABLE fixed_val : UNSIGNED(13 DOWNTO 0);
        BEGIN
            -- Scale to 0-1 range (assuming 8-bit input) and convert to fixed-point (14 fractional bits)
            fixed_val := TO_UNSIGNED(pixel * 16, 14); -- pixel * (2^14 / 256)
            RETURN STD_LOGIC_VECTOR(fixed_val);
        END FUNCTION;
    BEGIN
        -- Initialize inputs
        img <= (OTHERS => (OTHERS => (OTHERS => '0')));
        -- Wait for 100 ns for global reset to finish
        WAIT FOR 100 ns;

        -- Load image from file (simulated)
        -- Note: In real simulation, you would need to read from an actual file
        -- This is a simplified version that creates a test pattern      
        REPORT "Loading test image...";

        -- Option 1: Create a simple test pattern (gradient)
        FOR i IN 0 TO 7 LOOP
            FOR j IN 0 TO 7 LOOP
                -- Create a gradient pattern for testing
                img_temp(i, j) := TO_UNSIGNED((i + j) MOD 256 * 16, 14);
                img(i, j) <= STD_LOGIC_VECTOR(img_temp(i, j));
            END LOOP;
        END LOOP;

        -- Option 2: Uncomment and modify to read from actual file
        -- FILE_OPEN(image_file, "D:\Lenna_(test_image).pgm", READ_MODE);
        -- FOR i IN 0 TO 7 LOOP
        --     FOR j IN 0 TO 7 LOOP
        --         READ(image_file, pixel_val);
        --         img(i, j) <= pixel_to_fixed(pixel_val);
        --     END LOOP;
        -- END LOOP;
        -- FILE_CLOSE(image_file);       
        image_loaded <= TRUE;
        REPORT "Image loaded successfully.";

        -- Wait for processing to complete
        WAIT FOR 10 us;

        -- Check some output values
        REPORT "Checking output coefficients...";

        -- Check that outputs are not all zeros
        ASSERT UNSIGNED(cA(0, 0)) /= TO_UNSIGNED(0, 14) 
            REPORT "cA output is all zeros - possible error" SEVERITY WARNING;
        ASSERT SIGNED(cH(0, 0)) /= TO_SIGNED(0, 14) 
            REPORT "cH output is all zeros - possible error" SEVERITY WARNING;
        ASSERT SIGNED(cV(0, 0)) /= TO_SIGNED(0, 14) 
            REPORT "cV output is all zeros - possible error" SEVERITY WARNING;
        ASSERT SIGNED(cD(0, 0)) /= TO_SIGNED(0, 14) 
            REPORT "cD output is all zeros - possible error" SEVERITY WARNING;

        -- Print some sample values
        REPORT "Sample cA(0,0): " & INTEGER'image(TO_INTEGER(UNSIGNED(cA(0, 0))));
        REPORT "Sample cH(0,0): " & INTEGER'image(TO_INTEGER(SIGNED(cH(0, 0))));
        REPORT "Sample cV(0,0): " & INTEGER'image(TO_INTEGER(SIGNED(cV(0, 0))));
        REPORT "Sample cD(0,0): " & INTEGER'image(TO_INTEGER(SIGNED(cD(0, 0))));

        -- Write outputs to file (for verification)
        REPORT "Writing results to files...";

        -- Write cA (approximation coefficients)
        FILE_OPEN(image_file, "cA_output.txt", WRITE_MODE);
        FOR i IN 0 TO 3 LOOP
            FOR j IN 0 TO 3 LOOP
                WRITE(line_in, TO_INTEGER(UNSIGNED(cA(i, j))));
                WRITELINE(image_file, line_in);
            END LOOP;
        END LOOP;
        FILE_CLOSE(image_file);

        -- Write cH (horizontal detail coefficients)
        FILE_OPEN(image_file, "cH_output.txt", WRITE_MODE);
        FOR i IN 0 TO 3 LOOP
            FOR j IN 0 TO 3 LOOP
                WRITE(line_in, TO_INTEGER(SIGNED(cH(i, j))));
                WRITELINE(image_file, line_in);
            END LOOP;
        END LOOP;
        FILE_CLOSE(image_file);

        -- Write cV (vertical detail coefficients)
        FILE_OPEN(image_file, "cV_output.txt", WRITE_MODE);
        FOR i IN 0 TO 3 LOOP
            FOR j IN 0 TO 3 LOOP
                WRITE(line_in, TO_INTEGER(SIGNED(cV(i, j))));
                WRITELINE(image_file, line_in);
            END LOOP;
        END LOOP;
        FILE_CLOSE(image_file);

        -- Write cD (diagonal detail coefficients)
        FILE_OPEN(image_file, "cD_output.txt", WRITE_MODE);
        FOR i IN 0 TO 3 LOOP
            FOR j IN 0 TO 3 LOOP
                WRITE(line_in, TO_INTEGER(SIGNED(cD(i, j))));
                WRITELINE(image_file, line_in);
            END LOOP;
        END LOOP;
        FILE_CLOSE(image_file);

        REPORT "Simulation completed successfully.";
        sim_done <= TRUE;
        WAIT;
    END PROCESS;

    -- Monitor process
    monitor_proc: PROCESS
    BEGIN
        WAIT UNTIL image_loaded;
        REPORT "Starting DWT processing...";
        processing_started <= TRUE;

        WAIT UNTIL sim_done;
        processing_done <= TRUE;
        WAIT;
    END PROCESS;

END behavior;

