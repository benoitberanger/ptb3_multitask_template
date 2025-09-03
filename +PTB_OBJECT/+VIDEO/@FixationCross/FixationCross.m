classdef FixationCross < PTB_OBJECT.VIDEO.Base
    % FIXATIONCROSS Class to prepare and draw a fixation cross in PTB

    properties(GetAccess = public, SetAccess = public)
        % User accessible paramters :
        dim      (1,1) double % ratio from window_size_y, from 0 to 1
        width    (1,1) double % ratio from self.dim, from 0 to 1
        color    (1,4) uint8  % [R G B a] from 0 to 255
        center_x (1,1) double % ratio from window_size_x, from 0 to 1
        center_y (1,1) double % ratio from window_size_y, from 0 to 1
    end % props

    properties(GetAccess = public, SetAccess = protected)
        % Internal parameters :
        dim_px         (1,1) double
        width_px       (1,1) double
        center_x_px    (1,1) double
        center_y_px    (1,1) double
        coord_rects    (4,2) double % pre-calculated coordinates of the cross for PTB, in pixels
        coord_dot      (1,4) double
        coord_mask     (1,4) double
        width_mask     (1,1) double
        coord_frame    (1,4) double
        color_frame    (1,4) uint8  % [R G B a] from 0 to 255
    end % props

    methods(Access = public)

        %--- constructor --------------------------------------------------
        function self = FixationCross()
            % pass
        end % fcn

        %------------------------------------------------------------------
        function GenerateCoords( self )
            % ratio->px
            self.dim_px      = self.dim * self.window.size_y;
            self.width_px    = self.dim_px * self.width;
            self.center_x_px = self.center_x * self.window.size_x;
            self.center_y_px = self.center_y * self.window.size_y;

            % re-compute
            hRect = [0 0 self.dim_px   self.width_px ];
            vRect = [0 0 self.width_px self.dim_px   ];
            self.coord_rects = [
                CenterRectOnPoint(hRect, self.center_x_px, self.center_y_px)
                CenterRectOnPoint(vRect, self.center_x_px, self.center_y_px)
                ]';

            dotRect = [0 0 self.width_px self.width_px]*0.8;
            self.coord_dot = CenterRectOnPoint(dotRect, self.center_x_px, self.center_y_px);

            h = sqrt(self.dim_px^2 + self.width_px^2);
            self.width_mask = h - self.dim_px;
            maskRect = [0 0 h+1 h+1];
            self.coord_mask = CenterRectOnPoint(maskRect, self.center_x_px, self.center_y_px);

            frameRect = [0 0 self.dim_px+2 self.dim_px+2];
            self.coord_frame = CenterRectOnPoint(frameRect, self.center_x_px, self.center_y_px);
            self.color_frame = [self.color(1)/2 self.color(2)/2 self.color(3)/2 self.color(4)];
        end % fcn

        %------------------------------------------------------------------
        function Draw( self )
            Screen('FillRect' , self.window.ptr, self.color          , self.coord_rects);
            Screen('FillOval' , self.window.ptr, self.window.bg_color, self.coord_dot  );
            Screen('FrameOval', self.window.ptr, self.window.bg_color, self.coord_mask , self.width_mask/2);
            Screen('FrameOval', self.window.ptr, self.color_frame    , self.coord_frame, 1);
        end % fcn

    end % meths

end % class
