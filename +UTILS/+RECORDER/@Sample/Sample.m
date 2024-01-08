classdef Sample < UTILS.RECORDER.Base
    % SAMPLE This class is optimized to store numerical samples.
    % Samples will be stored in a double array, not a cell array (like EventRecorder)


    %% Properties

    properties

        Data            = zeros(0) % zeros( NumberOfSamples , Columns )
        Columns         = 0        % double(positive integer)
        NumberOfSamples = 0        % double(positive integer)
        SampleCount     = 0        % double(positive integer)

    end % properties


    %% Methods

    methods

        %------------------------------------------------------------------
        %                           Constructor
        %------------------------------------------------------------------
        function self = Sample( header , numberofsamples )
            % self = EventRecorder( Header = cell( 1 , Columns ) , NumberOfSamples = double(positive integer) )

            % Usually, first column is the time, and other columns are samples type

            % ================ Check input argument =======================

            % Arguments ?
            if nargin > 0

                % --- header ----
                if isvector( header ) && ...
                        iscell( header ) && ...
                        ~isempty( header ) % Check input argument
                    if all( cellfun( @isstr , header ) )
                        self.Header =  header ;
                    else
                        error( 'Header should be a line cell of strings' )
                    end
                else
                    error( 'Header should be a line cell of strings' )
                end

                % --- numberofevents ---
                if isnumeric( numberofsamples ) && ...
                        numberofsamples == round( numberofsamples ) && ...
                        numberofsamples > 0 % Check input argument
                    self.NumberOfSamples = numberofsamples;
                else
                    error( 'NumberOfEvents must be a positive integer' )
                end

            end

            % ================== Callback =============================

            self.Description = mfilename( 'fullpath' );
            self.Columns     = length( self.Header );
            self.Data        = zeros( self.NumberOfSamples , self.Columns );

        end % ctor

        %------------------------------------------------------------------
        function AddSample( self , sample )
            % self.AddSample( double(1,n) = ( timestamp data1 date2 ... ) )
            %
            % Add sample, according to the dimensions given by the Header

            if length( sample ) == self.Columns % Check input arguments
                if size( sample , 1 ) > 0 && size( sample , 2 ) == 1 % if iscolumn( event )
                    sample = sample';
                end
                self.IncreaseSampleCount;
                self.Data( self.SampleCount , : ) = sample;
            else
                error( 'Wrong number of arguments' )
            end

        end % function

        %------------------------------------------------------------------
        function ClearEmptySamples( self )

            if self.SampleCount == 0
                self.Data = [];
                return
            end

            self.Data(self.SampleCount+1:end,:) = [];

        end % function

        %------------------------------------------------------------------
        function IncreaseSampleCount( self )
            % self.IncreaseSampleCount()
            %
            %

            self.SampleCount = self.SampleCount + 1;

        end % function

        %------------------------------------------------------------------
        function Plot( self )
            % self.Plot()
            %
            % Plot samples over the time.

            % Check if not empty
            self.IsEmptyProperty('Data');

            % Figure
            figure( ...
                'Name'        , [ inputname(1) ' : ' class(self) ] , ...
                'NumberTitle' , 'off'                         ...
                )
            hold all

            % For each Event, plot the curve
            for signal = 2 : size( self.Data , 2 )
                plot(self.Data(:,1),self.Data(:,signal));
            end

            % Legend
            lgd = legend( self.Header(2:end) );
            set(lgd,'Interpreter','none','Location','Best')

            xlabel(self.Header{1})

            % ================ Adapt the graph axes limits ================

            % Change the limit of the graph so we can clearly see the
            % rectangles.

            UTILS.ScaleAxisLimits( gca , 1.1 )

        end % function

        %------------------------------------------------------------------
        function PlotDiffTime( self )
            % self.PlotDiffTime()
            %
            % Plot diff(time).

            % Check if not empty
            self.IsEmptyProperty('Data');

            % Figure
            figure( ...
                'Name'        , [ inputname(1) ' : ' class(self) ] , ...
                'NumberTitle' , 'off'                         ...
                )
            hold all


            plot(self.Data(1:end-1,1),diff(self.Data(:,1)));


            % Legend
            lgd = legend( 'diff(time)' );
            set(lgd,'Interpreter','none','Location','Best')

            xlabel(self.Header{1})

            % ================ Adapt the graph axes limits ================

            % Change the limit of the graph so we can clearly see the
            % rectangles.

            UTILS.ScaleAxisLimits( gca , 1.1 )

        end % function

        %------------------------------------------------------------------
        function ScaleTime( self )
            % self.ScaleTime()
            %
            % Scale the time origin to the first entry in self.Data

            % Onsets of events
            time = self.Data( : , 1 );

            % Write scaled time
            if ~isempty( time )
                self.Data( : , 1 ) = time - time(1);
            else
                warning( 'SampleRecorder:ScaleTime' , 'No data in %s.Data (%s)' , inputname(1) )
            end

        end % function

    end % methods


end % class
