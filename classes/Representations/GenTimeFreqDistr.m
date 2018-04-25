classdef (Abstract) GenTimeFreqDistr < Rep
    %Time-frequency distribution representation
    properties (Abstract, GetAccess = public, SetAccess = protected)
        sound        % Sound object of which it is a representation
        
        tSupport %(in seconds)
        
        value
    end
    properties (Abstract, Access = public)
        descrs % structure containing possible descriptors of this representation
    end
    properties (Abstract, Constant)
        exceptions
    end
    methods (Abstract)
        sameConfig = HasSameConfig(rep, config)
        
        PlotAndYLabel(gtfDistr, ax, alone, timeRes)
        
        csvfile = ExportCSVValue(gtfDistr, csvfile, directory, csvfileName, valueType, timeRes)
    end
    methods (Access = public)
        function gtfDistr = GenTimeFreqDistr(sound)
            gtfDistr = gtfDistr@Rep(sound);
        end
    end
end