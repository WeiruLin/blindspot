function BSlocation(subject)
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

filename=[subject '_left' '_7T'];
load(filename, 'dotmatrix', 'bscenter', 'center');

lcenter=center;
leftcoord=dotmatrix;
lbscenter=bscenter;
filename=[subject '_right' '_7T'];
load(filename, 'dotmatrix', 'bscenter', 'center');

rcenter=center;
rightcoord=dotmatrix;
rbscenter=bscenter;

r=10*pixelsPerDeg;
freq=0.7/pixelsPerDeg*2*pi;
style='checker';
mask='rect';
angle=0/360*2*pi;
phase=pi/2;
circle=0;

tex = createTex(windowPtr,  r, freq, style, angle, mask, phase, circle);

adjust(windowPtr, tex, subject, 'left');

adjust(windowPtr, tex, subject, 'right');

sca;

end

function adjust(windowPtr, tex, subject, eye)
global white; global gray; global black; global bgcolor; global pixelsPerDeg;

filename=[subject '_' eye '_7T'];
load(filename, 'dotmatrix', 'bscenter', 'center');
stretchfactor=round(2.5*pixelsPerDeg);
d=1;
pointlistSinCos=sinAndcos(dotmatrix, bscenter);
pointlistCMF=getCMF(dotmatrix, bscenter, center);
% newdotmatrix=equalDistanceStretch(dotmatrix, pointlistSinCos, ...
%     stretchfactor);
newdotmatrix=CMFStretch(dotmatrix, pointlistSinCos, pointlistCMF, stretchfactor);
if strcmp(eye, 'left')
    m=1;
else
    m=0;
end

