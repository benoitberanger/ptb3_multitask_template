clear
clc

OpenParPort();
WriteParPort(0);

Eyelink('Initialize');
Eyelink('OpenFile', 'testPP');
Eyelink('StartRecording');

% WaitSecs(0.100);

dt = 0.005;
for i = 0 :  7

    WriteParPort(2^i);
    WaitSecs(dt);
    WriteParPort(0);
    WaitSecs(dt);

    fprintf('i=%d \n', i)

end
WriteParPort(0);
CloseParPort();

% WaitSecs(0.100);

Eyelink('StopRecording');
Eyelink('CloseFile');

Eyelink('ReceiveFile', 'testPP', 'testPP.edf');
system('edf2asc -y testPP');
type('testPP.asc');
