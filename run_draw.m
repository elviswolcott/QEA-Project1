%% Run the entire PCA process
% This function is the entry point into our application. It prompts the
% user to draw on a figure, then runs segmentation, runs PCA on each
% segmented symbol, and outputs the result of segmentation back to the
% figure.
function [label, match_idx] = run_draw(model)
    processed_upto = 1;
    last_stroke_end = -1;
    
	%% Begin Drawing
    start_draw("Draw Some Math:", @on_stroke_end);
    
    function on_stroke_end(points)
        %% Initial Condition: return if it's the first stroke
        % Since we only process Stroke N when Stroke N+1 has been rendered
        % and doesn't overlap, we never process on the first stroke.
        if last_stroke_end == -1
            last_stroke_end = size(points, 1);
            return
        end
        
        %% Extract Points
        % pending_points is all the points that haven't been processed by
        % PCA yet, and new_points are all the points of the stroke that
        % just ended (pending_points does not include new_points).
        pending_points = points(processed_upto:last_stroke_end, :);
        new_points = points((last_stroke_end + 1):end, :);
        
        %% Detect Stroke Overlap
        % We assume that a single character (for PCA purposes) is any
        % number of strokes whose bounding boxes ovelap. Therefore, we
        % can't process a stroke(s) until we know that the following stroke
        % doesn't overlap.
        pending_mins = min(pending_points);
        pending_maxes = max(pending_points);
        new_mins = min(new_points);
        new_maxes = max(new_points);
        
        done_with_symbol = ...
            (pending_maxes(1) < new_mins(1) || pending_mins(1) > new_maxes(1)) || ...
            (pending_maxes(2) < new_mins(2) || pending_mins(2) > new_maxes(2));
        
        if ~done_with_symbol
            last_stroke_end = size(points, 1);
            return
        end
        
        %% Character Recognition
        [label, match_idx, success] = recognize(model, img);

        %% Output
        fprintf("You drew a %s (#%1.0f)!\n", label, match_idx);

        %% Draw Results on Figure
        coords = min(pending_points);
        dimensions = range(pending_points);
        position = [coords dimensions];

        if success; color = "green"; else; color = "red"; end

        rectangle('Position', position, "EdgeColor", color, "LineWidth", 2);
        text(coords(1) + (dimensions(1) / 2), coords(2) - 2, label, ...
            "FontSize", 12, "Color", color, "HorizontalAlignment", "center");
        
        %% Update State
        processed_upto = last_stroke_end;
        last_stroke_end = size(points, 1);
    end
end