function Calibration( handles )
logger = getLogger();

% IMPORTANT : must be same as task BG color for accurate position !!!
bg_color = [50 50 50];

logger.warn('Background for EL calib should be the same as the task :')
logger.warn('Current BG color is [%g %g %g]', bg_color(:))

try

    % Eyelink setup
    logger.log('Reseting Eyelink')
    Eyelink('Shutdown')
    logger.log('Initilizing Eyelink ...')
    Eyelink('Initialize','PsychEyelinkDispatchCallback');
    logger.log('... Eyelink initialized.')

    % Need sound for the beeps
    logger.log('Initilizing sound (for feedback)...')
    InitializePsychSound();
    logger.log('... sound initialized.')

    % Open window
    logger.log('Initilizing window...')
    Window = PTB_ENGINE.VIDEO.Window();
    Window.bg_color       = bg_color;
    Window.screen_id      = GUI.GET.ScreenID   ( handles );
    Window.is_transparent = GUI.GET.Windowed   ( handles );
    Window.is_windowed    = GUI.GET.Transparent( handles );
    Window.Open();
    logger.log('... window initialized.')

    % Special Eylink setup for Calibration
    logger.log('Prepare Eyelink for calibration...')
    el = EyelinkInitDefaults(Window.ptr);
    el.backgroundcolour = bg_color;
    EyelinkUpdateDefaults(el);
    logger.log('... Eyelink ready for calibration.')

    % Perform tracker setup - interactive setup with video display:
    EyelinkDoTrackerSetup(el);

    Window.Close();
    logger.ok('Eylink calibration procedure done SUCCESSFULLY, using BG color [%g %g %g]', bg_color(:))

catch err
    sca();
    rethrow(err)
end

end % fcn
