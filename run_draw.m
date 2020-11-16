%% Run the entire PCA process
% This function is the entry point into our application. It prompts the
% user to draw on a figure, then runs segmentation, runs PCA on each
% segmented symbol, and outputs the result of segmentation back to the
% figure.
function [label, match_idx] = run_draw(model)
    processed_upto = 1;
    last_stroke_end = 1;
    
	%% Begin Drawing
    start_draw("Draw Some Math:", @on_stroke_end);
    title("You Drew:");
    
    function on_stroke_end(points, is_final)
        %% Initial Condition: return if it's the first stroke
        % Since we only process Stroke N when Stroke N+1 has been rendered
        % and doesn't overlap, we never process on the first stroke.
        if ~is_final && last_stroke_end == 1
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
        % We split symbols by vertical gaps along the x-axis, assuming that
        % the user writes left to right.
        pending_max = max(pending_points(:, 1));
        new_min = min(new_points(:, 1));
        required_gap = 2;
        
        done_with_symbol = (pending_max + required_gap) < new_min;
        
        % If this is final data, we need to process it even if it doesn't
        % look done.
        if ~is_final && ~done_with_symbol
            last_stroke_end = size(points, 1);
            return
        end
        
        %% Process Points
        % If we think that we've finished a symbol, we'll try processing
        % it. If that fails (which means the projection was too far from
        % eigenspace, meaning that the drawn symbol wasn't a lot like
        % anything we've seen before), we don't mark those strokes as
        % processed, and we'll try processing it again on the next stroke.
        % NOTE: I'm not sure this is the correct thing to do, because if
        % there's a malformed symbol it will never match and will get
        % stuck.
        if process_points(pending_points)
            processed_upto = last_stroke_end;
        end
        
        %% Update State
        last_stroke_end = size(points, 1);
    end

    function success = process_points(points)
        %% Character Recognition
        [success, label, match_idx] = recognize(model, points);
        
        if success
            fprintf("You drew a %s (#%1.0f)!\n", label, match_idx);
        else
            label = "???";
            match_idx = -1;
        end

        %% Draw Results on Figure
        coords = min(points);
        dimensions = range(points);
        position = [coords dimensions];

        if success; color = "green"; else; color = "red"; end

        rectangle('Position', position, "EdgeColor", color, "LineWidth", 2);
        
        text(coords(1) + (dimensions(1) / 2), coords(2) - 2, label, ...
            "FontSize", 12, "Color", color, "HorizontalAlignment", "center");
    end
end