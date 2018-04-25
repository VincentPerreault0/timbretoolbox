# Timbre Toolbox

Matlab Toolbox originally accompanying the paper 
Title: 		"The Timbre Toolbox: Extracting audio descriptors from musical signals" 
Author: 	Geoffroy Peeters, Bruno L Giordano, Patrick Susini, Nicolas Misdariis, and Stephen McAdams 
appeared in Journal of Acoustical Society of America, 130 (5), November 2011


## Contents

The Timbre Toolbox is a set of Matlab functions and mex files for computing the audio descriptors described in Peeters et al. (JASA-130 (5) ). 
It is organized as a main directory and a set of sub-directories containing classes and sub-functions.

The main example on how to use is Full_Config_Example.m located in timbretoolbox/doc.

For an entire folder of sounds or a single file therein, it 
- evaluates all selected descriptors of selected representations
- exports to .csv (statistics and/or full time series, grouped by sound or descriptor) if an output folder is specified
- saves to .mat (matlab-loadable object) the SoundFile objects containing all the evaluated representations and descriptors if an output folder is specified
- plots the representations and their descriptors and saves them as .png images if an output folder is specified


## Obtaining the TT

Development versions:
`https://github.com/VincentPerreault0/timbretoolbox`

Download a development version either using git or clicking on the "Download
ZIP" link.

Decompress the archive to some location. For this documentation we will assume
you have decompressed it to a folder named "timbretoolbox".

Add this location to path, e.g., by using the MATLAB browser, left-clicking on
the extracted directory and then right-clicking on it (now that it is
highlighted) and finally clicking Add to Path -> Selected Folders and
Subfolders.

A quick way to do this using the command-line is:

```
>> addpath(genpath('/path/to/timbretoolbox'));
```

Compile the mex files. Currently there is only one and must be compiled as
follows:

```
>> mex ./classes/@cERBRep/private/rsmooth.c -outdir ./classes/@cERBRep/private/
```

Make another directory (not inside the `timbretoolbox…` directory) that you will
do work in.

Copy the scripts from `timbretoolbox/doc/` to this directory, or simply use them
as a guide for writing new scripts.

The reason we suggest making a new directory is so when you download new
versions of the timbretoolbox, you can simply replace the "timbretoolbox" folder
with the new version and not lose your scripts.

NB: If you run the “multifile” example, be sure to create the “sounds” and
“results” directories and specify the appropriate paths (if they differ from
what’s already provided). After creating these directories, add these to the
MATLAB path the same way you added the TT to the path.

Run your script either by opening the script and clicking run, or doing
```
>> run script_name
```
in the MATLAB prompt.


## Notes on using with a Git repository

A convenient way to incorporate the newest improvements and bug-fixes to your
workflow using the TT is to use version control. Fans of the command line can
simply clone as follows

```
cd /some/directory/where/you/work
git clone https://github.com/VincentPerreault0/timbretoolbox
```

This will create a folder called "timbretoolbox" and will contain the latest
version of the master branch of the repository. When you want the latest changes
to the repository, simply do

```
cd /some/directory/where/you/work/timbretoolbox
git pull
```
Those who prefer the MATLAB interface to Git can do as follows (The following
has only been tested on MATLAB versions R2015a-b but will probably work in other
later versions).

In MATLAB
- Navigate to `/some/directory/where/you/work`.
- Right-click on some white space in the "Current Folder" pane.
- Select "Source Control -> Manage Files".
A dialog with title "Manage Files Using Source Control" will appear.
- From the drop-down menu next to "Source control integration:" select "Git".
- In the textbox next to "Repository path:" type `https://github.com/VincentPerreault0/timbretoolbox`.
- In the textbox next to "Sandbox:" type
  `/some/directory/where/you/work/timbretoolbox`.
- Then click "Retrieve". It will probably ask if you want to create the
  `timbretoolbox` folder, click "Yes".
- It should retrieve the files and the "Current Folder" pane should be in the
  timbretoolbox folder.

After doing this, you will have the latest version of the master branch of the
repository. To get updates to the repository (if they are available) do as
follows:

With "Current Folder" located at `/some/directory/where/you/work/timbretoolbox`,
- right-click on some white space in the "Current Folder" pane.
- Select "Source control -> Fetch". This will obtain the latest changes to the
  repository. As far as I can tell, there is no visual feedback when this
  happens.
- Then right-click on some white space again and select "Source Control ->
  Manage Branches".
