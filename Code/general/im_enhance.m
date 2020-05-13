function im_enh = im_enhance(imr, lims, mask, plotta)


t1 = imadjust(imr, lims, [0; 1]);
im_seg = t1 .* mask;
im_enh = im_seg;


if plotta,
    figure,
    imshow(im_enh)
    title('enhanced');
end