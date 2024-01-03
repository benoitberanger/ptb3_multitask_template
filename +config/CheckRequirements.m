function CheckRequirements()
% perform all installation checks
lgr = utils.logger.get();

lgr.assert( ~isempty(which('PsychtoolboxRoot')), '"PsychtoolboxRoot" not found : check Psychtooblox installation => http://psychtoolbox.org/' )

datapath = fullfile( pwd, 'data');
if ~exist(datapath, 'dir')
    lgr.warning('creating main output dir = %s', datapath)
    mkdir(datapath)
end
lgr.log('main output dir = %s', datapath)

end % function