A dialog with title "Manage Branches" will appear.
- In the drop-down menu next to "Branches:", select the branch
  `refs/remotes/origin/master`
- Then click on "Merge".
- Close the dialog.
You should now have the latest changes from the repository at
`https://github.com/VincentPerreault0/timbretoolbox`.


## Usage

The main example on how to use is Full_Config_Example.m located in timbretoolbox/doc.

The only object of interest to the user is the SoundFile object. It is the container class for all the sound file's representations and their descriptors.

It is instantiated by
```
sound = SoundFile(filename);
```
or
```
sound = SoundFile(filename, Config);
```
where Config is a structure with the possible fields ChunkSize (in samples), SampleRange (in samples) and FileFormat, NumChannels and SampleRate for .raw files.

You can evaluate all representations and descriptors (with default parameter values) with
```
sound.Eval();
```
or you can evaluate selected representations/descriptors (and with custom parameter values) with
```
sound.Eval(Config);
```
where Config is a structure with possible fields : AudioSignal, TEE, STFT, ERB and Harmonic.
These fields, if specified (i.e. the representation will be evaluated), must be structures themselves with possibles fields : all parameter names (with the first letter capitalized) and all their possible descriptors.
The parameter fields must take values of appropriate format (or an error will prompt you to do so).
If no descriptors are specified in the fields of a representation structure (within the Config structure), all of its descriptors will be evaluated, unless the field NoDescr is specified (with any value).
If a descriptor is specified in a representation structure, it must itself be a structure with possible fields : all parameter names (with the first letter capitalized).
Once again, these parameter fields must take values of appropriate format (or an error will prompt you to do so).

Here is a simple example below where the STFT representation is evaluated (with custom hop size) and its Spectral Rollof descriptor is evaluated (with custom threshold).
```
Config = struct();
Config.STFT = struct();
Config.STFT.HopSize = 128;
Config.STFT.SpecRollOff = struct();
Config.STFT.SpecRollOff.Threshold = 0.9;

sound.Eval(Config);
```
Following this example, the sound object would have in its reps property, a structure containing an AudioSignal (necessary for the evaluation of the STFT representation, but with no descriptors) and a STFT representations with, in its descrs property, a structure containing the Spectral Rolloff descriptor.

You can export to .csv all evaluated representations/descriptors or only specified ones (in the same fashion as Eval) with
```
CsvConfig = struct();
CsvConfig.Directory = 'Specified directory';
CsvConfig.Grouping = 'sound';
CsvConfig.TimeRes = 10; % in Hz
CsvConfig.ValueTypes = {'ts'};
% CsvConfig.STFT.SpecRollOff = struct(); % Uncomment to export only the STFT and its Spectral Rolloff descriptor

sound.ExportCSV(CsvConfig);
```
where Directory is the specified output directory, Grouping is how the csv files are organized, TimeRes is the time resolution for the exported time series (ValueType 'ts'), i.e. the representations and descriptors.

You can also save your full sound object as a .mat file in a specified directory (if it is smaller than 2 GB) with
```
MatConfig = struct();
MatConfig.Directory = 'Specified directory';

sound.Save(MatConfig);
```

Finally, you can plot all evaluated representations/descriptors with or only specified ones (in the same fashion as Eval) with
```
PltConfig = struct();
% PltConfig.Directory = 'Specified directory'; % Uncomment to save the image as .png in the specified directory
% PltConfig.TimeRes = 50; % in Hz, Uncomment to specify a lower time resolution
% PltConfig.STFT.NoDescr = struct(); % Uncomment to plot only the STFT representation

sound.Plot(PltConfig);
```


## On programming

The Timbre Toolbox started from the Matlab version of ircamdescriptor (Geoffroy Peeters) 
which itself contains inputs from J. Krimphoff, Nicolas Misdariis, Patrick Susini and Stephen McAdams.
It was then modified at McGill by Cory Kereliuk which made it object-oriented.
It was then modified again by Geoffroy Peeters at Ircam to make the 2011 article version.
It was then modified at McGill a final time by Vincent Perreault who restructured the toolbox and completed the object-oriented hiearchy.

The Toolbox is written as a set of classes that correspond to the various signal representations and their descriptors.
The sound files themselves are container objects for their representations which are also containers for their descriptors.

