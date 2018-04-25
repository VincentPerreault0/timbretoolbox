classdef (Abstract) TTObject < handle
    % An abstract class for timbretoolbox objects.
    
    methods
        function size = GetSize(object)
            
            metaClass = metaclass(object);
            metaProps = metaClass.PropertyList;
            
            size = 0;
            for i = 1:length(metaProps)
                if ~metaProps(i).Dependent
                    fieldValue = object.(metaProps(i).Name);
                    w = whos('fieldValue');
                    size = size + w.bytes;
                    if isa(fieldValue, 'struct')
                        fVFields = fields(fieldValue);
                        for j = 1:length(fVFields)
                            if isa(fieldValue.(fVFields{j}), 'TTObject')
                                size = size + fieldValue.(fVFields{j}).GetSize();
                            end
                        end
                    elseif isa(fieldValue, 'TTObject') && ~any(strcmp(metaProps(i).Name, {'sound', 'rep'}))
                        size = size + fieldValue.GetSize();
                    end
                end
            end
        end
    end
    
end
