classdef Event < UTILS.RECORDER.Omni
    % EVENT Class to record any stimulation events


    %% Properties

    properties

        BlockData      = cell(0) % cell( ? , Columns )
        BlockGraphData = cell(0) % cell( ? , Columns )

    end % properties


    %% Methods

    methods

        %------------------------------------------------------------------
        %                           Constructor
        %------------------------------------------------------------------
        function self = Event( header , numberofevents )
            % self = EventRecorder( Header = cell( 1 , Columns ) , NumberOfEvents = double(positive integer) )

            % Usually, first column is the event name, and second column is
            % it's onset.

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
                if isnumeric( numberofevents ) && ...
                        numberofevents == round( numberofevents ) && ...
                        numberofevents > 0 % Check input argument
                    self.NumberOfEvents = numberofevents;
                else
                    error( 'NumberOfEvents must be a positive integer' )
                end

            end

            % ================== Callback =============================

            self.Description = mfilename( 'fullpath' );
            self.Columns     = length( self.Header );
            self.Data        = cell( self.NumberOfEvents , self.Columns );

        end

        %------------------------------------------------------------------
        function MakeBlocks( self )
            % self.MakeBlocks()
            %
            % Transform self.Data Events into Block
            % IMPORTANT : do NOT applay self.ComputeDurations, you need to
            % fill the duration column manually

            % Find the blocks
            [ ~ , ~ , indC ] = unique( self.Data(:,1), 'stable' );

            % Where do they start ?
            blockStart = vertcat( -1 , diff(indC) );
            for b = 1 : length(blockStart)
                if b > 1
                    if self.Data{b-1,2} + self.Data{b-1,3} < self.Data{b,2} - self.Data{b-1,3} % if huge gap between two events with the same name
                        blockStart(b) = 1; % add a start block
                    end

                end
            end
            blockStart_idx = find(blockStart);

            % Create a cell, equivalent of self.Data, but for the blocks
            blockData = cell(length(blockStart_idx),size(self.Data,2));
            for b = 1 : length(blockStart_idx)

                % Copy line
                blockData(b,:) = self.Data(blockStart_idx(b),:);

                % Change the duration : block duration
                if b ~= length(blockStart_idx)
                    blockData{b,3} = sum( cell2mat( self.Data( blockStart_idx(b) : blockStart_idx(b+1)-1 , 3 ) ) );
                end

            end

            % Store
            self.BlockData = blockData;

        end % function

        %------------------------------------------------------------------
        function BuildGraph( self , method )
            % self.BuildGraph( [method] )
            %
            % Build curves for each events, ready to be plotted.
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
                    input  = 'Data';
                    output = 'GraphData';
                case 'block'
                    input  = 'BlockData';
                    output = 'BlockGraphData';
                otherwise
                    error( 'unknown method : %s' , method )
            end

            % ===================== Regroup each event ====================

            % Check if not empty
            self.IsEmptyProperty(input);

            [ event_name , ~ , idx_event2data ] = unique(self.(input)(:,1), 'stable');

            % Col 1 : event_name
            % Col 2 : self.Data(event_name)
            %Col 3 ~= self.Data(event_name), adapted for plot
            self.(output) = cell(length(event_name),3);

            for e = 1:length(event_name)
                self.(output){e,1} = event_name{e};
                self.(output){e,2} = cell2mat ( self.(input)( idx_event2data == e , 2:3 ) );
            end

            % ================= Build curves for each Event ===============

            for e = 1 : size( self.(output) , 1 ) % For each Event

                data = [ self.(output){e,2} ones(size(self.(output){e,2},1),1) ]; % Catch data for this Event

                N  = size( data , 1 ); % Number of data = UP(0) + DOWN(1)

                % Here we need to build a curve that looks like recangles
                for n = N:-1:1

                    switch n

                        case N

                            % Split data above & under the point
                            dataABOVE  = data( 1:n-1 ,: );
                            dataMIDDLE = data( n ,: );
                            dataUNDER  = NaN( 1 , size(data,2) );

                        case 1

                            % Split data above & under the point
                            dataABOVE  = data( 1:n-1 ,: );
                            dataMIDDLE = data( n ,: );
                            dataUNDER  = data( n+1:end , : );

                        otherwise

                            % Split data above & under the point
                            dataABOVE  = data( 1:n-1 ,: );
                            dataMIDDLE = data( n ,: );
                            dataUNDER  = data( n+1:end , : );

                    end

                    % Add a point ine curve to build a rectangle
                    data  = [ ...

                    dataABOVE ;...

                    % Add points to create a rectangle
                    dataMIDDLE(1,1) NaN NaN ;...
                    dataMIDDLE(1,1) NaN 0 ;...
                    dataMIDDLE(1,:) ;...
                    dataMIDDLE(1,1)+dataMIDDLE(1,2) NaN 1 ;...
                    dataMIDDLE(1,1)+dataMIDDLE(1,2) NaN 0 ;...

                    dataUNDER ...

                    ] ;

                end

                % Delete second column
                data(:,2) = [];

                % Store curves
                self.(output){e,3} = data;

            end

        end % function

    end % methods


end % class
