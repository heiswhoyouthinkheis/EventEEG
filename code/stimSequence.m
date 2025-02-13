%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This code is created by Brian Yan (by2139@nyu.edu)
% And has been adapted for this course.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% [edit 02/12/25] make sure that the first 4 items are regular ones

% reg = ds structure for regular stimuli
% odd = data structure for odd stimuli
% catFields = selected categories (arrays of fieldnames)
% blkWords = the selection of categories and words (ds containing cell
% arrays)

% returns a ds containing 4 sequences of stimulus, with another data
% structure containing their odd-regular label

function [sequences, labels] = stimSequence(reg,odd,catFields, blkWords)

% Step 1: Randomly select 24 words from each category and store the rest in odd
for i = 1:length(catFields) % length = 4 
    category = catFields{i}; % category name
    words = blkWords.(category);  % Get the words for the current category
    
    % Randomly shuffle the words
    shuffled_idx = randperm(length(words));
    
    % Select 24 words for reg
    reg.(category) = words(shuffled_idx(1:24));
    
    % Select remaining 6 words for odd
    odd.(category) = words(shuffled_idx(25:end));
end



% Step 2: Create 4 sequences by combining 24 words from reg with 6 words from odd
sequences = struct();
labels = struct();  % To store corresponding labels ("reg" or "odd") for each word
used_odd_words = struct();  % To track used odd words for each category

% Initialize used_odd_words as empty cells for each category
for i = 1:length(catFields)
    used_odd_words.(catFields{i}) = {};
end

for i = 1:length(catFields)
    category = catFields{i};
    
    % Take the 24 words from the reg structure
    regWords = reg.(category);
    regLabels = repmat({'reg'}, 1, length(regWords));  % Label all 24 regular words as "reg"
    
    % Initialize odd words for this sequence
    oddWords = {};
    oddLabels = {};  % To label the odd words as "odd"
    
    % Loop through the other categories to pick odd words
    for j = 1:length(catFields)
        if j ~= i
            % Available odd words from the current other category
            available_odd = setdiff(odd.(catFields{j}), used_odd_words.(catFields{j}));
            
            % Select 2 random words from the available odd words
            selected_odd_idx = randperm(length(available_odd), 2);
            selected_odd_words = available_odd(selected_odd_idx);
            
            % Add to the odd words and label as "odd"
            oddWords = [oddWords, selected_odd_words];
            oddLabels = [oddLabels, repmat({'odd'}, 1, length(selected_odd_words))];
            disp(oddLabels);
            % Add selected words to the used_odd_words list
            used_odd_words.(catFields{j}) = [used_odd_words.(catFields{j}), selected_odd_words];
        end
    end
    
    % % (old) Combine the 24 regular words with the 6 odd words and their labels
    % sequence = [regWords, oddWords];
    % sequence_labels = [regLabels, oddLabels];
    % 
    % % Shuffle the final sequence of 30 words and keep the labels aligned
    % shuffled_idx = randperm(30);
    % sequence = sequence(shuffled_idx);
    % sequence_labels = sequence_labels(shuffled_idx);

    % Get the randomized sequences while making sure the first items are
    % regular ones
    shuffledIdxReg = randperm(24); % get permutation of 24 indices
    prefixN = 4;
    prefixIdx = shuffledIdxReg(1:prefixN); % get the first 5 from the permuted indices
    otherIdx = shuffledIdxReg((prefixN+1):end);
    wordReg1 = regWords(prefixIdx); % access the words using the 5 indices to get the first 5 regular words to display
    wordReg2 = regWords(otherIdx); % the rest of the regular words
        
    % Slice the labels for regs 
    regLabelsPre = regLabels(1:prefixN);
    regLabelsSuf = regLabels((prefixN+1):end);
    
    % Construct the suffix words and labels to be shuffled
    seqSuffix = [wordReg2 oddWords]; % construct the suffix of the sequence
    labelSuffix = [regLabelsSuf oddLabels]; % the labels

    % Randomize the suffix of the sequence
    shuffledIdx = randperm(30-prefixN);
    seqSuffixShuffled = seqSuffix(shuffledIdx);
    labelSuffixShuffled = labelSuffix(shuffledIdx);

    % Construct the final sequence and corresponding labels
    sequence = [wordReg1 seqSuffixShuffled];
    sequenceLabels = [regLabelsPre labelSuffixShuffled];


    
    % Store the sequence and corresponding labels in the appropriate field
    sequences.([category, 'Seq']) = sequence;
    labels.([category, 'Seq']) = sequenceLabels;
end

% Display or save the results as needed
disp(sequences);
disp(labels);  % Display the labels for each sequence
