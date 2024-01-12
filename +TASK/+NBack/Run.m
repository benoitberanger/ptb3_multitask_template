function Run()
global S


%% prepare events, timings, randomization

[S.Planning, S.cfgEvents] = TASK.(S.guiTask).PrepareEvents(S.guiACQmode);

%% create other recorders

S.Event = UTILS.RECORDER.Event(S.Planning);


%% set keybinds

S.cfgKeybinds = TASK.cfgKeyboard(); % cross task keybinds

switch S.guiKeybind
    case 'fORP (MRI)'
        S.cfgKeybinds.Catch = KbName('b');
    case 'Keyboard'
        S.cfgKeybinds.Catch = KbName('DownArrow');
    otherwise
end


%% set parameters for rendering objects

S.cfgFixationCross = TASK.cfgFixationCross();

S.cfgText.SizeInstruction = 0.10;              % TextSize = round(ScreenY_px * Size)
S.cfgText.SizeStim        = 0.20;              % TextSize = round(ScreenY_px * Size)
S.cfgText.Color           = [127 127 127 255]; % [R G B a], from 0 to 255
S.cfgText.Center          = [0.5 0.5];         % Position_px = [ScreenX_px ScreenY_px] .* Position


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
FixationCross.dim      = S.cfgFixationCross.Size;
FixationCross.width    = S.cfgFixationCross.Width;
FixationCross.color    = S.cfgFixationCross.Color;
FixationCross.center_x = S.cfgFixationCross.Position(1);
FixationCross.center_y = S.cfgFixationCross.Position(2);
FixationCross.GenerateCoords();

TextInstruction        = PTB_OBJECT.VIDEO.CenteredText();
TextInstruction.window = Window;
TextInstruction.color  = S.cfgFixationCross.Color;
TextInstruction.size   = 0.10;

TextStim      = TextInstruction.CopyObject();
TextStim.size = 0.20;


%% run the events

% initialize / pre-allocate some vars
EXIT = false;
secs = GetSecs();
icol_content = S.Planning.Get('content');

% main loop
for evt = 1 : S.Planning.count

    evt_name     = S.Planning.data{evt,S.Planning.icol_name    };
    evt_onset    = S.Planning.data{evt,S.Planning.icol_onset   };
    evt_duration = S.Planning.data{evt,S.Planning.icol_duration};
    content      = S.Planning.data{evt,           icol_content };

    if evt < S.Planning.count
        next_evt_onset = S.Planning.data{evt+1,S.Planning.icol_onset};
    end

    switch evt_name

        case 'START'

            FixationCross.Draw();
            Window.Flip();
            S.STARTtime = PTB_ENGINE.START(S.cfgKeybinds.Start, S.cfgKeybinds.Abort);
            S.Event.AddStart();


        case 'END'


        case 'Rest'

            FixationCross.Draw();
            real_onset = Window.Flip(S.STARTtime + evt_onset - Window.slack);
            S.Event.AddStim(evt_name, evt_onset-S.STARTtime, []);

            next_onset = S.STARTtime + next_evt_onset - Window.slack;
            while secs < next_onset
                [keyIsDown, secs, keyCode] = KbCheck();
                if keyIsDown
                    EXIT = keyCode(S.cfgKeybinds.Abort);
                    if EXIT, break, end
                end
            end


        case 'Instruction'

            TextInstruction.Draw(content);
            real_onset = Window.Flip(S.STARTtime + evt_onset - Window.slack);
            S.Event.AddStim(evt_name, real_onset-S.STARTtime, []);

            next_onset = S.STARTtime + next_evt_onset - Window.slack;
            while secs < next_onset
                [keyIsDown, secs, keyCode] = KbCheck();
                if keyIsDown
                    EXIT = keyCode(S.cfgKeybinds.Abort);
                    if EXIT, break, end
                end
            end

        case 'Delay'

            real_onset = Window.Flip(S.STARTtime + evt_onset - Window.slack);
            S.Event.AddStim(evt_name, real_onset-S.STARTtime, []);

            % While loop for most of the duration of the event, so we can press ESCAPE
            next_onset = S.STARTtime + next_evt_onset - Window.slack;
            while secs < next_onset
                [keyIsDown, secs, keyCode] = KbCheck();
                if keyIsDown
                    EXIT = keyCode(S.cfgKeybinds.Abort);
                    if EXIT, break, end
                end
            end

        case 'Stim'

            TextStim.Draw(content);
            real_onset = Window.Flip(S.STARTtime + evt_onset - Window.slack);
            S.Event.AddStim(evt_name, real_onset-S.STARTtime, []);

            % While loop for most of the duration of the event, so we can press ESCAPE
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

        % TODO : save stop time

        if S.WriteFiles
            save([S.OutFilepath '_ABORT_at_runtime.mat'], 'S')
        end

        fprintf(' !!! Abort key received !!! \n')
        break % stop the forloop:evt

    end

end % forloop:evt


%% End of task routine

sca


end % fcn
