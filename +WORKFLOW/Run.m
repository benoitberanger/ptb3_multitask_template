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

S
end % fcn
