function main()
% Just run this function

clc

% get logger instance
logger = getLogger();

% make sure to stay in the current directory
project_dir = fileparts(mfilename('fullpath')); % "fileparts" first output is the dir of the input
cd(project_dir); % just to make sure we are in the right dir

logger.log('Project name = %s', CONFIG.project_name() );
logger.log('Project path = %s', project_dir);

UTILS.CheckRequirements()
CONFIG.PrintReminder()
GUI.VIEW.OpenGUI() % the GUI is the **ONLY** interface the user will interact with

end % function
