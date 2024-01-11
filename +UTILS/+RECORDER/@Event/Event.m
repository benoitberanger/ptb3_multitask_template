classdef Event < UTILS.RECORDER.Stim
    % real stim, onset and duration will be compared to the ones registerd in @UTILS.RECORDER.Planning

    methods(Access = public)

        %------------------------------------------------------------------
        %                           Constructor
        %------------------------------------------------------------------
        function self = Event(nline,header_data)
            if nargin < 2
                header_data = {};
            end
            self = self@UTILS.RECORDER.Stim(nline,header_data)
            self.description = class(self);
        end

    end % methods

end % class
