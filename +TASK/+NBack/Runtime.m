function Runtime()
global S
logger = getLogger();


%% prepare events, timings, randomization

[S.Planning, S.cfgEvents] = TASK.(S.guiTask).PrepareEvents(S.guiACQmode);


%% prepare graphic objects

cfg.FixationCross = TASK.cfgFixationCross();

cfg.Text.SizeInstruction = 0.10;              % TextSize = round(ScreenY_px * Size)
cfg.Text.SizeStim        = 0.20;              % TextSize = round(ScreenY_px * Size)
cfg.Text.Color           = [127 127 127 255]; % [R G B a], from 0 to 255
cfg.Text.Center          = [0.5 0.5];         % Position_px = [ScreenX_px ScreenY_px] .* Position


%% start PTB engine

S.Window = PTB_ENGINE.VIDEO.Window();
S.Window.Open();

S.Window

%% prepare rendering object

% FixationCross =

WaitSecs(1);
sca
S
end % fcn
