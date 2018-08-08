%
% File: ImageTest.m
% -------------------
% Author: Erick Blankenberg
% Date 8/8/2018
% 
% Description:
%   Tests out the tile manager, images are stored in the 'TestImages'
%   folder, but are not included in the git by default.
%

tileManager = Manager_Tile;

for index = 1:10
    fileString = sprintf('TestImages/Stitch_%d.tif', index);
    if(exist(fileString, 'file'))
        newestImage = imread(fileString);
        %{
        tileManager.addImage(newestImage);
        %}
    end
end

figure(1);
hold on;
imshow(tileManager.getCompositeImage());
hold off;