The different representation classes are as following:
- AudioSignal for the original waveform
- TEE for the Temporal Energy Envelope
- STFT for the Short-Time Fourier Transform representation
- ERB for the Equivalent Rectangular Bandwidth representation
- Harmonic for the Harmonic Partials representation

Every descriptor has its own class (* denotes global descriptors, i.e. not time-varying):
- AutoCorr for Autocorrelation (AudioSignal)
- ZcrRate for Zero Crossing Rate (AudioSignal)
- Att for Attack* (TEE)
- Dec for Decay* (TEE)
- Rel for Release* (TEE)
- LAT for Log-Attack-Time* (TEE)
- AttSlope for Attack Slope* (TEE)
- DecSlope for Decrease Slope* (TEE)
- TempCent for Temporal Centroid* (TEE)
- EffDur for Effective Duration* (TEE)
- FreqMod for Frequency of Energy Modulation* (TEE)
- AmpMod for Amplitude of Energy Modulation* (TEE)
- RMSEnv for RMS-Energy Envelope (TEE)
- SpecCent for Spectral Centroid (STFT, ERB, Harmonic)
- SpecSpread for Spectral Spread (STFT, ERB, Harmonic)
- SpecSkew for Spectral Skewness (STFT, ERB, Harmonic)
- SpecKurt for Spectral Kurtosis (STFT, ERB, Harmonic)
- SpecSlope for Spectral Slope (STFT, ERB, Harmonic)
- SpecDecr for Spectral Decrease (STFT, ERB, Harmonic)
- SpecRollOff for Spectral Rolloff (STFT, ERB, Harmonic)
- SpecVar for Spectro-temporal Variation (STFT, ERB, Harmonic)
- FrameErg for Frame Energy (STFT, ERB, Harmonic)
- SpecFlat for Spectral Flatness (STFT, ERB, Harmonic)
- SpecCrest for Spectral Crest (STFT, ERB, Harmonic)
- HarmErg for Harmonic Energy (Harmonic)
- NoiseErg for Noise Energy (Harmonic)
- Noisiness for Noisiness (Harmonic)
- F0 for Fundamental Frequency (Harmonic)
- Inharm for Inharmonicity (Harmonic)
- TriStim for Tristimulus (Harmonic)
- HarmDev for Harmonic Spectral Deviation (Harmonic)
- OddEvenRatio for Odd-to-Even Harmonic Ratio (Harmonic)


## Files in the ./classes directory & general class hierarchy

- @SoundFile : folder for the SoundFile class and its functions
- Descriptors : folder containing all descriptor class definitions (descriptors and their abstract parents : TVDescr for time-varying, GlobDescr for global descriptors and Descr for all descriptors)
- Representations : folder containing all representation class definitions and their functions (representations and their abstract parents : TimeSignal for AudioSignal and TEE, TimeFreqDistr for STFT and ERB, GenTimeFreqDistr for Harmonic and TimeFreqDistr and Rep for all representations)
- TimeSeries.m : abstract class containing Rep and Descr
- TTObject.m : abstract class containing SoundFile and TimeSeries


## Earlier version

For an earlier version of the toolbox (the version from the 2011 Peeters et al article), visit 

`https://github.com/mondaugen/timbretoolbox`

Changes from this previous version include :
- complete restructuring of the classes and their hiearchy
- plotting and .csv exporting of the representations and their descriptors
- the Harmonic Partials representation doesn't suppose a constant inharmonicity coefficient anymore (contrary to the article)
- error correction in the objective function for the optimization of the inharmonicity coefficient
- Spectral Flatness (SpecFlat) and Spectral Crest (SpecCrest) are now available in the Harmonic Partials representation
- there are now no more difference between the representations evaluated on the whole sound and in chunks for the TEE, STFT and ERB representations
- reduced difference between the representations evaluated on the whole sound and in chunks for the Harmonic representation
- Autocorrelation and Zero Crossing Rate are now evaluated with a square window (as in their definition in the article)
- RMS Energy Envelope now uses RMS averaging


## Future perspectives

In the evaluation of the Harmonic Partials representation, the fundamental frequency and the inharmonicity coefficient should be conjointly evaluated for a more accurate representation.

If not, the swipep.m function used to estimate the fundamental frequency (in its first approximation in the current implementation) should be changed to be more robust (to small differences in the signal) and less convoluted in its evaluations.


## Reporting bugs

If you find that something is not working properly, please report it here:

`https://github.com/VincentPerreault0/timbretoolbox/issues`
