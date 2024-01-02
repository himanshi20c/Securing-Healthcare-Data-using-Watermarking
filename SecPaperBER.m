function SecPaperBER(cover_image, watermark_logo, cover_image_filename)

    % Initialize a structure to store BER values
    results = struct('Attack', {}, 'WatermarkSize', [], 'BER', []);

    % Define parameters
    method = 'DWT-HD-SVD';
    alpha = 0.08;
    attacks = {'No Attack', 'Gaussian low-pass filter', 'Median', 'Gaussian noise', ...
        'Salt and pepper noise', 'Speckle noise', 'JPEG compression', ...
        'JPEG2000 compression', 'Sharpening attack', 'Histogram equalization', ...
        'Average filter', 'Motion blur'};
    params = [0; 3; 3; 0.001; 0; 0; 50; 12; 0.8; 0; 0; 0];

    % Loop through all attacks
    for attackIndex = 1:length(attacks)
        attack = attacks{attackIndex};
        param = params(attackIndex);
        
        % Loop through different watermark sizes (256x256, 128x128, and 64x64)
        watermark_sizes = [256, 128, 64];
        for watermark_size = watermark_sizes
            watermark_logo_resized = imresize(watermark_logo, [watermark_size, watermark_size]);
            
            % Perform watermarking
            [watermarked_image, extracted_watermark] = watermark(cover_image, watermark_logo_resized, method, alpha, attack, param);
            
            % Calculate and store BER
            cover_binary = imbinarize(cover_image);
            watermarked_binary = imbinarize(watermarked_image);
            BER = sum(abs(cover_binary(:) - watermarked_binary(:))) / numel(cover_binary);
            
            % Store BER results in the structure
            results(end + 1).Attack = attack;
            results(end).WatermarkSize = watermark_size;
            results(end).BER = BER;
        end
    end
    
    % Convert the BER structure to a table after collecting all data
    results_table = struct2table(results);

    % Create a unique Excel file for each cover image
    excel_filename = 'BER_Results.xlsx';
    
    % Check if the Excel file exists, and if not, create it
    if ~exist(excel_filename, 'file')
        % Create a new Excel file with the first sheet
        writetable(results_table, excel_filename, 'Sheet', cover_image_filename);
    else
        % Check if the sheet with the same name already exists
        [~, sheet_names] = xlsfinfo(excel_filename);
    
        if ismember(cover_image_filename, sheet_names)
            % Append to the existing sheet
            writetable(results_table, excel_filename, 'Sheet', cover_image_filename, 'WriteMode', 'Append');
        else
            % Create a new sheet in the existing Excel file
            writetable(results_table, excel_filename, 'Sheet', cover_image_filename);
        end
    end
end
