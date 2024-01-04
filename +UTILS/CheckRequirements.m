function CheckRequirements()
% perform all installation checks
logger = getLogger();

logger.assert( ~isempty(which('PsychtoolboxRoot')), '"PsychtoolboxRoot" not found : check Psychtooblox installation => http://psychtoolbox.org/' )

datapath = fullfile( pwd, 'data');
if ~exist(datapath, 'dir')
    logger.warning('creating main output dir = %s', datapath)
    mkdir(datapath)
end
logger.log('main output dir = %s', datapath)

end % function
