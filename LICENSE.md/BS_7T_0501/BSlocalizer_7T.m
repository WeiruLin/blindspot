function BSlocalizer_7T(subject, runNum)

if nargin<2
    runNum=1;
end

if nargin<1
    subject='xiaoming';
end

global black; global white; global gray; global inc; global bgcolor;
global screenXpixels; global screenYpixels; global xCenter; global yCenter;
global pixelsPerDeg; global disrectLeft; global disrectRight; global windowRect;
global delta; global changeTime;

KbName('UnifyKeyNames');
scrnNum=max(Screen('Screens'));
black=BlackIndex(scrnNum);
white=WhiteIndex(scrnNum);
gray=GrayIndex(scrnNum);
bgcolor=black;
inc=white-gray;
commandwindow();

[windowPtr, windowRect] = PsychImaging('OpenWindow', scrnNum, bgcolor);

[screenXpixels, screenYpixels] = Screen('WindowSize', windowPtr);
[xCenter, yCenter] = RectCenter(windowRect);
center=[xCenter, yCenter];

% parameters for view angle measurement
load('screenarguments.mat', 'screenWidth', 'distanceFromEyetoScreen');
pixelsPerDeg=2*distanceFromEyetoScreen*tan(1*2*pi/360/2)*screenXpixels/screenWidth;

% parameters for focus point task
delta=0;
changeTime=6;

% block time
blockStimTime=16;
blockRestTime=16;
%stretchpara=round(2.5*pixelsPerDeg);

% load subject's personal blind spot data
filename=[subject '_left' '_7T'];
load(filename, 'dotmatrix', 'center', 'bscenter', 'Outermatrix');
lcenter=center;
lbscenter=round(bscenter);
% L_localizer_stretchfactor=localizer_stretchfactor;
leftcoord=dotmatrix;
% leftcoordSinCos=sinAndcos(leftcoord, lbscenter);
% leftcoordPlus=equalDistanceStretch(leftcoord, leftcoordSinCos, L_localizer_stretchfactor);
leftcoordPlus=Outermatrix;
filename=[subject '_right' '_7T'];
load(filename, 'dotmatrix', 'bscenter', 'center', 'Outermatrix');
rcenter=center;
rbscenter=round(bscenter);
%R_localizer_stretchfactor=localizer_stretchfactor;
rightcoord=dotmatrix;
% rightcoordSinCos=sinAndcos(rightcoord, rbscenter);
% rightcoordPlus=equalDistanceStretch(rightcoord, rightcoordSinCos, R_localizer_stretchfactor);
rightcoordPlus=Outermatrix;
filename=[subject '_stimpara'];
load(filename, 'bsstretchfactor');
% leftcoord=equalDistanceStretch(leftcoord, leftcoordSinCos, bsstretchfactor);
% rightcoord=equalDistanceStretch(rightcoord, rightcoordSinCos, bsstretchfactor);

% create stimulus and it's rectangle
r=round(10*pixelsPerDeg)+1;
disrectLeft=[lbscenter(1)-r lbscenter(2)-r lbscenter(1)+r lbscenter(2)+r];
disrectRight=[rbscenter(1)-r rbscenter(2)-r rbscenter(1)+r rbscenter(2)+r];
freq=0.35/pixelsPerDeg*2*pi;
style='checker';
mask='rect';
angle=0/360*2*pi;
phase=pi/2;
circle=0;
tex=cell(2, 1);
tex{1} = createTex(windowPtr,  r, freq, style, angle, mask, phase, circle);
tex{2} = createTex(windowPtr,  r, freq, style, angle, mask, phase+pi, circle);

% stimulus array 1 for surround and 2 for blind spot
if mod(runNum, 2)
    stimArray=[1 2 3 4 1 2 3 4 1 2 3 4];
else
    stimArray=[3 4 1 2 3 4 1 2 3 4 1 2];
end
run(windowPtr, stimArray, tex, angle, leftcoord, rightcoord, leftcoordPlus, ...
    rightcoordPlus, lcenter, rcenter, lbscenter, rbscenter, blockStimTime, blockRestTime, r)

sca;
end

function dotmatrixStretch=stretchDotmatrix(dotmatrix, stretchpara, angleArray)
if nargin < 3
    angleArray=[];
end

n=numel(dotmatrix(1, :));
if isempty(angleArray)
    angleArray=(0:n-1)*360/n;
end

