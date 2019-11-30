%This script scans an OCT image of a target or flat surface for analysis
%% Inputs

% IMPORTANT: 
% Before running this script make sure target is at focus

% What are we imaging
switch(1)
    case 1
        experimentType = 'Imaging Flat Surface';
    case 2
        experimentType = 'Imaging 25um Trenches';
end

%Path to probe ini
currentFileFolder = [fileparts(mfilename('fullpath')) '\'];
probeIniPath = awsModifyPathForCompetability(...
    [currentFileFolder '\..\..\01 OCT Scan and Pattern\Thorlabs\Probe - Olympus 10x.ini']);

% Reference Scan JSON - where to get default scan parameters from
configPath = s3SubjectPath('01');
config = awsReadJSON([configPath 'OCTVolumes/ScanConfig.json']);

% Output path 
s3OutputPath = awsModifyPathForCompetability(...
    [s3SubjectPath('') 'Calibratoins\' datestr(now,'yyyy-mm-dd') ' ' experimentType '/']);

%% Preform scan
if ~exist(probeIniPath,'file')
    error('Cannot locate probe ini at "%s"',probeIniPath);
end
ini = yOCTReadProbeIniToStruct(probeIniPath);

% Temporary output path (before uploading to the cloud)
tmpOutputPath = [pwd '\tmp\'];

% Scan itelf
fprintf('%s Scanning Target\n',datestr(datetime));
scanParameters = yOCTScanTile (...
    tmpOutputPath, ...
    'octProbePath', probeIniPath, ...
    'tissueRefractiveIndex', config.volume.tissueRefractiveIndex, ...
    'xOffset', 0, ...
    'yOffset', 0, ... 
    'xRange', config.volume.xRange, ...
    'yRange', config.volume.yRange, ...
    'nXPixels', config.volume.nXPixels, ...
    'nYPixels', config.volume.nYPixels, ...
    'nBScanAvg', 1, ...
    'zDepths',  [0 -0.5], ... [mm]
    'v',true  ...
    );

%% Preprocess scan

%If you would like to process a scan that is in the cloud, uncomment:
%tmpOutputPath = s3OutputPath

scanParameters = awsReadJSON([tmpOutputPath '\ScanInfo.json']);

x = scanParameters.xRange*linspace(-0.5,0.5,scanParameters.nXPixels) + scanParameters.xOffset; %mm
y = scanParameters.yRange*linspace(-0.5,0.5,scanParameters.nYPixels) + scanParameters.yOffset; %mm

for scanI = 1:length(scanParameters.octFolders)
    octScanPath = awsModifyPathForCompetability([tmpOutputPath '\' scanParameters.octFolders{scanI} '\']);
    
    fprintf('%s Processing Scan... (%d of %d)\n',datestr(datetime),scanI,length(scanParameters.octFolders));

    [scanAbs,dim] = yOCTProcessScan(octScanPath, 'meanAbs', 'n', scanParameters.tissueRefractiveIndex, ...
        'runProcessScanInParallel', true, 'dispersionParameterA', ini.DefaultDispersionParameterA);
        
    dim.x.values = x*1e3;
    dim.y.values = y*1e3;
    dim.x.units = 'microns';
    dim.y.units = 'microns';

    %Save
    tic;
    fprintf('%s Saving Processd Scan (%d of %d)\n',datestr(datetime),scanI,length(scanParameters.octFolders));
    yOCT2Tif(log(scanAbs),[octScanPath '\scanAbs.tif']);
    awsWriteJSON(dim,[octScanPath 'scanAbsMetaData.json']);
    toc;
end

%% Copy to cloud
if ~strcmp(tmpOutputPath,s3OutputPath)
    awsCopyFileFolder(tmpOutputPath,s3OutputPath);
    rmdir(tmpOutputPath,'s')
end