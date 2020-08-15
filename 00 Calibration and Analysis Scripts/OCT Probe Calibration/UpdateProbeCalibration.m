clear; clc;

%read new optical path correction data
CalibrationDataFolder = '/Users/ziv/Stanford Drive/Main/Research/Projects/Brain Imaging/Results/July2020Summary/ProbeCalibrationAugust2020/';
jsonTemp = awsReadJSON([CalibrationDataFolder 'ScanInfoCalibration.json']);
newOpticalPathcCrrection = jsonTemp.octProbe.OpticalPathCorrectionPolynomial;



% Read brain OCT volume Json file and update the optical path correction estimation 
OCTVolumesFolder = 's3://delazerdamatlab/Users/BrainProject/7-9-2020Ganymede20x/3_Scan/Test3Volume/Volume/';
json = awsReadJSON([OCTVolumesFolder 'ScanInfo.json']);

%Update JSON
json.octProbe.OpticalPathCorrectionPolynomial = newOpticalPathcCrrection;
awsWriteJSON(json,[OCTVolumesFolder 'ScanInfo.json']); %Can save locally or to AWS

 
