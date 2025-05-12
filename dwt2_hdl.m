function [cA, cH, cV, cD] = dwt2_hdl(img)
%#codegen
% HDL-compatible 2D DWT using only CDF 9/7 wavelet with streaming interface

% Define filter coefficients as constants (not persistent)
lpf = [0.026748757411, -0.016864118443, -0.078223266529, ...
       0.266864118443, 0.602949018236, 0.266864118443, ...
      -0.078223266529, -0.016864118443, 0.026748757411];
hpf = [0.091271763114, -0.057543526229, -0.591271763114, ...
       1.11508705, -0.591271763114, -0.057543526229, ...
       0.091271763114, 0, 0]; % Pad to length 9

% Get image dimensions
[rows, cols] = size(img);

% Initialize outputs with fixed sizes (important for HDL)
output_size = ceil([rows cols]/2);
cA = zeros(output_size, 'like', img);
cH = zeros(output_size, 'like', img);
cV = zeros(output_size, 'like', img);
cD = zeros(output_size, 'like', img);

% Process one column at a time to reduce I/O
row_cA = zeros(output_size(1), cols, 'like', img);
row_cD = zeros(output_size(1), cols, 'like', img);

for c = 1:cols
    % Process one column (convert to row vector for processing)
    col_data = img(:, c)';
    
    % Use streaming version of 1D DWT
    [approx, detail] = dwt_1d_hdl_streaming(col_data, lpf, hpf);
    
    row_cA(:, c) = approx';
    row_cD(:, c) = detail';
end

% Process one row at a time to reduce I/O
for r = 1:output_size(1)
    % Process approximation and detail rows separately
    [cA_row, cV_row] = dwt_1d_hdl_streaming(row_cA(r, :), lpf, hpf);
    [cH_row, cD_row] = dwt_1d_hdl_streaming(row_cD(r, :), lpf, hpf);
    
    cA(r, :) = cA_row;
    cV(r, :) = cV_row;
    cH(r, :) = cH_row;
    cD(r, :) = cD_row;
end
end

function [approx, detail] = dwt_1d_hdl_streaming(signal, lpf, hpf)
%#codegen
% Stream-processing version of 1D DWT for HDL

N = length(signal);
approx_len = ceil(N/2);
approx = zeros(1, approx_len, 'like', signal);
detail = zeros(1, approx_len, 'like', signal);

% Use circular buffer for symmetric extension (more HDL-friendly)
buffer_size = length(lpf);
circular_buffer = zeros(1, buffer_size, 'like', signal);

% Initialize buffer with first samples
for i = 1:buffer_size-1
    if i <= length(signal)
        circular_buffer(i) = signal(i);
    else
        % Symmetric extension
        circular_buffer(i) = signal(2*length(signal)-i);
    end
end

% Process samples in streaming fashion
for i = 1:approx_len
    % Update circular buffer
    sample_pos = 2*(i-1) + buffer_size;
    if sample_pos <= length(signal)
        new_sample = signal(sample_pos);
    else
        % Symmetric extension
        new_sample = signal(2*length(signal)-sample_pos);
    end
    
    % Shift buffer
    circular_buffer = [circular_buffer(2:end), new_sample];
    
    % Compute convolution
    a_temp = 0;
    d_temp = 0;
    for j = 1:length(lpf)
        a_temp = a_temp + lpf(j) * circular_buffer(j);
        d_temp = d_temp + hpf(j) * circular_buffer(j);
    end
    
    approx(i) = a_temp;
    detail(i) = d_temp;
end
end