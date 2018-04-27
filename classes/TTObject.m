classdef (Abstract) TTObject < handle
    %TTOBJECT An abstract class for all timbretoolbox objects.
    %   The purpose of this most abstract class is to estimate the size of
    %   the matlab objects to be saved (through soundfile.Save(config)).
    
    methods
        function size = GetSize(object)
            %GETSIZE Estimates the size of the matlab object
            
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
