%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This code is created by Brian Yan (by2139@nyu.edu)
% And has been adapted for this course by Mrugank Dake
% (mrugank.dake@nyu.edu)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% [TODO 03/02/25] Fix Keyboard Problem
% Watch out for Screen Crash/Errors
% optimized experimenter display
% Made sure of the audio device

% [TODO 02/12/25] set up as a function so that it can be run from the
% terminal --
% counterbalancing argument input  --
% add day id so that the files saved in one day can be distinguished --
% access conditions in terminal  --
% change data storage directory  --
% recording device
% fix video latency --
% note that the audio data is mono --
% make words bigger --
% the first stimulus in the first part and the second part are identical --
% naming issues --
% video issues is likely due to initscreen, no GStreamer update? needs admin
% permission 
% must open matlab2020 from search bar
% change image --
% create control condition

% 02/12/25
% new edits:
% fixation cross is now automatically customized to fit the screen size
% first items are regular

% [TODO sometime ago] add "port" to function input for trigger sending --
% figure out stimulus choice --
%   odd words from two categories check----------------
% discuss stimulus presentation duration --
%   try to unify the trial length (stimulus + gap) check--------
% instructions for recall?
%   no.
% make sure that a word does not repeat too soon 
% check, now by 5--------------------
% for each task in each section, stimulus needs to be manually inputted
% the recorded file name is date+name+task+regular stimulus --

% average display time for semantic audio stimulus is 0.457740545
% average gap time is 1 sec
%

%---------trigger code-------------------------------------
% addpath('triggers');
% trigger code
% classicalau
% start = 1
% reg = 64, odd = 128

% visual semantic
% start = 2
% reg = 64, odd = 128

% audio semantic
% start = 4
% reg = 64, odd = 128

% story
% start = 8
% onset = 64, offset = 128

% rest 
% start and end = 256
%-----------trigger code----------------------------



% Running the (main vs. control) task.
% subject = numerical value to identify subjects run in the same day (1,
% 2,...)
% condition = counterbalancing condition codes (0 or 1)
function runTask(subject,ctBalanceCondition)

% Initialize Psychtoolbox and set up the experiment environment
close all; clc;

% Check if both arguments are missing
if nargin < 2
    error('Please enter both subject identifier and ctBalanceCondition code (0 or 1).');
end

