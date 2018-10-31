%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
% Jan R. Wessel, University of Iowa, June 2018                            %
%   Email: jan-wessel@uiowa.edu / www.wessellab.org                       %  
%   Edited by Alec Mather, June 2018                                      %  
%                                                                         %
%   Psychtoolbox 3.0.12 / Matlab 2015a                                    %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Safety check
clear;clc
commandwindow;

% MacOS Specific
Screen('Preference', 'SkipSyncTests', 1);

% INITIALIZE
addpath(genpath(fileparts(which('ALTS.m'))));

% Data columns
id = ALTS_columns;

% DESCRIPTIVES
data = ALTS_data;

% INITIALIZE
settings = ALTS_initialize(data);

% TRIAL SEQUENCE
trialseq = ALTS_sequence(settings,id);

% TRIALS
trialseq = ALTS_backend(settings,trialseq,id);

% OUTRO
ALTS_outro(settings,trialseq,data);