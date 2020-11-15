%% Run the entire PCA process
% This function is a wrapper over the entire recognition process (not
% including training). It accepts a trained model, then prompts the user to
% draw a symbol, rasterizes it, projects it onto the eigenvectors, and
% finds the nearest neighbor.
function [label, match] = run_draw(model)
    processed_upto = 1;
    last_stroke_end = 1;
    
	%% Drawing
    points = draw("Draw a Mathematical Character or Symbol:", @on_stroke_end);
	
%     %% Rasterization
%     img = rasterize(points, 45);
% 
%     %% Sanity Check: Display Rasterized Image
% 	figure; 
%     imshow(img);
%     title("You drew:");
%     
%     %% Character Recognition
% 	[label, match] = recognize(model, img);
% 
%     %% Output
%     title(sprintf("You drew a %s (#%1.0f):", label, match));
% 	fprintf("You drew a %s (#%1.0f)!\n", label, match);
    
    function [success, label] = process_char(points)
        %% Rasterization
        img = rasterize(points, 45);

        %% Sanity Check: Display Rasterized Image
        %figure; 
        %imshow(img);
        %title("You drew:");

        %% Character Recognition
        [label, match, success] = recognize(model, img);

        %% Output
        %title(sprintf("You drew a %s (#%1.0f):", label, match));
        fprintf("You drew a %s (#%1.0f)!\n", label, match);
    end
    
    function on_stroke_end(points)
        disp("here2");
        if (last_stroke_end == 1)
            last_stroke_end = size(points, 1)
            return
        end
        
        pending_strokes = points(processed_upto:last_stroke_end, :);
        new_stroke = points((last_stroke_end + 1):end, :);
        
        pending_mins = min(pending_strokes)
        pending_maxes = max(pending_strokes)
        new_mins = min(new_stroke)
        new_maxes = max(new_stroke)
        
        
        done_with_stroke = ...
            (pending_maxes(1) < new_mins(1) || pending_mins(1) > new_maxes(1)) || ...
            (pending_maxes(2) < new_mins(2) || pending_mins(2) > new_maxes(2));
        
        if done_with_stroke
            [success, label] = process_char(pending_strokes);
            
            coords = min(pending_strokes)
            dimensions = range(pending_strokes)
            position = [coords dimensions]
            
            rectangle('Position', position, "EdgeColor", "red", "LineWidth", 2);
            
            text(coords(1) + (dimensions(1) / 2), coords(2) - 2, label, "FontSize", 12, "Color", "red", "HorizontalAlignment", "center");
            processed_upto = last_stroke_end;
        end
        
        last_stroke_end = size(points, 1);
    end
end