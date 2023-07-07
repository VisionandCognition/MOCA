% MOCA_edf_to_mat.m
% J.A. Westerberg, Ph.D. (VandC, NIN-KNAW; Psych, Vanderbilt)
% j.westerberg@nin.knaw.nl
% westerberg-science
%
% script used to convert clinical edf patient data into a more useful 
% format for us mere neurophysiolgists. Uses Brainstorm3 for the heavy
% lifting. Mostly using this roundabout strategy because the vanilla matlab
% edfread function does not appreciate the annotations of our specific
% dataset.
%
% NOTE: I am keeping a lot of the variables in the standard Brainstorm
% nomenclature. I figure the tools it provides might be useful in the
% future and the GUI relies on names to be certain ways...
%

%% Prep the workspace

% A clean workshop is an effective workshop
clear

% Top-of-file flags for quick changes...
flag.reprocess                      = true;

% Point to toolbox locations and generate paths
brainstorm_directory                = 'C:\Users\jakew\OneDrive\Documents\GitHub\brainstorm3';
toolkit_directory                   = 'C:\Users\jakew\OneDrive\Documents\GitHub\westerberg-toolkit';

addpath(genpath(brainstorm_directory));
addpath(genpath(toolkit_directory));

% Identify relevant data input and output directories
data_input_directory                = 'C:\Users\jakew\Dropbox\StimEEG\';
data_output_directory               = '\\vs01\VandC_DATA\HumanEphys\MOCA_human_seeg_stimulation\';

% This project uses .edf files, specify
FileFormat                          = 'EEG-EDF';

% Initialize options for Brainstorm
ImportOptions                       = db_template('ImportOptions');
ImportOptions.ImportMode            = 'Time';
ImportOptions.DisplayMessages       = false;

% Start the engine
brainstorm nogui

%% Main loop

% Identify the relevant edf files
FilesToProcess = find_in_dir(data_input_directory, '.edf');
for ii = 1 : numel(FilesToProcess)

    % Ident names/fileparts 
    DataFile = FilesToProcess{ii};
    [~, CurrentFilename, ~] = fileparts(DataFile);

    % Skip file if already processed and don't want to reprocess
    if exist([data_output_directory 'raw_data' filesep CurrentFilename '.edf'], 'file') & ~flag.reprocess
        continue
    end

    % Pull the data
    [ImportedData, ChannelMat, nChannels, nTime, ImportOptions, DateOfStudy] = in_data( ...
        DataFile, ...
        [], ...
        FileFormat, ...
        ImportOptions);

    % Move the data where desired
    if ~exist([data_output_directory 'mat_data'], 'dir')
        mkdir([data_output_directory 'mat_data'])
    end
    if ~exist([data_output_directory 'raw_data'], 'dir')
        mkdir([data_output_directory 'raw_data'])
    end

    copyfile(DataFile, [data_output_directory 'raw_data' filesep CurrentFilename '.edf'])
    movefile(ImportedData.FileName, [data_output_directory 'mat_data' filesep CurrentFilename '.mat'])
    save([data_output_directory 'mat_data' filesep CurrentFilename '.mat'], ...
        'DateOfStudy', 'ImportOptions', 'nTime', 'nChannels', 'ChannelMat', ...
        '-append', '-nocompression');

end

%% Cleanup

gui_brainstorm('EmptyTempFolder');
brainstorm stop