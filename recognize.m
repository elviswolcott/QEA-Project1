%% Recognize an image using a pre-trained model
% This function accepts a model and a series of points, then rasterizes the
% image, projects the image onto the model's eigenvectors and finds its
% nearest neighbor, returning if the match was successful, and (if it was)
% the label and the match index.
function [success, label, match] = recognize(model, points)
    %% Rasterization
    img = rasterize(points, 45);
    
    img = reshape(img, [size(img, 1) * size(img, 2), 1]);
    
    
    
    %% Image/Eigenvector Projection
    img_projected = model.eigenvectors' * img;
    
    %% Matching and Labeling
    [match, distance] = knnsearch(model.training_imgs_projected', img_projected')
    
    success = true; % TODO
    label = model.training_labels(match);
end