function Runtime()
global S


%% prepare events, timings, randomization

[S.Planning, S.cfgEvents] = TASK.(S.guiTask).PrepareEvents(S.guiACQmode);


%% set keybinds

cfg.Keybinds = TASK.cfgKeyboard(); % cross task keybinds

switch S.guiKeybind
    case 'fORP (MRI)'
        cfg.Keybinds.Catch = KbName('b');
    case 'Keyboard'
        cfg.Keybinds.Catch = KbName('DownArrow');
    otherwise
end


%% set parameters for rendering objects

cfg.FixationCross = TASK.cfgFixationCross();

cfg.Text.SizeInstruction = 0.10;              % TextSize = round(ScreenY_px * Size)
cfg.Text.SizeStim        = 0.20;              % TextSize = round(ScreenY_px * Size)
cfg.Text.Color           = [127 127 127 255]; % [R G B a], from 0 to 255
cfg.Text.Center          = [0.5 0.5];         % Position_px = [ScreenX_px ScreenY_px] .* Position


%% start PTB engine

% get object
Window = PTB_ENGINE.VIDEO.Window();
S.Window = Window; % also save it in the global structure for diagnostic

% task specific paramters
S.Window.bg_color       = [0 0 0];
S.Window.movie_filepath = [S.OutFilepath '.mov'];

% set parameters from the GUI
S.Window.screen_id      = S.guiScreenID; % mandatory
S.Window.is_transparent = S.guiTransparent;
S.Window.is_windowed    = S.guiWindowed;
S.Window.is_recored     = S.guiRecordMovie;

S.Window.Open();


%% prepare rendering object

FixationCross          = PTB_OBJECT.VIDEO.FixationCross();
FixationCross.window   = Window;
FixationCross.dim      = cfg.FixationCross.Size;
FixationCross.width    = cfg.FixationCross.Width;
FixationCross.color    = cfg.FixationCross.Color;
FixationCross.center_x = cfg.FixationCross.Position(1);
FixationCross.center_y = cfg.FixationCross.Position(2);
FixationCross.GenerateCoords();

TextInstruction        = PTB_OBJECT.VIDEO.CenteredText();
TextInstruction.window = Window;
TextInstruction.color  = cfg.FixationCross.Color;
TextInstruction.size   = 0.10;

TextStim      = TextInstruction.CopyObject();
TextStim.size = 0.20;


%% run the events

for evt = 1 : S.Planning.count
    
    evt_name     = S.Planning.data{evt,S.Planning.icol_name    };
    evt_onset    = S.Planning.data{evt,S.Planning.icol_onset   };
    evt_duration = S.Planning.data{evt,S.Planning.icol_duration};
    
    switch evt_name
        case 'START'
            FixationCross.Draw();
            Window.Flip();
            t0 = PTB_ENGINE.START(cfg.Keybinds.Start, cfg.Keybinds.Abort);
        case 'END'
        otherwise
            error('unknown event : %s', evt_name)
    end % switch
    
end % evt

WaitSecs(1);
sca
S
end % fcn
