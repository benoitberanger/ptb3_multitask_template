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


%% SubjectID & where to store the data

if isempty(S.SubjectID)
    logger.err('SubjectID is empty')
    return
end

S.SubjectDataDir = UTILS.GET.SubjectDataDir(S.SubjectID);

%% Generate base output filepath

basename_norun = sprintf('%s_%s', S.SubjectID, S.Task );
[S.RunName, S.RunNumber] = UTILS.GET.AppendRunNumber(S.SubjectDataDir, basename_norun);

S.OutFilename = sprintf('%s_%s', S.TimeStampFile, S.RunName);
S.OutFilpath  = fullfile(S.SubjectDataDir, S.OutFilename);


S
end % fcn
