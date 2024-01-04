function main()
% Just run this function

clc

% get logger instance
logger = UTILS.Logger.get();

% make sure to stay in the current directory
project_dir = fileparts(mfilename('fullpath')); % "fileparts" first output is the dir of the input
cd(project_dir); % just to make sure we are in the right dir

logger.log('Project name = %s', CONFIG.project_name() );
logger.log('Project path = %s', project_dir);

CONFIG.CheckRequirements()

logger.log('Starting (or focussing) GUI... \n');
GUI.VIEW.OpenGUI(); % the GUI is the **ONLY** interface the user will interact with

% NOTES:
%
% Here for the GUI I use the Model-View-Controller architecture : https://en.wikipedia.org/wiki/Model-view-controller
% The core program is gui.model.Core(). This is where everything happens.
% Inside gui.model.Core(), the program of the task will be called with all the settings comming from the GUI
% Tasks codes are in +task/+<task_name>/Runtime.m
%

end % function
