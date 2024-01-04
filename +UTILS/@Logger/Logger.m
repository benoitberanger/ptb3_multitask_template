classdef Logger < handle
    % Singleton class, only accessed using `logger = UTILS.Logger.get()`
    % the end user will only be interesed in the "public" part


    %% public

    methods(Static, Access = public)

        function self = getInstance()
            self = UTILS.Logger.get();
        end % fcn
        function self = get() % shortcur
            self = UTILS.Logger.instance;
        end % fcn

    end % meths

    properties(GetAccess = public, SetAccess = public)
        padding (1,1) double {mustBeInteger, mustBeNonnegative} = 20;
    end % props

    methods(Access = public)

        function log(self, formatted_char, varargin)
            fprintf('%s\n', self.FormatMessage(formatted_char, varargin{:}));
        end% fcn

        function warning(self, formatted_char, varargin)
            warning(self.FormatMessage(formatted_char, varargin{:}));
        end% fcn

        function error(self, formatted_char, varargin)
            error(self.FormatMessage(formatted_char, varargin{:}));
        end% fcn

        function assert(self, condition, formatted_char, varargin)
            assert(condition, self.FormatMessage(formatted_char, varargin{:}));
        end% fcn

    end % meths


    %% private

    properties(Constant, Access = private)
        instance (1,1) UTILS.Logger = UTILS.Logger()
    end % props

    properties(Constant, Access = public)
        creation (1,:) char         = datestr(now, 'yyyy-mm-dd HH:MM:ss')
    end % props

    methods (Access = private)

        function self = Logger() % constructor
            % pass
        end

        function str = FormatMessage(self, formatted_char, varargin)
            msg = sprintf(formatted_char, varargin{:});
            str = sprintf(sprintf('[%-*s - %s] %s', self.padding, self.getCaller(), self.getTimeStamp() , msg));
        end

    end % meths

    methods (Static, Access = private)

        function str = getCaller()
            stack = dbstack();
            str = stack(4).name;
        end

        function str = getTimeStamp()
            str = datestr(now, 'yyyy-mm-dd HH:MM:ss');
        end

    end % meths


end % class
