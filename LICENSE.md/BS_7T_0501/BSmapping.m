function BSmapping(subject, eye)

if nargin < 2
    eye='left';
end

if nargin < 1
    subject='xiaoming';
end

global black; global white; global gray; global inc; global bgcolor;
global screenXpixels; global screenYpixels; global xCenter; global yCenter;
global pixelsPerDeg; 

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

load('screenarguments.mat', 'screenWidth', 'distanceFromEyetoScreen');
pixelsPerDeg=2*distanceFromEyetoScreen*tan(1*2*pi/360/2)*screenXpixels/screenWidth;

Screen(windowPtr, 'BlendFunction', GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

angleArray=(0:11)*30;

% % first, locating the blindspot approximally and get the center
% if strcmp(eye, 'right')
%     center=[xCenter/2, yCenter];
% else
%     center=[xCenter*3/2 yCenter];
% end
% filename=[subject '_vision_field.mat'];
% if exist(filename, 'file')
%     load(filename, 'x1', 'y1', 'x2', 'y2');
% else
%     load('xiaoming_vision_field', 'x1', 'y1', 'x2', 'y2');
% end
% if strcmp(eye, 'left')
%     center=[round((x1*0+x2*20)/20); round((y1+y2)/2)];
% else
%     center=[round((x1*20+x2*0)/20); round((y1+y2)/2)];
% end

filename=[subject '_' eye '_focalpoint'];
load(filename, 'center');

fontsize=round(1*pixelsPerDeg);
Screen('TextSize', windowPtr, fontsize);
Screen('TextColor', windowPtr, [black white black]);
Screen('DrawText', windowPtr, [eye ' eye'], center(1)-pixelsPerDeg, ...
    center(2)+pixelsPerDeg, white);
focusPoint(windowPtr, center)
Screen('Flip', windowPtr);
KbStrokeWait(-1);
Mapping(windowPtr, subject, eye, center, angleArray);

filename=[subject '_' eye '_7T'];
load(filename, 'dotmatrix', 'bscenter');

if strcmp(eye, 'left')
    m=1;
else
    m=0;
end

dotsize=0.3*pixelsPerDeg;
dotcolor=[black, gray, black];
Screen('FillPoly', windowPtr, [gray, black, black], dotmatrix');
Screen('DrawDots', windowPtr, dotmatrix, dotsize, dotcolor, [], 1);
Screen('DrawDots', windowPtr, bscenter, dotsize, dotcolor, [], 1);
Screen('DrawText', windowPtr, 'check if no-filling-in', center(1)-m*250, center(2)+30, white);
focusPoint(windowPtr, center);
Screen('Flip', windowPtr);

KbStrokeWait(-1);

pointlistSinCos=sinAndcos(dotmatrix, bscenter);
newdotmatrix=equalDistanceStretch(dotmatrix, pointlistSinCos, round(pixelsPerDeg));
dotcolor=[black, black, white];
Screen('FillPoly', windowPtr, [black, gray, black], newdotmatrix');
Screen('FillPoly', windowPtr, [gray, black, black], dotmatrix');
Screen('DrawDots', windowPtr, dotmatrix, dotsize, dotcolor, [], 1);
Screen('DrawDots', windowPtr, bscenter, dotsize, dotcolor, [], 1);
Screen('DrawText', windowPtr, 'check if filling-in', center(1)-m*250, center(2)+30, white);
focusPoint(windowPtr, center);
Screen('Flip', windowPtr);

KbStrokeWait(-1);

checkLocation(windowPtr, subject, eye);

sca;

end

function focusPoint(windowPtr, center)
global white; global black; global pixelsPerDeg;

%c=1/5;
a=0.25;
rect=[center(1)-a*pixelsPerDeg center(2)-a*pixelsPerDeg ...
    center(1)+a*pixelsPerDeg center(2)+a*pixelsPerDeg];


Screen('FillArc', windowPtr, white, rect, 0, 90);
Screen('FillArc', windowPtr, white, rect, 180, 90);

Screen('FillArc', windowPtr, black, rect, 90, 90);
Screen('FillArc', windowPtr, black, rect, 270, 90);

end

function [xUnseen, yUnseen]=submappingOutward(windowPtr, center, bscenter, angle, dotsize, dotcolor, disrect, ovalangle, tex, eye)
global pixelsPerDeg; global black; global white;

if strcmp(eye, 'left')
    m=1;
else
    m=-1;
end

x=bscenter(1);
y=bscenter(2);
dotsizeFactor=dotsize;
dx=x+m*round(1*pixelsPerDeg)*cosd(angle);
dy=y-round(1*pixelsPerDeg)*sind(angle);
xUnseen=[];
yUnseen=[];
delta=2;
time=0.05;
text=[num2str(angle) ' degree mapping'];
text0='press 1 until dot shows up';
flag=1;
t1=GetSecs;
t=GetSecs;
while 1
    %Screen('DrawTexture', windowPtr, tex, [], disrect, ovalangle, [], 0.1);
    focusPoint(windowPtr, center);
    Screen('DrawText', windowPtr, text0, center(1)-3*pixelsPerDeg, ...
        center(2)-1.5*pixelsPerDeg, white);
    Screen('DrawText', windowPtr, text, center(1)-2*pixelsPerDeg, ...
        center(2)+1*pixelsPerDeg, white);
    if flag
        Screen('DrawDots', windowPtr, [dx, dy], dotsize, dotcolor, [], 1);
    end
    Screen('DrawDots', windowPtr, [x, y], dotsize, dotcolor, [], 1);
    Screen('Flip', windowPtr);
    
    if GetSecs-t>time
        if dotcolor==white
            dotcolor=black;
        else
            dotcolor=white;
        end
        t=GetSecs;
    end
    
%     if GetSecs-t1>0.5
%         t1=GetSecs;
%         flag=1-flag;
%     end
    
    [pressed, ~, keycode]=KbCheck(-1);
    if pressed
        %WaitSecs(0.1);
        if keycode(KbName('1!'))
            WaitSecs(0.05);
            dx=dx+m*delta*cosd(angle);
            dy=dy-delta*sind(angle);
        elseif keycode(KbName('2@'))
            WaitSecs(0.05);
            dx=dx-m*delta*cosd(angle);
            dy=dy+delta*sind(angle);
        elseif keycode(KbName('3#'))
            %Beeper(1000, 1, 0.3);
            xUnseen=dx;
            yUnseen=dy;
            break;
        end
    end
    dotsize=dotsizeFactor*sqrt(((round(dx-center(1))).^2+(round(dy-center(2))).^2)/...
        ((round(bscenter(1)-center(1)).^2+round(bscenter(2)-center(2)).^2)));
    if dotsize<0.3*pixelsPerDeg
        dotsize=0.3*pixelsPerDeg;
    end
    
end
WaitSecs(0.5);
xUnseen=round(xUnseen);
yUnseen=round(yUnseen);
end

function Mapping(windowPtr, subject, eye, center, angleArray)
global pixelsPerDeg; global white;

height=5*pixelsPerDeg/2;
width=4*pixelsPerDeg/2;
freq=0.05;
style='checker';
mask='rect';
phase=0;
oval=1;
tex=cell(1,2);
tex{1}=createOvaltex(windowPtr, height, width, freq, style, mask, phase, oval);
tex{2}=createOvaltex(windowPtr, height, width, freq, style, mask, phase+pi, oval);

if strcmp(eye, 'left')
    x=round(center(1)-15*pixelsPerDeg);
elseif strcmp(eye, 'right')
    x=(center(1)+15*pixelsPerDeg);
end
y=round(center(2)+1.5*pixelsPerDeg);
ovalangle=0;
deltatranslate=1;
deltaangle=0.3;
Mode=0;
text='horizotal translation';

%button=0;
num=1;
t=GetSecs;
while 1
    [x, y, button]=GetMouse(windowPtr);
    disrect=[x-width y-height x+width y+height];
    
%     Screen('DrawText', windowPtr, text, center(1)-4.5*pixelsPerDeg, ...
%         center(2)+1.5*pixelsPerDeg, white);
    Screen('DrawTexture', windowPtr, tex{num}, [], disrect, ovalangle);
    focusPoint(windowPtr, center);
    Screen('Flip', windowPtr);
    
    if GetSecs-t>0.1
        t=GetSecs;
        num=mod(num, 2)+1;
    end
    
%     [pressed, ~, keycode]=KbCheck(-1);
%     if pressed
%         m=find(keycode==1);
%         if m == KbName('1!')
%             %ovalangle=ovalangle-deltaangle;
%             if Mode==0
%                 x=x-deltatranslate;
%             elseif Mode==1
%                 y=y-deltatranslate;
%             elseif Mode==2
%                 ovalangle=ovalangle-deltaangle;
%             end
%         elseif m == KbName('2@')
%             %ovalangle=ovalangle+deltaangle;
%             if Mode==0
%                 x=x+deltatranslate;
%             elseif Mode==1
%                 y=y+deltatranslate;
%             elseif Mode==2
%                 ovalangle=ovalangle+deltaangle;
%             end
%         elseif m == KbName('3#')
%             WaitSecs(0.2)
%             if Mode==0
%                 Mode=1;
%                 text='vertical translation';
%             elseif Mode==1
%                 Mode=2;
%                 text='      rotation      ';
%             elseif Mode==2
%                 Mode=0;
%                 text='horizotal translation';
%             end
%         elseif m == KbName('4$')
%             break;
%         end
%     end
    if find(button)
        break;
    end
    
                  
end
WaitSecs(0.2);
% a flickering dot move from center's left to its right, subject report
% it's appearance and disapperance, then record the blind spot coordinates;
dotsize=0.30*pixelsPerDeg;
dotcolor=white;
bscenter=[x, y];
dotmatrix=[];
for angle=angleArray
    [dotcoordx, dotcoordy] = submappingOutward(windowPtr, center, bscenter, angle, dotsize, dotcolor, disrect, ovalangle, tex, eye);
    dotmatrix=[dotmatrix [dotcoordx;dotcoordy]];
end


dotmatrix=round(dotmatrix);
bscenter=round(mean(dotmatrix, 2));

filename=[subject '_' eye '_7T'];
save(filename, 'center', 'bscenter', 'dotmatrix');

end

function tex = createOvaltex(windowPtr, height, width, freq, style, mask, phase, oval)
global white; global gray; global inc; global bgcolor;

if nargin < 2
    height = 100;
end

if nargin < 3
    width = 100;
end

if nargin < 4
    freq = 2;
end

if nargin < 5
    style = 'grating';
end

if nargin < 6
    mask = 'rect';
end

if nargin < 7
    phase = 0;
end

if nargin < 8
    oval = 1;
end

[x, y]=meshgrid(-width:width, -height:height);
m=sin(freq*x+phase);

if strcmp(style, 'grating')
    m=m*inc+gray;
elseif strcmp(style, 'checker') || strcmp(style, 'chekcerboard')
    m=m.*cos(freq*y);
    m=m*inc+gray;
end

if strcmp(mask, 'rect')
    m=(m>gray)*white;
end

if oval
    m=(((x/width).^2+(y/height).^2)<1).*m+(((x/width).^2+(y/height).^2)>1)*bgcolor;
end

tex=Screen('MakeTexture', windowPtr, m);

end

function tex = createTex(windowPtr, r, freq, style, mask, phase, circle, secondmask)
global white; global gray; global inc;

if nargin < 2
    height = 100;
end

if nargin < 3
    width = 100;
end

if nargin < 4
    freq = 2;
end

if nargin < 5
    style = 'grating';
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

if nargin < 9
    secondmask=0;
end

[x, y]=meshgrid(-r:r, -r:r);
m=sin(freq*x+phase);

if strcmp(style, 'grating')
    m=m*inc+gray;
elseif strcmp(style, 'checker') || strcmp(style, 'chekcerboard')
    m=m.*cos(freq*y);
    m=m*inc+gray;
end

if strcmp(mask, 'rect')
    m=(m>gray)*white;
end

if circle
    m=(((x/r).^2+(y/r).^2)<1).*m+(((x/r).^2+(y/r).^2)>1)*gray;
end

tex=Screen('MakeTexture', windowPtr, m);

end

function pointlistSinCos=sinAndcos(pointlist, bscenter)
%%% a function for caculating the angle between the line from each dot to
%%% the center and the horizontal line
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
%%% extend or shorten each dot from its center by the distance of 'd'
n=numel(pointlist(1,:));
newpointlist=zeros(2,n);
for i=1:n
    newpointlist(1,i)=pointlist(1, i)+d*pointlistSinCos(2,i);
    newpointlist(2,i)=pointlist(2, i)+d*pointlistSinCos(1,i);
end
end

function checkLocation(windowPtr, subject, eye)
global white; global gray; global black; global bgcolor; global pixelsPerDeg;

filename=[subject '_' eye '_7T'];
load(filename, 'dotmatrix', 'bscenter', 'center');
stretchfactor=round(2.5*pixelsPerDeg);
pointlistSinCos=sinAndcos(dotmatrix, bscenter);
newdotmatrix=equalDistanceStretch(dotmatrix, pointlistSinCos, ...
    stretchfactor);

if strcmp(eye, 'left')
    m=1;
else
    m=0;
end

dotsize=0.15*pixelsPerDeg;
dotcolor=[black, black, gray];
mode = 1;
yoffsetdelta=1;
stretchdelta=1;
surround=1;
text='location';
while 1
    
    if surround
        Screen('FillPoly', windowPtr, [black, gray, black], newdotmatrix');
    end
    Screen('FillPoly', windowPtr, [gray, black, black], dotmatrix');
    Screen('DrawDots', windowPtr, dotmatrix, dotsize, dotcolor, [], 1);
    Screen('DrawDots', windowPtr, bscenter, dotsize, dotcolor, [], 1);
    Screen('DrawText', windowPtr, text, center(1)-m*250, center(2)+30, white);
    focusPoint(windowPtr, center);
    Screen('Flip', windowPtr);

    [pressed, ~, keycode]=KbCheck(-1);
    if pressed
        if keycode(KbName('1!'))
            if mode==1
                dotmatrix(2, :)=dotmatrix(2, :)-yoffsetdelta;
                bscenter(2)=bscenter(2)-yoffsetdelta;
                center(2)=center(2)-yoffsetdelta;
                newdotmatrix=equalDistanceStretch(dotmatrix, pointlistSinCos, ...
                    stretchfactor);
            elseif mode==2
                stretchfactor=stretchfactor-stretchdelta;
                newdotmatrix=equalDistanceStretch(dotmatrix, pointlistSinCos, ...
                    stretchfactor);
            end
        elseif keycode(KbName('2@'))
            if mode==1
                dotmatrix(2, :)=dotmatrix(2, :)+yoffsetdelta;
                bscenter(2)=bscenter(2)+yoffsetdelta;
                center(2)=center(2)+yoffsetdelta;
                newdotmatrix=equalDistanceStretch(dotmatrix, pointlistSinCos, ...
                    stretchfactor);
            elseif mode==2
                stretchfactor=stretchfactor+stretchdelta;
                newdotmatrix=equalDistanceStretch(dotmatrix, pointlistSinCos, ...
                    stretchfactor);
            end
        elseif keycode(KbName('3#'))
            WaitSecs(0.3);
            mode=mode+1;
            if mode==4
                mode=1;
                text='location';
            end
            if mode==3
                surround=0;
                text='no surround';
            else
                surround=1;
            end
            if mode==2
                text='surround stim size';
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
localizer_stretchfactor=stretchfactor;
save(filename, 'dotmatrix', 'bscenter', 'center', 'localizer_stretchfactor');
end