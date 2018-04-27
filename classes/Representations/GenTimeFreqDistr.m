classdef (Abstract) GenTimeFreqDistr < Rep
    %GENTIMEFREQDISTR Abstract class for generalized time-frequency
    %distribution representations.
    %   This class is the parent of all representations of type generalized
    %   time-frequency distribution : TimeFreqDistr & Harmonic.
    
    properties (Abstract, GetAccess = public, SetAccess = protected)
        sound       % SoundFile object of which it is a representation.
        tSupport    % Temporal support line vector that indicates at what 
                    %   times the value columns refer to (in seconds).
        value       % Value of the representation (representation dimension
                    %   by length(tSupport) matrix).
    end
    properties (Abstract, Access = public)
        descrs      % Structure containing all the representation's 
                    %   possible descriptors. All fields correspond to a
                    %   possible descriptor type and are instantiated with
                    %   a value of 0 (see Rep's getDescrTypes() method).
    end
    properties (Abstract, Constant)
        exceptions  % The properties with default values that should not be
                    %    exported (in .csv format).
    end
    methods (Abstract)
        sameConfig = HasSameConfig(rep, config)
        
        PlotAndYLabel(gtfDistr, ax, alone, timeRes)
        
        csvfile = ExportCSVValue(gtfDistr, csvfile, directory, csvfileName, valueType, timeRes)
    end
    methods (Access = public)
        function gtfDistr = GenTimeFreqDistr(sound)
            %CONSTRUCTOR From a SoundFile, instantiates a GenTimeFreqDistr
            %object.
            %   Keeps a reference to the original SoundFile in the sound
            %   property and instantiates its descrs property.
            
            gtfDistr = gtfDistr@Rep(sound);
        end
    end
end