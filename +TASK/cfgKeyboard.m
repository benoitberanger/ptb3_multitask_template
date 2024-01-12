function cfg = cfgKeyboard()
% cross task keybinds

KbName('UnifyKeyNames') % make keybinds cross-platform compatible

cfg.Start = [KbName('t') KbName('s')];
cfg.Abort = KbName('escape');

end % fcn
