classdef Logger < handle
    % Singleton class, only accessed using `logger = getLogger()`
    % the end user will only be interesed in the "public" part


    %% public

    methods(Static, Access = public)

        function self = getInstance()
            self = getLogger();
        end % fcn
        function self = get() % shortcur
            self = UTILS.Logger.instance;
        end % fcn

        % declare this function from external file as static method
        cprintf(style,format,varargin)

    end % meths

    properties(GetAccess = public, SetAccess = public)
        padding (1,1) double {mustBeInteger, mustBeNonnegative} = 40;
    end % props

    methods(Access = public)

        function log(self, formatted_char, varargin)
            fprintf('%s\n', self.FormatMessage(formatted_char, varargin{:}));
        end% fcn

        function ok(self, formatted_char, varargin)
            self.cprintf('Comments', self.FormatMessage([formatted_char '\n'], varargin{:}));
        end% fcn

        function warn(self, formatted_char, varargin)
            self.cprintf('Keywords', self.FormatMessage([formatted_char '\n'], varargin{:}));
        end% fcn
        function warning(self, formatted_char, varargin)
            warning(self.FormatMessage(formatted_char, varargin{:}));
        end% fcn

        function err(self, formatted_char, varargin)
            self.cprintf('Errors', self.FormatMessage([formatted_char '\n'], varargin{:}));
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
            str = sprintf('[%s - %-*s] %s', self.getTimeStamp(), self.padding, self.getCaller(), msg);
            str = strrep(str,'\','\\');
        end

    end % meths

    methods (Static, Access = private)

        function str = getCaller()
            stack = dbstack(3,'-completenames');

            % basic cleaning
            str = strrep(stack(1).file, UTILS.GET.RootDir(),'');
            str = str(2:end); % remove the first `filesep`
            str = strrep(str, '.m', ''); % remove .m extension

            % convert the package disk separator to the matlab script usage (easier copy-paste)
            str = strrep(str, [filesep '+'], '.');
            str = strrep(str, filesep, '.');
            str = strrep(str, '+', '');
        end

        function str = getTimeStamp()
            str = datestr(now, 'HH:MM:ss');
        end

    end % meths


end % class
