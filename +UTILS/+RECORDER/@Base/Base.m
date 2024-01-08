classdef Base < handle
    % BASE is a 'virtual' class : all subclasses contain this virtual class methods and attributes
    % This is a very basic object, just a container of simple methods


    %% Properties

    properties
        TimeStamp   (1,:) char  = datestr( now )          % Time stamp for the creation of object
        Description (1,:) char  = mfilename( 'fullpath' ) % Fullpath of the file
        Header      (1,:) cell  = {''}                    % Description of each columns
    end % props


    %% Methods

    methods

        %---- Constructor -------------------------------------------------
        function self = Base()
            % pass
        end

        %------------------------------------------------------------------
        function newObject = CopyObject( self )
            % newObject = self.CopyObject()
            %
            % Deep copy of the object

            % Class name ?
            className = class( self );

            % Properties of this class ?
            propOfClass = properties( self );

            % New instance of this class
            newObject = eval(className);

            % Copy each properties
            for p = 1 : length(propOfClass)
                newObject.(propOfClass{p}) = self.(propOfClass{p});
            end
        end % function

        %------------------------------------------------------------------
        function t = data2table( self )
            data = self.Data; % make a copy so it can be modified if necessary

            if iscell(data)

                % remove StartTime & StopTime
                startstop = strcmp( data(:,1), 'StartTime' ) | strcmp( data(:,1), 'StopTime' );
                data( startstop , : ) = [];

                t = cell2table(data,'VariableName',matlab.lang.makeValidName(self.Header));

            elseif isnumeric(data)

                t = array2table(data,'VariableName',matlab.lang.makeValidName(self.Header));

            end
        end % function

        %------------------------------------------------------------------
        function ExportToCSV( self, filename, withHeader )
            if nargin < 3
                withHeader = 1;
            end

            self.ExportToTxt(filename,'csv',withHeader)
        end % function

        %------------------------------------------------------------------
        function savestruct = ExportToStructure( self )
            % StructureToSave = self.ExportToStructure()
            %
            % Export all proporties of the object into a structure, so it
            % can be saved.
            % WARNING : it does not save the methods, just transform the
            % object into a common structure.

            ListProperties = properties(self);

            for prop_number = 1:length(ListProperties)
                savestruct.(ListProperties{prop_number}) = self.(ListProperties{prop_number});
            end
        end % function

        %------------------------------------------------------------------
        function ExportToTSV( self, filename, withHeader )
            if nargin < 3
                withHeader = 1;
            end

            self.ExportToTxt(filename,'tsv',withHeader)
        end % function

        %------------------------------------------------------------------
        function ExportToTxt( self, filename, filetype, withHeader )
            %EXPORTTOTXT print the self.Header and self.Data in a text file
            % withHeader=1 prints header (default), withHeader=0 does not.

            switch filetype
                case 'csv'
                    ext = '.csv';
                    sep = ';';
                case 'tsv'
                    ext = '.tsv';
                    sep = sprintf('\t');
                otherwise
                    error('unmapped filetype')
            end

            % Open file in write mod
            fileID = fopen( [ filename ext ] , 'w' , 'n' , 'UTF-8' );
            if fileID < 0
                error('%d cannot be opened', filename)
            end

            % Fill the file
            % Print header
            if withHeader
                for h = 1 : length(self.Header)
                    fprintf(fileID, '%s%s', self.Header{h},sep);
                end
                fprintf(fileID, '\n'); % end of line
            end

            % Print data
            for i = 1 : size(self.Data,1)
                for j = 1 : size(self.Data,2)

                    % Apply conversion if necessary
                    switch class(self.Data)

                        case 'cell'

                            if ischar(self.Data{i,j})
                                toprint = self.Data{i,j};

                            elseif isnumeric(self.Data{i,j})
                                toprint = num2str(self.Data{i,j});

                            elseif islogical(self.Data{i,j})
                                switch self.Data{i,j}
                                    case true
                                        toprint = 'TRUE';
                                    case false
                                        toprint = 'FALSE';
                                end

                            end


                        case 'double'

                            if isnumeric(self.Data(i,j))
                                toprint = num2str(self.Data(i,j));

                            elseif islogical(self.Data(i,j))
                                switch self.Data(i,j)
                                    case true
                                        toprint = 'TRUE';
                                    case false
                                        toprint = 'FALSE';
                                end

                            end

                        otherwise
                            warning('unmapped input type')
                    end

                    fprintf(fileID, '%s%s', toprint,sep);

                    % End of line
                    if j == size(self.Data,2)
                        fprintf(fileID, '\n');
                    end

                end % j
            end % i

            % Close the file
            fclose( fileID );

        end % function

        %------------------------------------------------------------------
        function [ output ] = Get( self, str, evt )
            %GET is not a classc "get" method
            %
            % Here, this method is a way to fetch :
            % 1) a column number      in slef.data . Syntax : columnNumber = obj.Get('regex'            )
            % 2) an element contained in self.Data . Syntax : element      = obj.Get('regex', lineNumber)
            %    lineNumber=integer ... => 1 element // lineNumber=vector => N elements // lineNumber=[] => all the column
            %
            % The 'regex' is a regular expression that will be found in obj.Header
            %

            column = ~cellfun(@isempty,regexp(self.Header,str,'once'));
            assert(any(column), 'Get method did not find ''%s'' in the Header', str)

            column = find(column);

            if nargin < 3
                output = column;
                return
            end

            assert( isnumeric(evt), 'evt, if is defined, mut be numeric' )

            if isempty(evt)
                output = self.Data(:,column);
                return
            end

            if isscalar(evt)
                switch class(self.Data)
                    case 'cell'
                        output = self.Data{evt,column};
                    case 'double'
                        output = self.Data(evt,column);
                    otherwise
                        output = self.Data{evt,column};
                end
                return
            end

            if isvector(evt)
                output = self.Data(evt,column);
                return
            end

            error('evt ?')
        end % function

        %------------------------------------------------------------------
        function IsEmptyProperty( self , propertyname )
            % self.IsEmptyProperty( PropertyName )
            %
            % Raise an error if self.'PropertyName' is empty

            % Fetch caller object
            [~, objName, ~] = fileparts(self.Description);

            if isempty(self.(propertyname))
                error('No data in %s.%s' , objName , propertyname )
            end
        end % function

    end % meths


end % classdef
