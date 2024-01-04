function edit_SubjectID(hObject, ~)
logger = getLogger();

MinNrChar = 3;

id_str = get(hObject,'String');

if length(id_str) < MinNrChar
    set(hObject,'String','')
    logger.err('SubjectID must be at least %d chars', MinNrChar)
else
    logger.ok('SubjectID = %s \n', id_str)
end

end % function
