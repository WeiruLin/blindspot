function focalPointEstimation(subject)

if nargin < 1
    subject='xiaoming';
end

global white; global black; global pixelsPerDeg; 

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

%%%%%%%%%%%%%%%%%%%% parameters of screen for view angle caculation %%%%%%%%%%%%%%%
load('screenarguments.mat', 'screenWidth', 'distanceFromEyetoScreen');
pixelsPerDeg=2*distanceFromEyetoScreen*tan(1*2*pi/360/2)*screenXpixels/screenWidth;

center=focalPointLocating(windowPtr, 'left', screenXpixels, screenYpixels);
filename=[subject '_left' '_focalpoint'];
save(filename, 'center');

center=focalPointLocating(windowPtr, 'right', screenXpixels, screenYpixels);
filename=[subject '_right' '_focalpoint'];
save(filename, 'center');

sca;
end

function focusPoint(windowPtr, center)
global white; global black; global pixelsPerDeg; 

a=0.25;
rect=[center(1)-a*pixelsPerDeg center(2)-a*pixelsPerDeg ...
    center(1)+a*pixelsPerDeg center(2)+a*pixelsPerDeg];

delta=0;
% if GetSecs-t>changeTime+3
%     delta=delta+180*(randi(2)-1.5);
%     t=GetSecs;
%     changeTime=rand(5);
% end

endAngle=90;
for startAngle=[0 180]+[delta delta]
    Screen('FillArc', windowPtr, white, rect, startAngle, endAngle);
end
for startAngle=[90 270]+[delta delta]
    Screen('FillArc', windowPtr, black, rect, startAngle, endAngle);
end

end

function center=focalPointLocating(windowPtr, eye, screenXpixels, screenYpixels)

if strcmp(eye, 'right')
    center=[screenXpixels/10; screenYpixels/4];
else
    center=[screenXpixels*9/10; screenYpixels/4];
end

mode=1;
text='horizontal';
Screen('TextSize', windowPtr, 40);
while 1
    
    Screen('DrawText', windowPtr, text, screenXpixels/2, screenYpixels/4);
    focusPoint(windowPtr, center);
    Screen('Flip', windowPtr);
    
    [pressed, ~, keycode]=KbCheck(-1);
    
    if pressed
        if keycode(KbName('1!'))
            if mode==1
                center(1)=center(1)-1;
            else
                center(2)=center(2)-1;
            end
        elseif keycode(KbName('2@'))
            if mode==1
                center(1)=center(1)+1;
            else
                center(2)=center(2)+1;
            end
        elseif keycode(KbName('3#'))
            WaitSecs(0.2);
            mode=1-mode;
            if mode==1
                text='horizontal';
            else
                text='vertical';
            end
        elseif keycode(KbName('4$'))
            WaitSecs(0.2);
            break;
        end
    end

end

end
