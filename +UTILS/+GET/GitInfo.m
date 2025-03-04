function info = GitInfo()
logger = getLogger();

info = struct;

rootdir = UTILS.GET.RootDir();

gitdir = fullfile(rootdir, '.git');
if exist(gitdir, 'dir')
    % logger.log('.git dir found : %s', gitdir)
else
    % logger.err('.git dir NOT found : %s', gitdir)
    return
end

[~,cmdout] = system('git version');
if contains(cmdout, 'git version ')
    % logger.log('`git` binary found in system path')
else
    % logger.err('`git` binary NOT found in system path')
    return
end

[~,cmdout] = system('git branch --show-current');
info.branch = strtrim(cmdout);

[~,cmdout] = system(sprintf('git rev-parse %s', info.branch));
info.id = strtrim(cmdout);

[~,cmdout] = system(sprintf('git --no-pager show %s', info.id));
info.info = strtrim(cmdout);

% logger.log('Last commit info retrieved')

end % fcn
