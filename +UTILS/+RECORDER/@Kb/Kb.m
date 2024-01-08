classdef Kb < UTILS.RECORDER.Omni
    % KB Class to handle the the Keybinds Queue from Psychtoolbox
    %  (ex : record MRI triggers while other code is executing)


    %% Properties

    properties

        KbList   = []      % double = [ KbName( 'space' ) KbName( '5%' ) ]
        KbEvents = cell(0) % cell( Columns , 2 )
        Keyboard = struct  % structure

    end % properties


    %% Methods

    methods

        %------------------------------------------------------------------
        %                           Constructor
        %------------------------------------------------------------------
        function self = Kb( kblist , header )
            % self = KbLogger( KbList = [ KbName( 'space' ) KbName( '5%' ) ] , Header = cell( 1 , Columns ) )

            % ================ Check input argument =======================

            % Arguments ?
            if nargin > 0

                % --- kblist ----
                if isvector( kblist ) && isnumeric( kblist ) % Check input argument
                    self.KbList = kblist;
                else
                    error( 'KbList should be a line vector of positive integers' )
                end

                % --- header ----
                if isvector( header ) && ...
                        iscell( header ) && ...
                        length( kblist ) == length( header ) % Check input argument
                    if all( cellfun( @isstr , header ) )
                        self.Header = header;
                    else
                        error( 'Header should be a line cell of strings' )
                    end
                else
                    error( 'Header should be a line cell of strings and same size as KbList' )
                end

            end

            % ======================= Callback ============================

            self.Description    = mfilename( 'fullpath' );
            self.Columns        = 4;
            self.Data           = cell( self.NumberOfEvents , self.Columns );
            self.KbEvents       = cell( self.Columns , 2 );

            [keyboardIndices, productNames, allInfos]= GetKeyboardIndices;

            self.Keyboard.keyboardIndices = keyboardIndices;
            self.Keyboard.productNames    = productNames;
            self.Keyboard.allInfos        = allInfos;

        end % fcn

        %------------------------------------------------------------------
        function BuildGraph( self )
            % self.BuildGraph()
            %
            % Build curves for each events, ready to be plotted.


            % ================= Build curves for each Kb ==================

            for k = 1:size( self.KbEvents , 1 ) % For each KeyBinds

                if ~isempty( self.KbEvents{k,2} ) % Except for null (usually the last one)

                    data = cell2mat( self.KbEvents{k,2}(:,1:2) ); % Catch data for this Keybind

                    N  = size( data , 1 ); % Number of data = UP(0) + DOWN(1)

                    % Here we need to build a curve that looks like
                    % recangles
                    for n = N:-1:1

                        % Split data above & under the point
                        dataABOVE = data( 1:n-1 ,: );
                        dataUNDER = data( n:end , : );

                        % Add a point ine curve to build a rectangle
                        switch data(n,2)
                            case 0
                                data  = [ ...
                                    dataABOVE ; ...
                                    dataUNDER(1,1) 1 ;...
                                    dataUNDER ...
                                    ] ;
                            case 1
                                data  = [ ...
                                    dataABOVE ; ...
                                    dataUNDER(1,1) 0 ; ...
                                    dataUNDER ...
                                    ] ;

                            otherwise
                                disp( 'bug' )
                        end

                    end

                    % Now we have a continuous curve that draws rectangles.
                    % The objective now is to 'split' each rectangle, to
                    % have a more convinient display

                    % To find where are two consecutive 0, REGEXP is used
                    data_str  = num2str(num2str(data(:,2)')); % Convert to text
                    data_str  = regexprep(data_str,' ','');   % Delete white spaces
                    idx_data_str = regexp(data_str,'00');     % Find two consecutive zeros

                    % Add NaN between two consecutive zeros
                    for n = length(idx_data_str):-1:1

                        % Split data above & under the point
                        dataABOVE = data( 1:idx_data_str(n) , : );
                        dataUNDER = data( idx_data_str(n)+1:end , : );

                        % Add a point in curve to build a rectangle
                        data  = [ ...
                            dataABOVE ; ...
                            dataUNDER(1,1) NaN ; ...
                            dataUNDER ...
                            ] ;

                    end

                    % Store curves
                    self.KbEvents{k,3} = data;

                end

            end

            % Store curves
            self.GraphData = self.KbEvents;

        end % function

        %------------------------------------------------------------------
        function ComputeDurations( self )
            % self.ComputeDurations()
            %
            % Compute durations for each keybinds

            kbevents = cell( length(self.Header) , 2 );

            % Take out T_start and T_stop from Data

            T_start_idx = strcmp( self.Data(:,1) , 'StartTime' );
            T_stop_idx = strcmp( self.Data(:,1) , 'StopTime' );

            data = self.Data( ~( T_start_idx + T_stop_idx ) , : );

            % Create list for each KeyBind

            [ unique_kb , ~ ,  idx ] = unique(self.Data(:,1), 'stable'); % Filter each Kb

            % Re-order each input to be coherent with Header order
            input_found = nan(size(unique_kb));
            for c = 1:length(unique_kb)

                input_idx  = strcmp(self.Header,unique_kb(c));
                input_idx  = find(input_idx);

                input_found(c) = input_idx;

            end

            kbevents(:,1) = self.Header; % Name of KeyBind

            count = 0;

            for c = 1:length(unique_kb)

                count = count + 1;

                kbevents{ input_found(count) , 2 } = data( idx == c , [4 3] ); % Time & Up/Down of Keybind

            end

            % Compute the difference between each time
            for e = 1 : size( kbevents , 1 )

                if size( kbevents{e,2} , 1 ) > 1

                    time = cell2mat( kbevents {e,2} (:,1) );                       % Get the times
                    kbevents {e,2} ( 1:end-1 , end+1 ) = num2cell( diff( time ) ); % Compute the differences

                end

            end

            self.KbEvents = kbevents;

        end % function

        %------------------------------------------------------------------
        function ComputePulseSpacing( self , graph )
            % self.ComputePulseSpacing() no plot, or self.ComputePulseSpacing(1) to plot
            %
            % Compute time between each "KeyIsDown", then plot it if asked

            if ~exist('graph','var')
                graph = 0;
            end

            for k = 1 : size(self.KbEvents,1)

                if ~isempty(self.KbEvents{k,2})

                    if isempty(self.KbEvents{k,2}{end,end})
                        self.KbEvents{k,2}{end,end} = 0;
                    end

                    data = cell2mat(self.KbEvents{k,2});

                    KeyIsDown_idx = data(:,2) == 1;
                    KeyIsDown_onset = data(KeyIsDown_idx,1);
                    KeyIsDown_spacing = diff(KeyIsDown_onset);

                    fprintf('N = %d \n',length(KeyIsDown_onset));
                    fprintf('mean = %f ms \n',mean(KeyIsDown_spacing)*1000);
                    fprintf('std = %f ms \n',std(KeyIsDown_spacing)*1000);

                    if graph

                        figure( ...
                            'Name'        , [mfilename ' : ' self.KbEvents{k,1} ] , ...
                            'NumberTitle' , 'off'                                      )

                        subplot(2,2,[1 2])
                        plot(KeyIsDown_spacing)

                        subplot(2,2,3)
                        hist(KeyIsDown_spacing)

                        if ~isempty(which('boxplot'))
                            subplot(2,2,4)
                            boxplot(KeyIsDown_spacing)
                            grid on
                        end

                    end

                end

            end

        end % function

        %------------------------------------------------------------------
        function GenerateMRITrigger( self , tr, volumes, starttime )
            % self.GenerateMRITrigger( TR = positive number , Volumes = positive integer, StartTime = onset of the first volume )
            %
            % Generate MRI trigger according to he given number of Volumes
            % and the TR.

            % ================ Check input argument =======================

            % narginchk(3,3)
            % narginchk introduced in R2011b
            if nargin > 4 || nargin < 3
                error('%s uses 3 or 4 input argument(s)','GenerateMRITrigger')
            end

            if nargin == 3
                starttime = 0;
            end

            % --- tr ----
            if ~( isnumeric(tr) && tr > 0 )
                error('TR must be positive')
            end

            % --- volumes ----
            if ~( isnumeric(volumes) && volumes > 0 && volumes == round(volumes) )
                error('Volumes must be a positive integer')
            end

            % --- starttime ----
            if ~( isnumeric(starttime) && starttime >= 0 )
                error('StartTime must be positive or null')
            end


            % ======================= Callback ============================

            % MRI_trigger_tag = '5%'; % fORP in USB
            MRI_trigger_tag = self.Header{1};
            pulse_duration = 0.020; % seconds

            % Check if TR is compatible with the pulse duration
            if tr < pulse_duration
                error('pulse_duration is set to %.3f, but TR must be such as TR > pulse_duration',pulse_duration)
            end

            % Fill Data whith MRI trigger events

            for v = 1 : volumes

                self.AddEvent({ MRI_trigger_tag starttime+(v-1)*tr                1 starttime+(v-1)*tr                 })
                self.AddEvent({ MRI_trigger_tag starttime+(v-1)*tr+pulse_duration 0 starttime+(v-1)*tr+pulse_duration  })

            end

        end % function

        %------------------------------------------------------------------
        function GetQueue( self )
            % self.GetQueue()
            %
            % Fetch the queue and use AddEvent method to fill self.Data
            % according to the KbList

            for index = 1 : length(self.Keyboard.keyboardIndices)

                while KbEventAvail(self.Keyboard.keyboardIndices(index))
                    [evt, ~] = KbEventGet(self.Keyboard.keyboardIndices(index)); % Get all queued keys
                    if any( evt.Keycode == self.KbList )
                        key_idx = evt.Keycode == self.KbList;
                        self.AddEvent( { self.Header{ key_idx } evt.Time evt.Pressed NaN } )
                    end
                end

            end

        end % function

        %------------------------------------------------------------------
        function Start( self )
            % self.Start()
            %
            % Initialise the KeyBind Queue and start collecting the inputs

            kbVect = zeros(1,256);
            kbVect(self.KbList) = 1;

            for index = 1 : length(self.Keyboard.keyboardIndices)

                KbQueueCreate(self.Keyboard.keyboardIndices(index),kbVect)
                KbQueueStart(self.Keyboard.keyboardIndices(index))

            end

        end % function

        %------------------------------------------------------------------
        function Stop( self )
            % self.Stop()
            %
            % Stop collecting KeyBinds and Release the device

            for index = 1 : length(self.Keyboard.keyboardIndices)

                KbQueueStop(self.Keyboard.keyboardIndices(index))
                KbQueueRelease(self.Keyboard.keyboardIndices(index))

            end

        end % function

    end % methods


end % class
