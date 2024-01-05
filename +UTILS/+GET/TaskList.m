function tasklist = TaskList()
% To add a task, add a package dir like this : ./+TASK/+<MyNewTask>
% HOWEVER : do not use all uppercase name -> they will be discarded, such as ./+TASK/+<MYNEWTASK>

task_folder = './+TASK';

d = dir(fullfile(task_folder,'+*'));

dirname = {d.name}';
raw = regexprep(dirname, '\+', ''); % remove the + at the begining

% discard UPPER case dirs : they are not task
TaskList_upper = upper(raw);
Task_idx = ~strcmp(TaskList_upper, raw);
tasklist = raw(Task_idx);

end % fcn
