function Run()
global S


%% prepare events, timings, randomization

[S.recPlanning, S.cfgEvents] = TASK.(S.guiTask).PrepareEvents(S.guiACQmode);


%% create other recorders

S.recEvent     = UTILS.RECORDER.Event(S.recPlanning);
%S.recBehaviour = UTILS.RECORDER.Cell({'trial#' 'block#' 'stim#' 'content' 'iscatch' 'RT(s)' 'resp_ok'}, S.cfgEvents.nTrials);


%% set keybinds

S.cfgKeybinds = TASK.cfgKeyboard(); % cross task keybinds

switch S.guiKeybind
    case 'fORP (MRI)'
        %S.cfgKeybinds.Catch = KbName('b');
    case 'Keyboard'
        %S.cfgKeybinds.Catch = KbName('DownArrow');
    otherwise
        error('unknown S.guiKeybind : %s', S.guiKeybind)
end

S.recKeylogger = UTILS.RECORDER.Keylogger(S.cfgKeybinds);
S.recKeylogger.Start();


%% set parameters for rendering objects

S.cfgFixationCross = TASK.cfgFixationCross();


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
S.Window.is_recorded    = S.guiRecordMovie;

S.Window.Open();


%% prepare rendering object

FixationCross          = PTB_OBJECT.VIDEO.FixationCross();
FixationCross.window   = Window;
FixationCross.dim      = S.cfgFixationCross.Size;
FixationCross.width    = S.cfgFixationCross.Width;
FixationCross.color    = S.cfgFixationCross.Color;
FixationCross.center_x = S.cfgFixationCross.Position(1);
FixationCross.center_y = S.cfgFixationCross.Position(2);
FixationCross.GenerateCoords();

Tetris3D = PTB_OBJECT.VIDEO.Tetris3D();
Tetris3D.window = Window;
Tetris3D.segment_length = S.cfgEvents.cube_segment;
Tetris3D.InitializeOpenGL();
Tetris3D.GenCubeTexture();
Tetris3D.PrepareNormal();

Tetris3D.Render([1 2 3 1], 0, false);

Window.Flip();

KbWait();
Tetris3D.DeleteTextures();
sca
return

%% run the events

% initialize / pre-allocate some vars
EXIT = false;
secs = GetSecs();
% icol_trial   = S.recPlanning.Get('trial'  );
% icol_block   = S.recPlanning.Get('block'  );
% icol_stim    = S.recPlanning.Get('stim'   );
% icol_content = S.recPlanning.Get('content');
% icol_iscatch = S.recPlanning.Get('iscatch');

% main loop
for evt = 1 : S.recPlanning.count

    evt_name     = S.recPlanning.data{evt,S.recPlanning.icol_name    };
    evt_onset    = S.recPlanning.data{evt,S.recPlanning.icol_onset   };
    evt_duration = S.recPlanning.data{evt,S.recPlanning.icol_duration};

    if evt < S.recPlanning.count
        next_evt_onset = S.recPlanning.data{evt+1,S.recPlanning.icol_onset};
    end

    switch evt_name

        case 'START'

            FixationCross.Draw();
            Window.Flip();
            S.STARTtime = PTB_ENGINE.START(S.cfgKeybinds.Start, S.cfgKeybinds.Abort);
            S.recEvent.AddStart();
            S.Window.AddFrameToMovie();

        case 'END'

            S.ENDtime = WaitSecs('UntilTime', S.STARTtime + evt_onset );
            S.recEvent.AddEnd(S.ENDtime - S.STARTtime );
            S.Window.AddFrameToMovie();
            PTB_ENGINE.END();


        case 'Rest'

            FixationCross.Draw();
            real_onset = Window.Flip(S.STARTtime + evt_onset - Window.slack);
            S.recEvent.AddStim(evt_name, real_onset-S.STARTtime, [], S.recPlanning.data(evt,S.recPlanning.icol_data:end));

            fprintf('Rest : %gs \n', evt_duration)
            S.Window.AddFrameToMovie(evt_duration);

            next_onset = S.STARTtime + next_evt_onset - Window.slack;
            while secs < next_onset
                [keyIsDown, secs, keyCode] = KbCheck();
                if keyIsDown
                    EXIT = keyCode(S.cfgKeybinds.Abort);
                    if EXIT, break, end
                end
            end

        otherwise
            error('unknown event : %s', evt_name)

    end % switch

    % if Abort is pressed
    if EXIT

        S.ENDtime = GetSecs();
        S.recEvent.AddEnd(S.ENDtime - S.STARTtime);
        S.recEvent.ClearEmptyLines();

        S.recEvent.ClearEmptyLines();

        if S.WriteFiles
            save([S.OutFilepath '_ABORT_at_runtime.mat'], 'S')
        end

        fprintf('!!! @%s : Abort key received !!!\n', mfilename)
        break % stop the forloop:evt

    end

end % forloop:evt


%% End of task routine

S.Window.Close();

S.recEvent.ComputeDurations();
S.recKeylogger.GetQueue();
S.recKeylogger.Stop();
switch S.guiACQmode
    case 'Acquisition'
    case {'Debug', 'FastDebug'}
        TR = CONFIG.TR();
        n_volume = ceil((S.ENDtime-S.STARTtime)/TR);
        S.recKeylogger.GenerateMRITrigger(TR, n_volume, S.STARTtime)

        UTILS.plotDelay(S.recPlanning, S.recEvent);
        % UTILS.plotStim(S.recPlanning, S.recEvent, S.recKeylogger);
end
S.recKeylogger.kb2data();
S.recKeylogger.ScaleTime(S.STARTtime);
assignin('base', 'S', S)


end % fcn
