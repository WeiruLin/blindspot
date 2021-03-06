function BS_7T(subject, runNum)

if nargin<2
    runNum=1;
end

if nargin<1
    subject='xiaoming';
end

global black; global white; global gray; global inc; global bgcolor;
global screenXpixels; global screenYpixels; global xCenter; global yCenter;
global pixelsPerDeg; global t; global delta; global changeTime;

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

%%%%%%%%%%%%%%%% parameters for focal point task %%%%%%%%%%%%%%%%%
changeTime=5;
delta=0;

%%%%%%%%%%%%%%%%%%%% parameters of screen for view angle caculation %%%%%%%%%%%%%%%
load('screenarguments.mat', 'screenWidth', 'distanceFromEyetoScreen');
pixelsPerDeg=2*distanceFromEyetoScreen*tan(1*2*pi/360/2)*screenXpixels/screenWidth;

%%%%%%%%%%%%%% block time %%%%%%%%%%%%%%%%%%
blockStimTime=16;
blockRestTime=16;
stimInterval=2;

%%%%%%%%%%%%%% frame rate for caculating the stimuli' timing accurately
framerate=Screen('Framerate', windowPtr);
ifi=Screen('GetFlipInterval', windowPtr);
if framerate==0
    framerate=round(1/ifi);
end

%%% load subjects' blind spot documents
filename=[subject '_left' '_7T'];
load(filename, 'dotmatrix', 'bscenter', 'center');
leftcoord=dotmatrix;
lbscenter=bscenter;
filename=[subject '_right' '_7T'];
load(filename, 'dotmatrix', 'bscenter');
rightcoord=dotmatrix;
rbscenter=bscenter;


r=10*pixelsPerDeg;
%%%%%%%%%%%%
m=27;
stretchpara=40;
%%%%%%%%%%%%
shape='circle';
tex = createBar(windowPtr, 2*r+1, 2*r+1, white, shape);

if mod(runNum, 2)
    stimArray=[1 2 1 2 1 2];
else
    stimArray=[3 4 3 4 3 4];
end

%%%% ready
%text=['run ' num2str(runNum)];
Screen('TextSize', windowPtr, 40);
%Screen('DrawText', windowPtr, text, center(1)-40, center(2), white);
Screen('Flip', windowPtr);

t=GetSecs;
run(windowPtr, subject, stimArray, tex, framerate, blockStimTime, blockRestTime, stimInterval, r);

fprintf('framerate:%f \n', framerate);
fprintf('flip inteval:%f \n', ifi);

text=['run ' num2str(runNum) ' finish'];
Screen('TextSize', windowPtr, 40);
Screen('DrawText', windowPtr, text, center(1)-60, center(2), white);
Screen('Flip', windowPtr);
KbStrokeWait(-1);
sca;

end

function run(windowPtr, subject, stimArray, tex, framerate, blockStimTime, blockRestTime, stimInterval, r)
%%% load subjects' blind spot documents
global t; global changeTime; global delta;

filename=[subject '_left' '_7T'];
load(filename, 'dotmatrix', 'bscenter', 'center');
% p=30;
% center(2)=center(2)-p;
% dotmatrix(2, :)=dotmatrix(2, :)-p;
% bscenter(2, :)=bscenter(2, :)-p;
lcenter=center;
leftcoord=dotmatrix;
lbscenter=bscenter;
filename=[subject '_right' '_7T'];
load(filename, 'dotmatrix', 'bscenter', 'center');
% p=30;
% center(2)=center(2)-p;
% dotmatrix(2, :)=dotmatrix(2, :)-p;
% bscenter(2, :)=bscenter(2, :)-p;
rcenter=center;
rightcoord=dotmatrix;
rbscenter=bscenter;
filename=[subject '_stimpara'];
load(filename, 'stretchpara', 'm', 'bsstretchfactor');

if stimArray(1)==1 || stimArray(1)==2
    center=lcenter;
else
    center=rcenter;
end

