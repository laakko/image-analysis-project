clear all;
imdata = imread('final_cropped.jpg');
imdata_gray = rgb2gray(imdata);

 %% Calculating and substracting coastal sea area from image

imdata2 = im2bw(imdata,graythresh(imdata));
figure(1);
imshow(imdata2);

% Dilate to fill small gaps
imdata3 = imdilate(imdata2, strel('disk',1));
figure(2);
imshow(imdata3)

% Fills most of the remaining holes
imdata4 = imfill(imdata3, 'holes');
figure(3);
imshow(imdata4)

% Fill remaining holes graphically
% Note: to use, click on holes and then shift + click to continue

imdata5 = imfill(imdata4)
figure(4)
imdata5 = medfilt2(imdata5);
imshow(imdata5)

% Calculate all the black pixels (eg. whole sea area)
sea = find(imdata5==0); % 0 = Black

% Subtract pixels of the sea area from all the pixels
final_pixel_count = (size(imdata2,1)*size(imdata2,2))-size(sea,1);

sea_percentage = size(sea,1)/(size(imdata2,1)*size(imdata2,2));



%% Calculating portions of landtypes

% Percentage of waters can be done by calculating black pixels except that of sea area 

imdata3_filtered = medfilt2(imdata3); %filter out some grain
waters = find(imdata3_filtered==0);
waters = size(waters,1) - size(sea,1);

waters_percentage = waters/final_pixel_count; %approx. 0.08


% Percentages of forest types and cities are calculated from the original
% color image by first finding out RGB colorscales for them. 

R = imdata(:,:,1);
G = imdata(:,:,2);
B = imdata(:,:,3);

% Allocate variables for landtypes
dark_green = G;
cityareas = G;

% Determine conferous forest areas
g = (R < 25) & (G < 50) & (B < 25);
dark_green(~g) = [];
conferousforest = size(dark_green,2) - waters - size(sea,1);

% Plot to see if chosen area is correct
maskedImage = bsxfun(@times, imdata, cast(g,class(imdata)));
figure(7), imshow(maskedImage);

% The most light colored pixels are pure city area with more infrastructure
% than trees
c = (R > 40) & (G > 100) & (B > 40);
cityareas(~c) = [];

% Plot to see if chosen area
maskedImage2 = bsxfun(@times, imdata, cast(c,class(imdata)));
%figure(8), imshow(maskedImage2);

% Enhance clear city areas
maskedImage3 = imdilate(maskedImage2, strel('disk',10));
maskedImage3 = imerode(maskedImage3, strel('disk',12));
maskedImageBW = im2bw(maskedImage3);

% Plot again to see if chosen area is now good
figure(8); imshow(maskedImageBW);


cityareas2 = find(maskedImageBW==1);


% The remaining area is deciduos forest 
deciduosforest = final_pixel_count - waters - size(cityareas,2) - conferousforest;

% Calculate percentages
conferousforest_percentage = conferousforest/final_pixel_count;
cityareas_percentage = size(cityareas2,1)/final_pixel_count;
deciduosforest_percentage = deciduosforest/final_pixel_count; 



%% Plots


%Plot piechart of landtype percentages
X = [waters_percentage, conferousforest_percentage, deciduosforest_percentage, cityareas_percentage]; 
labels = {'Vesistöt' 'Havumetsä' 'Lehtimetsä' 'Kaupunkialue'};

figure(5);
subplot(1,2,1);
pie(X,labels);

subplot(1,2,2);
title('Kaupunkialue-osuuteen lasketut alueet');
[B,L] = bwboundaries(maskedImageBW,'noholes');
imshow(imdata)
hold on
for i = 1:length(B)
   boundary = B{i};
   plot(boundary(:,2), boundary(:,1), 'w', 'LineWidth', 1)
end

