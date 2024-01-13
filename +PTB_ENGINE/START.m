function STARTtime = START(keyStart,keyAbort)
global S

switch S.guiACQmode

    case 'Acquisition'

        if S.guiEyelink
            EYELINK.StartRecording();
        end

        HideCursor(S.guiScreenID);

        % print
        fprintf('----------------------------------\n')
        fprintf('      Waiting for trigger "%s"    \n', KbName(keyStart))
        fprintf('                OR                \n')
        fprintf('       Press "%s" to abort        \n', KbName(keyAbort))
        fprintf('----------------------------------\n')

        while 1

            [keyIsDown, STARTtime, keyCode] = KbCheck();

            if ~keyIsDown
                continue
            end

            if keyCode(keyStart)
                fprintf(' ===> Start key received <=== \n')
                break
            end

            if keyCode(keyAbort)

                % sca -- Execute Screen('CloseAll'); WRAPPER
                sca

                % Close all pahandle if audio is active
                [~,M,~] = inmem;
                if strcmp(M,'PsychPortAudio')
                    PsychPortAudio('Close');
                end

                % dump global S in a .mat file, for diagnostic
                if S.WriteFiles
                    save([S.OutFilepath '_ABORT_before_START.mat'], 'S')
                end
                error(' !!! Abort key received !!! ')
            end

        end

    otherwise
        fprintf('START event in debug mod \n')
        STARTtime = GetSecs();

end % switch

end % fcn
