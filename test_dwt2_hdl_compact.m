function test_dwt2_hdl_compact()
    % So sánh kết quả DWT giữa VHDL và MATLAB 
    close all; clc;

    % Tạo ảnh 8x8 
    img = zeros(8,8);
    for i = 0:7
        for j = 0:7
            val = mod(i + j, 256) * 16;
            img(i+1, j+1) = val / 16384;  % scale về [0,1]
        end
    end

    % DWT bằng hàm HDL-compatible
    [cA_mat, cH_mat, cV_mat, cD_mat] = dwt2_hdl(img);

    % Đọc output từ mô phỏng VHDL
    cA_vhdl = read_coeff_file('C:\questasim64_10.2c\examples\cA_output.txt');
    cH_vhdl = read_coeff_file('C:\questasim64_10.2c\examples\cH_output.txt');
    cV_vhdl = read_coeff_file('C:\questasim64_10.2c\examples\cV_output.txt');
    cD_vhdl = read_coeff_file('C:\questasim64_10.2c\examples\cD_output.txt');

    % Hiển thị ảnh và kết quả
    figure('Name', 'DWT2 HDL Verification', 'NumberTitle', 'off');
    subplot(3,4,1); imshow(img, []); title('Input Image');

    subplot(3,4,2); imshow(cA_mat, []); title('cA - MATLAB');
    subplot(3,4,3); imshow(cH_mat, []); title('cH - MATLAB');
    subplot(3,4,4); imshow(cV_mat, []); title('cV - MATLAB');
    subplot(3,4,5); imshow(cD_mat, []); title('cD - MATLAB');

    subplot(3,4,6); imshow(cA_vhdl, []); title('cA - VHDL');
    subplot(3,4,7); imshow(cH_vhdl, []); title('cH - VHDL');
    subplot(3,4,8); imshow(cV_vhdl, []); title('cV - VHDL');
    subplot(3,4,9); imshow(cD_vhdl, []); title('cD - VHDL');

    % Tính sai số trung bình
    fprintf('\nSai số trung bình (mean absolute error) giữa MATLAB và VHDL:\n');
    fprintf('  cA: %.6e\n', mean(abs(cA_mat(:) - cA_vhdl(:))));
    fprintf('  cH: %.6e\n', mean(abs(cH_mat(:) - cH_vhdl(:))));
    fprintf('  cV: %.6e\n', mean(abs(cV_mat(:) - cV_vhdl(:))));
    fprintf('  cD: %.6e\n', mean(abs(cD_mat(:) - cD_vhdl(:))));
end

function M = read_coeff_file(filename)
    % Đọc file ma trận 4x4 từ file text và scale về dạng double
    raw = readmatrix(filename);
    if numel(raw) ~= 16
        error('File %s không đúng định dạng 4x4.', filename);
    end
    M = reshape(raw, [4,4])' / 16384;  % Chia ngược lại từ fixed-point
end
