function edit_SubjectID_Callback(hObject, ~)
logger = getLogger();

MinNrChar = 3;

id_str = get(hObject,'String');

if length(id_str) < MinNrChar
    set(hObject,'String','')
    logger.err('SubjectID must be at least %d chars', MinNrChar)
else
    logger.ok('SubjectID     = %s', id_str)
    logger.ok('SubjectID dir = %s', UTILS.GET.SubjectDataDir(id_str))
end

end % function
