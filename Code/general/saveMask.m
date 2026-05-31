function [] = saveMask(im, mask, filename)

saveMask = zeros(size(im));
saveMask(:,:,1) = im2double(im(:,:,1)) - morf(edge(mask), 'dilate', 'disk', 5);
saveMask(:,:,2) = im2double(im(:,:,2));
saveMask(:,:,3) = im2double(im(:,:,3));

imwrite(saveMask, filename);