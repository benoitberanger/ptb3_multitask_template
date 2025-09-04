function [planning, cfgEvents] = PrepareEvents(ACQmode)

if nargin < 1 % only to plot the paradigm when we execute the function outside of the main script
    ACQmode = 'Acquisition';
end

cfgEvents = struct; % This structure will contain task specific parameters

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MODIFY SETTINGS FROM HERE....
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Design

cfgEvents.nBlock = 10;


%% Timings

% all in seconds
cfgEvents.durBreak  = 00.500;
cfgEvents.durRest   = 10.000;
cfgEvents.durMaxCue = 04.000;


%% Debugging

switch ACQmode
    case 'Acquisition'
        % pass
    case {'Debug','FastDebug'}
        cfgEvents.nBlock    = 1;
        cfgEvents.durRest   = 02.000;
    otherwise
        error('mode ?')
end


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ... TO HERE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generate

% left hand // right hand
block = [
    1 0 0 0   1 0 0 0
    1 0 0 0   0 1 0 0
    1 0 0 0   0 0 1 0
    1 0 0 0   0 0 0 1
    0 1 0 0   1 0 0 0
    0 1 0 0   0 1 0 0
    0 1 0 0   0 0 1 0
    0 1 0 0   0 0 0 1
    0 0 1 0   1 0 0 0
    0 0 1 0   0 1 0 0
    0 0 1 0   0 0 1 0
    0 0 1 0   0 0 0 1
    0 0 0 1   1 0 0 0
    0 0 0 1   0 1 0 0
    0 0 0 1   0 0 1 0
    0 0 0 1   0 0 0 1
    ];

cfgEvents.nTrials = cfgEvents.nBlock * size(block,1);


%% Build planning

% Create and prepare
header = {'#trial', '#block', '#stim', 'content'};
planning = UTILS.RECORDER.Planning(0,header);

% --- Start ---------------------------------------------------------------

planning.AddStart();

% --- Stim ----------------------------------------------------------------

planning.AddStim('Rest' ,planning.GetNextOnset(), cfgEvents.durRest)

iTrial = 0;
for iBlock = 1 : cfgEvents.nBlock
    current_block = Shuffle(block,2);
    for iStim = 1 : size(block,1)
        iTrial = iTrial + 1;
        planning.AddStim('Cue'  ,planning.GetNextOnset(),                1.5, {iTrial, iBlock, iStim, current_block(iStim,:)})
        planning.AddStim('Break',planning.GetNextOnset(), cfgEvents.durBreak)
    end
    planning.AddStim('Rest' ,planning.GetNextOnset(), cfgEvents.durRest)
end

% --- Stop ----------------------------------------------------------------

planning.AddEnd(planning.GetNextOnset());


%% Display

% To prepare the planning and visualize it, we can execute the function
% without output argument

if nargin < 1

    fprintf( '\n' )
    fprintf(' \n Total stim duration : %g seconds \n' , planning.GetNextOnset() )
    fprintf( '\n' )

    planning.Plot();

end


end % fcn
