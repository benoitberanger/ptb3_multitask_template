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
% everywhere, and make lighter the input paramters.

global S
S                 = struct; % S is the main structure, containing everything useful, and used everywhere
S.ProjectName     = CONFIG.ProjectName();
S.ProjectRootDir  = UTILS.GET.RootDir();
S.ProjectDataDir  = UTILS.GET.DataDir();
S.TimeStampSimple = datestr(now, 'yyyy-mm-dd HH:MM'); % readable
S.TimeStampFile   = datestr(now, 30                ); % yyyymmddTHHMMSS : to sort automatically by time of creation


%% Lots of get*

S.SubjectID   = GUI.GET.SubjectID  ( handles );
S.ACQmode     = GUI.GET.ACQmode    ( handles );
S.Save        = GUI.GET.Save       ( handles );
S.Keybind     = GUI.GET.Keybind    ( handles );
S.Parport     = GUI.GET.Parport    ( handles );
S.ScreenID    = GUI.GET.ScreenID   ( handles );
S.Windowed    = GUI.GET.Windowed   ( handles );
S.Transparent = GUI.GET.Transparent( handles );
S.RecordMovie = GUI.GET.RecordMovie( handles );
S.Eyelink     = GUI.GET.Eyelink    ( handles );
S.Task        = GUI.GET.Task       ( hObject );


%% Some warnings, and other stuff

write_files = strcmp(S.ACQmode, 'Acquistion') && S.Save;

if write_files
    logger.warn('In `Acquistion` mode, data should be saved.')
end


%% SubjectID & where to store the data

if isempty(S.SubjectID)
    logger.err('SubjectID is empty')
    return
end

S.SubjectDataDir = UTILS.GET.SubjectDataDir(S.SubjectID);


%% Generate base output filepath

basename_norun = sprintf('%s_%s', S.SubjectID, S.Task );
[S.RunName, S.RunNumber] = UTILS.GET.AppendRunNumber(S.SubjectDataDir, basename_norun);

S.OutFilename    = sprintf('%s_%s', S.TimeStampFile, S.RunName);
S.OutFilepath    = fullfile(S.SubjectDataDir, S.OutFilename);
logger.log('Output file name  = %s', S.OutFilename)

% Security : NEVER overwrite a file
% If erasing a file is needed, we need to do it manually
if write_files
    if ~exist(S.SubjectDataDir, 'dir')
        mkdir(S.SubjectDataDir);
    end
    logger.assert( ~exist([S.OutFilepath '.mat'],'file'), 'The file %s.mat already exists', [S.OutFilepath '.mat'] );
end


%% Eyelink

if S.Eyelink

    eyelink_detected = ~isempty(which('Eyelink.m'));
    if ~eyelink_detected, logger.err('No `Eyelink.m` detected in MATLAB path.')       , return, end
    if ~S.Save          , logger.err('Save data MUST be turned on when using Eyelink'), return, end
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

logger.log('Calling TASK.%s.Runtime()', S.Task)
TASK.(S.Task).Runtime();


%% Save data 'raw' data immediatly

if write_files
    save([S.OutFilepath '_RAW.mat'], 'S')
end


%% Eyelink

if S.Eyelink
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
