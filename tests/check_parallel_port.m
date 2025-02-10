clear
clc

OpenParPort();
WriteParPort(0);

i = 0;
dt = 0.020;
while ~KbCheck

    WriteParPort(2^i);
    WaitSecs(dt);
    WriteParPort(0);
    WaitSecs(dt);

    i = i + 1;

    i = mod(i, 8);

    fprintf('i=%d \n', i)

end
WriteParPort(0);
CloseParPort();
