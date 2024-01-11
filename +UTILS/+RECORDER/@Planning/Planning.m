classdef Planning < UTILS.RECORDER.Omni
    % EVENTPLANNING Class to schedul any stimulation events


    %% Properties

    properties

    end % properties


    %% Methods

    methods

        %------------------------------------------------------------------
        %                           Constructor
        %------------------------------------------------------------------
        function self = Planning( header )
            % self = EventRecorder( Header = cell( 1 , Columns ) )

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

            end

            % ================== Callback =============================

            self.Description = mfilename( 'fullpath' );
            self.Columns     = length( self.Header );
            self.Data        = cell( self.NumberOfEvents , self.Columns );

        end

        %------------------------------------------------------------------
        function AddPlanning( self , planning )
            % self.AddPlanning( cell(1,n) = { 'eventName' onset duration ... } )
            %
            % Add planning, according to the dimensions given by the Header

            if iscell(planning) && size( planning , 2 ) == self.Columns % Check input arguments
                self.EventCount = self.EventCount + size( planning , 1 );
                self.Data = [ self.Data ; planning ]; % == vertical concatenation
            else
                error( 'Wrong number of arguments' )
            end

        end % fcn

        %------------------------------------------------------------------
        function BuildGraph( self )
            % self.BuildGraph()
            %
            % Build curves for each events, ready to be plotted.

            % ===================== Regroup each event ====================

            % Check if not empty
            self.IsEmptyProperty('Data');

            [ event_name , ~ , idx_event2data ] = unique(self.Data(:,1), 'stable');

            % Col 1 : event_name
            % Col 2 : self.Data(event_name)
            %Col 3 ~= self.Data(event_name), adapted for plot
            self.GraphData = cell(length(event_name),3);

            for e = 1:length(event_name)
                self.GraphData{e,1} = event_name{e};
                self.GraphData{e,2} = cell2mat ( self.Data( idx_event2data == e , 2:3 ) );
            end

            % ================= Build curves for each Event ===============

            for e = 1 : size( self.GraphData , 1 ) % For each Event

                data = [ self.GraphData{e,2} ones(size(self.GraphData{e,2},1),1) ]; % Catch data for this Event

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
                self.GraphData{e,3} = data;

            end

        end % fcn


    end % methods


end % class
