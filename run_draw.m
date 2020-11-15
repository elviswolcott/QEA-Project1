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
	
    %% Rasterization
    img = rasterize(points, 45);

    %% Sanity Check: Display Rasterized Image
	figure; 
    imshow(img);
    title("You drew:");
    
    %% Character Recognition
	[label, match] = recognize(model, img);

    %% Output
    title(sprintf("You drew a %s (#%1.0f):", label, match));
	fprintf("You drew a %s (#%1.0f)!\n", label, match);
    
    function success=process_char(points)
        %% Rasterization
        img = rasterize(points, 45);

        %% Sanity Check: Display Rasterized Image
        figure; 
        imshow(img);
        title("You drew:");

        %% Character Recognition
        [label, match, success] = recognize(model, img);

        %% Output
        title(sprintf("You drew a %s (#%1.0f):", label, match));
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
        pending_coords = min(pending_strokes)
        pending_dims = max(pending_strokes) - min(pending_strokes)
        new_coords = min(new_stroke)
        new_dims = max(pending_strokes) - min(pending_strokes)
        
        pending_rect = [pending_coords, pending_dims]
        new_rect = [new_coords, new_dims]
        
        done_with_stroke = rectint(pending_rect, new_rect) == 0
        
       	disp("StrokeEnd:");
        disp(pending_rect);
        disp(new_rect);
        disp(done_with_stroke);
        
        if done_with_stroke
            process_char(pending_strokes)
            processed_upto = last_stroke_end;
        end
        
        last_stroke_end = size(points, 1);
    end
end