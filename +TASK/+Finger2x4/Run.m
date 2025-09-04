function Run()
global S


%% prepare events, timings, randomization

[S.recPlanning, S.cfgEvents] = TASK.(S.guiTask).PrepareEvents(S.guiACQmode);


%% create other recorders

S.recEvent     = UTILS.RECORDER.Event(S.recPlanning);
S.recBehaviour = UTILS.RECORDER.Cell({'trial#' 'block#' 'stim#' 'content'}, S.cfgEvents.nTrials);


%% set keybinds

S.cfgKeybinds = TASK.cfgKeyboard(); % cross task keybinds

switch S.guiKeybind
    case 'fORP (MRI)'
        S.cfgKeybinds.L4 = KbName('d');
        S.cfgKeybinds.L3 = KbName('n');
        S.cfgKeybinds.L2 = KbName('z');
        S.cfgKeybinds.L1 = KbName('e');
        S.cfgKeybinds.R1 = KbName('b');
        S.cfgKeybinds.R2 = KbName('y');
        S.cfgKeybinds.R3 = KbName('g');
        S.cfgKeybinds.R4 = KbName('r');
    case 'Keyboard'
        S.cfgKeybinds.L4 = KbName('s');
        S.cfgKeybinds.L3 = KbName('d');
        S.cfgKeybinds.L2 = KbName('f');
        S.cfgKeybinds.L1 = KbName('g');
        S.cfgKeybinds.R1 = KbName('h');
        S.cfgKeybinds.R2 = KbName('j');
        S.cfgKeybinds.R3 = KbName('k');
        S.cfgKeybinds.R4 = KbName('l');
    otherwise
        error('unknown S.guiKeybind : %s', S.guiKeybind)
end

keyCode_L = [S.cfgKeybinds.L1 S.cfgKeybinds.L2 S.cfgKeybinds.L3 S.cfgKeybinds.L4];
keyCode_R = [S.cfgKeybinds.R1 S.cfgKeybinds.R2 S.cfgKeybinds.R3 S.cfgKeybinds.R4];

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

ButtonBox4C_L = PTB_OBJECT.VIDEO.ButtonBox4C();
ButtonBox4C_L.window = Window;
ButtonBox4C_L.Prepare('Left');

ButtonBox4C_R = ButtonBox4C_L.copy();
ButtonBox4C_R.Prepare('Right');


%% run the events

% initialize / pre-allocate some vars
EXIT = false;
secs = GetSecs();
icol_trial   = S.recPlanning.Get('trial'  );
icol_block   = S.recPlanning.Get('block'  );
icol_stim    = S.recPlanning.Get('stim'   );
icol_content = S.recPlanning.Get('content');

n_ok    = 0;
resp_ok = false;