leftcoordSinCos=sinAndcos(leftcoord, lbscenter);
leftcoordPlus=equalDistanceStretch(leftcoord, leftcoordSinCos, stretchpara);
leftcoord2=equalDistanceStretch(leftcoord, leftcoordSinCos, bsstretchfactor);
rightcoordSinCos=sinAndcos(rightcoord, rbscenter);
rightcoordPlus=equalDistanceStretch(rightcoord, rightcoordSinCos, stretchpara);
rightcoord2=equalDistanceStretch(rightcoord, rightcoordSinCos, bsstretchfactor);

choose_which_control=2; %1 or 2
unitStim=round(framerate/2);              % stim cycle in frame numbers, default is 1 second, that is frametate*1
if choose_which_control==2
    unitstimframenum=round(unitStim/3);     % stim duration of a cycle in frame numbers
else
    unitstimframenum=round(unitStim/3);
end
interval=round(framerate/6);


TR=2;
dummy=2;

while true
    [~, secs, keyCode] = KbCheck(-1);
    if keyCode(KbName('s'))
        break;
    end
end

while GetSecs-secs<TR*dummy
    focusPoint(windowPtr, center);
    Screen('Flip', windowPtr);
end

t=GetSecs;
changeTime=5;
delta=0;

startTime=GetSecs;
while GetSecs-startTime<blockRestTime
    focusPoint(windowPtr, center);
    Screen('Flip', windowPtr);
end
for i=1:2
    
    switch stimArray(i)
        case 1
            fillinginblock(windowPtr, tex, leftcoord2, leftcoordPlus, unitStim, unitstimframenum, blockStimTime, lbscenter, r, m, lcenter);

            WaitSecs(0.1);
            while GetSecs-startTime<(2*i-1)*(blockStimTime+stimInterval)+blockRestTime
                focusPoint(windowPtr, rcenter);
                Screen('Flip', windowPtr);
            end
            fillinginblock(windowPtr, tex, rightcoord2, rightcoordPlus, unitStim, unitstimframenum, blockStimTime, rbscenter, r, m, rcenter);
            while GetSecs-startTime<(2*i)*(blockStimTime+stimInterval)+blockRestTime
                focusPoint(windowPtr, lcenter);
                Screen('Flip', windowPtr);
            end
        case 2
            if choose_which_control==2
                nofillinginblock2(windowPtr, tex, leftcoord2, leftcoordPlus, unitStim, unitstimframenum, blockStimTime, lbscenter, r, m, lcenter);
            else
                nofillinginblock(windowPtr, tex, leftcoord2, leftcoordPlus, unitStim, unitstimframenum, interval, blockStimTime, lbscenter, r, m, lcenter);
            end
            WaitSecs(0.1);
            while GetSecs-startTime<(2*i-1)*(blockStimTime+stimInterval)+blockRestTime
                focusPoint(windowPtr, rcenter);
                Screen('Flip', windowPtr);
            end
            if choose_which_control==2
                nofillinginblock2(windowPtr, tex, rightcoord2, rightcoordPlus, unitStim, unitstimframenum, blockStimTime, rbscenter, r, m, rcenter);
            else
                nofillinginblock(windowPtr, tex, rightcoord2, rightcoordPlus, unitStim, unitstimframenum, interval, blockStimTime, rbscenter, r, m, rcenter);
            end
            while GetSecs-startTime<(2*i)*(blockStimTime+stimInterval)+blockRestTime
                focusPoint(windowPtr, lcenter);
                Screen('Flip', windowPtr);
            end
        case 3
            fillinginblock(windowPtr, tex, rightcoord2, rightcoordPlus, unitStim, unitstimframenum, blockStimTime, rbscenter, r, m, rcenter);
            WaitSecs(0.1);
            while GetSecs-startTime<(2*i-1)*(blockStimTime+stimInterval)+blockRestTime
                focusPoint(windowPtr, lcenter);
                Screen('Flip', windowPtr);
            end
            fillinginblock(windowPtr, tex, leftcoord2, leftcoordPlus, unitStim, unitstimframenum, blockStimTime, lbscenter, r, m, lcenter);
            while GetSecs-startTime<(2*i)*(blockStimTime+stimInterval)+blockRestTime
                focusPoint(windowPtr, rcenter);
                Screen('Flip', windowPtr);
            end
        case 4
            if choose_which_control==2
                nofillinginblock2(windowPtr, tex, rightcoord2, rightcoordPlus, unitStim, unitstimframenum, blockStimTime, rbscenter, r, m, rcenter);
            else
                nofillinginblock(windowPtr, tex, rightcoord2, rightcoordPlus, unitStim, unitstimframenum, interval, blockStimTime, rbscenter, r, m, rcenter);
            end
            WaitSecs(0.1);
            while GetSecs-startTime<(2*i-1)*(blockStimTime+stimInterval)+blockRestTime
                focusPoint(windowPtr, lcenter);
                Screen('Flip', windowPtr);
            end
            if choose_which_control==2
                nofillinginblock2(windowPtr, tex, leftcoord2, leftcoordPlus, unitStim, unitstimframenum, blockStimTime, lbscenter, r, m, lcenter);
            else
                nofillinginblock(windowPtr, tex, leftcoord2, leftcoordPlus, unitStim, unitstimframenum, interval, blockStimTime, lbscenter, r, m, lcenter);
            end
            while GetSecs-startTime<(2*i)*(blockStimTime+stimInterval)+blockRestTime
                focusPoint(windowPtr, rcenter);
                Screen('Flip', windowPtr);
            end
    end
    
