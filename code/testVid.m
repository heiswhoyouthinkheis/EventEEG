% Test video play

%% V1

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


