classdef (Abstract) Rep < TimeSeries
    %REP Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Abstract)
        descrs % Structure of the representation's appropriate descriptors
    end
    
    properties (Abstract, GetAccess = public, SetAccess = protected)
        sound % SoundFile object of which it is a representation
        tSupport
        value
    end
    
    properties (Abstract, Constant)
        exceptions
    end
    
    methods (Abstract)
        PlotAndYLabel(rep, axes, alone, timeRes, header)
        
        csvfile = ExportCSVValue(rep, csvfile, directory, csvfileName, valueType, timeRes)
        
        sameConfig = HasSameConfig(rep, config)
    end
    
    methods
        function rep = Rep(varargin)
            if ~isempty(varargin)
                if ~isa(varargin{1}, 'SoundFile')
                    error('A rep object (representation) must be instantiated from a SoundFile object (sound).');
                end
                rep.sound = varargin{1};
            end
            rep.getDescrTypes();
        end
        function getDescrTypes(rep)
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