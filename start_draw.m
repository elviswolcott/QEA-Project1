% This is a helper tool that lets you draw into MATLAB, then returns the
% points as a matrix
function data = start_draw(draw_title, on_stroke_end)
    if nargin < 2
        on_stroke_end = @(data) []; % no op
    end

    X_MIN = 0;
    X_MAX = 2000;
    
    Y_MIN = 0;
    Y_MAX = 500;
    
    baseline_inset = (Y_MAX - Y_MIN) * .15;
    
    % As best I can tell, MATLAB's `waitfor` only works to wait for a
    % drawing to close. However, we don't actually want to close the main
    % drawing when we're done. So, we have this drawing that's hidden which
    % we use exclusively as a handle to `waitfor`.
    wait_drawing = figure("Name", "Ignore Me", "visible", "off");
    
    figure("Name", draw_title, "WindowButtonDownFcn", @onBtnDown); clf;
    % These don't seem to work, so we do it in onBtnDown
    %figure("WindowButtonMotionFcn", @onMove)
    %figure("WindowButtonUpFcn", @onBtnUp)

    pbaspect([(X_MAX - X_MIN) / (Y_MAX - Y_MIN), 1, 1]);
    axis([X_MIN X_MAX Y_MIN Y_MAX]);
    xlim([Y_MIN Y_MAX]);
    ylim([Y_MIN Y_MAX]);
    
    hold on;
    
    cur_axes = gca; %axes('SortMethod', 'childorder'); % not entirely sure what this does
    title(draw_title);
    
    % For some reason, the  first data point is always (0, 0), so we
    % ignore it and wait for subsequent points.
    skipped_first_point = false;
    data = [];
    
    line('XData', [0, X_MAX + 1], 'YData', [Y_MIN + baseline_inset, Y_MIN + baseline_inset], 'Color', [0.7, 0.7, 0.7], 'LineWidth', 2);

    ink = line('XData', 0, 'YData', 0, 'Marker', '.', 'color', 'k', 'LineWidth', 4);
    
    xlim([Y_MIN Y_MAX]);
    ylim([Y_MIN Y_MAX]);
    
    pen_down = false;
    
    waitfor(wait_drawing); % wait until the figure is closed to return
    
    % See https://www.mathworks.com/help/matlab/ref/matlab.ui.figure-properties.html#buiwuyk-1-WindowButtonMotionFcn
    function onBtnDown(src, ~)
        src.WindowButtonMotionFcn = @onMove;
        src.WindowButtonUpFcn = @onBtnUp;
        
        selectionType = src.SelectionType;
        if strcmp(selectionType, 'normal')
            src.Pointer = 'circle';
            pen_down = true;
        elseif strcmp(selectionType, 'alt')
            %% Update State
            src.Pointer = 'arrow';
            pen_down = false;
            
            %% Clear Event Handlers to Disable Drawing
            src.WindowButtonMotionFcn = @(~, ~) [];
            src.WindowButtonUpFcn = @(~, ~) [];
            src.WindowButtonDownFcn = @(~, ~) [];
            
            %% Flush Data
            on_stroke_end(data, true);
            
            %% Make the Original Call to `start_draw` Return
            close(wait_drawing);
        end
    end

    function onMove(~, ~)
        if ~pen_down
            return
        end
        
        curPoint = cur_axes.CurrentPoint;
        if (skipped_first_point == true)
            data(end + 1, :) = curPoint(1, 1:2);
        end
        
        skipped_first_point = true;
        
        if size(data, 1) >= 1
            ink.XData = data(:, 1);
            ink.YData = data(:, 2);
        end
        xlim([Y_MIN Y_MAX])
        ylim([Y_MIN Y_MAX])
    end

    function onBtnUp(~, ~)
        if ~pen_down
            return
        end
        data(end + 1, :) = [NaN, NaN];
        pen_down = false;
        on_stroke_end(data, false);
    end
end