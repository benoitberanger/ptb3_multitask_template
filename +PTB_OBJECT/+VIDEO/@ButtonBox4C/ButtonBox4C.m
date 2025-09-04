classdef ButtonBox4C < PTB_OBJECT.VIDEO.Base


    properties(GetAccess = public, SetAccess = public)
        % User accessible paramters :
    end % props

    properties(GetAccess = public, SetAccess = protected)
        % Internal parameters :

        % [R G B a] from 0 to 255
        color_plastic  (1,4) uint8 = [128 128 128 255]
        color_border   (1,4) uint8 = [150 150 150 255]
        color_cable    (1,4) uint8 = [020 020 020 255]

        % [R G B] from 0 to 255 -> alpha chanel managed by the code
        color_1        (1,3) uint8 = [000 080 255]
        color_2        (1,3) uint8 = [255 230 000]
        color_3        (1,3) uint8 = [000 180 000]
        color_4        (1,3) uint8 = [255 000 000]

        % pre-calculated coordinates of the cross for PTB, in pixels
        
        dim_px         (1,1) double
        center_x_px    (1,1) double
        center_y_px    (1,1) double

        coord_plastic  (1,4) double
        width_border   (1,1) double
        coord_cable    (1,4) double
       
        coord_1        (1,4) double
        coord_2        (1,4) double
        coord_3        (1,4) double
        coord_4        (1,4) double

    end % props

    methods(Access = public)

        %--- constructor --------------------------------------------------
        function self = ButtonBox4C()
            % pass
        end % fcn

        %------------------------------------------------------------------
        function Prepare(self, side)

            % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            % SCALING PARAMETERS ARE HERE
            self.dim_px = 0.8 * self.window.size_y;
            d = self.dim_px; % shortcut

            self.width_border = 0.02 * d;

            rect_plastic = [0 0 1.00 0.50] * d;
            rect_cable   = [0 0 0.05 0.03] * d;

            spacing = d/5;
            rect_button = [0 0 1 1] * 0.80 * spacing;
            % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

            switch side
                case 'Left'
                    self.coord_plastic = CenterRectOnPoint(rect_plastic, 0.25*self.window.size_x, self.window.center_y);
                    [x,y] = RectCenter(self.coord_plastic);
                    self.coord_cable = CenterRectOnPoint(rect_cable, x + d/2 + rect_cable(3)/2, y - rect_plastic(4)/4 );

                    right = self.coord_plastic(3);
                    self.coord_1 = CenterRectOnPoint(rect_button, right - spacing*1, y + spacing/5);
                    self.coord_2 = CenterRectOnPoint(rect_button, right - spacing*2, y - spacing/5);
                    self.coord_3 = CenterRectOnPoint(rect_button, right - spacing*3, y - spacing/5);
                    self.coord_4 = CenterRectOnPoint(rect_button, right - spacing*4, y + spacing/5);
                case 'Right'
                    self.coord_plastic = CenterRectOnPoint(rect_plastic, 0.75*self.window.size_x, self.window.center_y);
                    [x,y] = RectCenter(self.coord_plastic);
                    self.coord_cable = CenterRectOnPoint(rect_cable, x - d/2 - rect_cable(3)/2, y - rect_plastic(4)/4 );

                    left = self.coord_plastic(1);
                    self.coord_1 = CenterRectOnPoint(rect_button, left + spacing*1, y + spacing/5);
                    self.coord_2 = CenterRectOnPoint(rect_button, left + spacing*2, y - spacing/5);
                    self.coord_3 = CenterRectOnPoint(rect_button, left + spacing*3, y - spacing/5);
                    self.coord_4 = CenterRectOnPoint(rect_button, left + spacing*4, y + spacing/5);
                otherwise
                    error('!')
            end

        end % fcn

        %------------------------------------------------------------------
        function Draw(self, button)
            Screen('FillRect' , self.window.ptr, self.color_plastic, self.coord_plastic);
            Screen('FrameRect', self.window.ptr, self.color_border , self.coord_plastic, self.width_border);
            Screen('FillRect' , self.window.ptr, self.color_cable  , self.coord_cable);

            Screen('FillOval' , self.window.ptr,  [self.color_1 030], self.coord_1);
            Screen('FillOval' , self.window.ptr,  [self.color_2 030], self.coord_2);
            Screen('FillOval' , self.window.ptr,  [self.color_3 030], self.coord_3);
            Screen('FillOval' , self.window.ptr,  [self.color_4 030], self.coord_4);

            if nargin > 1
                if     button == 1, Screen('FillOval' , self.window.ptr,  [self.color_1 255], self.coord_1);
                elseif button == 2, Screen('FillOval' , self.window.ptr,  [self.color_2 255], self.coord_2);
                elseif button == 3, Screen('FillOval' , self.window.ptr,  [self.color_3 255], self.coord_3);
                elseif button == 4, Screen('FillOval' , self.window.ptr,  [self.color_4 255], self.coord_4);
                else, error('!')
                end
            end

            Screen('FrameOval', self.window.ptr,  [000 000 000  255], self.coord_1);
            Screen('FrameOval', self.window.ptr,  [000 000 000  255], self.coord_2);
            Screen('FrameOval', self.window.ptr,  [000 000 000  255], self.coord_3);
            Screen('FrameOval', self.window.ptr,  [000 000 000  255], self.coord_4);
        end % fcn

    end % meths

end % class