end
while GetSecs-startTime<blockRestTime-stimInterval+4*(blockStimTime+stimInterval)+blockRestTime
    focusPoint(windowPtr, center);
    Screen('Flip', windowPtr);
end
for i=3:4
    switch stimArray(i)
        case 1
            fillinginblock(windowPtr, tex, leftcoord2, leftcoordPlus, unitStim, unitstimframenum, blockStimTime, lbscenter, r, m, lcenter);
            WaitSecs(0.1);
            while GetSecs-startTime<(2*i-1)*(blockStimTime+stimInterval)+blockRestTime*2-stimInterval
                focusPoint(windowPtr, rcenter);
                Screen('Flip', windowPtr);
            end
            fillinginblock(windowPtr, tex, rightcoord2, rightcoordPlus, unitStim, unitstimframenum, blockStimTime, rbscenter, r, m, rcenter);
            while GetSecs-startTime<(2*i)*(blockStimTime+stimInterval)+blockRestTime*2-stimInterval
                focusPoint(windowPtr, lcenter);
                Screen('Flip', windowPtr);
            end
        case 2
            if choose_which_control==2
                nofillinginblock2(windowPtr, tex, leftcoord2, leftcoordPlus, unitStim, unitstimframenum, blockStimTime, lbscenter, r, m, lcenter);
            else
                nofillinginblock(windowPtr, tex, leftcoord2, leftcoordPlus, unitStim, unitstimframenum, interval, blockStimTime, lbscenter, r, m, lcenter);
            end
            WaitSecs(0.1);
            while GetSecs-startTime<(2*i-1)*(blockStimTime+stimInterval)+blockRestTime*2-stimInterval
                focusPoint(windowPtr, rcenter);
                Screen('Flip', windowPtr);
            end
           if choose_which_control==2
                nofillinginblock2(windowPtr, tex, rightcoord2, rightcoordPlus, unitStim, unitstimframenum, blockStimTime, rbscenter, r, m, rcenter);
            else
                nofillinginblock(windowPtr, tex, rightcoord2, rightcoordPlus, unitStim, unitstimframenum, interval, blockStimTime, rbscenter, r, m, rcenter);
            end
            while GetSecs-startTime<(2*i)*(blockStimTime+stimInterval)+blockRestTime*2-stimInterval
                focusPoint(windowPtr, lcenter);
                Screen('Flip', windowPtr);
            end
        case 3
            fillinginblock(windowPtr, tex, rightcoord2, rightcoordPlus, unitStim, unitstimframenum, blockStimTime, rbscenter, r, m, rcenter);
            WaitSecs(0.1);
            while GetSecs-startTime<(2*i-1)*(blockStimTime+stimInterval)+blockRestTime*2-stimInterval
                focusPoint(windowPtr, lcenter);
                Screen('Flip', windowPtr);
            end
            fillinginblock(windowPtr, tex, leftcoord2, leftcoordPlus, unitStim, unitstimframenum, blockStimTime, lbscenter, r, m, lcenter);
            while GetSecs-startTime<(2*i)*(blockStimTime+stimInterval)+blockRestTime*2-stimInterval
                focusPoint(windowPtr, rcenter);
                Screen('Flip', windowPtr);
            end
        case 4
            if choose_which_control==2
                nofillinginblock2(windowPtr, tex, rightcoord2, rightcoordPlus, unitStim, unitstimframenum, blockStimTime, rbscenter, r, m, rcenter);
            else
                nofillinginblock(windowPtr, tex, rightcoord2, rightcoordPlus, unitStim, unitstimframenum, interval, blockStimTime, rbscenter, r, m, rcenter);
            end
            WaitSecs(0.1);
            while GetSecs-startTime<(2*i-1)*(blockStimTime+stimInterval)+blockRestTime*2-stimInterval
                focusPoint(windowPtr, lcenter);
                Screen('Flip', windowPtr);
            end
            if choose_which_control==2
                nofillinginblock2(windowPtr, tex, leftcoord2, leftcoordPlus, unitStim, unitstimframenum, blockStimTime, lbscenter, r, m, lcenter);
            else
                nofillinginblock(windowPtr, tex, leftcoord2, leftcoordPlus, unitStim, unitstimframenum, interval, blockStimTime, lbscenter, r, m, lcenter);
            end
            while GetSecs-startTime<(2*i)*(blockStimTime+stimInterval)+blockRestTime*2-stimInterval
                focusPoint(windowPtr, rcenter);
                Screen('Flip', windowPtr);
            end
    end
    
