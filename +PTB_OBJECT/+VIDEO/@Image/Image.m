classdef Image < PTB_OBJECT.VIDEO.Base
    % FIXATIONCROSS Class to prepare and draw a fixation cross in PTB

    properties(GetAccess = public, SetAccess = public)
        % User accessible paramters :
        filename (1,:) char % path of the image
    end % props

    properties(GetAccess = public, SetAccess = protected)
        % Internal parameters :
        rgba     (:,:,4) uint8  % [R G B a] from 0 to 255
        size_h   (1,1)   double % number of horizontal pixel
        size_w   (1,1)   double % number of vertical   pixel
        ar       (1,1)   double % aspect ratio
        rect_raw (1,4)   double % [0 0 size_x size_y] % ptb coordinates
        tex      (1,1)   double % ptb texture pointer
    end % props

    methods(Access = public)

        %--- constructor --------------------------------------------------
        function self = Image()
            % pass
        end % fcn

        %------------------------------------------------------------------
        function Load(self)

            [data, map, alpha] = imread(self.filename);
            if isa(alpha,'double')
                alpha = uint8(alpha*255);
            end
            self.rgba = cat(3,ind2rgb8(data,map),alpha);
            self.size_h = size(self.rgba, 2);
            self.size_w = size(self.rgba, 1);
            self.ar = self.size_w / self.size_h;
            self.rect_raw = [0 0 self.size_h self.size_w];
        end % fcn

        %------------------------------------------------------------------
        function Plot(self)
            % build checkerboard mask with cyan tiles
            freq = 10 / self.size_h;
            [grid_x, grid_y]  = meshgrid(1:self.size_h, 1:self.size_w);
            grid_x = sin(2*pi*freq*grid_x)>0;
            grid_y = sin(2*pi*freq*grid_y)>0;
            checkerboard = xor(grid_x,grid_y);
            bg = zeros(self.size_w, self.size_h, 3); % cyan background
            bg(:,:,1) = 255;
            bg(:,:,2) = 000;
            bg(:,:,3) = 255;
            mask = bg .* checkerboard;
            mask = uint8(mask);

            % draw
            f = figure('Name',self.filename,'NumberTitle','off');
            a = axes(f);
            image(a, self.rgba(:,:,1:3) + (255-self.rgba(:,:,4)).*mask)
            axis(a, 'equal')
            set(a, 'XAxisLocation', 'top')
        end % function

        %------------------------------------------------------------------
        function Draw(self)

        end % fcn

    end % meths

end % class
