classdef Keylogger < UTILS.RECORDER.Stim
    % Handles the Keybinds Queue from Psychtoolbox
    %  (ex : record MRI triggers while other code is executing)

    properties(GetAccess = public, SetAccess = public)
        kbList_num (1,:) double
        kbList_str (1,:) cell
        kbEvents   (:,3) cell
        keyboard         struct = struct

        display_symbol = '+'
    end % props

    properties(GetAccess = public, SetAccess = protected)
        icol_kname     (1,1) double = 1 % key name
        icol_konset    (1,1) double = 2 % key onset
        icol_kud       (1,1) double = 3 % 0 up, 1 down
    end % props

    methods(Access = public)

        %------------------------------------------------------------------
        %                           Constructor
        %------------------------------------------------------------------
        function self = Keylogger( kblist  )
            self = self@UTILS.RECORDER.Stim(0,{})
            self.description = class(self);

            self.kbList_num = kblist;
            self.kbList_str = KbName(kblist);

            [self.keyboard.keyboardIndices, self.keyboard.productNames, self.keyboard.allInfos] = GetKeyboardIndices;
        end % fcn

        %------------------------------------------------------------------
        function Start( self )
            % Initialise the KeyBind Queue and start collecting the inputs

            kbVect = zeros(1,256);
            kbVect(self.kbList_num) = 1;

            for index = 1 : length(self.keyboard.keyboardIndices)
                KbQueueCreate(self.keyboard.keyboardIndices(index),kbVect)
                KbQueueStart (self.keyboard.keyboardIndices(index))
            end

        end % fcn

        %------------------------------------------------------------------
        function Stop( self )
            % Stop collecting KeyBinds and Release the device

            for index = 1 : length(self.keyboard.keyboardIndices)
                KbQueueStop   (self.keyboard.keyboardIndices(index))
                KbQueueRelease(self.keyboard.keyboardIndices(index))
            end

        end % fcn

        %------------------------------------------------------------------
        function GetQueue( self )
            % Fetch the queue

            for index = 1 : length(self.keyboard.keyboardIndices)

                while KbEventAvail(self.keyboard.keyboardIndices(index))
                    [evt, ~] = KbEventGet(self.keyboard.keyboardIndices(index)); % Get all queued keys
                    if any( evt.Keycode == self.kbList_num )
                        key_idx = evt.Keycode == self.kbList_num;
                        self.kbEvents(end+1,:) = { self.kbList_str{key_idx} evt.Time evt.Pressed };
                    end
                end

            end

        end % fcn



        % %------------------------------------------------------------------
        % function ComputeDurations( self )
        %     % self.ComputeDurations()
        %     %
        %     % Compute durations for each keybinds
        %
        %     kbevents = cell( length(self.Header) , 2 );
        %
        %     % Take out T_start and T_stop from Data
        %
        %     T_start_idx = strcmp( self.Data(:,1) , 'StartTime' );
        %     T_stop_idx = strcmp( self.Data(:,1) , 'StopTime' );
        %
        %     data = self.Data( ~( T_start_idx + T_stop_idx ) , : );
        %
        %     % Create list for each KeyBind
        %
        %     [ unique_kb , ~ ,  idx ] = unique(self.Data(:,1), 'stable'); % Filter each Kb
        %
        %     % Re-order each input to be coherent with Header order
        %     input_found = nan(size(unique_kb));
        %     for c = 1:length(unique_kb)
        %
        %         input_idx  = strcmp(self.Header,unique_kb(c));
        %         input_idx  = find(input_idx);
        %
        %         input_found(c) = input_idx;
        %
        %     end
        %
        %     kbevents(:,1) = self.Header; % Name of KeyBind
        %
        %     count = 0;
        %
        %     for c = 1:length(unique_kb)
        %
        %         count = count + 1;
        %
        %         kbevents{ input_found(count) , 2 } = data( idx == c , [4 3] ); % Time & Up/Down of Keybind
        %
        %     end
        %
        %     % Compute the difference between each time
        %     for e = 1 : size( kbevents , 1 )
        %
        %         if size( kbevents{e,2} , 1 ) > 1
        %
        %             time = cell2mat( kbevents {e,2} (:,1) );                       % Get the times
        %             kbevents {e,2} ( 1:end-1 , end+1 ) = num2cell( diff( time ) ); % Compute the differences
        %
        %         end
        %
        %     end
        %
        %     self.kbEvents = kbevents;
        %
        % end % fcn

        % %------------------------------------------------------------------
        % function ComputePulseSpacing( self , graph )
        %     % self.ComputePulseSpacing() no plot, or self.ComputePulseSpacing(1) to plot
        %     %
        %     % Compute time between each "KeyIsDown", then plot it if asked
        %
        %     if ~exist('graph','var')
        %         graph = 0;
        %     end
        %
        %     for k = 1 : size(self.kbEvents,1)
        %
        %         if ~isempty(self.kbEvents{k,2})
        %
        %             if isempty(self.kbEvents{k,2}{end,end})
        %                 self.kbEvents{k,2}{end,end} = 0;
        %             end
        %
        %             data = cell2mat(self.kbEvents{k,2});
        %
        %             KeyIsDown_idx = data(:,2) == 1;
        %             KeyIsDown_onset = data(KeyIsDown_idx,1);
        %             KeyIsDown_spacing = diff(KeyIsDown_onset);
        %
        %             fprintf('N = %d \n',length(KeyIsDown_onset));
        %             fprintf('mean = %f ms \n',mean(KeyIsDown_spacing)*1000);
        %             fprintf('std = %f ms \n',std(KeyIsDown_spacing)*1000);
        %
        %             if graph
        %
        %                 figure( ...
        %                     'Name'        , [mfilename ' : ' self.kbEvents{k,1} ] , ...
        %                     'NumberTitle' , 'off'                                      )
        %
        %                 subplot(2,2,[1 2])
        %                 plot(KeyIsDown_spacing)
        %
        %                 subplot(2,2,3)
        %                 hist(KeyIsDown_spacing)
        %
        %                 if ~isempty(which('boxplot'))
        %                     subplot(2,2,4)
        %                     boxplot(KeyIsDown_spacing)
        %                     grid on
        %                 end
        %
        %             end
        %
        %         end
        %
        %     end
        %
        % end % fcn

        % %------------------------------------------------------------------
        % function GenerateMRITrigger( self , tr, volumes, starttime )
        %     % self.GenerateMRITrigger( TR = positive number , Volumes = positive integer, StartTime = onset of the first volume )
        %     %
        %     % Generate MRI trigger according to he given number of Volumes
        %     % and the TR.
        %
        %     % ================ Check input argument =======================
        %
        %     % narginchk(3,3)
        %     % narginchk introduced in R2011b
        %     if nargin > 4 || nargin < 3
        %         error('%s uses 3 or 4 input argument(s)','GenerateMRITrigger')
        %     end
        %
        %     if nargin == 3
        %         starttime = 0;
        %     end
        %
        %     % --- tr ----
        %     if ~( isnumeric(tr) && tr > 0 )
        %         error('TR must be positive')
        %     end
        %
        %     % --- volumes ----
        %     if ~( isnumeric(volumes) && volumes > 0 && volumes == round(volumes) )
        %         error('Volumes must be a positive integer')
        %     end
        %
        %     % --- starttime ----
        %     if ~( isnumeric(starttime) && starttime >= 0 )
        %         error('StartTime must be positive or null')
        %     end
        %
        %
        %     % ======================= Callback ============================
        %
        %     % MRI_trigger_tag = '5%'; % fORP in USB
        %     MRI_trigger_tag = self.Header{1};
        %     pulse_duration = 0.020; % seconds
        %
        %     % Check if TR is compatible with the pulse duration
        %     if tr < pulse_duration
        %         error('pulse_duration is set to %.3f, but TR must be such as TR > pulse_duration',pulse_duration)
        %     end
        %
        %     % Fill Data whith MRI trigger events
        %
        %     for v = 1 : volumes
        %
        %         self.AddEvent({ MRI_trigger_tag starttime+(v-1)*tr                1 starttime+(v-1)*tr                 })
        %         self.AddEvent({ MRI_trigger_tag starttime+(v-1)*tr+pulse_duration 0 starttime+(v-1)*tr+pulse_duration  })
        %
        %     end
        %
        % end % fcn





    end % meths

end % class
