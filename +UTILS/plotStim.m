function plotStim( planning , event , kb )
%PLOTSTIM Plot all events from a run : events planned, events recorded, mri
%triggersUTILS.plotDelay
%
%  SYNTAX
%  plotStim( planning , event , kb )
%  plotStim
%
%  INPUTS
%  1. eventplanning is an UTILS.RECORDER.Planning object
%  2. eventrecorder is an UTILS.RECORDER.Event object
%  3. kblogger is a UTILS.RECORDER.Kb object
%
%  NOTES
%  1. All objects must have a non-empty GraphData property
%  2. Without input arguments, the function will try to use ER, EP, KL from
%  the base workspace
%
%
% See also UTILS.RECORDER.Event, UTILS.RECORDER.Planning, UTILS.RECORDER.Kb, UTILS.plotDelay


%% Check input data

% Must be 3 input arguments, or try with the base workspace
if nargin > 0
    
    % narginchk(2,3)
    % narginchk introduced in R2011b
    if nargin < 2 || nargin > 3
        error('%s uses 2 or 3 input argument(s)',mfilename)
    end
    
else
    
    % Import variables from base workspace
    vars = evalin('base','whos');
    
    % Check each variable from base workspace
    for v = 1 : length(vars)
        
        % UTILS.RECORDER.Planning ?
        if strcmp ( vars(v).name , 'EP' ) && strcmp ( vars(v).class , 'UTILS.RECORDER.Planning' )
            planning = evalin('base','EP');
        end
        % UTILS.RECORDER.Event ?
        if strcmp ( vars(v).name , 'ER' ) && strcmp ( vars(v).class , 'UTILS.RECORDER.Event' )
            event = evalin('base','ER');
        end
        % UTILS.RECORDER.Kb ?
        if strcmp ( vars(v).name , 'KL' ) && strcmp ( vars(v).class , 'UTILS.RECORDER.Kb' )
            kb = evalin('base','KL');
        end
        
    end
    
    % Check if all vairables have been found in the base workspace
    if ~ ( exist('eventplanning','var') && exist('eventrecorder','var') && exist('kblogger','var') )
        error('Even without input arguments, the function tries to use the base workspace variables, but failed.')
    end
    
end


if ~ isa ( planning , 'UTILS.RECORDER.Planning' )
    error( 'First argument eventplanning must be an object of class UTILS.RECORDER.Planning ' )
end

if ~ isa ( event , 'UTILS.RECORDER.Event' )
    error( 'First argument eventrecorder must be an object of class UTILS.RECORDER.Event ' )
end

if ~isprop( planning , 'GraphData' ) || isempty( planning.GraphData )
    error( 'eventplanning must have a non-empty GraphData property' )
end

if ~isprop( event , 'GraphData' ) || isempty( event.GraphData )
    error( 'eventrecorder must have a non-empty GraphData property' )
end

if exist('kblogger','var')
    
    if ~ isa ( kb , 'UTILS.RECORDER.Kb' )
        error( 'Last argument kblogger must be an object of class UTILS.RECORDER.Kb ' )
    end
    
    if ~isprop( kb , 'GraphData' ) || isempty( kb.GraphData )
        error( 'kblogger must have a non-empty GraphData property' )
    end
    
end

% if size( eventplanning.Data , 1 ) ~= size( eventrecorder.Data , 1 )
%     error( 'UTILS.RECORDER.Planning.Data and UTILS.RECORDER.Event.Data must have the same number of lines' )
% end

if exist('kblogger','var') && ~isempty(kb.Data)
    
    if isempty(kb.Data)
        warning('plotStim:NoDataInUTILS.RECORDER.Kb','kblogger.Data is empty')
    end
    
end

%% Preparation of curves

nb_lines = size(planning.GraphData,1) + size(event.GraphData,1);
if exist('kblogger','var') && ~isempty(kb.Data)
    nb_lines = nb_lines + size(kb.GraphData,1);
end
Colors = lines( nb_lines  );
color_count = 0;

% Link between curves

for ep = 1 : size(planning.GraphData,1)
    color_count = color_count + 1;
    EP(ep).object = 'EP'; %#ok<*AGROW>
    EP(ep).index = ep;
    EP(ep).color = Colors(ep,:);
    EP(ep).linestyle = '-';
end

% Is UTILS.RECORDER.Event entry in UTILS.RECORDER.Planning ?
for er = 1 : size(event.GraphData,1)
    %     idx_ep_in_er = regexp( eventrecorder.GraphData(:,1) , [ '^' eventplanning.GraphData{er,1} '$' ] );
    %     idx_ep_in_er = ~cellfun( @isempty , idx_ep_in_er );
    %     idx_ep_in_er = find( idx_ep_in_er );
    idx_ep_in_er = find( strcmp( event.GraphData(:,1) , planning.GraphData{er,1} ) );
    % Yes, so add it into PlotData
    if idx_ep_in_er
        ER(er).object = 'ER';
        ER(er).index = idx_ep_in_er;
        ER(er).color = EP(er).color;
        ER(er).linestyle = '--';
    end
    
end

