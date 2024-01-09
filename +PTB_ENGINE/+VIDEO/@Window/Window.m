classdef Window < handle
    % Class to open PTB window, and set its parameters


    %% Public

    properties(GetAccess = public, SetAccess = public)
        % here is a list of "default" parameters :

        % user-depend settings
        bg_color      (1,3) double  = [128 128 128]; % [R G B], from 0 to 255

        % from the gui
        screen_id           double % mandatory, you need to be set by the user
        is_transparent(1,1) logical = false;
        is_windowed   (1,1) logical = false;
        is_recored    (1,1) logical = false;

        % my suggestion of useful settings
        anti_aliazing (1,1) double  = 4; % number of samples for multi-sample anti-aliazing

        % for debugging
        opaqueForHID  (1,1) logical = false; % see PsychDebugWindowConfiguration
        opacity       (1,1) double  = 0.5    % see PsychDebugWindowConfiguration
        factor        (1,1) double  = 0.5

    end % props

    methods(Access = public)

        %------------------------------------------------------------------
        function Open(self)
            % paramters come from `global S` and default paramters (see above, in the Public)

            logger = getLogger();
            logger.log('Preparing PTB window')
            clear Screen % reset all cashed PTB screen settings

            % Transparent
            if self.is_transparent
                PsychDebugWindowConfiguration(self.opacity, self.opacity);
            end

            % Use GStreamer : for videos
            if self.is_recored
                Screen('Preference', 'OverrideMultimediaEngine', 1);
            end

            % PTB opening screen will be empty = black screen
            Screen('Preference', 'VisualDebugLevel', 1);

            % Windowed
            if self.is_windowed
                [ScreenWidth, ScreenHeight]=Screen('WindowSize', self.screen_id);
                SmallWindow = ScaleRect( [0 0 ScreenWidth ScreenHeight] , self.factor , self.factor );
                WindowRect = CenterRectOnPoint( SmallWindow , ScreenWidth/2 , ScreenHeight/2 );
            else
                WindowRect = [];
            end

            % Open
            logger.assert(~isempty(self.screen_id), 'screen_id must be set properly. See Screen(''Screens?'') ')
            try
                [self.ptr,self.rect] = Screen('OpenWindow',self.screen_id,self.bg_color,WindowRect,[],[],[],self.anti_aliazing);
            catch err
                logger.err(err)
                Screen('Preference', 'SkipSyncTests', 1)
                [self.ptr,self.rect] = Screen('OpenWindow',self.screen_id,self.bg_color,WindowRect,[],[],[],self.anti_aliazing);
            end

            % Center, Width & Hight
            [self.  size_x, self.  size_y] = RectSize  (self.rect);
            [self.center_x, self.center_y] = RectCenter(self.rect);

            logger.log('PTB window & rendring paramters set')
        end % fcn

    end % props


    %% Protected

    properties(GetAccess = public, SetAccess = protected)
        % paramters setted after Open()
        ptr           (1,1) double
        rect          (1,4) double
        size_x        (1,1) double
        size_y        (1,1) double
        center_x      (1,1) double
        center_y      (1,1) double
    end % props

    methods(Access = protected)
    end % props


    %% Private

    properties(GetAccess = public, SetAccess = private)
    end % props

    methods(Access = private)
    end % props


end % class