end
while GetSecs-startTime<2*(blockRestTime-stimInterval)+8*(blockStimTime+stimInterval)+blockRestTime
    focusPoint(windowPtr, center);
    Screen('Flip', windowPtr);
end

for i=5:6
    switch stimArray(i)
        case 1
            fillinginblock(windowPtr, tex, leftcoord2, leftcoordPlus, unitStim, unitstimframenum, blockStimTime, lbscenter, r, m, lcenter);
            WaitSecs(0.1);
            while GetSecs-startTime<(2*i-1)*(blockStimTime+stimInterval)+blockRestTime*3-2*stimInterval
                focusPoint(windowPtr, rcenter);
                Screen('Flip', windowPtr);
            end
            fillinginblock(windowPtr, tex, rightcoord2, rightcoordPlus, unitStim, unitstimframenum, blockStimTime, rbscenter, r, m, rcenter);
            while GetSecs-startTime<(2*i)*(blockStimTime+stimInterval)+blockRestTime*3-2*stimInterval
                focusPoint(windowPtr, lcenter);
                Screen('Flip', windowPtr);
            end
        case 2
            if choose_which_control==2
                nofillinginblock2(windowPtr, tex, leftcoord2, leftcoordPlus, unitStim, unitstimframenum, blockStimTime, lbscenter, r, m, lcenter);
            else
                nofillinginblock(windowPtr, tex, leftcoord2, leftcoordPlus, unitStim, unitstimframenum, interval, blockStimTime, lbscenter, r, m, lcenter);
            end
            WaitSecs(0.1);
            while GetSecs-startTime<(2*i-1)*(blockStimTime+stimInterval)+blockRestTime*3-2*stimInterval
                focusPoint(windowPtr, rcenter);
                Screen('Flip', windowPtr);
            end
            if choose_which_control==2
                nofillinginblock2(windowPtr, tex, rightcoord2, rightcoordPlus, unitStim, unitstimframenum, blockStimTime, rbscenter, r, m, rcenter);
            else
                nofillinginblock(windowPtr, tex, rightcoord2, rightcoordPlus, unitStim, unitstimframenum, interval, blockStimTime, rbscenter, r, m, rcenter);
            end
            while GetSecs-startTime<(2*i)*(blockStimTime+stimInterval)+blockRestTime*3-2*stimInterval
                focusPoint(windowPtr, lcenter);
                Screen('Flip', windowPtr);
            end
        case 3
            fillinginblock(windowPtr, tex, rightcoord2, rightcoordPlus, unitStim, unitstimframenum, blockStimTime, rbscenter, r, m, rcenter);
            WaitSecs(0.1);
            while GetSecs-startTime<(2*i-1)*(blockStimTime+stimInterval)+blockRestTime*3-2*stimInterval
                focusPoint(windowPtr, lcenter);
                Screen('Flip', windowPtr);
            end
            fillinginblock(windowPtr, tex, leftcoord2, leftcoordPlus, unitStim, unitstimframenum, blockStimTime, lbscenter, r, m, lcenter);
            while GetSecs-startTime<(2*i)*(blockStimTime+stimInterval)+blockRestTime*3-2*stimInterval
                focusPoint(windowPtr, rcenter);
                Screen('Flip', windowPtr);
            end
        case 4
            if choose_which_control==2
                nofillinginblock2(windowPtr, tex, rightcoord2, rightcoordPlus, unitStim, unitstimframenum, blockStimTime, rbscenter, r, m, rcenter);
            else
                nofillinginblock(windowPtr, tex, rightcoord2, rightcoordPlus, unitStim, unitstimframenum, interval, blockStimTime, rbscenter, r, m, rcenter);
            end
            WaitSecs(0.1);
            while GetSecs-startTime<(2*i-1)*(blockStimTime+stimInterval)+blockRestTime*3-2*stimInterval
                focusPoint(windowPtr, lcenter);
                Screen('Flip', windowPtr);
            end
            if choose_which_control==2
                nofillinginblock2(windowPtr, tex, leftcoord2, leftcoordPlus, unitStim, unitstimframenum, blockStimTime, lbscenter, r, m, lcenter);
            else
                nofillinginblock(windowPtr, tex, leftcoord2, leftcoordPlus, unitStim, unitstimframenum, interval, blockStimTime, lbscenter, r, m, lcenter);
            end
            while GetSecs-startTime<(2*i)*(blockStimTime+stimInterval)+blockRestTime*3-2*stimInterval
                focusPoint(windowPtr, rcenter);
                Screen('Flip', windowPtr);
            end
    end
    
