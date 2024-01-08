classdef Omni < UTILS.RECORDER.Base
    % OMNI is a 'virtual' class : all subclasses contain this virtual class methods and attributes
    % OmniRecorder can record everything.
    % Data are stored in Cell.
    % WARNING : if you need to store numeric data at high speed or for a lot of sample, use SampleRecorder.


    %% Properties

    properties
        Data           (:,:) cell                                          % cell( NumberOfEvents , Columns )
        Columns        (1,1) double {mustBeInteger,mustBeInteger}
        NumberOfEvents (1,1) double {mustBeInteger,mustBeInteger}
        EventCount     (1,1) double {mustBeInteger,mustBeInteger}
        GraphData      (:,:) cell                                          % cell( 'ev1' curve1 ; 'ev2' curve2 ; ... )
    end


    %% Methods

    methods

        %---- Constructor -------------------------------------------------
        function self = Omni()
            % pass
        end % fcn

        %------------------------------------------------------------------
        function AddEvent( self , event )
            % self.AddEvent( cell(1,n) = { 'eventName' data1 date2 ... } )
            %
            % Add event, according to the dimensions given by the Header

            if length( event ) == self.Columns % Check input arguments
                if size( event , 1 ) > 0 && size( event , 2 ) == 1 % if iscolumn( event )
                    event = event';
                end
                self.IncreaseEventCount;
                self.Data( self.EventCount , : ) = event;
            else
                error( 'Wrong number of arguments' )
            end
        end % function

        %------------------------------------------------------------------
        function AddStartTime( self, starttime_name , starttime )
            % self.AddStartTime( StartTime_name = str , StartTime = double )
            %
            % Add special event { StartTime_name starttime }

            if ~ischar( starttime_name )
                error( 'StartTime_name must be string' )
            end

            if ~isnumeric( starttime )
                error( 'StartTime must be numeric' )
            end

            self.IncreaseEventCount;
            self.Data( self.EventCount , 1:3 ) = { starttime_name starttime 0 };
            % ex : Add T_start = 0 on the next line (usually first line)

        end % function

        %------------------------------------------------------------------
        function AddStopTime( self, stoptime_name , starttime )
            % self.AddStartTime( StopTime_name = str , StartTime = double )
            %
            % Add special event { StopTime_name starttime }

            if ~ischar( stoptime_name )
                error( 'StopTime_name must be string' )
            end

            if ~isnumeric( starttime )
                error( 'StopTime must be numeric' )
            end

            self.IncreaseEventCount;
            self.Data( self.EventCount , 1:3 ) = { stoptime_name starttime 0 };
            % ex : Add T_stop = 0 on the next line (usually last line)

        end % function

        %------------------------------------------------------------------
        function ClearEmptyEvents( self )
            % self.ClearEmptyEvents()
            %
            % Delete empty rows. Useful when NumberOfEvents is not known
            % precisey but set to a great value (better for prealocating
            % memory).

            empty_idx = cellfun( @isempty , self.Data(:,1) );
            self.Data( empty_idx , : ) = [];

        end % function

        %------------------------------------------------------------------
        function ComputeDurations( self )
            % self.ComputeDurations()
            %
            % Compute durations for each onsets

            onsets               = cell2mat( self.Data (:,2) ); % Get the times
            duration             = diff(onsets);               % Compute the differences
            self.Data(1:end-1,3) = num2cell( duration );       % Save durations

            % For the last event, usually StopTime, we need an exception.
            if strcmp( self.Data{end,1} , 'StopTime' )
                self.Data{end,3} = 0;
            end


        end % function

        %------------------------------------------------------------------
        function [ output ] = Fetch( self, str, column )
            %FETCH will fetch the lines containing 'str' in the column 'column'
            %
            % Exemple : self.Fetch( '+', self.Get('reward') )
            %
            % If 'column' is not defined, it will fetch in the culumn=1;
            % To easily get a column index, use self.Get('columnRegex') method

            if nargin < 3
                column = 1;
            end

            assert( nargin>=2 , 'str must be defined')
            assert( ischar(str) && isvector(str), 'str must be char' )

            try
                lines = ~cellfun(@isempty,regexp(self.Data(:,column),str,'once'));
            catch err
                error('self.Data(:,column) must be char')
            end

            output = self.Data(lines,:);

        end % function

        %------------------------------------------------------------------
        function IncreaseEventCount( self )
            % self.IncreaseEventCount()
            %
            % Method used by other methods of the class. Usually, it's not
            % used from outside of the class.

            self.EventCount = self.EventCount + 1;

        end % function

        %------------------------------------------------------------------
        function Plot( self , method )
            % self.Plot( [method] )
            %
            % Plot events over the time.
            % method = 'normal' , 'block'

            % Arguments ?
            if nargin < 2
                method = 'normal';
            else
                if ~ischar(method)
                    error('method must be a char')
                end
            end

            switch lower(method)
                case 'normal'
                    input  = 'GraphData';
                case 'block'
                    input  = 'BlockGraphData';
                otherwise
                    error( 'unknown method : %s' , method )
            end

            % =============== BuildGraph if necessary =====================

            % Each subclass has its own BuildGraph method because Data
            % properties are different. But each BuildGraph subclass method
            % converge to a uniform GraphData.

            if nargin < 2 % no input argument

                if isprop(self,'BlockData') && ~isempty(self.BlockData) && isempty(self.BlockGraphData) % BlockData exists ?
                    self.BuildGraph('block')
                    input  = 'BlockGraphData';

                elseif isprop(self,'BlockData') && ~isempty(self.BlockData)
                    input  = 'BlockGraphData';

                elseif  isempty(self.GraphData)
                    self.BuildGraph;

                end

            end

            % ======================== Plot ===============================


            className = class(self);

            % Depending on the object calling the method, the display changes.
            switch className
                case 'UTILS.RECORDER.Event'
                    display_method = '+';
                case 'UTILS.RECORDER.Kb'
                    display_method = '*';
                case 'UTILS.RECORDER.Planning'
                    display_method = '+';
                otherwise
                    error('Unknown object caller. Check self.Description')
            end

            % Figure
            figure( ...
                'Name'        , [ inputname(1) ' : ' className ] , ...
                'NumberTitle' , 'off'                         ...
                )
            hold all

            % For each Event, plot the curve
            for e = 1 : size( self.(input) , 1 )

                if ~isempty(self.(input){e,2})

                    switch display_method

                        case '+'
                            plot( self.(input){e,3}(:,1) , self.(input){e,3}(:,2) + e )

                        case '*'
                            plot( self.(input){e,3}(:,1) , self.(input){e,3}(:,2) * e )

                        otherwise
                            error('Unknown display_method')
                    end

                else

                    plot(0,NaN)

                end

            end

            % Legend
            lgd = legend( self.(input)(:,1) );
            set(lgd,'Interpreter','none','Location','Best')


            % ================ Adapt the graph axes limits ================

            % Change the limit of the graph so we can clearly see the
            % rectangles.

            UTILS.ScaleAxisLimits( gca , 1.1 )

            % ================ Change YTick and YTickLabel ================

            % Put 1 tick in the middle of each event
            switch display_method
                case '+'
                    set( gca , 'YTick' , (1:size( self.(input) , 1 ))+0.5 )
                case '*'
                    set( gca , 'YTick' , (1:size( self.(input) , 1 )) )
            end

            % Set the tick label to the event name
            set( gca , 'YTickLabel' , self.(input)(:,1) )

            % Not all versions of MATLAB have this option
            try
                set(gca, 'TickLabelInterpreter', 'none')
            catch %#ok<CTCH>
            end

        end % function

        %------------------------------------------------------------------
        function PlotHRF( self, TR, nrVolumes )
            %PLOTHRF convolves the events with HRF, using SPM pipeline
            % TR is required to estimate the stimulus response function


            %=== Checks

            % SPM
            assert( ~isempty( which('spm_hrf') ) , 'SPM toolbox is required' )

            % Data
            assert( size(self.Data,1)>1, 'Empty data' )

            % TR
            assert( nargin>=1, 'TR is required to estimate the stimulus response function' )
            assert( isnumeric(TR) && isscalar(TR) && TR>0, 'TR must be positive' )

            % nrVolumes
            if nargin < 3
                nrVolumes = ceil( self.Data{end,2}/TR ) + 1;
            end
            assert( isnumeric(nrVolumes) && isscalar(nrVolumes) && nrVolumes>0 && nrVolumes==round(nrVolumes) , 'nrVolumes must be positive integer' )


            %=== Format self.Data into names onsets durations

            [names,~,indC] = unique( self.Data(:,1) , 'stable' );

            onsets    = cell(size(names));
            durations = cell(size(names));

            for n = 1 : length(names)
                onsets{n}    = cell2mat( self.Data(indC==n,2) );
                durations{n} = cell2mat( self.Data(indC==n,3) );
            end % names


            %=== Pipe my environement with SPM

            SPM.xY.RT = TR;
            SPM.nscan = nrVolumes;

            multicond           = struct;
            multicond.names     = names;
            multicond.onsets    = onsets;
            multicond.durations = durations;

            SPM.xBF.name = 'hrf'; % it means cannonical HRF
            SPM.xBF.UNITS = 'secs';


            %=== SPM : part 1

            %-Microtime onset and microtime resolution
            %--------------------------------------------------------------------------
            fMRI_T     = spm_get_defaults('stats.fmri.t');
            fMRI_T0    = spm_get_defaults('stats.fmri.t0');
            SPM.xBF.T  = fMRI_T;
            SPM.xBF.T0 = fMRI_T0;

            %-Time units, dt = time bin {secs}
            %--------------------------------------------------------------------------
            SPM.xBF.dt     = SPM.xY.RT/SPM.xBF.T;

            %-Get basis functions
            %--------------------------------------------------------------------------
            SPM.xBF        = spm_get_bf(SPM.xBF);


            %=== SPM : part 2

            i = 1;

            sess.cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});

            % %-Load MAT-file
            % %------------------------------------------------------------------
            % try
            %     multicond = load('/mnt/data/benoit/Protocol/NBI/fmri/behaviour_data/spmReady_MTMST_files/2016_04_29_NBI_Pilote01/MT_LEFT.mat');
            % catch
            %     error('Cannot load %s',sess.multi{1});
            % end

            %-Check structure content
            %------------------------------------------------------------------
            if ~all(isfield(multicond, {'names','onsets','durations'})) || ...
                    ~iscell(multicond.names) || ...
                    ~iscell(multicond.onsets) || ...
                    ~iscell(multicond.durations) || ...
                    ~isequal(numel(multicond.names), numel(multicond.onsets), ...
                    numel(multicond.durations))
                error(['Multiple conditions MAT-file ''%s'' is invalid:\n',...
                    'File must contain names, onsets, and durations '...
                    'cell arrays of equal length.\n'],sess.multi{1});
            end

            for j=1:numel(multicond.onsets)

                %-Mutiple Conditions: names, onsets and durations
                %--------------------------------------------------------------
                cond.name     = multicond.names{j};
                if isempty(cond.name)
                    error('MultiCond file: sess %d cond %d has no name.',i,j);
                end
                cond.onset    = multicond.onsets{j};
                if isempty(cond.onset)
                    error('MultiCond file: sess %d cond %d has no onset.',i,j);
                end
                cond.duration = multicond.durations{j};
                if isempty(cond.onset)
                    error('MultiCond file: sess %d cond %d has no duration.',i,j);
                end

                %-Mutiple Conditions: Time Modulation
                %--------------------------------------------------------------
                if ~isfield(multicond,'tmod'); %#ok<*NOSEL>
                    cond.tmod = 0;
                else
                    try
                        cond.tmod = multicond.tmod{j};
                    catch
                        error('Error specifying time modulation.');
                    end
                end

                %-Mutiple Conditions: Parametric Modulation
                %--------------------------------------------------------------
                cond.pmod = [];
                if isfield(multicond,'pmod')
                    try
                        %-Check if a PM is defined for that condition
                        if (j <= numel(multicond.pmod)) && ...
                                ~isempty(multicond.pmod(j).name)
                            for ii = 1:numel(multicond.pmod(j).name)
                                cond.pmod(ii).name  = multicond.pmod(j).name{ii};
                                cond.pmod(ii).param = multicond.pmod(j).param{ii};
                                cond.pmod(ii).poly  = multicond.pmod(j).poly{ii};
                            end
                        end
                    catch
                        warning('Error specifying parametric modulation.');
                        rethrow(lasterror); %#ok<*LERR>
                    end
                end

                %-Mutiple Conditions: Orthogonalisation of Modulations
                %--------------------------------------------------------------
                if isfield(multicond,'orth') && (j <= numel(multicond.orth))
                    cond.orth    = multicond.orth{j};
                else
                    cond.orth    = true;
                end

                %-Append to singly-specified conditions
                %--------------------------------------------------------------
                sess.cond(end+1) = cond;
            end


            %-Conditions
            %----------------------------------------------------------------------
            U = [];

            for j = 1:numel(sess.cond)

                %-Name, Onsets, Durations
                %------------------------------------------------------------------
                cond      = sess.cond(j);
                U(j).name = {cond.name}; %#ok<*AGROW>
                U(j).ons  = cond.onset(:);
                U(j).dur  = cond.duration(:);
                U(j).orth = cond.orth;
                if isempty(U(j).orth), U(j).orth = true; end
                if length(U(j).dur) == 1
                    U(j).dur = repmat(U(j).dur,size(U(j).ons));
                elseif numel(U(j).dur) ~= numel(U(j).ons)
                    error('Mismatch between number of onset and number of durations.');
                end

                %-Modulations
                %------------------------------------------------------------------
                P  = [];
                q1 = 0;
                %-Time Modulation
                %     switch job.timing.units
                %         case 'secs'
                sf    = 1 / 60;
                %         case 'scans'
                %             sf    = job.timing.RT / 60;
                %         otherwise
                %             error('Unknown unit "%s".',job.timing.units);
                %     end
                if cond.tmod > 0
                    P(1).name = 'time';
                    P(1).P    = U(j).ons * sf;
                    P(1).h    = cond.tmod;
                    q1        = 1;
                end
                %-Parametric Modulations
                if ~isempty(cond.pmod)
                    for q = 1:numel(cond.pmod)
                        q1 = q1 + 1;
                        P(q1).name = cond.pmod(q).name;
                        P(q1).P    = cond.pmod(q).param(:);
                        P(q1).h    = cond.pmod(q).poly;
                    end
                end
                %-None
                if isempty(P)
                    P.name = 'none';
                    P.h    = 0;
                end

                U(j).P = P;

            end

            SPM.Sess.U = U;


            %=== SPM : part 3

            s = 1;

            %-Number of scans for this session
            %----------------------------------------------------------------------
            k = SPM.nscan(s);

            %-Create convolved stimulus functions or inputs
            %======================================================================

            %-Get inputs, neuronal causes or stimulus functions U
            %----------------------------------------------------------------------
            U = spm_get_ons(SPM,s);

            %-Convolve stimulus functions with basis functions
            %----------------------------------------------------------------------
            SPM.xBF.Volterra = 1;
            % [X,Xn,Fc] = spm_Volterra(U, SPM.xBF.bf, SPM.xBF.Volterra);
            [X,~,~] = spm_Volterra(U, SPM.xBF.bf, SPM.xBF.Volterra);

            %-Resample regressors at acquisition times (32 bin offset)
            %----------------------------------------------------------------------
            if ~isempty(X)
                X_reg = X((0:(k - 1))*fMRI_T + fMRI_T0 + 32,:);
            end

            %=== Plot

            % Figure
            figure( ...
                'Name'        , [ inputname(1) ' : ' class(self) ] , ...
                'NumberTitle' , 'off'                                ...
                )
            hold all

            t = (0 : nrVolumes-1) * TR;

            for n = 1 : length(names)

                plot( t, X_reg(:,n), 'DisplayName',names{n} )

            end

            xlabel ('time (s)')
            ylabel ('hemodynamic response (A.U.)')

            legend('show')


        end % function

        %------------------------------------------------------------------
        function ScaleTime( self, t0 )
            % self.ScaleTime()
            %
            % Scale the time origin to the first entry in self.Data

            if nargin < 2
                t0 = [];
            end

            % Onsets of events
            time = cell2mat( self.Data( : , 2 ) );

            className = class(self);

            % Depending on the object calling the method, the display changes.
            switch className
                case 'EventRecorder'
                    column_to_write_scaled_onsets = 2;
                    value = time(1);
                case 'KbLogger'
                    column_to_write_scaled_onsets = 4;
                    if ~isempty(t0)
                        value = t0;
                    else
                        value = time(1);
                    end
                case 'EventPlanning'
                    column_to_write_scaled_onsets = 2;
                    value = time(1);
                otherwise
                    error('Unknown object caller. Check self.Description')
            end

            % Write scaled time
            if ~isempty( time )
                self.Data( : , column_to_write_scaled_onsets ) = num2cell( time - value );
            else
                warning( 'Recorder:ScaleTime' , 'No data in %s.Data (%s)' , inputname(1) , className )
            end

        end % function

    end % meths


end % classdef
