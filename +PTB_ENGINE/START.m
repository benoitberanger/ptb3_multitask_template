function t0 = START(keyStart,keyAbort)
global S

switch S.guiACQmode

    case 'Acquisition'

        if S.guiEyelink
            EYELINK.StartRecording();
        end

        HideCursor(S.guiScreenID);

        % print
        fprintf(    '----------------------------------\n')
        for ks = 1 : length(keyStart)
            fprintf('      Waiting for trigger "%s"     \n', KbName(keyStart(ks)))
        end
        fprintf(    '                OR                 \n')
        for ka = 1 : length(keyAbort)
            fprintf('       Press "%s" to abort        \n', KbName(keyAbort(ka)))
        end
        fprintf(    '----------------------------------\n')

        while 1

            [keyIsDown, t0, keyCode] = KbCheck();

            if ~keyIsDown
                continue
            end

            if any(keyCode(keyStart))
                fprintf(' ===> Start key received <=== \n')
                break
            end

            if any(keyCode(keyAbort))
                sca
                [~,M,~] = inmem;
                if strcmp(M,'PsychPortAudio')
                    PsychPortAudio('Close');
                end
                if S.WriteFiles
                    save([S.OutFilepath '_ABORT.mat'], 'S')
                end
                error(' !!! Abort key received !!! ')
            end

        end

    otherwise
        fprintf('START event in debug mod \n')
        t0 = GetSecs();

end



end % fcn
