function varargout = OpenGUI()
% OpenGUI is the function that creates (or bring to focus) gui.
% Then, CORE.Workflow() is always called to start each task. It is the
% "main" program.

logger = getLogger();

logger.log('Starting (or focussing) GUI... \n');

% debug=1 closes previous figure and reopens it, and send the gui handles
% to base workspace.
debug = 1;

gui_name = [ 'GUI_' CONFIG.project_name() ];


%% Open a singleton figure, or gring the actual into focus.

% Is the GUI already open ?
figPtr = findall(0,'Tag',gui_name);

if ~isempty(figPtr) % Figure exists so brings it to the focus
    
    figure(figPtr);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%% DEBUG %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if debug
        clc %#ok<UNRCH>
        close(figPtr);
        GUI.VIEW.OpenGUI();
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
else % Create the figure
    
    rng('default')
    rng('shuffle')
    
    % Create a figure
    figHandle = figure( ...
        'HandleVisibility', 'off',... % close all does not close the figure
        'MenuBar'         , 'none'                   , ...
        'Toolbar'         , 'none'                   , ...
        'Name'            , gui_name                 , ...
        'NumberTitle'     , 'off'                    , ...
        'Units'           , 'Pixels'                 , ...
        'Position'        , [50, 50, 600, 700]       , ...
        'Tag'             , gui_name                 );
    
    figureBGcolor = [0.9 0.9 0.9]; set(figHandle,'Color',figureBGcolor);
    buttonBGcolor = figureBGcolor - 0.1;
    editBGcolor   = [1.0 1.0 1.0];
    
    % Create GUI handles : pointers to access the graphic objects
    handles               = guihandles(figHandle);
    handles.figureBGcolor = figureBGcolor;
    handles.buttonBGcolor = buttonBGcolor;
    handles.editBGcolor   = editBGcolor  ;


    %% UI obj base config
    
    base_cfg_panel  = {'Units', 'Normalized', 'BackgroundColor',figureBGcolor                      };
    base_cfg_text   = {'Units', 'Normalized', 'BackgroundColor',figureBGcolor, 'Style','text'      };
    base_cfg_edit   = {'Units', 'Normalized', 'BackgroundColor',editBGcolor  , 'Style','edit'      };
    base_cfg_button = {'Units', 'Normalized', 'BackgroundColor',buttonBGcolor, 'Style','pushbutton'};


    %% Main pannels

    handles.uipanel_perma_cfg = uipanel(handles.(gui_name), base_cfg_panel{:}, ...
        'Title','CFG', 'Position',[0.00 0.50 1.00 0.50]);

    handles.uipanel_task = uipanel(handles.(gui_name), base_cfg_panel{:}, ...
        'Title','TASK', 'Position',[0.00 0.00 1.00 0.50]);


    %% Panel : permanent config

    where = handles.uipanel_perma_cfg;

    % first line

    handles.uipanel_sid = uipanel(where, base_cfg_panel{:}, ...
        'Title','Subject ID', 'Position',[0.00 0.50 0.25 0.50]);

    handles.uipanel_mode = uibuttongroup(where, base_cfg_panel{:}, ...
        'Title','ACQ mode', 'Position',[0.25 0.50 0.25 0.50]);

    handles.uipanel_save = uipanel(where, base_cfg_panel{:}, ...
        'Title','Save', 'Position',[0.50 0.50 0.25 0.50]);
    
    handles.uipanel_kb = uipanel(where, base_cfg_panel{:}, ...
        'Title','Keybind', 'Position',[0.75 0.50 0.25 0.50]);
    
    %second line
    
    handles.uipanel_screen = uipanel(where, base_cfg_panel{:}, ...
        'Title','Screen', 'Position',[0.00 0.00 0.25 0.50]);
    
    handles.uipanel_parport = uipanel(where, base_cfg_panel{:}, ...
        'Title','Parallel port', 'Position',[0.25 0.00 0.25 0.50]);
    
    handles.uipanel_eyelink = uipanel(where, base_cfg_panel{:}, ...
        'Title','Eyelink', 'Position',[0.50 0.00 0.50 0.50]);
    
    
    %% Panel : Subject ID
    
    where = handles.uipanel_sid;
    
    % label text on top
    handles.text_SubjectID = uicontrol(where, base_cfg_text{:}, ...
        'String','Subject ID', 'Position',[0.05 0.80 0.90 0.20]);
    
    % editable text bellow
    handles.edit_SubjectID = uicontrol(where, base_cfg_edit{:}, ...
        'String','', 'Position',[0.05 0.00 0.90 0.80], 'Callback',@GUI.VIEW.Callback.edit_SubjectID);
    
    %% Pannl : Mode
    
    
    
    
    
    %% End of opening
    
    % IMPORTANT
    guidata(figHandle,handles)
    % After creating the figure, dont forget the line
    % guidata(figHandle,handles) . It allows smart retrive like
    % handles=guidata(hObject)
    
    % Init with EYELINK Off
%     set(handles.uipanel_EyelinkMode,'SelectedObject',handles.radiobutton_Eyelink_0)
%     eventdata.NewValue = handles.radiobutton_Eyelink_0;
%     GUI.VIEW.SelectionChangeFcn.uipanel_EyelinkMode(handles.uipanel_EyelinkMode, eventdata)
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%% DEBUG %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if debug
        assignin('base','handles',handles) %#ok<UNRCH>
        disp(handles)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    figPtr = figHandle;

    
end % creation of figure

if nargout > 0
    
    varargout{1} = guidata(figPtr);
    
end


end % function