% Validate subject (example: ensure it's non-empty)
if isempty(subject) || ~isnumeric(subject)
    error('subject must be a number(e.g., 1).');
end

% Validate ctctBalanceCondition
if ~ismember(ctBalanceCondition, [0, 1])
    error('Invalid ctBalanceCondition code. Use 0 or 1.');
end

% get the date of the experiment to add to file name later
date = datestr(now, 'yyyymmdd_HHMMSS');
date = date(1:8);

% define subjectID
subjectID = ['sub_' date '_' num2str(subject)];

% Rest of your experiment code
disp(['Running experiment for subject: ', subjectID]);
disp(['ctBalanceCondition: ', num2str(ctBalanceCondition)]);


% ---- !! Counterbalancing !! ---- 
% if 0, run catA, if 1, run catB
ctCondition = ctBalanceCondition;


% Check the system running on: currently accepted: syndrome, tmsubuntu
[ret, hostname] = system('hostname');
if ret ~= 0
    hostname = getenv('HOSTNAME');
end
hostname = strtrim(hostname);

if strcmp(hostname, 'Hardware') || strcmp(hostname, '10-17-200-14.dynapool.wireless.nyu.edu')
    addpath(genpath('"C:\Matfiles\Psychtoolbox"'))
    parameters.isDemoMode=true;
    Screen('Preference', 'SkipSyncTests', 1)
    Screen('Preference', 'VisualDebugLevel', 0);
    Screen('Preference', 'SuppressAllWarnings', 1);
    PsychDefaultSetup(2);
    parameters.viewingDistance = 55;
    devType = 'neither';   
    port = 0;
elseif strcmp(hostname, 'meg-stim-mac.psych.nyu.edu')
    addpath(genpath('/Applications/Psychtoolbox'))
    parameters.isDemoMode = false;
    Screen('Preference', 'SkipSyncTests', 1)
    PsychDefaultSetup(2);
    parameters.viewingDistance = 25; % check onceq
    devType = 'MEG';
elseif strcmp(hostname, 'visioncore01m.psych.nyu.edu')
    addpath(genpath('/Applications/Psychtoolbox'))
    addpath(genpath('/Users/michelmannlab/Documents/BioSemiTrigger'));
    port = init_trigger;
    parameters.isDemoMode = false;
    Screen('Preference', 'SkipSyncTests', 0)
    Screen('Preference', 'VisualDebugLevel', 0);
    PsychDefaultSetup(2);
    parameters.viewingDistance = 55; % check once
    devType = 'EEG';
end

stimDir = '../stimulus';

% ---------------------Screen names--------------------------------
% Experiment Window -- screen.win
% Main Mirroring Window -- screen.mirror

screen = initScreen(parameters, devType);

% ---------------------Screen names--------------------------------

% Set data storage directory
dataDir = fullfile('../timingData/', subjectID);

mkdir(dataDir)  

disp(['Data storage directory: ', dataDir])







% ---the following section imports all the audio files and store them
% under corresponding variables names to be used later

curr_dir = stimDir;

% curr_dir = "D:\Desktop\MemoryLab";

% port = init_trigger;




% [rev] this section is probably not needed since the stimuli for vis will
% be retrieved from the audio data names
%--visual semantic oddball setup start------------------------------

% read the file that contains all the word
% wordTable = readtable([curr_dir filesep 'EventModel' filesep 'selected_categories.xlsx']);
% Define the file path
% file_path = fullfile(curr_dir, 'stimuliSemantic', 'selected_categories.xlsx');
%
% % Read the table
% wordTable = readtable(file_path);
%
%
% % slice the matrix into lists
% animalsListV = wordTable.Animals;
% toolsListV = wordTable.Tools;
% bodyPartsListV = wordTable.BodyParts;

%-------visual semantic oddball setup end-----------------------------





disp('import audio files');

%-------auditory semantic oddball setup start---------------------------

% specify the path to the stimulus folder
stimFolder = fullfile(curr_dir,'audioData');


% Get the list of all items in the folder
allItems = dir(stimFolder);

% Filter out the folders (ignoring the '.' and '..' special folders)
allFolders = allItems([allItems.isdir] & ~ismember({allItems.name}, {'.', '..'}));

% Get the folder names
folderNames = {allFolders.name};

% % initialize the data structure that stores the categories and words
categories = struct();
%
% initialize the data structure that stores the audio data
audioDataDS = struct();

% load audio file for animals and store the list in categories and audio in
%   audioDataDS

for i = 1:numel(folderNames)
    name =  folderNames{i};
    [categories, audioDataDS] = importAudio(name, categories, audioDataDS, stimFolder);
    loadInfo = sprintf("finished loading %s", name);
    disp(loadInfo)
end


%-------auditory semantic oddball setup end---------------------------







%------story setup begin-----------------------------------------------

% Read the audio file for the story
% The story is sliced by the events, along with a cue "next passage" for
% the cued condition
% [storyAu, freq] = audioread([curr_dir filesep 'EventModel' filesep 'SecretLife.mp3']);

% [storyAu, freq] = audioread(fullfile(curr_dir, 'stimuliSemantic', 'test.mp3'));

storyDir = fullfile(curr_dir,'story');
storyAu = dir(fullfile(storyDir, '*.mp3'));
storyData = struct();
for i = 1:numel(storyAu)
    filePath = fullfile(storyDir, storyAu(i).name);
    [audioData, fs] = audioread(filePath);
    [~, fileName, ~] = fileparts(storyAu(i).name);
    storyData.(fileName) = audioData;
    %disp(['Loaded: ' animalsAu(i).name ' as ' fileName]);
end
%-------story setup end----------------------------------------------

disp('import finished');

% % Set up the fixation cross
% fixCrossDimPix = 40;
% xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
% yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
% allCoords = [xCoords; yCoords];
% lineWidthPix = 4;

% Set up the fixation cross (customized to the screen) 
fixCrossDimPix = screen.screenYpixels/27;
xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
allCoords = [xCoords; yCoords];
lineWidthPix = screen.screenYpixels/270;


%-----------visual display setup end---------------------------------



% Define audio device
if devType == "neither"
    audioDevice = PsychPortAudio('Open', [], 1, 1, [],1);
elseif devType == "EEG"
    FSMan = 24000;
    audioDevice = initAudioDevice('Anker SoundCore', 2, FSMan, 1);
end
% Set playback volume to 60%
PsychPortAudio('Volume', audioDevice, 0.6);

disp('audio setup finished')

% ----------basic audio setup end---------------------------------------


%--------basic stimulus sequence setup before the task------------------------------
% the following section slices "categories" into "catA" and "catB', where:
% catA	                      catB
% animal	              insect
% vegetable	      fruit
% occupation	      vehicle
% kitchenware	  tool
% weapon	          furniture
% officesupply	  clothing
% building	          sport
% bodypart	          instrument
% Just to stress, categories contains all the names of the categories,
% which contains all names of the words 

fields_catA = {"animal","vegetable","occupation","kitchenware","weapon","officesupply","building","bodypart"};
fields_catB ={"insect","fruit","vehicle","tool","furniture","clothing","sport","instrument"};

catA = struct();
catB = struct();

for i = 1:length(fields_catA)
    catA.(fields_catA{i}) = categories.(fields_catA{i});
end

for i = 1:length(fields_catB)
    catB.(fields_catB{i}) = categories.(fields_catB{i});
end


% decide which task will use which set of stimuli
if ctCondition == 0
    catAud = catA;
    catVis = catB;
elseif ctCondition == 1
    catAud = catB;
    catVis = catA;
else
    error('ctCondition must be 0 or 1.')
end

% select the stimuli for the 2*2 blocks
fieldAud = fieldnames(catAud); % get the fieldnames of the categories
fieldVis = fieldnames(catVis);

fieldAud = fieldAud(randperm(length(fieldAud)));
fieldVis = fieldVis(randperm(length(fieldVis)));

audBlk1 = struct();
audBlk2 = struct();
visBlk1 = struct();
visBlk2 = struct();

for i = 1:numel(fieldAud)/2
    audBlk1.(fieldAud{i}) = catAud.(fieldAud{i});
end

for i = numel(fieldAud)/2+1: numel(fieldAud)
    audBlk2.(fieldAud{i}) = catAud.(fieldAud{i});
end

for i = 1:numel(fieldVis)/2
    visBlk1.(fieldVis{i}) = catVis.(fieldVis{i});
end

for i = numel(fieldVis)/2+1: numel(fieldVis)
    visBlk2.(fieldVis{i}) = catVis.(fieldVis{i});
end



% for each block, split the stimuli into reg and odd
% store them into two ds,

% % access all fieldnames and group them by blocks (way1)
% fieldAud1 = fieldAud(1:4);
% fieldAud2 = fieldAud(5:8);
% fieldVis1 = fieldVis(1:4);
% fieldVis2 = fieldVis(5:8);

% access all fieldnames that are grouped by blocks (way2)
fieldAud1 = fieldnames(audBlk1);
fieldAud2 = fieldnames(audBlk2);
fieldVis1 = fieldnames(visBlk1);
fieldVis2 = fieldnames(visBlk2);

% first block auditory
reg = struct();
odd = struct();

[audSeq1, audLabels1] = stimSequence(reg,odd,fieldAud1, audBlk1);

% second block auditory
[audSeq2, audLabels2] = stimSequence(reg,odd,fieldAud2, audBlk2);

% first block visual
[visSeq1, visLabels1] = stimSequence(reg,odd,fieldVis1, visBlk1);

% second block visual
[visSeq2, visLabels2] = stimSequence(reg,odd,fieldVis2, visBlk2);


%------------------------------generate sequence for tones------------------
range1 = {"n200","n400","n600","n800"};
range2 = {"n300","n500","n700","n900"};

range1perm = range1(randperm(length(range1)));
range2perm = range2(randperm(length(range2)));

% decide which set of stimulus to run
% task names
if ctCondition == 0
    caBlk1 = range1perm;
    caBlk2 = range2perm;
elseif ctCondition == 1
    caBlk1 = range2perm;
    caBlk2 = range1perm;
else
    error('ctCondition must be 0 or 1.')
end


tones =struct('caBlk1', {caBlk1}, 'caBlk2', {caBlk2});

[seqAll] = toneSequence(tones);

disp('stimulus sequence created')

% ---------------------------Stimulus Sequence Set-------------------------------------------





% Generate stimulus sequence
% The repmat function replicates and tiles an array. In this case,
% it’s creating an array that consists of the string ‘A’ repeated numA
% times. The {} around ‘A’ is used to create a cell array containing the string ‘A’. The 1
% get the sequence representing two categories
% numA = 5 * 4; % Each word in set A is played 4 times
% numB = round(0.2 / 0.8 * numA); % Calculate number of B words to maintain 0.8 to 0.2 ratio
% sequence = [repmat({'A'}, 1, numA) repmat({'B'}, 1, numB)];
% sequence = sequence(randperm(length(sequence))); % Shuffle sequence
%
% % define the function handles
% tasks = {@classicalAud, @semanticVis, @semanticAud};
%
% % initialize cell array to store the name and order of the task
taskNames = {};
%
% disp('main setup finished')

%--------------------ALL SETUP FINISHED------------------------------

%-----------sequence testing-------------
% finalSequence = getSequence(sequence, animalsListA, bodyPartsListA, toolsListA);
















%--------------------START DISPLAY-----------------------------------


% Clear both windows before drawing new content
Screen('FillRect', screen.win, screen.white/2);
Screen('FillRect', screen.mirror, screen.white/2);

% Instructions
line = 'Press any key to initiate experiment. This may take a few seconds.';

% Draw instructions
DrawFormattedText(screen.win, line, 'center', 'center', screen.white);

% Flip to the screen
Screen('Flip', screen.win, [], 1);

% Copy the exp window to mirroring window and flip
Screen('CopyWindow', screen.win, screen.mirror);

Screen('Flip', screen.mirror);

KbStrokeWait;




% -----------display testing---------------------------------
% fields = fieldnames(audSeq1)
% field =fields{1}

% semanticAud(audSeq1.(field), audLabels1.(field), audioDataDS, fieldAud1, audBlk1, date, ...
% window, white, allCoords, lineWidthPix, xCenter, yCenter, audioDevice, taskNames);
%
% semanticVis(fieldVis1{1}, audSeq1.(field), audLabels1.(field),date, ...
%     window, white, allCoords, lineWidthPix, xCenter, yCenter, taskNames);  % Call visual task function
%
% sca;
% classicalAud('n400', seqAll.caBlk1.Sequences.('n400'), ...
%             seqAll.caBlk1.Labels.('n400'), date, window, white, allCoords, lineWidthPix, xCenter, yCenter, taskNames); % Call classical auditory
% sca;
% timingData = struct();
%
% [timingData, taskNames] = semanticAud(sequence, animalsListA, bodyPartsListA, toolsListA, date, ...
%     window, white, allCoords, lineWidthPix, xCenter, yCenter, audioDevice, taskNames);
% [timingDataAll{i}, taskNames] = semanticVis(sequence, animalsListV, toolsListV, bodyPartsListV, date, ...
%     window, white, allCoords, lineWidthPix, xCenter, yCenter, taskNames);
% [timingDataAll{i}, taskNames] = classicalAud(sequence, listHi, listLo, listMe, date, ...
%     window, white, allCoords, lineWidthPix, xCenter, yCenter, taskNames, 1);
% %
% sca;
%


% Main Script: Randomized Sequence Execution

% Step 1: Define tasks and sequences
% tasks = {'vt', 'vt', 'vt', 'vt', 'at', 'at', 'at', 'at'};  % Visual and Auditory Tasks
% sequences_vt = {vtSeq1, vtSeq2, vtSeq3, vtSeq4};  % Visual sequences (replace with actual sequence names)
% sequences_at = {atSeq1, atSeq2, atSeq3, atSeq4};  % Auditory sequences (replace with actual sequence names)
%  
% % the categories in the block
% seqFieldsA = fieldnames(audSeq1);
% seqFieldsV = fieldnames(visSeq1);
% disp(1)
% 
% % same as above
% labelsFieldsA = fieldnames(audLabels1);
% labelsFieldsV = fieldnames(visLabels1);
% disp(2)
% % categories in the block for ca
% seqFieldsCa = fieldnames(seqAll.caBlk1.Sequences);
% labelsFieldsCa = fieldnames(seqAll.caBlk1.Labels);
% disp(3)
% % Combine task types with corresponding sequences into a single structure
% task_sequence_blk = [
%     struct('task', 'vs', 'sequence', seqFieldsV{1}, 'labels', labelsFieldsV{1}, 'cat', fieldVis1{1}), ...
%     struct('task', 'vs', 'sequence', seqFieldsV{2}, 'labels', labelsFieldsV{2}, 'cat', fieldVis1{2}), ...
%     struct('task', 'vs', 'sequence', seqFieldsV{3}, 'labels', labelsFieldsV{3}, 'cat', fieldVis1{3}), ...
%     struct('task', 'vs', 'sequence', seqFieldsV{4}, 'labels', labelsFieldsV{4}, 'cat', fieldVis1{4}), ...
%     struct('task', 'as', 'sequence', seqFieldsA{1}, 'labels', labelsFieldsA{1}, 'cat', fieldAud1{1}), ...
%     struct('task', 'as', 'sequence', seqFieldsA{2}, 'labels', labelsFieldsA{2}, 'cat', fieldAud1{2}), ...
%     struct('task', 'as', 'sequence', seqFieldsA{3}, 'labels', labelsFieldsA{3}, 'cat', fieldAud1{3}), ...
%     struct('task', 'as', 'sequence', seqFieldsA{4}, 'labels', labelsFieldsA{4}, 'cat', fieldAud1{4}), ...
%     struct('task', 'ca', 'sequence', seqFieldsCa{1}, 'labels', labelsFieldsCa{1}, 'cat', []), ...
%     struct('task', 'ca', 'sequence', seqFieldsCa{2}, 'labels', labelsFieldsCa{2}, 'cat', []), ...
%     struct('task', 'ca', 'sequence', seqFieldsCa{3}, 'labels', labelsFieldsCa{3}, 'cat', []), ...
%     struct('task', 'ca', 'sequence', seqFieldsCa{4}, 'labels', labelsFieldsCa{4}, 'cat', []), ...
%     ];
% disp(4)
% % Randomize the order of tasks and sequences
% random_order = randperm(length(task_sequence_blk));  % Get random order
% 
% % Execute the tasks in random order
% for i = 1:length(random_order)
%     current_task = task_sequence_blk(random_order(i));
% 
% 
%     % Execute the appropriate task function based on the task type
%     if strcmp(current_task.task, 'vs')
%         semanticVis(current_task.cat, visSeq1.(current_task.sequence), visLabels1.(current_task.labels),date, ...
%             screen.win, screen.white, allCoords, lineWidthPix, screen.xCenter, screen.yCenter, taskNames, devType);  % Call visual semantic function
%     elseif strcmp(current_task.task, 'as')
%         semanticAud(current_task.cat, audSeq1.(current_task.sequence), audLabels1.(current_task.labels), audioDataDS, fieldAud1, audBlk1, date, ...
%             screen.win, screen.white, allCoords, lineWidthPix, screen.xCenter, screen.yCenter, audioDevice, taskNames, devType);  % Call auditory semantic function
%     elseif strcmp(current_task.task, 'ca')
%         classicalAud(current_task.sequence, seqAll.caBlk1.Sequences.(current_task.sequence), ...
%             seqAll.caBlk1.Labels.(current_task.labels), date, screen.win, screen.white, allCoords, lineWidthPix, screen.xCenter, screen.yCenter, taskNames, devType); % Call classical auditory
%     end
% end





%-------------------Section I---------------------------------------

% the categories in the block
seqFieldsA = fieldnames(audSeq1);
seqFieldsV = fieldnames(visSeq1);
disp(1)

% same as above
labelsFieldsA = fieldnames(audLabels1);
labelsFieldsV = fieldnames(visLabels1);
disp(2)
% categories in the block for ca
seqFieldsCa = fieldnames(seqAll.caBlk1.Sequences);
labelsFieldsCa = fieldnames(seqAll.caBlk1.Labels);
disp(3)
% Combine task types with corresponding sequences into a single structure
task_sequence_blk = [
    struct('task', 'vs', 'sequence', seqFieldsV{1}, 'labels', labelsFieldsV{1}, 'cat', fieldVis1{1}), ...
    struct('task', 'vs', 'sequence', seqFieldsV{2}, 'labels', labelsFieldsV{2}, 'cat', fieldVis1{2}), ...
    struct('task', 'vs', 'sequence', seqFieldsV{3}, 'labels', labelsFieldsV{3}, 'cat', fieldVis1{3}), ...
    struct('task', 'vs', 'sequence', seqFieldsV{4}, 'labels', labelsFieldsV{4}, 'cat', fieldVis1{4}), ...
    struct('task', 'as', 'sequence', seqFieldsA{1}, 'labels', labelsFieldsA{1}, 'cat', fieldAud1{1}), ...
    struct('task', 'as', 'sequence', seqFieldsA{2}, 'labels', labelsFieldsA{2}, 'cat', fieldAud1{2}), ...
    struct('task', 'as', 'sequence', seqFieldsA{3}, 'labels', labelsFieldsA{3}, 'cat', fieldAud1{3}), ...
    struct('task', 'as', 'sequence', seqFieldsA{4}, 'labels', labelsFieldsA{4}, 'cat', fieldAud1{4}), ...
    struct('task', 'ca', 'sequence', seqFieldsCa{1}, 'labels', labelsFieldsCa{1}, 'cat', seqFieldsCa{1}), ...
    struct('task', 'ca', 'sequence', seqFieldsCa{2}, 'labels', labelsFieldsCa{2}, 'cat', seqFieldsCa{2}), ...
    struct('task', 'ca', 'sequence', seqFieldsCa{3}, 'labels', labelsFieldsCa{3}, 'cat', seqFieldsCa{3}), ...
    struct('task', 'ca', 'sequence', seqFieldsCa{4}, 'labels', labelsFieldsCa{4}, 'cat', seqFieldsCa{4}), ...
    ];
disp(4)
% Randomize the order of tasks and sequences
random_order = randperm(length(task_sequence_blk));  % Get random order

% Execute the tasks in random order
for i = 1:length(random_order)
    current_task = task_sequence_blk(random_order(i));


    % Execute the appropriate task function based on the task type
    if strcmp(current_task.task, 'vs')
        semanticVis(current_task.cat, visSeq1.(current_task.sequence), visLabels1.(current_task.labels),subjectID, ...
            screen.win, screen.mirror, screen.white, allCoords, lineWidthPix, screen.xCenter, screen.yCenter, taskNames, devType, port, dataDir);  % Call visual semantic function
    elseif strcmp(current_task.task, 'as')
        semanticAud(current_task.cat, audSeq1.(current_task.sequence), audLabels1.(current_task.labels), audioDataDS, fieldAud1, audBlk1, subjectID, ...
            screen.win, screen.mirror, screen.white, allCoords, lineWidthPix, screen.xCenter, screen.yCenter, audioDevice, taskNames, devType, port, dataDir);  % Call auditory semantic function
    elseif strcmp(current_task.task, 'ca')
        classicalAud(current_task.cat, seqAll.caBlk1.Sequences.(current_task.sequence), ...
            seqAll.caBlk1.Labels.(current_task.labels), subjectID, screen.win, screen.mirror, screen.white, allCoords, lineWidthPix, screen.xCenter, screen.yCenter, taskNames, devType, port, dataDir); % Call classical auditory
    end
end

% Clean up
PsychPortAudio('Close', audioDevice);

disp("End of the block")


%------------------end of Section I------------------------------






















% ----------Section II------------------------------------------------

% Define audio device
if devType == "neither"
    audioDevice = PsychPortAudio('Open', [], 1, 1, [],2);
elseif devType == "EEG"
    FSMan = 44100;
    audioDevice = initAudioDevice('Anker SoundCore', 2, FSMan, 2);
end

% Set playback volume to 60%
PsychPortAudio('Volume', audioDevice, 0.6);

% Clear both windows before drawing new content
Screen('FillRect', screen.win, screen.white/2);
Screen('FillRect', screen.mirror, screen.white/2);

line1 = 'In the following task, you will listen to a story.';
line2 = '\n\n Press [space] to continue whenever you are ready.';

% Draw instructions
DrawFormattedText(screen.win, [line1 line2], 'center', 'center', screen.white);

% Flip to the screen
Screen('Flip', screen.win, [], 1);

% Copy the exp window to mirroring window and flip
Screen('CopyWindow', screen.win, screen.mirror);

Screen('Flip', screen.mirror);


% PsychPortAudio('FillBuffer', audioDevice, [storyAu']);

% Set the cell array that contains the sequence of audio to be played
%   (the field name for the cue audio is "Cue")
storySeq = {'Marine' 'Main1' 'Medical' 'Main2' 'Trial' 'Main3' 'War' 'Main4'};

% Test latency
% storySeq = {'Marine_edited', 'Main1_edited'};

% initialize ds to store timing structure
timingData3 = struct();

% Press any key to continue
KbStrokeWait;

% Clear both windows before drawing new content
Screen('FillRect', screen.win, screen.white/2);
Screen('FillRect', screen.mirror, screen.white/2);

% Draw fixation cross
if strcmp(devType, 'EEG')
    Screen('DrawLines', screen.win, allCoords, lineWidthPix, screen.white, [screen.xCenter, screen.yCenter], 2);
elseif strcmp(devType, 'MEG')
    Screen('DrawLines', screen.win, allCoords, lineWidthPix, screen.white, [screen.xCenter, screen.yCenter], 2);
else
    Screen('DrawLines', screen.win, allCoords, lineWidthPix, screen.white, [screen.xCenter, screen.yCenter]);
end
Screen('Flip', screen.win, [], 1);

% Copy the exp window to mirroring window and flip
Screen('CopyWindow', screen.win, screen.mirror);

Screen('Flip', screen.mirror);

disp("story started");

%--! send trigger ! --

if strcmp(devType, 'EEG')
    write(port, 8,"uint8");
elseif strcmp(devType, 'MEG')
    PTBSendTrigger(8,0);
else
    Beeper(2000)
end

%--! send trigger ! --

startTime = GetSecs;

% Start audio playback
%[, repetitions=1] [, when=0] [, waitForStart=1] (so it records the actual
% onset time)

for i = 1:numel(storySeq)

    % get event name
    event = storySeq{i};

    % get audio
    audioData = storyData.(event);

    PsychPortAudio('FillBuffer', audioDevice, audioData');

    % write(port, current_code,"uint8");
    
    disp(event);
    
    %--! send trigger ! --

    if strcmp(devType, 'EEG')
        write(port, 16,"uint8");
    elseif strcmp(devType, 'MEG')
        PTBSendTrigger(16,0);
    else
        Beeper(2000)
    end

    %--! send trigger ! --
    
    % Start audio and record onset time
    onsetTime = PsychPortAudio('Start', audioDevice, 1, 0, 1);


    % Wait for the audio to finish
    PsychPortAudio('Stop', audioDevice, 1, 1);


    % get offset time
    offsetTime = GetSecs();


    onsetTime = onsetTime - startTime;
    offsetTime = offsetTime - startTime;


    % onsetTime = PsychPortAudio('Start', audioDevice, 1, 0, 1);
    %
    % % Wait for the audio to finish
    % offsetTime = PsychPortAudio('Stop', audioDevice, 1, 1);
    %

    % Record duration time
    duration = offsetTime-onsetTime;

    timingData3(i).event = event;
    timingData3(i).onsetTime = onsetTime;
    timingData3(i).offsetTime = offsetTime;
    timingData3(i).duration = duration;

end

disp("story ended");

% dateStringBlah = datestr(now, 'yyyymmdd_HHMMSS');

filename = sprintf('%s_timingData_%s.mat', subjectID, 'story1');

dirToSave = fullfile(dataDir, 'story');

mkdir(dirToSave)  

filename = fullfile(dirToSave, filename);
% Save timing data to a .mat file
save(filename, 'timingData3');

% Clean up
PsychPortAudio('Close', audioDevice);

disp("End of the block")

%------------end of Section II--------------------------------------



























%-------------------Section III----------------------------------

% Define audio device
if devType == "neither"
    audioDevice = PsychPortAudio('Open', [], 1, 1, [],2);
elseif devType == "EEG"
    FSMan = 24000;
    audioDevice = initAudioDevice('Anker SoundCore', 2, FSMan, 1);
end

% Set playback volume to 60%
PsychPortAudio('Volume', audioDevice, 0.6);

% the categories in the block
seqFieldsA = fieldnames(audSeq1);
seqFieldsV = fieldnames(visSeq1);
disp(1)

% same as above
labelsFieldsA = fieldnames(audLabels1);
labelsFieldsV = fieldnames(visLabels1);
disp(2)
% categories in the block for ca
seqFieldsCa = fieldnames(seqAll.caBlk1.Sequences);
labelsFieldsCa = fieldnames(seqAll.caBlk1.Labels);
disp(3)
% Combine task types with corresponding sequences into a single structure
task_sequence_blk = [
    struct('task', 'vs', 'sequence', seqFieldsV{1}, 'labels', labelsFieldsV{1}, 'cat', strcat(fieldVis1{1}, "_b")), ...
    struct('task', 'vs', 'sequence', seqFieldsV{2}, 'labels', labelsFieldsV{2}, 'cat', strcat(fieldVis1{2}, "_b")), ...
    struct('task', 'vs', 'sequence', seqFieldsV{3}, 'labels', labelsFieldsV{3}, 'cat', strcat(fieldVis1{3}, "_b")), ...
    struct('task', 'vs', 'sequence', seqFieldsV{4}, 'labels', labelsFieldsV{4}, 'cat', strcat(fieldVis1{4}, "_b")) ...
    struct('task', 'as', 'sequence', seqFieldsA{1}, 'labels', labelsFieldsA{1}, 'cat', strcat(fieldAud1{1}, "_b")), ...
    struct('task', 'as', 'sequence', seqFieldsA{2}, 'labels', labelsFieldsA{2}, 'cat', strcat(fieldAud1{2}, "_b")), ...
    struct('task', 'as', 'sequence', seqFieldsA{3}, 'labels', labelsFieldsA{3}, 'cat', strcat(fieldAud1{3}, "_b")), ...
    struct('task', 'as', 'sequence', seqFieldsA{4}, 'labels', labelsFieldsA{4}, 'cat', strcat(fieldAud1{4}, "_b")), ...
    struct('task', 'ca', 'sequence', seqFieldsCa{1}, 'labels', labelsFieldsCa{1}, 'cat', strcat(seqFieldsCa{1}, "_b")), ...
    struct('task', 'ca', 'sequence', seqFieldsCa{2}, 'labels', labelsFieldsCa{2}, 'cat', strcat(seqFieldsCa{2}, "_b")), ...
    struct('task', 'ca', 'sequence', seqFieldsCa{3}, 'labels', labelsFieldsCa{3}, 'cat', strcat(seqFieldsCa{3}, "_b")), ...
    struct('task', 'ca', 'sequence', seqFieldsCa{4}, 'labels', labelsFieldsCa{4}, 'cat', strcat(seqFieldsCa{4}, "_b")), ...
    ];
disp(4)
% Randomize the order of tasks and sequences
random_order = randperm(length(task_sequence_blk));  % Get random order

% Execute the tasks in random order
for i = 1:length(random_order)
    current_task = task_sequence_blk(random_order(i));


    % Execute the appropriate task function based on the task type
    if strcmp(current_task.task, 'vs')
        semanticVis(current_task.cat, visSeq1.(current_task.sequence), visLabels1.(current_task.labels),subjectID, ...
            screen.win, screen.mirror, screen.white, allCoords, lineWidthPix, screen.xCenter, screen.yCenter, taskNames, devType, port, dataDir);  % Call visual semantic function
    elseif strcmp(current_task.task, 'as')
        semanticAud(current_task.cat, audSeq1.(current_task.sequence), audLabels1.(current_task.labels), audioDataDS, fieldAud1, audBlk1, subjectID, ...
            screen.win, screen.mirror, screen.white, allCoords, lineWidthPix, screen.xCenter, screen.yCenter, audioDevice, taskNames, devType, port, dataDir);  % Call auditory semantic function
    elseif strcmp(current_task.task, 'ca')
        classicalAud(current_task.cat, seqAll.caBlk1.Sequences.(current_task.sequence), ...
            seqAll.caBlk1.Labels.(current_task.labels), subjectID, screen.win, screen.mirror, screen.white, allCoords, lineWidthPix, screen.xCenter, screen.yCenter, taskNames, devType, port, dataDir); % Call classical auditory
    end
end

% Clean up
PsychPortAudio('Close', audioDevice);

disp("End of the block")


%-----------------end of Section III---------------------------










%--------------------rest--------------------------------------------
%--! send trigger ! --

if strcmp(devType, 'EEG')
    write(port, 256,"uint8");
elseif strcmp(devType, 'MEG')
    PTBSendTrigger(256,0);
else
    Beeper(2000)
end

%--! send trigger ! --

disp("rest started")


% Clear both windows before drawing new content
Screen('FillRect', screen.win, screen.white/2);
Screen('FillRect', screen.mirror, screen.white/2);

% Instructions
line1 = 'Good job! You have completed the first part of the task. Please feel free to take a five-minute break. .';
line2 = '\n\n During the break, please sit quietly with your eyes remaining open.';
line3 = '\n\n A painting will be shown during the break. It will disappear after five minutes,'; 
line4 = '\n\n after which you can resume the to the task. Feel free to press [space] to proceed to the video.';

% Draw instructions
DrawFormattedText(screen.win, [line1 line2 line3 line4], 'center', 'center', screen.white);

% Flip to the screen
Screen('Flip', screen.win, [], 1);

% Copy the exp window to mirroring window and flip
Screen('CopyWindow', screen.win, screen.mirror);

Screen('Flip', screen.mirror);

KbStrokeWait;


% display image-------------------------------------------------

% Load the image
imagePath = fullfile(pwd, '../stimulus/images/boat_sky.jpg'); 
image = imread(imagePath);
imageHeight = size(image, 1);
imageWidth = size(image, 2);

% Calculate the scaling factor to fill the screen while maintaining aspect ratio
screenAspectRatio = screen.screenXpixels / screen.screenYpixels;
imageAspectRatio = imageWidth / imageHeight;

if imageAspectRatio > screenAspectRatio
    % Image is wider than the screen; scale based on height
    scaleFactor = screen.screenYpixels / imageHeight;
else
    % Image is taller than the screen; scale based on width
    scaleFactor = screen.screenXpixels / imageWidth;
end

% Scale the image dimensions
scaledWidth = imageWidth * scaleFactor;
scaledHeight = imageHeight * scaleFactor;

% Create a texture from the image
imageTexture = Screen('MakeTexture', screen.win, image);

% Calculate the destination rectangle for the image
destinationRect = CenterRectOnPointd([0 0 scaledWidth scaledHeight], screen.screenXpixels/2, screen.screenYpixels/2);

% Clear both windows before drawing new content
Screen('FillRect', screen.win, screen.white/2);
Screen('FillRect', screen.mirror, screen.white/2);

% Draw the image
Screen('DrawTexture', screen.win, imageTexture, [], destinationRect);

Screen('Flip', screen.win)


% Get the duration for which the video should play (in seconds)
playDuration = 300; % 300s, 5 mins

startTime = GetSecs; 

% % Initialize key variables *BEFORE* the loop
% keyIsDown = false; % Initialize to false (no key pressed initially)
% keyCode = zeros(1, 256); % Initialize keyCode (size depends on your keyboard)

while (GetSecs - startTime) < playDuration


    % disp('debug')
    % % Check if 'q' is pressed (case-insensitive)
    % Check for a key press
    [keyIsDown, ~, keyCode] = KbCheck;
    if keyIsDown
        if strcmpi(KbName(keyCode), 'q') % Compare key pressed with 'q'
            break; % Exit the loop if 'q' is pressed
        end
        % break
    end

end

% end of image display------------------------------



% 
% 
% % play vid------------------
% 
% % Get the duration for which the video should play (in seconds)
% playDuration = 20; % Change this to desired duration
% 
% % Get the movie file
% % Define audio device
% if devType == "neither"
%     movieFile = fullfile(pwd, '../stimulus/videos/galaxy.mp4'); 
% elseif devType == "EEG"
%     movieFile = fullfile(pwd, '../stimulus/videos/galaxy.mp4');
% end
% 
% 
% 
% % Open the movie file with additional parameters
% async = 1;
% preloadSecs = [];
% specialFlags1 = 0;
% pixelFormat = 4;
% maxNumberThreads = -1;
% movieOptions = [];
% 
% movie = Screen('OpenMovie', screen.win, movieFile, async, preloadSecs, specialFlags1, pixelFormat, maxNumberThreads, movieOptions);
% 
% WaitSecs(0.5);
% 
% % Start playback engine
% Screen('PlayMovie', movie, 1,1); 
% 
% % Get the start time
% startTime = GetSecs;
% 
% % % Initialize key variables *BEFORE* the loop
% % keyIsDown = false; % Initialize to false (no key pressed initially)
% % keyCode = zeros(1, 256); % Initialize keyCode (size depends on your keyboard)
% 
% % Loop the video until the time is up
% while (GetSecs - startTime) < playDuration
%     % Check for new frame
%     tex = Screen('GetMovieImage', screen.win, movie,1);
% 
%     % disp('debug')
%     % % Check if 'q' is pressed (case-insensitive)
%     % if keyIsDown
%     %     if strcmpi(KbName(keyCode), 'q') % Compare key pressed with 'q'
%     %         break; % Exit the loop if 'q' is pressed
%     %     end
%     % end
% 
%     % If there is a new frame, draw it
%     if tex > 0
%         Screen('DrawTexture', screen.win, tex);
%         Screen('Flip', screen.win);
%         Screen('Close', tex);
%     else
%         WaitSecs(0.001); % Add a small delay if no frame is ready
%     end
% end
% 
% 
% 
% % Stop playback
% Screen('PlayMovie', movie, 0);
% 
% % Close the movie
% Screen('CloseMovie', movie);
% % end of vid-----------
% 



% Clear both windows before drawing new content
Screen('FillRect', screen.win, screen.white/2);
Screen('FillRect', screen.mirror, screen.white/2);

% Instructions
line = 'Ready? Press [space] to continue to the second part of the experiment.';

% Draw instructions
DrawFormattedText(screen.win, line, 'center', 'center', screen.white);

% Flip to the screen
Screen('Flip', screen.win, [], 1);

% Copy the exp window to mirroring window and flip
Screen('CopyWindow', screen.win, screen.mirror);

Screen('Flip', screen.mirror);

KbStrokeWait;

%--! send trigger ! --

if strcmp(devType, 'EEG')
    write(port, 256,"uint8");
elseif strcmp(devType, 'MEG')
    PTBSendTrigger(256,0);
else
    Beeper(2000)
end

%--! send trigger ! --

disp("rest ended")

%--------------------rest--------------------------------------------

 


 







% -------------------begin section IV---------------------------------------

% Define audio device
if devType == "neither"
    audioDevice = PsychPortAudio('Open', [], 1, 1, [],2);
elseif devType == "EEG"
    FSMan = 24000;
    audioDevice = initAudioDevice('Anker SoundCore', 2, FSMan, 1);
end
% Set playback volume to 60%
PsychPortAudio('Volume', audioDevice, 0.6);

disp('audio setup finished')

% the categories in the block
seqFieldsA = fieldnames(audSeq2);
seqFieldsV = fieldnames(visSeq2);
disp(1)

% same as above
labelsFieldsA = fieldnames(audLabels2);
labelsFieldsV = fieldnames(visLabels2);
disp(2)
% categories in the block for ca
seqFieldsCa = fieldnames(seqAll.caBlk2.Sequences);
labelsFieldsCa = fieldnames(seqAll.caBlk2.Labels);
disp(3)
% Combine task types with corresponding sequences into a single structure
task_sequence_blk = [
    struct('task', 'vs', 'sequence', seqFieldsV{1}, 'labels', labelsFieldsV{1}, 'cat', fieldVis2{1}), ...
    struct('task', 'vs', 'sequence', seqFieldsV{2}, 'labels', labelsFieldsV{2}, 'cat', fieldVis2{2}), ...
    struct('task', 'vs', 'sequence', seqFieldsV{3}, 'labels', labelsFieldsV{3}, 'cat', fieldVis2{3}), ...
    struct('task', 'vs', 'sequence', seqFieldsV{4}, 'labels', labelsFieldsV{4}, 'cat', fieldVis2{4}), ...
    struct('task', 'as', 'sequence', seqFieldsA{1}, 'labels', labelsFieldsA{1}, 'cat', fieldAud2{1}), ...
    struct('task', 'as', 'sequence', seqFieldsA{2}, 'labels', labelsFieldsA{2}, 'cat', fieldAud2{2}), ...
    struct('task', 'as', 'sequence', seqFieldsA{3}, 'labels', labelsFieldsA{3}, 'cat', fieldAud2{3}), ...
    struct('task', 'as', 'sequence', seqFieldsA{4}, 'labels', labelsFieldsA{4}, 'cat', fieldAud2{4}), ...
    struct('task', 'ca', 'sequence', seqFieldsCa{1}, 'labels', labelsFieldsCa{1}, 'cat', seqFieldsCa{1}), ...
    struct('task', 'ca', 'sequence', seqFieldsCa{2}, 'labels', labelsFieldsCa{2}, 'cat', seqFieldsCa{2}), ...
    struct('task', 'ca', 'sequence', seqFieldsCa{3}, 'labels', labelsFieldsCa{3}, 'cat', seqFieldsCa{3}), ...
    struct('task', 'ca', 'sequence', seqFieldsCa{4}, 'labels', labelsFieldsCa{4}, 'cat', seqFieldsCa{4}), ...
    ];
disp(4)
% Randomize the order of tasks and sequences
random_order = randperm(length(task_sequence_blk));  % Get random order

% Execute the tasks in random order
for i = 1:length(random_order)
    current_task = task_sequence_blk(random_order(i));


    % Execute the appropriate task function based on the task type
    if strcmp(current_task.task, 'vs')
        semanticVis(current_task.cat, visSeq2.(current_task.sequence), visLabels2.(current_task.labels),subjectID, ...
            screen.win, screen.mirror, screen.white, allCoords, lineWidthPix, screen.xCenter, screen.yCenter, taskNames, devType, port, dataDir);  % Call visual semantic function
    elseif strcmp(current_task.task, 'as')
        semanticAud(current_task.cat, audSeq2.(current_task.sequence), audLabels2.(current_task.labels), audioDataDS, fieldAud2, audBlk2, subjectID, ...
            screen.win, screen.mirror, screen.white, allCoords, lineWidthPix, screen.xCenter, screen.yCenter, audioDevice, taskNames, devType, port, dataDir);  % Call auditory semantic function
    elseif strcmp(current_task.task, 'ca')
        classicalAud(current_task.cat, seqAll.caBlk2.Sequences.(current_task.sequence), ...
            seqAll.caBlk2.Labels.(current_task.labels), subjectID, screen.win, screen.mirror, screen.white, allCoords, lineWidthPix, screen.xCenter, screen.yCenter, taskNames, devType, port, dataDir); % Call classical auditory
    end
end

% Clean up
PsychPortAudio('Close', audioDevice);

disp("End of the block")


%----------------end of section IV---------------------------------












%------------------start of Section V-----------------------------------

% Define audio device
if devType == "neither"
    audioDevice = PsychPortAudio('Open', [], 1, 1, [],2);
elseif devType == "EEG"
    FSMan = 44100;
    audioDevice = initAudioDevice('Anker SoundCore', 2, FSMan, 2);
end

% Set playback volume to 60%
PsychPortAudio('Volume', audioDevice, 0.6);

% Clear both windows before drawing new content
Screen('FillRect', screen.win, screen.white/2);
Screen('FillRect', screen.mirror, screen.white/2);

line1 = 'In the following task, you will listen to the story again.';
line2 = '\n\n Press [space] to continue whenever you are ready.';

% Draw instructions
DrawFormattedText(screen.win, [line1 line2], 'center', 'center', screen.white);

% Flip to the screen
Screen('Flip', screen.win, [], 1);

% Copy the exp window to mirroring window and flip
Screen('CopyWindow', screen.win, screen.mirror);

Screen('Flip', screen.mirror);




% Define audio device (no need since no clean up in the previous section)
% audioDevice = PsychPortAudio('Open', [], 1, 1, [], 2);

% Set playback volume to 60%
PsychPortAudio('Volume', audioDevice, 0.6);


% PsychPortAudio('FillBuffer', audioDevice, [storyAu']);

% Set the cell array that contains the sequence of audio to be played
%   (the field name for the cue audio is "Cue")
storySeq = {'Marine' 'Main1' 'Medical' 'Main2' 'Trial' 'Main3' 'War' 'Main4'};

% initialize ds to store timing structure
timingData3 = struct();

% Press any key to continue
KbStrokeWait;

% Clear both windows before drawing new content
Screen('FillRect', screen.win, screen.white/2);
Screen('FillRect', screen.mirror, screen.white/2);

% Draw fixation cross
if strcmp(devType, 'EEG')
    Screen('DrawLines', screen.win, allCoords, lineWidthPix, screen.white, [screen.xCenter, screen.yCenter], 2);
elseif strcmp(devType, 'MEG')
    Screen('DrawLines', screen.win, allCoords, lineWidthPix, screen.white, [screen.xCenter, screen.yCenter], 2);
else
    Screen('DrawLines', screen.win, allCoords, lineWidthPix, screen.white, [screen.xCenter, screen.yCenter]);
end
Screen('Flip', screen.win, [], 1);

% Copy the exp window to mirroring window and flip
Screen('CopyWindow', screen.win, screen.mirror);

Screen('Flip', screen.mirror);

disp("story started")

%--! send trigger ! --

if strcmp(devType, 'EEG')
    write(port, 8,"uint8");
elseif strcmp(devType, 'MEG')
    PTBSendTrigger(8,0);
else
    Beeper(2000)
end

%--! send trigger ! --

startTime = GetSecs;

% Start audio playback
%[, repetitions=1] [, when=0] [, waitForStart=1] (so it records the actual
% onset time)

for i = 1:numel(storySeq)

    % get event name
    event = storySeq{i};

    % get audio
    audioData = storyData.(event);

    PsychPortAudio('FillBuffer', audioDevice, audioData');

    % write(port, current_code,"uint8");
    
    disp(event)
    
    %--! send trigger ! --

    if strcmp(devType, 'EEG')
        write(port, 16,"uint8");
    elseif strcmp(devType, 'MEG')
        PTBSendTrigger(16,0);
    else
        Beeper(2000)
    end

    %--! send trigger ! --
    
    % Start audio and record onset time
    onsetTime = PsychPortAudio('Start', audioDevice, 1, 0, 1);


    % Wait for the audio to finish
    PsychPortAudio('Stop', audioDevice, 1, 1);


    % get offset time
    offsetTime = GetSecs();


    onsetTime = onsetTime - startTime;
    offsetTime = offsetTime - startTime;


    % onsetTime = PsychPortAudio('Start', audioDevice, 1, 0, 1);
    %
    % % Wait for the audio to finish
    % offsetTime = PsychPortAudio('Stop', audioDevice, 1, 1);
    %

    % Record duration time
    duration = offsetTime-onsetTime;

    timingData3(i).event = event;
    timingData3(i).onsetTime = onsetTime;
    timingData3(i).offsetTime = offsetTime;
    timingData3(i).duration = duration;

end

disp("story ended")

dateStringBlah = datestr(now, 'yyyymmdd_HHMMSS');

filename = sprintf('%s_timingData_%s.mat', subjectID, 'story2');

dirToSave = fullfile(dataDir, 'story');

mkdir(dirToSave)  

filename = fullfile(dirToSave, filename)
% Save timing data to a .mat file
save(filename, 'timingData3');

% Clean up
PsychPortAudio('Close', audioDevice);

disp("End of the block")



%-------------------end of Section V--------------------------



















%--------------------Section VI---------------------------------------
% Define audio device
if devType == "neither"
    audioDevice = PsychPortAudio('Open', [], 1, 1, [],2);
elseif devType == "EEG"
    FSMan = 24000;
    audioDevice = initAudioDevice('Anker SoundCore', 2, FSMan, 1);
end

% Set playback volume to 60%
PsychPortAudio('Volume', audioDevice, 0.6);

% the categories in the block
seqFieldsA = fieldnames(audSeq2);
seqFieldsV = fieldnames(visSeq2);
disp(1)

% same as above
labelsFieldsA = fieldnames(audLabels2);
labelsFieldsV = fieldnames(visLabels2);
disp(2)
% categories in the block for ca
seqFieldsCa = fieldnames(seqAll.caBlk2.Sequences);
labelsFieldsCa = fieldnames(seqAll.caBlk2.Labels);
disp(3)
% Combine task types with corresponding sequences into a single structure
task_sequence_blk = [
    struct('task', 'vs', 'sequence', seqFieldsV{1}, 'labels', labelsFieldsV{1}, 'cat', strcat(fieldVis2{1}, "_b")), ...
    struct('task', 'vs', 'sequence', seqFieldsV{2}, 'labels', labelsFieldsV{2}, 'cat', strcat(fieldVis2{2}, "_b")), ...
    struct('task', 'vs', 'sequence', seqFieldsV{3}, 'labels', labelsFieldsV{3}, 'cat', strcat(fieldVis2{3}, "_b")), ...
    struct('task', 'vs', 'sequence', seqFieldsV{4}, 'labels', labelsFieldsV{4}, 'cat', strcat(fieldVis2{4}, "_b")), ...
    struct('task', 'as', 'sequence', seqFieldsA{1}, 'labels', labelsFieldsA{1}, 'cat', strcat(fieldAud2{1}, "_b")), ...
    struct('task', 'as', 'sequence', seqFieldsA{2}, 'labels', labelsFieldsA{2}, 'cat', strcat(fieldAud2{2}, "_b")), ...
    struct('task', 'as', 'sequence', seqFieldsA{3}, 'labels', labelsFieldsA{3}, 'cat', strcat(fieldAud2{3}, "_b")), ...
    struct('task', 'as', 'sequence', seqFieldsA{4}, 'labels', labelsFieldsA{4}, 'cat', strcat(fieldAud2{4}, "_b")), ...
    struct('task', 'ca', 'sequence', seqFieldsCa{1}, 'labels', labelsFieldsCa{1}, 'cat', strcat(seqFieldsCa{1}, "_b")), ...
    struct('task', 'ca', 'sequence', seqFieldsCa{2}, 'labels', labelsFieldsCa{2}, 'cat', strcat(seqFieldsCa{2}, "_b")), ...
    struct('task', 'ca', 'sequence', seqFieldsCa{3}, 'labels', labelsFieldsCa{3}, 'cat', strcat(seqFieldsCa{3}, "_b")), ...
    struct('task', 'ca', 'sequence', seqFieldsCa{4}, 'labels', labelsFieldsCa{4}, 'cat', strcat(seqFieldsCa{4}, "_b")), ...
    ];
disp(4)
% Randomize the order of tasks and sequences
random_order = randperm(length(task_sequence_blk));  % Get random order

% Execute the tasks in random order
for i = 1:length(random_order)
    current_task = task_sequence_blk(random_order(i));


    % Execute the appropriate task function based on the task type
    if strcmp(current_task.task, 'vs')
        semanticVis(current_task.cat, visSeq2.(current_task.sequence), visLabels2.(current_task.labels),subjectID, ...
            screen.win, screen.mirror, screen.white, allCoords, lineWidthPix, screen.xCenter, screen.yCenter, taskNames, devType, port, dataDir);  % Call visual semantic function
    elseif strcmp(current_task.task, 'as')
        semanticAud(current_task.cat, audSeq2.(current_task.sequence), audLabels2.(current_task.labels), audioDataDS, fieldAud2, audBlk2, subjectID, ...
            screen.win, screen.mirror, screen.white, allCoords, lineWidthPix, screen.xCenter, screen.yCenter, audioDevice, taskNames, devType, port, dataDir);  % Call auditory semantic function
    elseif strcmp(current_task.task, 'ca')
        classicalAud(current_task.cat, seqAll.caBlk2.Sequences.(current_task.sequence), ...
            seqAll.caBlk2.Labels.(current_task.labels), subjectID, screen.win, screen.mirror, screen.white, allCoords, lineWidthPix, screen.xCenter, screen.yCenter, taskNames, devType, port, dataDir); % Call classical auditory
    end
end

% Clean up
PsychPortAudio('Close', audioDevice);

disp("End of the block")


%----------------end of Section VI-----------------------------------







disp("End of all blocks. Now go in and set up recorder for recall.")



filename = sprintf('%s_taskOrder.mat', subjectID);

dirToSave = dataDir;
  
filename = fullfile(dirToSave, filename);
save(filename,'taskNames')

% Clear both windows before drawing new content
Screen('FillRect', screen.win, screen.white/2);
Screen('FillRect', screen.mirror, screen.white/2);

line1 = 'Great job! You have come to the last part of the experiment.';
line2 = '\n\n Before we proceed, please wait for the experimenter to set up the equipment for this part.';
line3 = '\n\n Please do not press any key unless instructed by the experimenter.';

% Draw instructions
DrawFormattedText(screen.win, [line1 line2 line3], 'center', screen.screenYpixels * 0.35, screen.white);

% Flip to the screen
Screen('Flip', screen.win, [], 1);

% Copy the exp window to mirroring window and flip
Screen('CopyWindow', screen.win, screen.mirror);

Screen('Flip', screen.mirror);


% Press any key to continue
KbStrokeWait;

% Clear both windows before drawing new content
Screen('FillRect', screen.win, screen.white/2);
Screen('FillRect', screen.mirror, screen.white/2);

% Page for accidental pressing.
line1 = 'BACK UP SLIDE FOR ACCIDENTS!';
line2 = '\n\n DO NOT PROCEED UNLESS INSTRUCTED SO!';

% Draw instructions
DrawFormattedText(screen.win, [line1 line2], 'center', screen.screenYpixels * 0.5, screen.white);

% Flip to the screen
Screen('Flip', screen.win, [], 1);

% Copy the exp window to mirroring window and flip
Screen('CopyWindow', screen.win, screen.mirror);

Screen('Flip', screen.mirror);

% Press any key to continue
KbStrokeWait;

% Clear both windows before drawing new content
Screen('FillRect', screen.win, screen.white/2);
Screen('FillRect', screen.mirror, screen.white/2);

% Instructions
line1 = 'In the next section, you will be asked to recall the story verbally in detail.';
line2 = '\n\n You have 15 seconds to prepare. Please start the verbal recall after you hear the "Beep".';
line3 = '\n\n The countdown will start in 2 seconds';
% Draw instructions
DrawFormattedText(screen.win, [line1 line2 line3], 'center', screen.screenYpixels * 0.35, screen.white);

% Flip to the screen
Screen('Flip', screen.win, [], 1);

% Copy the exp window to mirroring window and flip
Screen('CopyWindow', screen.win, screen.mirror);

Screen('Flip', screen.mirror);

% wait
WaitSecs(5);

% Determine the width of the rectangles
wid = 50;

% Make a base Rect of 200 by 200 pixels.
baseRect = [0 0 wid wid];

% Number of triangles
numRects = 15;

% Compute the total width 
totalWidth = numRects*wid;

% Initial position of the rectangle
initPos = screen.xCenter - totalWidth / 2 + wid / 2;

for i = 1:numRects

    for j = 1:i    
    
    currentRect = CenterRectOnPointd(baseRect, initPos + (j-1) * wid, screen.screenYpixels*0.75);
    
    Screen('FillRect', screen.win, [1 1 1], currentRect);
    
    end
    
% Clear both windows before drawing new content
Screen('FillRect', screen.win, screen.white/2);
Screen('FillRect', screen.mirror, screen.white/2);    
    
% Instructions
line1 = 'In the next section, you will be asked to recall the story verbally in detail';
line2 = '\n\n You have 15 seconds to prepare. Please start the verbal recall after you hear the "Beep".';

% Draw instructions
DrawFormattedText(screen.win, [line1 line2], 'center', screen.screenYpixels * 0.35, screen.white);

Screen('Flip', screen.win, [], 1);

% Copy the exp window to mirroring window and flip
Screen('CopyWindow', screen.win, screen.mirror);

Screen('Flip', screen.mirror);

WaitSecs(1);

end

% Clear both windows before drawing new content
Screen('FillRect', screen.win, screen.white/2);
Screen('FillRect', screen.mirror, screen.white/2);

% Draw fixation cross
if strcmp(devType, 'EEG')
    Screen('DrawLines', screen.win, allCoords, lineWidthPix, screen.white, [screen.xCenter, screen.yCenter], 2);
elseif strcmp(devType, 'MEG')
    Screen('DrawLines', screen.win, allCoords, lineWidthPix, screen.white, [screen.xCenter, screen.yCenter], 2);
else
    Screen('DrawLines', screen.win, allCoords, lineWidthPix, screen.white, [screen.xCenter, screen.yCenter]);
end
Screen('Flip', screen.win, [], 1);

Beeper(2000)

%--! send trigger ! --

if strcmp(devType, 'EEG')
    write(port, 512,"uint8");
elseif strcmp(devType, 'MEG')
    PTBSendTrigger(512,0);
else
    Beeper(2000)
end

%--! send trigger ! --

KbStrokeWait;

% Clear both windows before drawing new content
Screen('FillRect', screen.win, screen.white/2);
Screen('FillRect', screen.mirror, screen.white/2);

% Instructions
line1 = 'You have reached the end of the experiment. Thank you for your participation.';

% Draw instructions
DrawFormattedText(screen.win, [line1], 'center', screen.screenYpixels * 0.5, screen.white);

Screen('Flip', screen.win, [], 1);

% Copy the exp window to mirroring window and flip
Screen('CopyWindow', screen.win, screen.mirror);

Screen('Flip', screen.mirror);



KbStrokeWait;
sca;


end