for i=1:n
    dotmatrixStretch(1, i)=round(dotmatrix(1, i)+stretchpara*cosd(angleArray(i)));
    dotmatrixStretch(2, i)=round(dotmatrix(2, i)-stretchpara*sind(angleArray(i)));
end

end

function tex = createTex(windowPtr,  r, freq, style, angle, mask, phase, circle)
global white; global gray; global inc;

if nargin < 2
    r = 100;
end

if nargin < 3
    freq = 2;
end

if nargin < 4
    style = 'grating';
end

if nargin < 5
    angle = 90;
end

if nargin < 6
    mask = 'rect';
end

if nargin < 7
    phase = 0;
end

if nargin < 8
    circle = 1;
end

[x, y]=meshgrid(-r:r, -r:r);
a=cos(angle)*freq;
b=sin(angle)*freq;
m=sin(a*x+b*y+phase);

if strcmp(style, 'grating')
    m=m*inc+gray;
elseif strcmp(style, 'checker') || strcmp(style, 'chekcerboard')
    m=m.*cos(a*y-b*x);
    m=m*inc+gray;
end

if strcmp(mask, 'rect')
    m=(m>gray)*white;
end

if circle
    m=((x.^2+y.^2)<r.^2).*m+((x.^2+y.^2)>=r.^2)*gray;
end

tex=Screen('MakeTexture', windowPtr, m);

end

function focusPoint(windowPtr, center)
global white; global black; global pixelsPerDeg; global t; global delta; global changeTime;

a=0.25;
rect=[center(1)-a*pixelsPerDeg center(2)-a*pixelsPerDeg ...
    center(1)+a*pixelsPerDeg center(2)+a*pixelsPerDeg];

if GetSecs-t>changeTime+3
    delta=delta+180*(randi(2)-1.5);
    t=GetSecs;
    changeTime=rand(5);
end

endAngle=90;
for startAngle=[0, 180]+delta
    Screen('FillArc', windowPtr, white, rect, startAngle, endAngle);
end
for startAngle=[90 270]+delta
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

