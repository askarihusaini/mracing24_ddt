Fig = figure;
s1 = subplot(5,1,1);
s2 = subplot(5,1,2);
s3 = subplot(5,1,3);
s4 = subplot(5,1,4);
s5 = subplot(5,1,5);

MovingVerticalLine(Fig, s1, s2, s3, s4, s5);

function MovingVerticalLine (Fig, s1, s2, s3, s4, s5)

    VertLine1 = xline(s1, 0);
    VertLine2 = xline(s2, 0);
    VertLine3 = xline(s3, 0);
    VertLine4 = xline(s4, 0);
    VertLine5 = xline(s5, 0);

    set(Fig,'WindowButtonDownFcn', @mouseDown);

    function mouseDown(hObject,~)
        
        % is the mouse down event within the axes?
        if IsCursorInControl(hObject, s1)
        
            currentPoint = get(s1,'CurrentPoint');
            xCurrentPoint = currentPoint(2,1);
        
        elseif IsCursorInControl(hObject, s2)
        
            currentPoint = get(s2,'CurrentPoint');
            xCurrentPoint = currentPoint(2,1);
            
         elseif IsCursorInControl(hObject, s3)
        
            currentPoint = get(s3,'CurrentPoint');
            xCurrentPoint = currentPoint(2,1);
            
         elseif IsCursorInControl(hObject, s4)
        
            currentPoint = get(s4,'CurrentPoint');
            xCurrentPoint = currentPoint(2,1);
            
         elseif IsCursorInControl(hObject, s5)
        
            currentPoint = get(s5,'CurrentPoint');
            xCurrentPoint = currentPoint(2,1);
            
        end
        
        delete(VertLine1);
        delete(VertLine2);
        delete(VertLine3);
        delete(VertLine4);
        delete(VertLine5);
        VertLine1 = xline(s1, xCurrentPoint);
        VertLine2 = xline(s2, xCurrentPoint);
        VertLine3 = xline(s3, xCurrentPoint);
        VertLine4 = xline(s4, xCurrentPoint);
        VertLine5 = xline(s5, xCurrentPoint);

    end

    function [status] = IsCursorInControl(hCursor, hControl)
        
        status = false;
        
        % get the position of the mouse
        figCurrentPoint = get(hCursor, 'CurrentPoint');
        position      = get(hCursor, 'Position');
        xCursor       = figCurrentPoint(1,1)/position(1,3); % normalize
        yCursor       = figCurrentPoint(1,2)/position(1,4); % normalize

        % get the position of the axes within the GUI
        controlPos = get(hControl,'Position');
        minx    = controlPos(1);
        miny    = controlPos(2);
        maxx    = minx + controlPos(3);
        maxy    = miny + controlPos(4);
            
        % is the mouse down event within the axes?
        if xCursor >= minx && xCursor <= maxx && yCursor >= miny && yCursor <= maxy
            status = true;
        end
    end
end