function visionfieldestimation(subject)

if nargin < 1
    subject='xiaoming';
end

KbName('UnifyKeyNames');
scrnNum=max(Screen('Screens'));
black=BlackIndex(scrnNum);
white=WhiteIndex(scrnNum);
gray=GrayIndex(scrnNum);
bgcolor=gray;
inc=white-gray;
commandwindow();

%[windowPtr, windowRect] = PsychImaging('OpenWindow', scrnNum, bgcolor, [0 0 800 450]);
[windowPtr, windowRect] = PsychImaging('OpenWindow', scrnNum, bgcolor);

[screenXpixels, screenYpixels] = Screen('WindowSize', windowPtr);
[xCenter, yCenter] = RectCenter(windowRect);

x1=xCenter-300;y1=yCenter-250;x2=x1+600;y2=y1+500;
baserect=[x1, y1, x2, y2];
xy=[round((x1+x2)/2); round((y1+y2)/2)];
whichline=1;
[fromX, fromY, toX, toY]=line(whichline, x1, y1, x2, y2);

lineOrnot=1; t=GetSecs;
while 1
    Screen('FillRect', windowPtr, white, baserect);
    if lineOrnot
        Screen('DrawLine', windowPtr, black, fromX, fromY, toX, toY, 10);
    end
    %Screen('DrawDots', windowPtr, xy, 15, [white black black]);
    Screen('Flip', windowPtr);

    if GetSecs-t>0.5
        lineOrnot=1-lineOrnot;
        t=GetSecs;
    end
    
    [pressed, ~, keycode]=KbCheck(-1);
    
    if pressed
        if keycode(KbName('1!'))
            if whichline==1
                x1=x1+1;
            elseif whichline==2
                y2=y2-1;
            elseif whichline==3
                x2=x2-1;
            elseif whichline==4
                y1=y1+1;
            end
        elseif keycode(KbName('2@'))
            if whichline==1
                x1=x1-1;
            elseif whichline==2
                y2=y2+1;
            elseif whichline==3
                x2=x2+1;
            elseif whichline==4
                y1=y1-1;
            end
        elseif keycode(KbName('3#'))
            WaitSecs(0.2);
            if whichline==4
                whichline=1;
            else
                whichline=whichline+1;
            end
        elseif keycode(KbName('4$'))
            break;
        end
        
        baserect=[x1, y1, x2, y2];
        [fromX, fromY, toX, toY]=line(whichline, x1, y1, x2, y2);
        xy=[round((x1+x2)/2); round((y1+y2)/2)];

    end
            
end

filename=[subject '_vision_field'];
save(filename, 'x1', 'y1', 'x2', 'y2');
sca;
end

function [fromX, fromY, toX, toY]=nextline(fromX, fromY, toX, toY, x1, y1, x2, y2)

if fromX==toX && fromX==x1
    toX=x2;
    fromY=toY;
elseif fromX==toX && fromX==x2
    toX=x1;
    fromY=toY;
elseif fromY==toY && fromY==y1
    toY=y2;
    fromX=toX;
elseif fromY==toY && fromY==y2
    toY=y1;
    fromX=toX;
end

end

function [fromX, fromY, toX, toY]=line(whichline, x1, y1, x2, y2)
if whichline==1
    fromX=x1; fromY=y1; toX=x1; toY=y2;
elseif whichline==2
    fromX=x1; fromY=y2; toX=x2; toY=y2;
elseif whichline==3
    fromX=x2; fromY=y2; toX=x2; toY=y1;
else
    fromX=x2; fromY=y1; toX=x1; toY=y1;
end
end
    