%function surround(windowPtr, tex, angle, leftcoord, rightcoord, leftcoordPlus, rightcoordPlus, center)
% global white; global disrectLeft; global disrectRight;
% 
%     Screen('Blendfunction', windowPtr, GL_ONE, GL_ZERO, [0 0 0 1]);
%     Screen('FillOval', windowPtr, [0, 0, 0, 0], disrectLeft);
%     Screen('FillPoly', windowPtr, [0, 0, 0, white], leftcoordPlus');
%     Screen('FillPoly', windowPtr, [0, 0, 0, 0], leftcoord');
%     
%     Screen('Blendfunction', windowPtr, GL_ONE, GL_ZERO, [0 0 0 1]);
%     Screen('FillOval', windowPtr, [0, 0, 0, 0], disrectRight);
%     Screen('FillPoly', windowPtr, [0, 0, 0, white], rightcoordPlus');
%     Screen('FillPoly', windowPtr, [0, 0, 0, 0], rightcoord');
%     
%     %Screen('FillOval', windowPtr, [0 0 0 white], [center(1)-8 center(2)-8 center(1)+8 center(2)+8]);
%     Screen('Blendfunction', windowPtr, GL_DST_ALPHA, GL_ONE_MINUS_DST_ALPHA, [1 1 1 1]);
%     Screen('DrawTexture', windowPtr, tex,[],disrectLeft,angle);
%     Screen('DrawTexture', windowPtr, tex,[],disrectRight,angle);
%     
%     focusPoint(windowPtr, center);
%     Screen('Blendfunction', windowPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
%     Screen('Flip', windowPtr);
% 
% end

function surround(windowPtr, tex, angle, dotmatrix, dotmatrixPlus, center, bscenter, r)
global white;  global bgcolor;  global windowRect;

disrect=[bscenter(1)-r bscenter(2)-r bscenter(1)+r bscenter(2)+r];

    Screen('Blendfunction', windowPtr, GL_ONE, GL_ZERO, [0 0 0 1]);
    Screen('FillRect', windowPtr, [0, 0, 0, 0], windowRect);
    Screen('FillPoly', windowPtr, [0, 0, 0, white], dotmatrixPlus');
    Screen('FillPoly', windowPtr, [0, 0, 0, 0], dotmatrix');
    
    %Screen('FillOval', windowPtr, [0 0 0 white], [center(1)-8 center(2)-8 center(1)+8 center(2)+8]);
    Screen('Blendfunction', windowPtr, GL_DST_ALPHA, GL_ONE_MINUS_DST_ALPHA, [1 1 1 1]);
    Screen('DrawTexture', windowPtr, tex,[],disrect,angle);
    
    Screen('Blendfunction', windowPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    focusPoint(windowPtr, center);
    Screen('Flip', windowPtr);

end

%function blindspot(windowPtr, tex, angle, leftcoord, rightcoord, leftcoordPlus, rightcoordPlus, center)
% global white; global disrectLeft; global disrectRight;
% 
%     Screen('Blendfunction', windowPtr, GL_ONE, GL_ZERO, [0 0 0 1]);
%     Screen('FillOval', windowPtr, [0, 0, 0, 0], disrectLeft);
%     Screen('FillPoly', windowPtr, [0, 0, 0, 0], leftcoordPlus');
%     Screen('FillPoly', windowPtr, [0, 0, 0, white], leftcoord');
%     
%     Screen('Blendfunction', windowPtr, GL_ONE, GL_ZERO, [0 0 0 1]);
%     Screen('FillOval', windowPtr, [0, 0, 0, 0], disrectRight);
%     Screen('FillPoly', windowPtr, [0, 0, 0, 0], rightcoordPlus');
%     Screen('FillPoly', windowPtr, [0, 0, 0, white], rightcoord');
%     
%     %Screen('FillOval', windowPtr, [0 0 0 white], [center(1)-8 center(2)-8 center(1)+8 center(2)+8]);
%     Screen('Blendfunction', windowPtr, GL_DST_ALPHA, GL_ONE_MINUS_DST_ALPHA, [1 1 1 1]);
%     Screen('DrawTexture', windowPtr, tex,[],disrectLeft,angle);
%     Screen('DrawTexture', windowPtr, tex,[],disrectRight,angle);
%     
%     focusPoint(windowPtr, center);
%     Screen('Blendfunction', windowPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
%     Screen('Flip', windowPtr);
%     
% end

function blindspot(windowPtr, tex, angle, dotmatrix, dotmatrixPlus, center, bscenter, r)
global white;  global bgcolor; global windowRect;

disrect=[bscenter(1)-r bscenter(2)-r bscenter(1)+r bscenter(2)+r];

    Screen('Blendfunction', windowPtr, GL_ONE, GL_ZERO, [0 0 0 1]);
    Screen('FillRect', windowPtr, [0, 0, 0, 0], windowRect);
    Screen('FillPoly', windowPtr, [0, 0, 0, 0], dotmatrixPlus');
    Screen('FillPoly', windowPtr, [0, 0, 0, white], dotmatrix');
    
    %Screen('FillOval', windowPtr, [0 0 0 white], [center(1)-8 center(2)-8 center(1)+8 center(2)+8]);
    Screen('Blendfunction', windowPtr, GL_DST_ALPHA, GL_ONE_MINUS_DST_ALPHA, [1 1 1 1]);
    Screen('DrawTexture', windowPtr, tex,[],disrect,angle);
    
    Screen('Blendfunction', windowPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    focusPoint(windowPtr, center);
    Screen('Flip', windowPtr);
    
end

function run(windowPtr, stimArray, tex, angle, leftcoord, rightcoord, leftcoordPlus, ...
    rightcoordPlus, lcenter, rcenter, lbscenter, rbscenter, blockStimTime, blockRestTime, r)
global t;

stimInterval=2;
num=1;
delta=0;
TR=2;
dummy=2;

if stimArray(1)==1 || stimArray(1)==2
    center=lcenter;
else
    center=rcenter;
end

while true
    [~, secs, keyCode] = KbCheck(-1);
    if keyCode(KbName('s'))
        break;
    end
end
t=secs;

while GetSecs-secs<TR*dummy
    focusPoint(windowPtr, center);
    Screen('Flip', windowPtr);
end

startTime=GetSecs;
while GetSecs-startTime<blockRestTime
    focusPoint(windowPtr, center);
    Screen('Flip', windowPtr);
end
for i=1:4
    
    t1=GetSecs;
    while GetSecs-startTime<i*(blockStimTime+stimInterval)-stimInterval+blockRestTime
        switch stimArray(i)
            case 1
                surround(windowPtr, tex{num}, angle, leftcoord, leftcoordPlus, lcenter, lbscenter, r);
            case 2
                blindspot(windowPtr, tex{num}, angle, leftcoord, leftcoordPlus, lcenter, lbscenter, r);
            case 3
                surround(windowPtr, tex{num}, angle, rightcoord, rightcoordPlus, rcenter, rbscenter, r);
            case 4
                blindspot(windowPtr, tex{num}, angle, rightcoord, rightcoordPlus, rcenter, rbscenter, r);
        end
        
        if GetSecs-t1>1/15
            angle=angle+delta;
            if num==1
                num=2;
            else
                num=1;
            end
            t1=GetSecs;
        end
    end
    
    focusPoint(windowPtr, center);
    Screen('Flip', windowPtr);
    WaitSecs(1);
    
    if i<numel(stimArray) && (stimArray(i+1)==1 || stimArray(i+1)==2)
        center=lcenter;
    else
        center=rcenter;
    end
    
    while GetSecs-startTime<i*(blockStimTime+stimInterval)+blockRestTime
        focusPoint(windowPtr, center);
        Screen('Flip', windowPtr);
    end
    
end

while GetSecs-startTime<blockRestTime-stimInterval+4*(blockStimTime+stimInterval)+blockRestTime
    focusPoint(windowPtr, center);
    Screen('Flip', windowPtr);
end

for i=5:8
    
    t1=GetSecs;
    while GetSecs-startTime<i*(blockStimTime+stimInterval)-stimInterval+blockRestTime*2-stimInterval
        switch stimArray(i)
            case 1
                surround(windowPtr, tex{num}, angle, leftcoord, leftcoordPlus, lcenter, lbscenter, r);
            case 2
                blindspot(windowPtr, tex{num}, angle, leftcoord, leftcoordPlus, lcenter, lbscenter, r);
            case 3
                surround(windowPtr, tex{num}, angle, rightcoord, rightcoordPlus, rcenter, rbscenter, r);
            case 4
                blindspot(windowPtr, tex{num}, angle, rightcoord, rightcoordPlus, rcenter, rbscenter, r);
        end
        
        if GetSecs-t1>1/15
            angle=angle+delta;
            if num==1
                num=2;
            else
                num=1;
            end
            t1=GetSecs;
        end
    end
    
    focusPoint(windowPtr, center);
    Screen('Flip', windowPtr);
    WaitSecs(1);
    
    if i<numel(stimArray) && (stimArray(i+1)==1 || stimArray(i+1)==2)
        center=lcenter;
    else
        center=rcenter;
    end
    
    while GetSecs-startTime<i*(blockStimTime+stimInterval)+blockRestTime*2-stimInterval
        focusPoint(windowPtr, center);
        Screen('Flip', windowPtr);
    end
    
end
while GetSecs-startTime<2*(blockRestTime-stimInterval)+8*(blockStimTime+stimInterval)+blockRestTime
    focusPoint(windowPtr, center);
    Screen('Flip', windowPtr);
end

for i=9:12
    
    t1=GetSecs;
    while GetSecs-startTime<i*(blockStimTime+stimInterval)-stimInterval+blockRestTime*3-2*stimInterval
        switch stimArray(i)
            case 1
                surround(windowPtr, tex{num}, angle, leftcoord, leftcoordPlus, lcenter, lbscenter, r);
            case 2
                blindspot(windowPtr, tex{num}, angle, leftcoord, leftcoordPlus, lcenter, lbscenter, r);
            case 3
                surround(windowPtr, tex{num}, angle, rightcoord, rightcoordPlus, rcenter, rbscenter, r);
            case 4
                blindspot(windowPtr, tex{num}, angle, rightcoord, rightcoordPlus, rcenter, rbscenter, r);
        end
        
        if GetSecs-t1>1/15
            angle=angle+delta;
            if num==1
                num=2;
            else
                num=1;
            end
            t1=GetSecs;
        end
    end
    
    focusPoint(windowPtr, center);
    Screen('Flip', windowPtr);
    WaitSecs(1);
    
    if i<numel(stimArray) && (stimArray(i+1)==1 || stimArray(i+1)==2)
        center=lcenter;
    else
        center=rcenter;
    end
    
    while GetSecs-startTime<i*(blockStimTime+stimInterval)+blockRestTime*3-2*stimInterval
        focusPoint(windowPtr, center);
        Screen('Flip', windowPtr);
    end
    
end

while GetSecs-startTime<3*(blockRestTime-stimInterval)+12*(blockStimTime+stimInterval)+blockRestTime
    focusPoint(windowPtr, center);
    Screen('Flip', windowPtr);
end

endTime=GetSecs-startTime;
fprintf('run time: %f\n', endTime);
end