dotsize=0.15*pixelsPerDeg;
dotcolor=[black, black, gray];
mode = 1;
yoffsetdelta=1;
xoffsetdelta=1;
stretchdelta=1;
surround=1;
text='vertical location';
while 1
    
    if surround
        Screen('FillPoly', windowPtr, [black, gray, black], newdotmatrix');
    end
    Screen('Blendfunction', windowPtr, GL_ONE, GL_ZERO, [0 0 0 1]);
    %Screen('FillPoly', windowPtr, [gray, black, black], dotmatrix');
    Screen('FillRect', windowPtr, [0, 0, 0, 0], [bscenter(1)-10*pixelsPerDeg ...
        bscenter(2)-10*pixelsPerDeg bscenter(1)+10*pixelsPerDeg bscenter(2)+10*pixelsPerDeg]);
    Screen('FillPoly', windowPtr, [0, 0, 0, white], dotmatrix');
    
    Screen('Blendfunction', windowPtr, GL_DST_ALPHA, GL_ONE_MINUS_DST_ALPHA, [1 1 1 1]);
    
    Screen('DrawTexture', windowPtr, tex, [], [bscenter(1)-10*pixelsPerDeg ...
        bscenter(2)-10*pixelsPerDeg bscenter(1)+10*pixelsPerDeg bscenter(2)+10*pixelsPerDeg]);
    %Screen('DrawDots', windowPtr, dotmatrix, dotsize, dotcolor, [], 1);
    Screen('Blendfunction', windowPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    Screen('DrawDots', windowPtr, bscenter, dotsize, dotcolor, [], 1);
    Screen('DrawText', windowPtr, text, center(1)-m*250, center(2)+30, white);
    focusPoint(windowPtr, center);
    Screen('Flip', windowPtr);

    [pressed, ~, keycode]=KbCheck(-1);
    if pressed
        if keycode(KbName('1!'))
            if mode==1
                dotmatrix(2, :)=dotmatrix(2, :)-yoffsetdelta;
                newdotmatrix(2, :)=newdotmatrix(2, :)-yoffsetdelta;
                bscenter(2)=bscenter(2)-yoffsetdelta;
                center(2)=center(2)-yoffsetdelta;
%                 newdotmatrix=equalDistanceStretch(dotmatrix, pointlistSinCos, ...
%                     stretchfactor);
%                newdotmatrix=CMFStretch(newdotmatrix, pointlistSinCos, ...
%                    pointlistCMF, stretchfactor);
            elseif mode==2
                dotmatrix(1, :)=dotmatrix(1, :)-xoffsetdelta;
                newdotmatrix(1, :)=newdotmatrix(1, :)-xoffsetdelta;
                bscenter(1)=bscenter(1)-xoffsetdelta;
                center(1)=center(1)-xoffsetdelta;
%                 newdotmatrix=equalDistanceStretch(dotmatrix, pointlistSinCos, ...
%                     stretchfactor);
%            newdotmatrix=CMFStretch(newdotmatrix, pointlistSinCos, ...
%                    pointlistCMF, stretchfactor);
            elseif mode==3
                %stretchfactor=stretchfactor-stretchdelta;
%                 newdotmatrix=equalDistanceStretch(dotmatrix, pointlistSinCos, ...
%                     stretchfactor);
                newdotmatrix=CMFStretch(newdotmatrix, pointlistSinCos, ...
                    pointlistCMF, -d);
            end
        elseif keycode(KbName('2@'))
            if mode==1
                dotmatrix(2, :)=dotmatrix(2, :)+yoffsetdelta;
                newdotmatrix(2, :)=newdotmatrix(2, :)+yoffsetdelta;
                bscenter(2)=bscenter(2)+yoffsetdelta;
                center(2)=center(2)+yoffsetdelta;
%                 newdotmatrix=equalDistanceStretch(dotmatrix, pointlistSinCos, ...
%                     stretchfactor);
%                newdotmatrix=CMFStretch(newdotmatrix, pointlistSinCos, ...
%                    pointlistCMF, stretchfactor);
            elseif mode==2
                dotmatrix(1, :)=dotmatrix(1, :)+xoffsetdelta;
                newdotmatrix(1, :)=newdotmatrix(1, :)+xoffsetdelta;
                bscenter(1)=bscenter(1)+xoffsetdelta;
                center(1)=center(1)+xoffsetdelta;
%                 newdotmatrix=equalDistanceStretch(dotmatrix, pointlistSinCos, ...
%                     stretchfactor);
%                newdotmatrix=CMFStretch(newdotmatrix, pointlistSinCos, ...
%                    pointlistCMF, stretchfactor);
            elseif mode==3
                %stretchfactor=stretchfactor+stretchdelta;
%                 newdotmatrix=equalDistanceStretch(dotmatrix, pointlistSinCos, ...
%                     stretchfactor);
                newdotmatrix=CMFStretch(newdotmatrix, pointlistSinCos, ...
                    pointlistCMF, d);
            end
        elseif keycode(KbName('3#'))
            WaitSecs(0.3);
            mode=mode+1;
            if mode==5
                mode=1;
                text='vertical location';
            end
            if mode==4
                surround=0;
                text='no surround';
            else
                surround=1;
            end
            if mode==3
                text='surround stim size';
            end
            if mode==2
                text='horizontal location';
            end
        elseif keycode(KbName('4$'))
            WaitSecs(0.3);
            break;
        end
    end
end

dotmatrix=round(dotmatrix);
bscenter=round(bscenter);
center=round(center);
Outermatrix=newdotmatrix;
save(filename, 'dotmatrix', 'bscenter', 'center', 'Outermatrix');

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

delta=0;
% if GetSecs-t>changeTime+3
%     delta=delta+180*(randi(2)-1.5);
%     t=GetSecs;
%     changeTime=rand(5);
% end

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

function newpointlist=CMFStretch(pointlist, pointlistSinCos, ...
    pointlistCMF, d)
% CMF: cortical magnification factor
% stretch each point by a distance considering the CMF
% the CMF is calculated by the log distance from each points to focal point
% devide by the log distance from blind spot center to focal point
n=numel(pointlist(1,:));
newpointlist=zeros(2,n);
for i=1:n
    newpointlist(1,i)=pointlist(1, i)+d.*pointlistCMF(i).*pointlistSinCos(2,i);
    newpointlist(2,i)=pointlist(2, i)+d.*pointlistCMF(i).*pointlistSinCos(1,i);
end
end

function pointlistCMF=getCMF(pointlist, bscenter, center)
norm_distance=sqrt((center(1)-bscenter(1)).^2+(center(2)-bscenter(2)).^2);
n=numel(pointlist(1,:));
distance=zeros(1, n);
for i=1:n
    distance(i)=sqrt((pointlist(1,i)-center(1)).^2+(pointlist(2,i)-...
        center(2)).^2);
end
%pointlistCMF=log(distance+1)./log(norm_distance+1);
%pointlistCMF=distance./norm_distance;
pointlistCMF=sqrt(distance./norm_distance);
end