% main loop
for evt = 1 : S.recPlanning.count

    evt_name     = S.recPlanning.data{evt,S.recPlanning.icol_name    };
    evt_onset    = S.recPlanning.data{evt,S.recPlanning.icol_onset   };
    evt_duration = S.recPlanning.data{evt,S.recPlanning.icol_duration};
    content      = S.recPlanning.data{evt,              icol_content };

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
            real_onset = Window.Flip();
            S.recEvent.AddStim(evt_name, real_onset-S.STARTtime, [], S.recPlanning.data(evt,S.recPlanning.icol_data:end));

            fprintf('Rest : %gs \n', evt_duration)
            S.Window.AddFrameToMovie(evt_duration);

            next_onset = real_onset + S.cfgEvents.durRest - Window.slack;
            while secs < next_onset
                [keyIsDown, secs, keyCode] = KbCheck();
                if keyIsDown
                    EXIT = keyCode(S.cfgKeybinds.Abort);
                    if EXIT, break, end
                end
            end

        case 'Cue'

            FixationCross.Draw();
            button_L = find(content(4:-1:1));
            button_R = find(content(5:8));
            ButtonBox4C_L.Draw(button_L);
            ButtonBox4C_R.Draw(button_R);
            real_onset = Window.Flip();
            cue_onset = real_onset;
            RT = 0;
            S.recEvent.AddStim(evt_name, real_onset-S.STARTtime, [], S.recPlanning.data(evt,S.recPlanning.icol_data:end));
            S.Window.AddFrameToMovie(evt_duration);

            itrial  = S.recPlanning.data{evt,icol_trial  };
            iblock  = S.recPlanning.data{evt,icol_block  };
            istim   = S.recPlanning.data{evt,icol_stim   };

            fprintf('#trial=%3d   #block=%2d   #stim=%2d   content=%s  ',...
                itrial,...
                iblock,...
                istim,...
                sprintf('[%d %d %d %d   %d %d %d %d]', content)...
                )

            % While loop for most of the duration of the event, so we can press ESCAPE
            next_onset = real_onset + S.cfgEvents.durMaxCue - Window.slack;
            while secs < next_onset
                [keyIsDown, secs, keyCode] = KbCheck();
                if keyIsDown

                    EXIT = keyCode(S.cfgKeybinds.Abort);
                    if EXIT, break, end

                    if keyCode(keyCode_L(button_L)) && keyCode(keyCode_R(button_R))
                        RT = secs - cue_onset;
                        resp_ok = true;
                        n_ok = n_ok + 1;
                        break
                    end

                end
            end % while

            fprintf('RT=%5.fms  resp_ok=%1d (%3d%%) \n', ...
                round(RT * 1000),...
                resp_ok,...
                round(100*n_ok/itrial) ...
                )
            resp_ok = false;

        case 'Break'
            
            FixationCross.Draw();
            ButtonBox4C_L.Draw();
            ButtonBox4C_R.Draw();
            real_onset = Window.Flip(S.STARTtime + evt_onset - Window.slack);
            S.recEvent.AddStim(evt_name, real_onset-S.STARTtime, [], S.recPlanning.data(evt,S.recPlanning.icol_data:end));
            S.Window.AddFrameToMovie(evt_duration);

            % While loop for most of the duration of the event, so we can press ESCAPE
            next_onset = real_onset + S.cfgEvents.durBreak - Window.slack;
            while secs < next_onset
                [keyIsDown, secs, keyCode] = KbCheck();
                if keyIsDown
                    EXIT = keyCode(S.cfgKeybinds.Abort);
                    if EXIT, break, end

                end
            end % while

        otherwise
            error('unknown event : %s', evt_name)

    end % switch

    % if Abort is pressed
    if EXIT

        S.ENDtime = GetSecs();
        S.recEvent.AddEnd(S.ENDtime - S.STARTtime);
        S.recEvent.ClearEmptyLines();

        S.recBehaviour.ClearEmptyLines();

        if S.WriteFiles
            save([S.OutFilepath '__ABORT_at_runtime.mat'], 'S')
        end

        PTB_ENGINE.END();

        fprintf('!!! @%s : Abort key received !!!\n', mfilename)
        break % stop the forloop:evt

    end

end % forloop:evt


%% End of task routine

S.Window.Close();

S.recEvent.ComputeDurations();
S.recKeylogger.GetQueue();
S.recKeylogger.Stop();
S.recKeylogger.kb2data();
switch S.guiACQmode
    case 'Acquisition'
    case {'Debug', 'FastDebug'}
        TR = CONFIG.TR();
        n_volume = ceil((S.ENDtime-S.STARTtime)/TR);
        S.recKeylogger.GenerateMRITrigger(TR, n_volume, S.STARTtime)
end
S.recKeylogger.ScaleTime(S.STARTtime);
assignin('base', 'S', S)

switch S.guiACQmode
    case 'Acquisition'
    case {'Debug', 'FastDebug'}
        % UTILS.plotDelay(S.recPlanning, S.recEvent);
        % UTILS.plotStim(S.recPlanning, S.recEvent, S.recKeylogger);
end

end % fcn
