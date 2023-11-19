clc, clear, close all;

% List of image file names
imageFiles = {'072.jpg', '168.jpg', 'RET025OD.jpg', 'RET026OS.jpg', 'TRAIN000022.jpg', 'TRAIN000053.jpg'};

radioMascara = 160; % Ajusta este valor según sea necesario

% Iterate over each image
for i = 1:length(imageFiles)
    % Read the current image
    currentImage = imread(imageFiles{i});

    % Normalize the size of the image to 720 x 576 pixels
    targetSize = [720, 576];
    resizedImage = imresize(currentImage, targetSize);

    % Convert the resized image to grayscale
    grayImage = rgb2gray(resizedImage);

    %grayImage = histeq(grayImage);

    % Choose a threshold value (you can change this value)
    thresholdValue = 120;


% Create a circular mask
    [rows, cols] = size(grayImage);
    [x, y] = meshgrid(1:cols, 1:rows);
    circularMask = ((x - cols / 2).^2 + (y - rows / 2).^2) <= (radioMascara^2);

    % Apply the circular mask to the equalized image
    maskedImage = grayImage;
    maskedImage(~circularMask) = 0;



    % Perform thresholding
    binaryImage = im2bw(maskedImage, thresholdValue/255); % Normalize threshold to [0, 1]

    % Calculate centroid
    [m, n] = size(binaryImage);
    sumx = 0;
    sumy = 0;
    mu00 = sum(binaryImage(:)); % µ00

    for x = 1:m
        for y = 1:n
            sumx = sumx + x * binaryImage(x, y);
            sumy = sumy + y * binaryImage(x, y);
        end
    end

    % Calculate centroid coordinates
    Cx = sumx / mu00;
    Cy = sumy / mu00;

    % Dimensions of the square ROI
    roiSize = 173;

    % Calculate the coordinates for the top-left corner of the ROI
    roiTopLeftX = round(Cx - roiSize / 2);
    roiTopLeftY = round(Cy - roiSize / 2);

    % Ensure that the ROI stays within the image boundaries
    roiTopLeftX = max(1, roiTopLeftX);
    roiTopLeftY = max(1, roiTopLeftY);

    % Calculate the coordinates for the bottom-right corner of the ROI
    roiBottomRightX = roiTopLeftX + roiSize - 1;
    roiBottomRightY = roiTopLeftY + roiSize - 1;

    % Ensure that the ROI stays within the image boundaries
    roiBottomRightX = min(size(resizedImage, 1), roiBottomRightX);
    roiBottomRightY = min(size(resizedImage, 2), roiBottomRightY);

    % Extract the sub-image or patch
    opticDiscPatch = resizedImage(roiTopLeftX:roiBottomRightX, roiTopLeftY:roiBottomRightY, :);

    % Create a new figure for each image
    figure;

    % Original Image
    subplot(2, 2, 1);
    imshow(resizedImage);
    title('Original Image');

    % Grayscale Image
    subplot(2, 2, 2);
    imshow(maskedImage);
    title('Masked Image');

    % Binary Image with Centroid
    subplot(2, 2, 3);
    imshow(binaryImage);
    hold on;
    plot(Cy, Cx, 'r*'); % Note: Swap Cx and Cy for plotting due to matrix indexing
    title('Binary Image with Centroid');
    hold off;

    % Optic Disc Patch
    subplot(2, 2, 4);
    imshow(opticDiscPatch);
    title('Optic Disc Patch');

    % Display the ROI on the original image
    hold on;
    rectangle('Position', [roiTopLeftY, roiTopLeftX, roiSize, roiSize], 'EdgeColor', 'r', 'LineWidth', 2);
    hold off;
end
