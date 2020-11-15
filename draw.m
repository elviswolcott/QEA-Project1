% This is a helper tool that lets you draw into MATLAB, then returns the
% points as a matrix
function data = draw(instructions, onStrokeEnd)
    if nargin < 2
        onStrokeEnd = @(data) [] % no op
    end

    clf;

    X_MIN = 1;
    X_MAX = 45;
    
    Y_MIN = 1;
    Y_MAX = 45;
    
    drawing = figure("WindowButtonDownFcn", @onBtnDown);
    % These don't seem to work, so we do it in onBtnDown
    %figure("WindowButtonMotionFcn", @onMove)
    %figure("WindowButtonUpFcn", @onBtnUp)

    axis([X_MIN X_MAX Y_MIN Y_MAX])
    
    hold on;
    
    curAxes = axes('SortMethod', 'childorder'); % not entirely sure what this does
    title(instructions)
    
    % For some reason, the  first data point is always (0, 0), so we
    % ignore it and wait for subsequent points.
    skippedFirstDataPoint = false;
    data = [];

    ink = line('XData', 0, 'YData', 0, 'Marker', '.', 'color', 'k', 'LineWidth', 4);
    
    penDown = false;
    
    waitfor(drawing); % wait until the figure is closed to return
    
    % See https://www.mathworks.com/help/matlab/ref/matlab.ui.figure-properties.html#buiwuyk-1-WindowButtonMotionFcn
    function onBtnDown(src, ~)
        src.WindowButtonMotionFcn = @onMove;
        src.WindowButtonUpFcn = @onBtnUp;
        
        selectionType = src.SelectionType;
        if strcmp(selectionType, 'normal')
            src.Pointer = 'circle';
            penDown = true;
        elseif strcmp(selectionType, 'alt')
            src.Pointer = 'arrow';
            penDown = false;
            close(drawing);
        end
    end

    function onMove(~, ~)
        if ~penDown
            return
        end
        
        curPoint = curAxes.CurrentPoint;
        if (skippedFirstDataPoint == true)
            data(end + 1, :) = curPoint(1, 1:2);
        end
        
        skippedFirstDataPoint = true;
        
        if size(data, 1) >= 1
            ink.XData = data(:, 1);
            ink.YData = data(:, 2);
        end
        xlim([Y_MIN Y_MAX])
        ylim([Y_MIN Y_MAX])
    end

    function onBtnUp(~, ~)
        if ~penDown
            return
        end
        data(end + 1, :) = [NaN, NaN];
        penDown = false;
        disp("HERE1");
        onStrokeEnd(data);
    end
end