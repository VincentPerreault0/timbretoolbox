classdef (Abstract) Rep < TimeSeries
    %REP Abstract class for all representations.
    %   This class is the parent of all representation types.
    
    properties (Abstract)
        descrs      % Structure containing all the representation's 
                    %   possible descriptors. All fields correspond to a
                    %   possible descriptor type and are instantiated with
                    %   a value of 0 (see Rep's getDescrTypes() method).
    end
    
    properties (Abstract, GetAccess = public, SetAccess = protected)
        sound       % SoundFile object of which it is a representation.
        tSupport    % Temporal support line vector that indicates at what 
                    %   times the value columns refer to (in seconds).
        value       % Value of the representation (representation dimension
                    %   by length(tSupport) matrix).
    end
    
    properties (Abstract, Constant)
        exceptions  % The properties with default values that should not be
                    %    exported (in .csv format).
    end
    
    methods (Abstract)
        PlotAndYLabel(rep, axes, alone, timeRes, header)
        
        csvfile = ExportCSVValue(rep, csvfile, directory, csvfileName, valueType, timeRes)
        
        sameConfig = HasSameConfig(rep, config)
    end
    
    methods
        function rep = Rep(varargin)
            %CONSTRUCTOR From a SoundFile, instantiates a Rep object.
            %   Keeps a reference to the original SoundFile in the sound
            %   property and instantiates its descrs property.
            
            if ~isempty(varargin)
                if ~isa(varargin{1}, 'SoundFile')
                    error('A rep object (representation) must be instantiated from a SoundFile object (sound).');
                end
                rep.sound = varargin{1};
            end
            rep.getDescrTypes();
        end
        
        function getDescrTypes(rep)
            %GETDESCRTYPES Instantiates the rep's descrs property.
            %   Finds all possible descriptors of the representation and
            %   adds them as a field with initial value of 0 to the descrs
            %   structure.
            
            rep.descrs = struct();
            
            descrsFilepath = mfilename('fullpath');
            descrsFilepath = [descrsFilepath(1:end-20) '/Descriptors'];
            filelist = dir(descrsFilepath);
            
            for i=1:length(filelist)
                if filelist(i).name(1) ~= '.'
                    if filelist(i).name(1) == '@'
                        filelist(i).name = filelist(i).name(2:end);
                    elseif strcmp(filelist(i).name(end-1:end), '.m')
                        filelist(i).name = filelist(i).name(1:end-2);
                    end
                    if exist(filelist(i).name, 'class') && ismember('Descr', superclasses(filelist(i).name))
                        mc = eval(['?' filelist(i).name]);
                        if ~mc.Abstract
                            if strcmp(eval([filelist(i).name '.repType']), class(rep)) || ...
                                    ismember(eval([filelist(i).name '.repType']), superclasses(class(rep)))
                                rep.descrs.(filelist(i).name) = 0;
                            end
                        end
                    end
                end
            end
        end
    end
    
end