end

while GetSecs-startTime<3*(blockRestTime-stimInterval)+12*(blockStimTime+stimInterval)+blockRestTime
    focusPoint(windowPtr, center);
    Screen('Flip', windowPtr);
end
runTime=GetSecs-startTime;
fprintf('run time:%f \n', runTime);
    
end

function fillinginblock(windowPtr, tex, dotmatrix, newdotmatrix, unitStim, unitstimframenum, blockStimTime, bscenter, r, m, center)
global white; global bgcolor; 
disrect=[bscenter(1)-r bscenter(2)-r bscenter(1)+r bscenter(2)+r];
Frame=0;
angle=(randi(8)-1)*45;
leftmaskrect1=getmaskpointlist(bscenter, r, m, 1);
leftmaskrect2=getmaskpointlist(bscenter, r, m, 2);
leftmaskrect1=rotatepointlist(leftmaskrect1, bscenter, angle);
leftmaskrect2=rotatepointlist(leftmaskrect2, bscenter, angle);

t0=GetSecs;
while GetSecs-t0<blockStimTime-0.1
    
    if mod(Frame, unitStim)<unitstimframenum
        Screen('Blendfunction', windowPtr, GL_ONE, GL_ZERO, [0 0 0 1]);
        Screen('FillRect', windowPtr, [0 0 0 0], disrect);
        Screen('FillPoly', windowPtr, [0 0 0 white], newdotmatrix');
        Screen('FillPoly', windowPtr, [0 0 0 0], leftmaskrect1', 0);
        Screen('FillPoly', windowPtr, [0 0 0 0], leftmaskrect2', 0);
        Screen('Blendfunction', windowPtr, GL_DST_ALPHA, GL_ONE_MINUS_DST_ALPHA, [1 1 1 1]);
        Screen('DrawTexture', windowPtr, tex, [], disrect, angle);
    end
    %Screen('DrawDots', windowPtr, newdotmatrix, 10, [255 0 0]);
    Screen('Blendfunction', windowPtr, GL_ONE, GL_ZERO);
    Screen('FillPoly', windowPtr, bgcolor, dotmatrix');
    focusPoint(windowPtr, center);
    Screen('Flip', windowPtr);
    Frame=mod(Frame, unitStim)+1;
    if Frame==unitStim
        temp=randi(8);
        if temp~=1
            angle1=(randi(4)-1)*45;
            if angle==angle1
                angle=angle+(randi(2)-1.5)*90;
            else
                angle=angle1;
            end
        end
        leftmaskrect1=getmaskpointlist(bscenter, r, m, 1);
        leftmaskrect2=getmaskpointlist(bscenter, r, m, 2);
        leftmaskrect1=rotatepointlist(leftmaskrect1, bscenter, angle);
        leftmaskrect2=rotatepointlist(leftmaskrect2, bscenter, angle);
    end
end

end

function nofillinginblock(windowPtr, tex, dotmatrix, newdotmatrix, unitStim, unitstimframenum, interval, blockStimTime, bscenter, r, m, center)
global white; global bgcolor;
disrect=[bscenter(1)-r bscenter(2)-r bscenter(1)+r bscenter(2)+r];
Frame=1;
%anglen = randsample(1:8,1);angle=(anglen-1)*45;lastOri = anglen;
locSeq = [];
for i=1:100
    locSeq = [locSeq Shuffle(1:8)];
end
dup = locSeq(2:end)-locSeq(1:end-1); locSeq(find(dup==0|abs(dup==4))+1) = [];
angle=(randi(8)-1)*45;
leftAo=getmaskpointlist(bscenter, r, m, 3);
leftAo1=rotatepointlist(leftAo, bscenter, locSeq(1)*45);
leftAo2=rotatepointlist(leftAo, bscenter, locSeq(2)*45);
t=GetSecs;
ori = [angle];count = 0;
while GetSecs-t<blockStimTime-0.1
    if mod(Frame, unitStim)<unitstimframenum
        Screen('Blendfunction', windowPtr, GL_ONE, GL_ZERO, [0 0 0 1]);
        Screen('FillRect', windowPtr, [0 0 0 0], disrect);
        Screen('FillPoly', windowPtr, [0 0 0 white], newdotmatrix');
        Screen('FillPoly', windowPtr, [0 0 0 0], leftAo1', 0);
        Screen('Blendfunction', windowPtr, GL_DST_ALPHA, GL_ONE_MINUS_DST_ALPHA, [1 1 1 1]);
        Screen('DrawTexture', windowPtr, tex, [], disrect, angle);
    elseif mod(Frame, unitStim)<unitstimframenum*2+interval && mod(Frame, unitStim)>=unitstimframenum+interval
        Screen('Blendfunction', windowPtr, GL_ONE, GL_ZERO, [0 0 0 1]);
        Screen('FillRect', windowPtr, [0 0 0 0], disrect);
        Screen('FillPoly', windowPtr, [0 0 0 white], newdotmatrix');
        Screen('FillPoly', windowPtr, [0 0 0 0], leftAo2', 0);
        Screen('Blendfunction', windowPtr, GL_DST_ALPHA, GL_ONE_MINUS_DST_ALPHA, [1 1 1 1]);
        Screen('DrawTexture', windowPtr, tex, [], disrect, angle);
    end
    Screen('Blendfunction', windowPtr, GL_ONE, GL_ZERO);
    Screen('FillPoly', windowPtr, bgcolor, dotmatrix');
    focusPoint(windowPtr, center);
    Screen('Flip', windowPtr);
    Frame=mod(Frame, unitStim)+1;
    if Frame==unitStim
%         randseq = Shuffle(1:8);randseq(randseq==lastOri) = [];randseq(randseq==mod(lastOri+4,8)) = [];anglen = randseq(1); angle=(anglen-1)*45;lastOri = anglen;
        
        ori = [ori angle];
        leftAo=getmaskpointlist(bscenter, r, m, 3);
        leftAo1=rotatepointlist(leftAo, bscenter, locSeq(count*2+1)*45);
        leftAo2=rotatepointlist(leftAo, bscenter, locSeq(count*2+2)*45);
        count=count+1;
    end
end
end

function nofillinginblock2(windowPtr, tex, dotmatrix, newdotmatrix, unitStim, unitstimframenum, blockStimTime, bscenter, r, m, center)
global white; global bgcolor; 
disrect=[bscenter(1)-r bscenter(2)-r bscenter(1)+r bscenter(2)+r];
Frame=0;
angle=(randi(8)-1)*45;
leftAo1=getmaskpointlist(bscenter, r, m, 3);
leftAo1=rotatepointlist(leftAo1, bscenter, angle);
leftAo2=rotatepointlist(leftAo1, bscenter, 90);

t0=GetSecs;
while GetSecs-t0<blockStimTime-0.1
    if mod(Frame, unitStim)<unitstimframenum
        Screen('Blendfunction', windowPtr, GL_ONE, GL_ZERO, [0 0 0 1]);
        Screen('FillRect', windowPtr, [0 0 0 0], disrect);
        Screen('FillPoly', windowPtr, [0 0 0 white], newdotmatrix');
        Screen('FillPoly', windowPtr, [0 0 0 0], leftAo1', 0);
        Screen('Blendfunction', windowPtr, GL_DST_ALPHA, GL_ONE_MINUS_DST_ALPHA, [1 1 1 1]);
        Screen('DrawTexture', windowPtr, tex, [], disrect, angle);
        Screen('Blendfunction', windowPtr, GL_ONE, GL_ZERO, [0 0 0 1]);
        Screen('FillRect', windowPtr, [0 0 0 0], disrect);
        Screen('FillPoly', windowPtr, [0 0 0 white], newdotmatrix');
        Screen('FillPoly', windowPtr, [0 0 0 0], leftAo2', 0);
        Screen('Blendfunction', windowPtr, GL_DST_ALPHA, GL_ONE_MINUS_DST_ALPHA, [1 1 1 1]);
        Screen('DrawTexture', windowPtr, tex, [], disrect, angle);
    end
    Screen('Blendfunction', windowPtr, GL_ONE, GL_ZERO);
    Screen('FillPoly', windowPtr, bgcolor, dotmatrix');
    focusPoint(windowPtr, center);
    Screen('Flip', windowPtr);
    Frame=mod(Frame, unitStim)+1;
    if Frame==unitStim
        temp=randi(8);
        if temp~=1
            angle1=(randi(8)-1)*45;
            if angle==angle1
                angle=angle+(randi(2)-1.5)*90;
            else
                angle=angle1;
            end
        end
        leftAo1=getmaskpointlist(bscenter, r, m, 3);
        leftAo1=rotatepointlist(leftAo1, bscenter, angle);
        leftAo2=rotatepointlist(leftAo1, bscenter, 90);
    end
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

function focusPoint(windowPtr, center)
global white; global black; global pixelsPerDeg; global t; global delta; global changeTime;

a=0.25;
rect=[center(1)-a*pixelsPerDeg center(2)-a*pixelsPerDeg ...
    center(1)+a*pixelsPerDeg center(2)+a*pixelsPerDeg];

% if GetSecs-t>changeTime+5
%     delta=delta+180*(randi(2)-1.5);
%     t=GetSecs;
%     changeTime=randi(5);
% end

endAngle=90;
% for startAngle=[0 180]+delta
%     Screen('FillArc', windowPtr, white, rect, startAngle, endAngle);
% end
% for startAngle=[90 270]+[delta delta]
%     Screen('FillArc', windowPtr, black, rect, startAngle, endAngle);
% end
Screen('FillArc', windowPtr, white, rect, delta, endAngle);
Screen('FillArc', windowPtr, white, rect, 180+delta, endAngle);
Screen('FillArc', windowPtr, black, rect, 90+delta, endAngle);
Screen('FillArc', windowPtr, black, rect, 270+delta, endAngle);
%fprintf('%f\n', delta);
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

function newpointlist=getmaskpointlist(bscenter, r, m, mode)

switch mode
    case 1
        newpointlist=zeros(2, 4);
        newpointlist(1, 1)=bscenter(1)-r;
        newpointlist(2, 1)=bscenter(2)-r;
        newpointlist(1, 2)=bscenter(1)-m;
        newpointlist(2, 2)=bscenter(2)-r;
        newpointlist(1, 3)=bscenter(1)-m;
        newpointlist(2, 3)=bscenter(2)+r;
        newpointlist(1, 4)=bscenter(1)-r;
        newpointlist(2, 4)=bscenter(2)+r;
    case 2
        newpointlist=zeros(2, 4);
        newpointlist(1, 1)=bscenter(1)+r;
        newpointlist(2, 1)=bscenter(2)-r;
        newpointlist(1, 2)=bscenter(1)+m;
        newpointlist(2, 2)=bscenter(2)-r;
        newpointlist(1, 3)=bscenter(1)+m;
        newpointlist(2, 3)=bscenter(2)+r;
        newpointlist(1, 4)=bscenter(1)+r;
        newpointlist(2, 4)=bscenter(2)+r;
    case 3
        newpointlist=zeros(2, 8);
        newpointlist(1, 1)=bscenter(1)-r;
        newpointlist(2, 1)=bscenter(2)-r;
        newpointlist(1, 2)=bscenter(1)-m;
        newpointlist(2, 2)=bscenter(2)-r;
        newpointlist(1, 3)=bscenter(1)-m;
        newpointlist(2, 3)=bscenter(2)+m;
        newpointlist(1, 4)=bscenter(1)+m;
        newpointlist(2, 4)=bscenter(2)+m;
        newpointlist(1, 5)=bscenter(1)+m;
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
        newpointlist(2, 2)=bscenter(2)-m;
        newpointlist(1, 3)=bscenter(1)-m;
        newpointlist(2, 3)=bscenter(2)-m;
        newpointlist(1, 4)=bscenter(1)-m;
        newpointlist(2, 4)=bscenter(2)+m;
        newpointlist(1, 5)=bscenter(1)+r;
        newpointlist(2, 5)=bscenter(2)+m;
        newpointlist(1, 6)=bscenter(1)+r;
        newpointlist(2, 6)=bscenter(2)+r;
        newpointlist(1, 7)=bscenter(1)-r;
        newpointlist(2, 7)=bscenter(2)+r;
        newpointlist(1, 8)=bscenter(1)-r;
        newpointlist(2, 8)=bscenter(2)-r;
    case 5
        newpointlist=zeros(2, 8);
        newpointlist(1, 1)=bscenter(1)-r;
        newpointlist(2, 1)=bscenter(2)+r;
        newpointlist(1, 2)=bscenter(1)-r;
        newpointlist(2, 2)=bscenter(2)+m;
        newpointlist(1, 3)=bscenter(1)+m;
        newpointlist(2, 3)=bscenter(2)+m;
        newpointlist(1, 4)=bscenter(1)+m;
        newpointlist(2, 4)=bscenter(2)-m;
        newpointlist(1, 5)=bscenter(1)-r;
        newpointlist(2, 5)=bscenter(2)-m;
        newpointlist(1, 6)=bscenter(1)-r;
        newpointlist(2, 6)=bscenter(2)-r;
        newpointlist(1, 7)=bscenter(1)+r;
        newpointlist(2, 7)=bscenter(2)-r;
        newpointlist(1, 8)=bscenter(1)+r;
        newpointlist(2, 8)=bscenter(2)+r;
    case 6
        newpointlist=zeros(2, 8);
        newpointlist(1, 1)=bscenter(1)+r;
        newpointlist(2, 1)=bscenter(2)+r;
        newpointlist(1, 2)=bscenter(1)+m;
        newpointlist(2, 2)=bscenter(2)+r;
        newpointlist(1, 3)=bscenter(1)+m;
        newpointlist(2, 3)=bscenter(2)-m;
        newpointlist(1, 4)=bscenter(1)-m;
        newpointlist(2, 4)=bscenter(2)-m;
        newpointlist(1, 5)=bscenter(1)-m;
        newpointlist(2, 5)=bscenter(2)+r;
        newpointlist(1, 6)=bscenter(1)-r;
        newpointlist(2, 6)=bscenter(2)+r;
        newpointlist(1, 7)=bscenter(1)-r;
        newpointlist(2, 7)=bscenter(2)-r;
        newpointlist(1, 8)=bscenter(1)+r;
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