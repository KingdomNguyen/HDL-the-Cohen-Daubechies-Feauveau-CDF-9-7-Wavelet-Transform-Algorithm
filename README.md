# DESIGNED & VERIFIED FPGA-BASED 2D WAVELET TRANSFORM
## Problem statement 
Design a hardware-optimized 2D Discrete Wavelet Transform (DWT) core for real-time signal/image processing with:
- Low latency: Suitable for streaming applications (e.g., 5G baseband, image compression).
- Resource efficiency: Minimize FPGA resource usage (LUTs, DSP blocks).
- Accuracy: Maintain fidelity vs. floating-point MATLAB reference.
## Methodology
1. Algorithm Selection
   - CDF 9/7 Biorthogonal Wavelet: Industry standard for lossy compression (JPEG 2000).
   - Fixed-point arithmetic: 14-bit precision balances accuracy and hardware cost.
2. Hardware Optimization Techniques
   - Streaming architecture: Process data row/column-wise to reduce buffer memory.
   - Circular buffers: Handle symmetric boundary extension for edge pixels.
   - Parallel convolution: Unroll filter loops for pipelining.
3. Testbench Design & Verification Approach
### Test Strategy
- Goal: Verify functional correctness of the 2D DWT core against a MATLAB golden reference.
- Key Metrics:
  + Accuracy: Output coefficients (cA, cH, cV, cD) must match MATLAB within 14-bit fixed-point tolerance.
  + Latency: Ensure real-time processing (streaming).
  + Resource: Monitor FPGA utilization (LUTs, DSP blocks).
### Testbench Components
- Stimulus Generator: Provides input image data to DUT.
- Clock & Reset: Mimics FPGA clock timing.
- DUT: Device Under Test (my VHDL Wavelet core).
- Output Checker: Validates results against expected values.
- Report Generator: Logs simulation results.
### Verification Methods
 a) Functional Testing:
- Self-Checking Testbench:
   + Predefined Inputs: Synthetic gradient (deterministic)
   + Boundary Handling: Tests symmetric extension via edge pixels (circular_buffer).
- File I/O:
   + Input: Option to read real images (commented in your code).
   + Output: Exports coefficients to text files for MATLAB comparison.
b) Corner-Case Testing
- Fixed-Point Overflow: Tests with max/min pixel values (TO_UNSIGNED(255*16, 14)).
- Small Images: Validates 8×8 → 4×4 downsampling.
## Result
```
Mean absolute error between MATLAB and VHDL outputs:
  cA: 9.700785e-04
  cH: 7.401618e-04
  cV: 1.104303e-03
  cD: 1.110829e-03
```
![Compare DWT coefficients between MATLAB and HDL](https://github.com/KingdomNguyen/image_1/blob/main/Screenshot%202025-07-30%20195459.jpg)
