function Run( hObject, ~ )
% Here is the main workflow, where everythging happens
% --- in the GUI, click on task button
% - Retrieve GUI paramters
% - Set most of the variables
% - Start PTB3 components (video, audio, keyboard, ...)
% - Start task Runtime()
% - Save 'raw' data immediately after the end of task
% - Perform post-task operations : generate models for SPM, print run performances, ...
% - Save all files
% --- ready for another run

clc
sca
rng('shuffle')
logger = getLogger();


%% Retrieve GUI data

handles = guidata( hObject );


%% Initialize the main structure

% NOTES : Here I made the choice of using a "global" variable, because it
% simplifies a lot all the functions. It allows retrieve of the variable
% everywhere, and make lighter the input

global S
S                 = struct; % S is the main structure, containing everything useful, and used everywhere
S.ProjectName     = CONFIG.ProjectName();
S.ProjectRootDir  = UTILS.GET.RootDir();
S.ProjectDataDir  = UTILS.GET.DataDir();
S.TimeStampSimple = datestr(now, 'yyyy-mm-dd HH:MM'); % readable
S.TimeStampFile   = datestr(now, 30                ); % yyyymmddTHHMMSS : to sort automatically by time of creation


%% Lots of get*

S.guiSubjectID   = GUI.GET.SubjectID  ( handles );
S.guiACQmode     = GUI.GET.ACQmode    ( handles );
S.guiSave        = GUI.GET.Save       ( handles );
S.guiKeybind     = GUI.GET.Keybind    ( handles );
S.guiParport     = GUI.GET.Parport    ( handles );
S.guiScreenID    = GUI.GET.ScreenID   ( handles );
S.guiWindowed    = GUI.GET.Windowed   ( handles );
S.guiTransparent = GUI.GET.Transparent( handles );
S.guiRecordMovie = GUI.GET.RecordMovie( handles );
S.guiEyelink     = GUI.GET.Eyelink    ( handles );
S.guiTask        = GUI.GET.Task       ( hObject );


%% Some warnings, and other stuff

S.WriteFiles = strcmp(S.guiACQmode, 'Acquisition') && S.guiSave;

if S.WriteFiles
    logger.warn('In `Acquisition` mode, data should be saved.')
end


%% SubjectID & where to store the data

if isempty(S.guiSubjectID)
    logger.err('SubjectID is empty')
    return
end

S.SubjectDataDir = UTILS.GET.SubjectDataDir(S.guiSubjectID);


%% Generate base output filepath

basename_norun = sprintf('%s_%s', S.guiSubjectID, S.guiTask );
[S.RunName, S.RunNumber] = UTILS.AppendRunNumber(S.SubjectDataDir, basename_norun);

S.OutFilename    = sprintf('%s_%s', S.TimeStampFile, S.RunName);
S.OutFilepath    = fullfile(S.SubjectDataDir, S.OutFilename);
logger.log('Output file name  = %s', S.OutFilename)

% Security : NEVER overwrite a file
% If erasing a file is needed, we need to do it manually
if S.WriteFiles
    if ~exist(S.SubjectDataDir, 'dir')
        mkdir(S.SubjectDataDir);
    end
    logger.assert( ~exist([S.OutFilepath '.mat'],'file'), 'The file %s.mat already exists', [S.OutFilepath '.mat'] );
end


%% Eyelink

if S.guiEyelink

    eyelink_detected = ~isempty(which('Eyelink.m'));
    if ~eyelink_detected, logger.err('No `Eyelink.m` detected in MATLAB path.')       , return, end
    if ~S.guiSave          , logger.err('Save data MUST be turned on when using Eyelink'), return, end
    if ~EYELINK.IsConnected()                                                         , return, end % log message is inside the function

    % Generate the Eyelink filename
    eyelink_max_finename = 8;                                                       % Eyelink filename must be 8 char maximum (Eyelink limitation)
    available_char        = ['a':'z' 'A':'Z' '0':'9'];                              % This is all characters available (N=62)
    name_num              = randi(length(available_char),[1 eyelink_max_finename]); % Pick 8 numbers, from 1 to N=62 (same char can be picked twice)
    name_str              = available_char(name_num);                               % Convert the 8 numbers into char

    S.EyelinkFile = name_str;
    logger.log('Eyelink file name = %s', S.EyelinkFile)

end


%% Task

result = which(sprintf('TASK.%s.Run', S.guiTask));
if isempty(result)
    logger.err('No `Run.m` file found to start the task `%s`. Expected path = %s', S.guiTask, fullfile(S.ProjectRootDir,'+TASK',sprintf('+%s',S.guiTask),'Run.m'))
    return
end

logger.log('Calling TASK.%s.Run()', S.guiTask)

switch S.guiACQmode

    case 'Acquisition'
        % call the Run() in a try/catch
        try
            TASK.(S.guiTask).Run();
        catch exception
            exception.message
            exception.identifier
            exception.cause
            for i = 1:numel(exception.stack), exception.stack(i), end
        end

    case {'Debug', 'FastDebug'}
        % no try/catch, because it's easier for debugging
        TASK.(S.guiTask).Run();

end


%% Save data 'raw' data immediatly

if S.WriteFiles
    save([S.OutFilepath '_RAW.mat'], 'S')
end


%% Eyelink

if S.guiEyelink
    EYELINK.StopRecording();
    EYELINK.CloseFile();
end


%% Save post-processing files

logger.err('Save post-processing files: TODO')


%% Ready for another run

WaitSecs(0.100);
pause(0.100);
logger.log('~~~~~~~~~~~~~~~~~~~~~~~~~~~~')
logger.log('    Ready for another run   ')
logger.log('~~~~~~~~~~~~~~~~~~~~~~~~~~~~')


end % fcn
