function temp
global black; global white; global gray; global inc; global bgcolor;
global screenXpixels; global screenYpixels; global xCenter; global yCenter;
global pixelsPerDeg;
PsychDefaultSetup(2);
KbName('UnifyKeyNames');
scrnNum=max(Screen('Screens'));
black=BlackIndex(scrnNum);
white=WhiteIndex(scrnNum);
gray=GrayIndex(scrnNum);
bgcolor=black;
inc=white-gray;
commandwindow();

%[windowPtr, windowRect] = PsychImaging('OpenWindow', scrnNum, bgcolor, [0 0 800 450]);
[windowPtr, windowRect] = PsychImaging('OpenWindow', scrnNum, bgcolor);

[screenXpixels, screenYpixels] = Screen('WindowSize', windowPtr);
[xCenter, yCenter] = RectCenter(windowRect);

%center=[xCenter, yCenter];

%%%%%%%%%%%%%%%%%%%% parameters of screen for view angle caculation %%%%%%%%%%%%%%%
Width=35;
distance=75;
pixelsPerDeg=2*distance*tan(1*2*pi/360/2)*screenXpixels/Width;

filename=['zhangp' '_right' '_7T'];
load(filename, 'dotmatrix', 'bscenter', 'center');
rcenter=center;
rightcoord=dotmatrix;
rbscenter=bscenter;

p=30;
center(2)=center(2)-p;
dotmatrix(2, :)=dotmatrix(2, :)-p;
bscenter(2, :)=bscenter(2, :)-p;

rcenter=center;
rightcoord=dotmatrix;
rbscenter=bscenter;

rightcoordSinCos=sinAndcos(rightcoord, rbscenter);
rightcoordPlus=equalDistanceStretch(rightcoord, rightcoordSinCos, 2.5*pixelsPerDeg);

dotsize=0.3*pixelsPerDeg;
dotcolor=[black, gray, black];
% Screen('FillPoly', windowPtr, [gray, black, black], rightcoord');
% Screen('DrawDots', windowPtr, rightcoord, dotsize, dotcolor, [], 1);
% Screen('DrawDots', windowPtr, rbscenter, dotsize, dotcolor, [], 1);
% focusPoint(windowPtr, center);
% Screen('Flip', windowPtr);
% 
% KbStrokeWait(-1);

pointlistSinCos=sinAndcos(dotmatrix, bscenter);
newdotmatrix=equalDistanceStretch(dotmatrix, pointlistSinCos, round(pixelsPerDeg));
dotcolor=[black, black, white];
Screen('FillPoly', windowPtr, [black, gray, black], rightcoordPlus');Screen('FillPoly', windowPtr, [gray, black, black], dotmatrix');
% Screen('DrawDots', windowPtr, dotmatrix, dotsize, dotcolor, [], 1);
Screen('DrawDots', windowPtr, bscenter, dotsize, dotcolor, [], 1);
focusPoint(windowPtr, center);
Screen('Flip', windowPtr);

KbStrokeWait(-1);

sca;
end

function focusPoint(windowPtr, center)
global white; global black; global pixelsPerDeg; global t; global delta; global changeTime;

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

function pointlistSinCos=sinAndcos(pointlist, bscenter)
n=numel(pointlist(1,:));
Sin_value=zeros(1, n);
Cos_value=zeros(1, n);
for i=1:n
    d=sqrt((pointlist(1,i)-bscenter(1)).^2+(pointlist(2,i)-bscenter(2)).^2);
    Sin_value(i)=(pointlist(2,i)-bscenter(2))/d;
    Cos_value(i)=(pointlist(1,i)-bscenter(1))/d;
end
pointlistSinCos=[Sin_value; Cos_value];
end

function newpointlist=equalDistanceStretch(pointlist, pointlistSinCos, d)
n=numel(pointlist(1,:));
newpointlist=zeros(2,n);
for i=1:n
    newpointlist(1,i)=pointlist(1, i)+d*pointlistSinCos(2,i);
    newpointlist(2,i)=pointlist(2, i)+d*pointlistSinCos(1,i);
end
end