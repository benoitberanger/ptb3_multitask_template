function plotSPMnod( names , onsets , durations )
%PLOTSPMNOD plots names onsets and durations (n.o.d.) defined for SPM
%
%  SYNTAX
%  plotSPMnod( names , onsets , durations )
%
%  INPUTS
%  1. names     : cellstr
%  2. onsets    : cell of vectors
%  3. durations : cell of vectors
%
% See also spm


args   = {'names','onsets','durations'};
n_args = length(args);


%% Check input arguments

assert(nargin == n_args, '%s uses %d input argument(s)',mfilename,n_args)

% Correct arguments ?
l_args = nan(size(args));
for iarg = 1 : n_args
    validateattributes(eval(args{iarg}),{'cell'},{'vector'},mfilename,args{iarg},iarg)
    l_args(iarg) = length(eval(args{iarg}));
end

% All inputs with the same dimension ?
collinear = cross( l_args , ones(size(args)) ); % is l_args vector collinear to [1 ; 1 ; 1] ?
assert(~any(collinear), ...
    'All inputs must have the same dimensions : n=%d o=%d d=%d', ...
    l_args(1), l_args(2), l_args(3))

% names is only strings ?
assert(iscellstr(names),'names must be a cell array of strings')

for ireg  = 1 : l_args(1)
    assert(length(onsets{ireg}) == length(durations{ireg}) , ...
        'onsets{%d} and durations{%d} have different dimensions : %d and %d ' , ...
        ireg , ireg , length(onsets{ireg}) , length(durations{ireg}) )
    assert(isnumeric(onsets   {ireg}),    'onsets{%d} must be numeric ', ireg )
    assert(isnumeric(durations{ireg}), 'durations{%d} must be numeric ', ireg )
end


%% Prepare curves

% structure to hold the data in convenient way
graph_data = struct;
for ireg = 1:length(names)
    graph_data(ireg).name     = names    {ireg};
    graph_data(ireg).onset    = onsets   {ireg};
    graph_data(ireg).duration = durations{ireg};
end

for ireg = 1 : length(graph_data) % For each regressor

    N   = length(graph_data(ireg).onset);
    pts = 5; % build : rectangle -> 4 corners + 1 invisible point between event
    data = nan(N*pts,2);

    for n = 1 : N

        % 4 corner X
        data(pts*n+0,1) = graph_data(ireg).onset(n);
        data(pts*n+1,1) = graph_data(ireg).onset(n);
        data(pts*n+2,1) = graph_data(ireg).onset(n) + graph_data(ireg).duration(n);
        data(pts*n+3,1) = graph_data(ireg).onset(n) + graph_data(ireg).duration(n);

        % 4 corners Y
        data(pts*n+0,2) = 0;
        data(pts*n+1,2) = 1;
        data(pts*n+2,2) = 1;
        data(pts*n+3,2) = 0;

        % +1 invisible point between events
        if n < N
            data(pts*n+4,1) = graph_data(ireg).onset(n+1);
            data(pts*n+4,1) = NaN;
        end

    end

    % Store curves
    graph_data(ireg).x = data(:,1);
    graph_data(ireg).y = data(:,2);

end % e


%% Plot

% Figure
f = figure('Name', mfilename, 'NumberTitle', 'off');
a = axes(f);
hold(a,'on')

% For each Event, plot the curve
for e = 1 : length(graph_data)
    plot(a, graph_data(e).x, graph_data(e).y + e, 'DisplayName', graph_data(e).name)
end

% Legend
legend(a,'Interpreter','none','Location','Best');

% Change the limit of the graph so we can clearly see the rectangles.
UTILS.ScaleAxisLimits(a)

% Put 1 tick in the middle of each event
set(a, 'YTick' , (1:length(graph_data))+0.5 )
set(a, 'YTickLabel' , {graph_data.name} )
set(a, 'TickLabelInterpreter', 'none')


end
