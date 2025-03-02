% Test video play and progress bar

% Test video play
addpath("C:/Matfiles/Psychtoolbox")

% Initialize Psychtoolbox
Screen('Preference', 'SkipSyncTests', 1);
Screen('Preference', 'VisualDebugLevel', 0);
Screen('Preference', 'SuppressAllWarnings', 1);
PsychDefaultSetup(2);

% Open a window
[window, windowRect] = PsychImaging('OpenWindow', 0, 0);

% Get the duration for which the video should play (in seconds)
playDuration = 40; % Change this to your desired duration

% Get the movie file
movieFile = 'C:/Users/Brain Yan/Downloads/galaxy.mp4'; 

% Open the movie file with additional parameters
async = 0;
preloadSecs = 1;
specialFlags1 = 0;
pixelFormat = 4;
maxNumberThreads = -1;
movieOptions = [];

movie = Screen('OpenMovie', window, movieFile, async, preloadSecs, specialFlags1, pixelFormat, maxNumberThreads, movieOptions);


% Start playback engine
Screen('PlayMovie', movie, 1,1);

% Get the start time
startTime = GetSecs;

% Loop the video until the time is up
while (GetSecs - startTime) < playDuration
    % Check for new frame
    tex = Screen('GetMovieImage', window, movie);
    
    % If there is a new frame, draw it
    if tex > 0
        Screen('DrawTexture', window, tex);
        Screen('Flip', window);
        Screen('Close', tex);
    end
end



% Stop playback
Screen('PlayMovie', movie, 0);

% Close the movie
Screen('CloseMovie', movie);

% Close the window
Screen('CloseAll');
%% Play movie

% Test video play
addpath("C:/Matfiles/Psychtoolbox")

% Initialize Psychtoolbox
Screen('Preference', 'SkipSyncTests', 1);
Screen('Preference', 'VisualDebugLevel', 0);
Screen('Preference', 'SuppressAllWarnings', 1);
PsychDefaultSetup(2);

% Open a window
[window, windowRect] = PsychImaging('OpenWindow', 0, 0);

% Get the duration for which the video should play (in seconds)
playDuration = 20; % Change this to your desired duration

% Get the movie file
movieFile = fullfile(pwd,'../stimulus/videos/galaxy.mp4'); 

% Open the movie file with additional parameters
async = 1;
preloadSecs = 1;
specialFlags1 = 0;
pixelFormat = 4;
maxNumberThreads = -1;
movieOptions = [];

movie = Screen('OpenMovie', window, movieFile, async, preloadSecs, specialFlags1, pixelFormat, maxNumberThreads, movieOptions);


% Start playback engine
Screen('PlayMovie', movie, 1,1);

% Get the start time
startTime = GetSecs;

% Loop the video until the time is up
while (GetSecs - startTime) < playDuration
    % Check for new frame
    tex = Screen('GetMovieImage', window, movie);
    
    % If there is a new frame, draw it
    if tex > 0
        Screen('DrawTexture', window, tex);
        Screen('Flip', window);
        Screen('Close', tex);
    else
        WaitSecs(0.001); % Add a small delay if no frame is ready
    end
end



% Stop playback
Screen('PlayMovie', movie, 0);

% Close the movie
Screen('CloseMovie', movie);

% Close the window
Screen('CloseAll');




%% Progress bar


Screen('Preference', 'SkipSyncTests', 1);
Screen('Preference', 'VisualDebugLevel', 0);
Screen('Preference', 'SuppressAllWarnings', 1);
PsychDefaultSetup(2);
% Open a window
[window, windowRect] = PsychImaging('OpenWindow', 1, 0.5);

Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% Get the size of the on screen window in pixels
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Get the centre coordinate of the window in pixels
[xCenter, yCenter] = RectCenter(windowRect);

% Determine the width of the rectangles
wid = 50;

% Make a base Rect of 200 by 200 pixels.
baseRect = [0 0 wid wid];

% Number of triangles
numRects = 5;

% Compute the total width 
totalWidth = numRects*wid;

% Initial position of the rectangle
initPos = xCenter - totalWidth / 2 + wid / 2;

for i = 1:numRects

    for j = 1:i    
    
    currentRect = CenterRectOnPointd(baseRect, initPos + (j-1) * wid, yCenter);
    
    Screen('FillRect', window, [1 1 1], currentRect);
    
    end

Screen('Flip', window);

WaitSecs(1);

end

KbStrokeWait;

sca;



%% test



Screen('Preference', 'SkipSyncTests', 1);
Screen('Preference', 'VisualDebugLevel', 0);
Screen('Preference', 'SuppressAllWarnings', 1);
PsychDefaultSetup(2);
% Open a window
[window, windowRect] = PsychImaging('OpenWindow', 1, 0.5);

Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% Get the size of the on screen window in pixels
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Get the centre coordinate of the window in pixels
[xCenter, yCenter] = RectCenter(windowRect);

line1 = 'Great job! You have come to the last part of the experiment.';
line2 = '\n\n Before we proceed, please wait for the experimenter to set up the equipment for this part.';
line3 = '\n\n Please do not press any key unless instructed by the experimenter.';

