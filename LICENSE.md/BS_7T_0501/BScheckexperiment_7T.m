function BScheckexperiment_7T(subject)     

if nargin<1
    subject='xiaoming';
end

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
load('screenarguments.mat', 'screenWidth', 'distanceFromEyetoScreen');
pixelsPerDeg=2*distanceFromEyetoScreen*tan(1*2*pi/360/2)*screenXpixels/screenWidth;

% block time
blockStimTime=16;
blockRestTime=16;
framerate=Screen('Framerate', windowPtr);
ifi=Screen('GetFlipInterval', windowPtr);
if framerate==0
    framerate=round(1/ifi);
end

%%% load subjects' blind spot documents
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
shape='circle';
tex = createBar(windowPtr, 2*r+1, 2*r+1, white, shape);

%run(windowPtr, subject, stimArray, tex, stretchpara, framerate, blockStimTime, blockRestTime, r, width);

%nofillinginblock2(windowPtr, tex, leftcoordPlus, framerate, blockStimTime, lbscenter, r, width, center);
stretchpara=round(1*pixelsPerDeg);
width=round(1*pixelsPerDeg);
bsstretchfactor=-2;

[Outerdotmatrix, width, Innerdotmatrix]=checking(windowPtr, stretchpara, width, bsstretchfactor, leftcoord, lbscenter, framerate, tex, lcenter);

filename=[subject 'left_stimpara'];
save(filename, 'Outerdotmatrix', 'width', 'Innerdotmatrix');

[Outerdotmatrix, width, Innerdotmatrix]=checking(windowPtr, stretchpara, width, bsstretchfactor, rightcoord, rbscenter, framerate, tex, rcenter);

filename=[subject 'right_stimpara'];
save(filename, 'Outerdotmatrix', 'width', 'Innerdotmatrix');
sca;

end

function [Outerdotmatrix, width, Innerdotmatrix]=checking(windowPtr, stretchpara, width, bsstretchfactor, dotmatrix, bscenter, framerate, tex, center)
global pixelsPerDeg; global white; global bgcolor;

KbName('UnifyKeyNames');
unitStim=round(framerate);
unitstimframenum=round(unitStim/2);

r=round(10*pixelsPerDeg);

dotmatrixSinCos=sinAndcos(dotmatrix, bscenter);
newdotmatrix=equalDistanceStretch(dotmatrix, dotmatrixSinCos, stretchpara);
dotmatrix2=equalDistanceStretch(dotmatrix, dotmatrixSinCos, round(bsstretchfactor));

pointlistCMF=getCMF(dotmatrix, bscenter, center);
newdotmatrix=CMFStretch(dotmatrix, dotmatrixSinCos, pointlistCMF, stretchpara);

Frame=0;
angle=(randi(8)-1)*45;

leftmaskrect1=getmaskpointlist(bscenter, r, width, 1);
leftmaskrect2=getmaskpointlist(bscenter, r, width, 2);
leftmaskrect1=rotatepointlist(leftmaskrect1, bscenter, angle);
leftmaskrect2=rotatepointlist(leftmaskrect2, bscenter, angle);

