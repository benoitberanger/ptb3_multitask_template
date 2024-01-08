function [Planning, Parameters] = PrepareEvents(ACQmode)

if nargin < 1 % only to plot the paradigm when we execute the function outside of the main script
    ACQmode = 'Acquisition';
end

p = struct; % This structure will contain task specific parameters

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MODIFY SETTINGS FROM HERE....
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% N-Back

p.nBack      = [0 2]; % 0-back & 2-back
p.nBlock     = 3;     % repetition of each x-back block
p.catchRatio = 0.20;  % percentage of catch
p.nCatch     = 5;     % catch items per block

p.availLetter{1} = { 'B' 'N' 'D' 'Q' 'G' 'S' 'J' 'V' };
p.availLetter{2} = { 'C' 'P' 'F' 'R' 'H' 'T' 'L'  };
% this is seperated into 2 lists, to help psedo-random setup


%% Timings

% all in seconds
p.durInstruction = 4.0;
p.durStim        = 0.5;
p.durDelay       = 1.5;
p.durRest        = [7 8]; % [min max] for the jitter


%% Debugging

switch ACQmode
    case 'Acquisition'
        % pass
    case 'Debug'
        p.nBlock     = 1;
        p.nCatch     = 3;
        p.durRest    = [1.0 1.0];
    case 'FastDebug'
        p.nBlock     = 1;
        p.nCatch     = 3;
        p.durInstruction = 1.0;
        p.durStim        = 0.2;
        p.durDelay       = 0.5;
        p.durRest        = [0.5 0.5];
    otherwise
        error('mode ?')
end


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ... TO HERE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generate

nStim = round(p.nCatch * 1/p.catchRatio);
block_order = repmat(p.nBack, [1 p.nBlock]);
p.nTrials = length(block_order) * nStim;

blocks(length(block_order)) = struct;

for iBlock = 1 : length(block_order)
    
    % save difficulty info
    blocks(iBlock).nBack = block_order(iBlock);
    
    % generate random pseudo-random stim
    starting_subgroup = round(rand)+1;
    ending_subgroup   = -starting_subgroup + 3; % [1 2] -> [2 1]
    blk = [];
    while length(blk) < nStim % generate as much as we need
        blk = [blk Shuffle( p.availLetter{starting_subgroup} ) Shuffle( p.availLetter{ending_subgroup} )];
    end
    blk = blk(1:nStim); % crop to the right number
    
    % define position of catch trials
    catch_position = linspace(1,nStim,p.nCatch+2); catch_position = catch_position(2:end-1); % evenly spread in the middle
    displacement = round(3*(rand(1,p.nCatch)-0.5)); % add some radomness {-1 0 +1} in the position
    catch_position = round(catch_position) + displacement;
    
    if block_order(iBlock) == 0
        blk(catch_position) = {'X'}; % replace the catch trials
        blocks(iBlock).instruction = 'CLICK ON "X"';
    else
        for pos_idx = 1:length(catch_position)
            blk(catch_position(pos_idx)) = blk(catch_position(pos_idx)-block_order(iBlock)); % replace the catch trials
        end
        blocks(iBlock).instruction = sprintf('%d-BACK', block_order(iBlock));
    end
    
    % save
    blocks(iBlock).Trials = blk;
    blocks(iBlock).CatchIdx = catch_position;
    vect = zeros(1,nStim);
    vect(catch_position) = 1;
    blocks(iBlock).CatchVect = vect;
    
end

% save
p.blocks = blocks;


%% Generate jitter

all_jitters = linspace(p.durRest(1), p.durRest(2), length(block_order) + 1);
all_jitters = Shuffle(all_jitters);


%% Build planning

% Create and prepare
header = {'event_name', 'onset(s)', 'duration(s)', '#trial',  '#block', '#stim', 'content', 'iscatch'};
Planning = UTILS.RECORDER.Planning(header);

% NextOnset = PreviousOnset + PreviousDuration
NextOnset = @(EP) EP.Data{end,2} + EP.Data{end,3};

% --- Start ---------------------------------------------------------------

Planning.AddStartTime('StartTime',0);

% --- Stim ----------------------------------------------------------------

count = 0;
for iBlock = 1 : length(block_order)
    
    Planning.AddPlanning({     'Rest'        NextOnset(Planning) all_jitters(iBlock)   []    []     []    []                          []                               })
    Planning.AddPlanning({     'Instruction' NextOnset(Planning) p.durInstruction      []    []     []    blocks(iBlock).instruction  []                               })
    Planning.AddPlanning({     'Delay'       NextOnset(Planning) p.durDelay            []    []     []    []                          []                               })
    for iStim = 1 : nStim
        count = count + 1;
        Planning.AddPlanning({ 'Stim'        NextOnset(Planning) p.durStim             count iBlock iStim blocks(iBlock).Trials{iStim} blocks(iBlock).CatchVect(iStim) })
        Planning.AddPlanning({ 'Delay'       NextOnset(Planning) p.durDelay            []    []     []    []                          []                               })
    end
end
Planning.AddPlanning({         'Rest'        NextOnset(Planning) all_jitters(iBlock+1) []    []     []    []                          []                               })


% --- Stop ----------------------------------------------------------------

Planning.AddStopTime('StopTime',NextOnset(Planning));

Planning.BuildGraph();


%% Display

% To prepare the planning and visualize it, we can execute the function
% without output argument

if nargin < 1
    
    fprintf( '\n' )
    fprintf(' \n Total stim duration : %g seconds \n' , NextOnset(Planning) )
    fprintf( '\n' )
    
    Planning.Plot();
    
end


%% Save


Parameters = p;


end % fcn
