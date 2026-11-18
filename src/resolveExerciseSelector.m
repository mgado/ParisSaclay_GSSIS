function item = resolveExerciseSelector(selector)
%RESOLVEEXERCISESELECTOR Find a training exercise by number or readable name.
%   ITEM = resolveExerciseSelector(2) returns the catalog entry for exercise 2.
%   Selectors also accept "02-Requirements", "Requirements", the full catalog
%   name, and legacy IDs such as "w02_requirements". Text is case insensitive.
%   This training helper resolves a file without opening it.
%   See also openExercise, demoAgenda.
arguments
    selector {validateSelector}
end
project = requireTrainingProject;
catalog = jsondecode(fileread(fullfile(project.RootFolder,'exerciseCatalog.json')));
items = catalog.Exercises;
if isnumeric(selector)
    match = [items.Number] == double(selector);
else
    query = strtrim(string(selector));
    match = false(1,numel(items));
    for index = 1:numel(items)
        keyword = "";
        key = "";
        if isfield(items,'Keyword')
            keyword = string(items(index).Keyword);
        end
        if isfield(items,'Key')
            key = string(items(index).Key);
        end
        aliases = [string(items(index).Id),string(items(index).Name),keyword,key, ...
            string(items(index).Number) + "-" + keyword];
        match(index) = any(strcmpi(query,aliases));
    end
end
assert(nnz(match)==1,'ParisSaclay:UnknownExercise', ...
    'Use a listed number/name, or type openExercise(" and press Tab to browse.');
item = items(match);
end

function validateSelector(value)
validNumber = isnumeric(value) && isscalar(value) && isreal(value) ...
    && isfinite(value) && value>=1 && value==fix(value);
validString = isstring(value) && isscalar(value) && ~ismissing(value) ...
    && strlength(strtrim(value))>0;
validChar = ischar(value) && isrow(value) && ~isempty(strtrim(value));
if ~(validNumber || validString || validChar)
    error('ParisSaclay:InvalidSelector', ...
        'Select one positive integer exercise number or one nonempty text name.');
end
end