deltaStretch=1;
mode=0;
text='length';
text2='press 1 to reduce';
text3='and 2 to increase';
Screen('TextSize', windowPtr, 40);
disrect=[bscenter(1)-r bscenter(2)-r bscenter(1)+r bscenter(2)+r];
while 1
    if mod(Frame, unitStim)<unitstimframenum
        Screen('Blendfunction', windowPtr, GL_ONE, GL_ZERO, [0 0 0 1]);
        Screen('FillRect', windowPtr, [0 0 0 0], disrect);
        Screen('FillPoly', windowPtr, [0 0 0 white], newdotmatrix');
        Screen('FillPoly', windowPtr, [0 0 0 0], leftmaskrect1', 0);
        Screen('FillPoly', windowPtr, [0 0 0 0], leftmaskrect2', 0);
        Screen('Blendfunction', windowPtr, GL_DST_ALPHA, GL_ONE_MINUS_DST_ALPHA, [1 1 1 1]);
        Screen('DrawTexture', windowPtr, tex, [], disrect, angle);
        Screen('Blendfunction', windowPtr, GL_ONE, GL_ZERO);
        Screen('FillPoly', windowPtr, bgcolor, dotmatrix2');
        
        angle=angle+1;
        leftmaskrect1=getmaskpointlist(bscenter, r, width, 1);
        leftmaskrect2=getmaskpointlist(bscenter, r, width, 2);
        leftmaskrect1=rotatepointlist(leftmaskrect1, bscenter, angle);
        leftmaskrect2=rotatepointlist(leftmaskrect2, bscenter, angle);
    end
    Screen('DrawText', windowPtr, text, center(1)-100, center(2)-50, white);
    Screen('DrawText', windowPtr, text2, center(1)-100, center(2)+60, white);
    Screen('DrawText', windowPtr, text3, center(1)-100, center(2)+120, white);
    %Screen('DrawDots', windowPtr, newdotmatrix, 10, [255 0 0]);
    focusPoint(windowPtr, center);
    Screen('Flip', windowPtr);
    Frame=mod(Frame, unitStim)+1;
    
    [pressed, ~, keycode]=KbCheck(-1);
    if pressed
        Frame=48;
        if keycode(KbName('1!'))
            if mode==0
%                 stretchpara=stretchpara-1;
%                 newdotmatrix=equalDistanceStretch(dotmatrix, dotmatrixSinCos, stretchpara);
                newdotmatrix=CMFStretch(newdotmatrix, dotmatrixSinCos, pointlistCMF, -deltaStretch);
            elseif mode==1
                width=width-1;
            elseif mode==2
                %bsstretchfactor=bsstretchfactor-0.2;
                dotmatrix2=CMFStretch(dotmatrix2, dotmatrixSinCos, pointlistCMF, -deltaStretch);
            end
        elseif keycode(KbName('2@'))
            if mode==0
%                 stretchpara=stretchpara+1;
%                 newdotmatrix=equalDistanceStretch(dotmatrix, dotmatrixSinCos, stretchpara);
                newdotmatrix=CMFStretch(newdotmatrix, dotmatrixSinCos, pointlistCMF, deltaStretch);
            elseif mode==1
                width=width+1;
            elseif mode==2
                %bsstretchfactor=bsstretchfactor+0.2;
                dotmatrix2=CMFStretch(dotmatrix2, dotmatrixSinCos, pointlistCMF, deltaStretch);
            end
        elseif keycode(KbName('3#'))
            WaitSecs(0.3);
            mode=mode+1;
            if mode>2
                mode=0;
            end
            if mode==0
                text='length';
            elseif mode==1
                text='width';
            elseif mode==2
                text='blind spot area';
            end
        elseif keycode(KbName('4$'))
            WaitSecs(0.3);
            break;
        end
    end
end

Outerdotmatrix=newdotmatrix;
Innerdotmatrix=dotmatrix2;
end

function newpointlist=getmaskpointlist(bscenter, r, width, mode)

switch mode
    case 1
        newpointlist=zeros(2, 4);
        newpointlist(1, 1)=bscenter(1)-r;
        newpointlist(2, 1)=bscenter(2)-r;
        newpointlist(1, 2)=bscenter(1)-width;
        newpointlist(2, 2)=bscenter(2)-r;
        newpointlist(1, 3)=bscenter(1)-width;
        newpointlist(2, 3)=bscenter(2)+r;
        newpointlist(1, 4)=bscenter(1)-r;
        newpointlist(2, 4)=bscenter(2)+r;
    case 2
        newpointlist=zeros(2, 4);
        newpointlist(1, 1)=bscenter(1)+r;
        newpointlist(2, 1)=bscenter(2)-r;
        newpointlist(1, 2)=bscenter(1)+width;
        newpointlist(2, 2)=bscenter(2)-r;
        newpointlist(1, 3)=bscenter(1)+width;
        newpointlist(2, 3)=bscenter(2)+r;
        newpointlist(1, 4)=bscenter(1)+r;
        newpointlist(2, 4)=bscenter(2)+r;
    case 3
        newpointlist=zeros(2, 8);
        newpointlist(1, 1)=bscenter(1)-r;
        newpointlist(2, 1)=bscenter(2)-r;
        newpointlist(1, 2)=bscenter(1)-width;
        newpointlist(2, 2)=bscenter(2)-r;
        newpointlist(1, 3)=bscenter(1)-width;
        newpointlist(2, 3)=bscenter(2)+width;
        newpointlist(1, 4)=bscenter(1)+width;
        newpointlist(2, 4)=bscenter(2)+width;
        newpointlist(1, 5)=bscenter(1)+width;
        newpointlist(2, 5)=bscenter(2)-r;
        newpointlist(1, 6)=bscenter(1)+r;
        newpointlist(2, 6)=bscenter(2)-r;
        newpointlist(1, 7)=bscenter(1)+r;
        newpointlist(2, 7)=bscenter(2)+r;
        newpointlist(1, 8)=bscenter(1)-r;
        newpointlist(2, 8)=bscenter(2)+r;
    case 4
        newpointlist=zeros(2, 8);
        newpointlist(1, 1)=bscenter(1)+r;
        newpointlist(2, 1)=bscenter(2)-r;
        newpointlist(1, 2)=bscenter(1)+r;
        newpointlist(2, 2)=bscenter(2)-width;
        newpointlist(1, 3)=bscenter(1)-width;
        newpointlist(2, 3)=bscenter(2)-width;
        newpointlist(1, 4)=bscenter(1)-width;
        newpointlist(2, 4)=bscenter(2)+width;
        newpointlist(1, 5)=bscenter(1)+r;
        newpointlist(2, 5)=bscenter(2)+width;
        newpointlist(1, 6)=bscenter(1)+r;
        newpointlist(2, 6)=bscenter(2)+r;
        newpointlist(1, 7)=bscenter(1)-r;
        newpointlist(2, 7)=bscenter(2)+r;
        newpointlist(1, 8)=bscenter(1)-r;
        newpointlist(2, 8)=bscenter(2)-r;
end

end

function newpointlist=rotatepointlist(pointlist, bscenter, angle)
W=[cosd(angle) -sind(angle); sind(angle) cosd(angle)];
n=numel(pointlist(1,:));
for i=1:n
    newpointlist(:, i)=W*(pointlist(:, i)-bscenter)+bscenter;
end
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

function tex=createBar(windowPtr, height, width, color, shape)
global bgcolor;

if isempty(width)
    width=height;
end

height=round(height);
width=round(width);

n=numel(color);
m=ones(height, width, n);
for i=1:n
    m(:, :, i)=m(:, :, i)*color(i);
    if strcmp(shape, 'circle')
        [x, y]=meshgrid(-(height-1)/2:(height-1)/2, -(width-1)/2:(width-1)/2);
        m(:, :, i)=(((x/((height-1)/2)).^2+((y/((width-1)/2)).^2))<1).*m(:, :, i)+...
            (((x/((height-1)/2)).^2+(y/((width-1)/2)).^2)>=1)*bgcolor;
    end
end

tex=Screen('MakeTexture', windowPtr, m);
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
