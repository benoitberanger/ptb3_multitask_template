function str = RootDir()
% get root directory of the project

str = fileparts(fileparts(fileparts(mfilename('fullpath'))));

end % fcn
