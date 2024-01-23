function Run()
global S
logger = getLogger();
logger.err('This is a demo script, dont use Logger in the realtime part of a task !')


%% image path

image_path = fileparts(mfilename('fullpath'));
img_no_transparency  = fullfile(image_path,'face_no-transparency.jpg');
img_with_tranparency = fullfile(image_path,'face_with-transparency.png');


%% keymap


%% start PTB engine

Window = PTB_ENGINE.VIDEO.Window();
Window.screen_id = max(Screen('Screens'));
Window.Open();


%% prepare rendering object

ImageTransparency = PTB_OBJECT.VIDEO.Image();
ImageTransparency.window = Window;
ImageTransparency.filename = img_with_tranparency;
ImageTransparency.Load();
% ImageTransparency.Plot()


%% End

WaitSecs(0.1);
logger.warn('Press any key to Exit...');
% KbWait();
Window.Close();


end % fcn