if exist('kblogger','var') && ~isempty(kb.Data)
    
    % Prepare MRI trigger curve
    MRI_trigger_kb_input = kb.Header{1}; % fORP in USB mode
    MRI_trigger_reference = regexp( kb.GraphData(:,1) , [ '^' MRI_trigger_kb_input '$' ] );
    MRI_trigger_reference = ~cellfun( @isempty , MRI_trigger_reference );
    MRI_trigger_reference = find( MRI_trigger_reference );
    
    kb_count = 0;
    for kb = 1 : size(kb.GraphData,1)
        
        if ~isempty(kb.GraphData{kb,2})
            
            kb_count = kb_count + 1;
            
            if kb == MRI_trigger_reference
                
                color_count = color_count + 1;
                KL(kb_count).object = 'KL';
                KL(kb_count).index = MRI_trigger_reference;
                KL(kb_count).color = Colors(color_count,:);
                KL(kb_count).linestyle = ':';
                
            else
                
                color_count = color_count + 1;
                KL(kb_count).object = 'KL';
                KL(kb_count).index = kb;
                KL(kb_count).color = Colors(color_count,:);
                KL(kb_count).linestyle = '-';
                
            end
            
        end
        
    end
    
end

%% Plot

% Input names
all_ipn = '';

if nargin ~= 0 % real function input
    
    for ipn = 1 : nargin
        
        if ipn == 1
            all_ipn = [ all_ipn inputname(ipn) ];
        else
            all_ipn = [ all_ipn ' + ' inputname(ipn) ];
        end
        
    end
    
else % import from base workspace
    
    all_ipn = 'EP + ER + KL';
    
end

% Figure
figure( ...
    'Name'        , [ mfilename ' : ' all_ipn ] , ...
    'NumberTitle' , 'off'                         ...
    )

hold all

% Prepare the loop to plot each curves
PlotData.EP = EP;
PlotData.ER = ER;
if exist('kblogger','var') && ~isempty(kb.Data)
    PlotData.KL = KL;
end
PlotDataFields = fieldnames(PlotData);

% How many curves ?
nb_curves = 0;
for pdf = 1:length(PlotDataFields)
    nb_curves = nb_curves + length( PlotData.(PlotDataFields{pdf}) );
end

% Prepare the legend
CurvesNames = cell(nb_curves,1);
curve_count = 0;

% Plot loop
for pdf = 1:length(PlotDataFields)
    
    % Shortcut : easier to read
    current_plot_data = PlotData.(PlotDataFields{pdf});
    
    for cpd = 1 : length(current_plot_data)
        
        % Shortcut : easier to read
        current_curve_data = current_plot_data(cpd);
        
        curve_count = curve_count + 1;
        
        % Curve comes from which object ?
        switch current_curve_data.object
            
            case 'EP'
                
                plot(planning.GraphData{current_curve_data.index,3}(:,1) ,...
                    planning.GraphData{current_curve_data.index,3}(:,2)*0.9 + current_curve_data.index - 1 ,...
                    'Color' , current_curve_data.color ,...
                    'LineStyle' , current_curve_data.linestyle )
                
                current_curve_name = planning.GraphData{current_curve_data.index,1};
                
            case 'ER'
                
                plot(event.GraphData{current_curve_data.index,3}(:,1) ,...
                    event.GraphData{current_curve_data.index,3}(:,2) + current_curve_data.index - 1 ,...
                    'Color' , current_curve_data.color ,...
                    'LineStyle' , current_curve_data.linestyle )
                
                current_curve_name = event.GraphData{current_curve_data.index,1};
                
            case 'KL'
                
                if isempty( kb.GraphData{current_curve_data.index,3} )
                    
                    plot( 0 ,...
                        0 ,...
                        'Color' , current_curve_data.color ,...
                        'LineStyle' , current_curve_data.linestyle )
                    
                else
                    
                    plot( kb.GraphData{current_curve_data.index,3}(:,1) ,...
                        kb.GraphData{current_curve_data.index,3}(:,2) * length(PlotData.EP) ,...
                        'Color' , current_curve_data.color ,...
                        'LineStyle' , current_curve_data.linestyle )
                    
                end
                
                if current_curve_data.index == MRI_trigger_reference
                    current_curve_name = 'MRI_trigger';
                else
                    current_curve_name = kb.GraphData{current_curve_data.index,1};
                end
                
        end
        
        % Store curve name
        CurvesNames{curve_count} = current_curve_name;
        
    end
    
end

% Legend
lgd = legend(CurvesNames);
set(lgd,'interpreter','none','Location','Best')


%%  Adapt the graph axes limits

% Change the limit of the graph so we can clearly see the
% rectangles.

UTILS.ScaleAxisLimits( gca , 1.1 )


%% Change YTick and YTickLabel

% Put 1 tick in the middle of each event
set( gca , 'YTick' , (1:length(PlotData.EP)) - 0.5 )

% Set the tick label to the event name
set( gca , 'YTickLabel' , CurvesNames(1:length(PlotData.EP)) )

% Not all versions of MATLAB have this option
try
    set(gca, 'TickLabelInterpreter', 'none')
catch %#ok<CTCH>
end


end
