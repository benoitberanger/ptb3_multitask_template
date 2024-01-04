function listbox_Screens(hObject , ~)

AvailableScreens = Screen('Screens')'; % make it column vector
AvailableScreens = flip(AvailableScreens); % flip it so it appears in descending order

set(hObject, 'String', num2str(AvailableScreens))

end % function
