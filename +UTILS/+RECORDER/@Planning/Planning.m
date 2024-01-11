classdef Planning < UTILS.RECORDER.Stim
    % planned stim, onset and duration will be compared to the ones registerd in @UTILS.RECORDER.Event

    properties(GetAccess = public, SetAccess = public)
        display_symbol = '+'
    end % properties

    methods(Access = public)

        %------------------------------------------------------------------
        %                           Constructor
        %------------------------------------------------------------------
        function self = Planning(nline,header_data)
            if nargin < 2
                header_data = {};
            end
            self = self@UTILS.RECORDER.Stim(nline,header_data)
            self.description = class(self);
        end

    end % methods

end % class
