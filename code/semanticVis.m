%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This code is created by Brian Yan (by2139@nyu.edu)
% And has been adapted for this course.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% runs the stimlus sequence for semantic visual oddball task
% it takes as arguments
% cat = the single category for the current stimulus
% seq = the stimulus sequence
% labels = the label sequence
% seq = the stimulus sequence based on categories created previously
% date = date of today (yyyymmdd) specified previouisly

% the following arguments are general

function [timingData, taskNames] = semanticVis(cat, seq, labels, ...
    subjectID, window, mirror, white, allCoords, lineWidthPix, xCenter, yCenter, taskNames, devType, port, dataDir)

% Draw loading instruction to wait for sequence creation
line = 'loading ...';

% Clear both windows before drawing new content
Screen('FillRect', window, white/2);
Screen('FillRect', mirror, white/2);

DrawFormattedText(window, line, 'center', 'center', white);
Screen('Flip', window, [], 1);

% Copy the main window to the mirror and flip it
Screen('CopyWindow', window, mirror);
Screen('Flip', mirror);

category = cat;

disp("semanticVis starting")

% Clear both windows before drawing new content
Screen('FillRect', window, white/2);
Screen('FillRect', mirror, white/2);

line1 = 'In this task, you will be visually presented with a set of words.';
line2 = '\n\n Please pay attention to the words presented to you, and try to';
line3 = '\n\n identify the categories the words fall under. Please bear';
line4 = '\n\n in mind that the words may come from more than one category.';
line5 = '\n\n After the presentation is finished, you will be asked to';
line6 = '\n\n report the categories you identified. Press [space] to continue.';

% Draw instructions
DrawFormattedText(window, [line1 line2 line3 line4 line5 line6], 'center', 'center', white);

Screen('Flip', window, [], 1);

% Copy the main window to the mirror and flip it
Screen('CopyWindow', window, mirror);
Screen('Flip', mirror);

KbStrokeWait;

% Clear both windows before drawing new content
Screen('FillRect', window, white/2);
Screen('FillRect', mirror, white/2);

% Draw fixation cross
if strcmp(devType, 'EEG')
    Screen('DrawLines', window, allCoords, lineWidthPix, white, [xCenter yCenter], 2);
elseif strcmp(devType, 'MEG')
    Screen('DrawLines', window, allCoords, lineWidthPix, white, [xCenter yCenter], 2);
else
    Screen('DrawLines', window, allCoords, lineWidthPix, white, [xCenter yCenter]);
end
Screen('Flip', window, [], 1);

% Copy the main window to the mirror and flip it
Screen('CopyWindow', window, mirror);
Screen('Flip', mirror);

WaitSecs(1);

% Empty window
Screen('FillRect', window, white / 2)
Screen('Flip', window, [], 1);

% Copy the main window to the mirror and flip it
Screen('CopyWindow', window, mirror);
Screen('Flip', mirror);

WaitSecs(1);

defTextSize = 80; 

% initialize data structure to store timing data
timingData = struct();

% -----------------!!!send trigger for starting!!!-----------------
if strcmp(devType, 'EEG')
    write(port, 2,"uint8");
elseif strcmp(devType, 'MEG')
    PTBSendTrigger(2,0);
else
    Beeper(2000)
end

% Record the start time of the experiment
startTime = GetSecs();

% % running the stimlus sequence
% for i = 1:size(finalSequence, 1)
%     stiType = finalSequence{i, 1};
%     stiName = finalSequence{i, 2};
%
%     % onsetTime = GetSecs() - startTime;
%
%     if strcmp(stiType, 'A')
%         current_code = 64;
%         stimulus = stiName;
%     else
%         current_code = 128;
%         stimulus = stiName;
%     end
for i = 1:length(seq)
    stimulus = seq{i};
    label = labels{i};
    
    Screen('TextSize', window, 250);
    
    % Clear both windows before drawing new content
    Screen('FillRect', window, white/2);
    Screen('FillRect', mirror, white/2);
    
    % Draw stimulus
    DrawFormattedText(window, stimulus, 'center', 'center', white);

    % -----------------!!!send trigger for stimulus onset!!!-----------------


    if label == "reg"
        current_code = 64;
    elseif label == "odd"
        current_code = 128;
    end

    if strcmp(devType, 'EEG')
        write(port, current_code,"uint8");
    elseif strcmp(devType, 'MEG')
        PTBSendTrigger(current_code,0);
    else
        Beeper(2000)
    end

    % Flip to the screen
    onsetTime = Screen('Flip', window, [], 1);
    
    % Copy the main window to the mirror and flip it
    Screen('CopyWindow', window, mirror);
    Screen('Flip', mirror);

    % Display word for 1 second and then offset word
    WaitSecs(1);

    Screen('FillRect', window, white / 2);

    offsetTime = Screen('Flip', window, [], 1);
    
    % Copy the main window to the mirror and flip it
    Screen('CopyWindow', window, mirror);
    Screen('Flip', mirror);



    onsetTime = onsetTime - startTime;
    offsetTime = offsetTime - startTime;

    disp(stimulus)

    % store
    timingData(i).stiType = label;
    timingData(i).stiName = stimulus;
    timingData(i).onsetTime = onsetTime;
    timingData(i).offsetTime = offsetTime;

    % Randomize inter-stimulus interval between 750ms to 1250ms
    WaitSecs(0.5 + rand() * 0.5);

end

timingData(1).startTime = startTime;

% For testing, could ignore
dateStringBlah = datestr(now, 'yyyymmdd_HHMMSS');

filename = sprintf('%s_timingData_%s_%s.mat', subjectID, 'svis', category);

taskNames{end+1} = filename;

% dir name for data storage
dirToSave = fullfile(dataDir, 'semanticVis');

% created directory if not found
mkdir(dirToSave)  

filename = fullfile(dirToSave, filename);

save(filename, 'timingData');

Screen('TextSize', window, defTextSize);

disp("semanticVis ended")

% Clear both windows before drawing new content
Screen('FillRect', window, white/2);
Screen('FillRect', mirror, white/2);

% line1 = 'This is the end of the task. Please put down the categories';
% line2 = '\n\n you identified from the task. Press [space] to continue when you finish.';
line1 = 'This is the end of the task. Please say out loud the categories';
line2 = '\n\n you identified from the task. Press [space] to continue when you finish.';

DrawFormattedText(window, [line1 line2], 'center', 'center', white);

Screen('Flip', window, [], 1);

% Copy the main window to the mirror and flip it
Screen('CopyWindow', window, mirror);
Screen('Flip', mirror);

KbStrokeWait;

end % end of function