% Draw instructions
DrawFormattedText(window, [line1 line2 line3], 'center', screenYpixels * 0.35, 1);

% Flip to the screen
Screen('Flip', window);

% Press any key to continue
KbStrokeWait;

% Page for accidental pressing.
line1 = 'BACK UP SLIDE FOR ACCIDENTS!';
line2 = '\n\n DO NOT PROCEED UNLESS INSTRUCTED SO!';

% Draw instructions
DrawFormattedText(window, [line1 line2], 'center', screenYpixels * 0.55, 1);

% Flip to the screen
Screen('Flip', window);

% Press any key to continue
KbStrokeWait;

% Instructions
line1 = 'In the next section, you will be asked to recall the story verbally in detail';
line2 = '\n\n You have 15 seconds to prepare. Please start the verbal recall after you hear the "Beep".';
line3 = '\n\n The countdown will start in 2 seconds';
% Draw instructions
DrawFormattedText(window, [line1 line2 line3], 'center', screenYpixels * 0.35, 1);

% Flip to the screen
Screen('Flip', window);

% Press any key to continue
WaitSecs(5);

% Determine the width of the rectangles
wid = 50;

% Make a base Rect of 200 by 200 pixels.
baseRect = [0 0 wid wid];

% Number of triangles
numRects = 5;

% Compute the total width 
totalWidth = numRects*wid;

% Initial position of the rectangle
initPos = xCenter - totalWidth / 2 + wid / 2;

for i = 1:numRects

    for j = 1:i    
    
    currentRect = CenterRectOnPointd(baseRect, initPos + (j-1) * wid, screenYpixels*0.75);
    
    Screen('FillRect', window, [1 1 1], currentRect);
    
    end
    
% Instructions
line1 = 'In the next section, you will be asked to recall the story verbally in detail.';
line2 = '\n\n You have 15 seconds to prepare. Please start the verbal recall after you hear the "Beep".';

% Draw instructions
DrawFormattedText(window, [line1 line2], 'center', screenYpixels * 0.35, 1);

Screen('Flip', window);

WaitSecs(1);

end

% Set up the fixation cross
fixCrossDimPix = 40;
xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
allCoords = [xCoords; yCoords];
lineWidthPix = 4;

% Draw fixation cross
% if strcmp(devType, 'EEG')
%     Screen('DrawLines', screen.win, allCoords, lineWidthPix, screen.white, [screen.xCenter, screen.yCenter], 2);
% elseif strcmp(devType, 'MEG')
%     Screen('DrawLines', screen.win, allCoords, lineWidthPix, screen.white, [screen.xCenter, screen.yCenter], 2);
% else
    Screen('DrawLines', window, allCoords, lineWidthPix, 1, [xCenter, yCenter]);
% end
Screen('Flip', window);

Beeper(500)

%--! send trigger ! --

% if strcmp(devType, 'EEG')
%     write(port, 512,"uint8");
% elseif strcmp(devType, 'MEG')
%     PTBSendTrigger(512,0);
% else
%     Beeper(2000)
% end

%--! send trigger ! --



KbStrokeWait


% Instructions for recall

sca;




%% test image display

% Clear the workspace and close all windows
clear;
close all;
sca;

% Initialize Psychtoolbox
PsychDefaultSetup(2);
Screen('Preference', 'SkipSyncTests', 1);

% Open a window
screenNumber = max(Screen('Screens'));
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, [0.5 0.5 0.5]); % Grey background

% Get the screen dimensions
[screenWidth, screenHeight] = Screen('WindowSize', window);

% Load the image
imagePath = fullfile(pwd, '../stimulus/images/testimage4k.jpg'); % Replace with the path to your image
image = imread(imagePath);
imageHeight = size(image, 1);
imageWidth = size(image, 2);

% Calculate the scaling factor to fill the screen while maintaining aspect ratio
screenAspectRatio = screenWidth / screenHeight;
imageAspectRatio = imageWidth / imageHeight;

if imageAspectRatio > screenAspectRatio
    % Image is wider than the screen; scale based on height
    scaleFactor = screenHeight / imageHeight;
else
    % Image is taller than the screen; scale based on width
    scaleFactor = screenWidth / imageWidth;
end

% Scale the image dimensions
scaledWidth = imageWidth * scaleFactor;
scaledHeight = imageHeight * scaleFactor;

% Create a texture from the image
imageTexture = Screen('MakeTexture', window, image);

% Calculate the destination rectangle for the image
destinationRect = CenterRectOnPointd([0 0 scaledWidth scaledHeight], screenWidth/2, screenHeight/2);

while true

% Draw the image
Screen('DrawTexture', window, imageTexture, [], destinationRect);

% Flip to the screen
Screen('Flip', window);
 
    [keyIsDown, ~, keyCode] = KbCheck;
    if keyIsDown
        % if strcmpi(KbName(keyCode), 'q') % Compare key pressed with 'q'
        %     break; % Exit the loop if 'q' is pressed
        % end
        break
    end

end

% Wait for a key press to exit
KbStrokeWait;

% Close the window
sca;