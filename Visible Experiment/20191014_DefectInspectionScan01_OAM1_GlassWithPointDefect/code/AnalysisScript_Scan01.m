% Save each and every code that YOU run for each and every data set
% seperately, so that YOU can still find the parameters that YOU use two
% years later
%% parameters used below
% 1: background subtraction - background = 0.2;

% 2: Center of diff patt - [X,Y] = [519,512];
% 3: size of cropped data - [M,N] = [256,256]*2;

close all
clear all
clc

%% Add the reconstuction codes to the Matlab File Path

% addpath('/imaging/imaging4/Reconstructions/ReconstructData'); %For x-wing camera code (readMightexPtych)

% addpath('/imaging/imaging4/Three_Beam'); %For three beam Fourier Separation

% addpath('/imaging/imaging4/MultiColor/Reconstructions'); %For the multicolor probe plotting function

% addpath('/imaging/imaging4/Undersampling_and_Superresolution'); %for the upsampling ptych code

% addpath('/home/binw/Bin_Code');

% addpath('/home/binw/Dropbox (KM JILA)/OAM/Data analysis/20171212-1941-OAM');

addpath('/home/imaging/binw/Github/OAM-Ptychography-VisibleExperiment/code');

clear ans;

%% Load Ptychography Data

% path2data_1 = '/home/imaging/binw/Github/OAM-Ptychography-VisibleExperiment/20191010_Scan01_GaussianOnAFTP_10cmFTL/data/20191010_Scan01_GaussianOnAFTP_10cmFTL';
path2data_1 = '/home/imaging/binw/Github/OAM-DefectInspection/Visible Experiment/20191014_DefectInspectionScan01_OAM1_GlassWithPointDefect/data';
[dataTensor3,~,~] = readMightexPtych(path2data_1);

dataTensor_1 = dataTensor3;

%%
path2data_1 = '/home/imaging/binw/Github/OAM-DefectInspection/Visible Experiment/20191014_DefectInspectionScan02_OAM-1_GlassWithPointDefect/data';
[dataTensor3,~,~] = readMightexPtych(path2data_1);

dataTensor_2 = dataTensor3;

%% crop the data
dataTensor_1 = dataTensor_1(485-256:485+255,631-256:631+255,:);
dataTensor_2 = dataTensor_2(480-256:480+255,630-256:630+255,:);
%% take the difference and inverse fourier transform
diff = dataTensor_1.^2 - fliplr(dataTensor_2.^2);
f_diff = fftshift(ifft2(ifftshift(diff)));

%% play all the frames
figure(12);

for i = 1:size(dataTensor_1,3)
    subplot(231);imagesc(dataTensor_1(:,:,i));axis image;
    subplot(234);imagesc(dataTensor_2(:,:,i));axis image;
    
    subplot(2,3,[2 5]);imagesc(diff(:,:,i));axis image;
    
    subplot(233);imagesc(abs(f_diff(200:300,200:300,i)));axis image;
    subplot(236);imagesc(angle(f_diff(200:300,200:300,i)));axis image;
    
    title(num2str(i));
    pause(0.1);
end






















%% load MEP data
% path2data_2 = '/home/binw/Dropbox (KM JILA)/OAM/Data taking/20171212-1941-OAM-MEP';
% [dataTensor0,~,~] = readMightexPtych(path2data_2);
% 
% clear path2data_1 path2data_2

%% Just use the raw data


%dataTensor(:,:,65) = dataTensor0;


%% Look through all the scan positions

displayPtychographyScans(dataTensor.^(0.5), xPositionVector, yPositionVector);

%displayPtychographyScans(dataTensor0.^(1/8),xP0,yP0);

%% use only part of the dataset
% temp = reshape(dataTensor, 1024,1280,10,12);
% temp = temp(:,:,2:8,:);
% 
% dataTensor = reshape(temp,1024,1280,12*7);

%% corresponding scan positions
% temp = reshape(xPositionVector,10,12);
% temp = temp(2:8,:);
% xPositionVector = reshape(temp,1,12*7);
% 
% temp = reshape(yPositionVector,10,12);
% temp = temp(2:8,:);
% yPositionVector = reshape(temp,1,12*7);

%%
plotAllScatters_Bin(dataTensor,0.25,0.1);
%% Sum in third dimenstion to get the center of the beam _ CTR

close all;

artificalBeamData = sum(dataTensor,3);

imagesc(artificalBeamData);

[yc, xc] = find(artificalBeamData == max(artificalBeamData(:)));

clear artificalBeamData 

%% Center the dNachoRobata

xc = 646;
yc = 495;
cenDataStack = circshift(dataTensor,[512-yc,640-xc]);

%% histogram of scan data

close all;

temp = dataTensor.^2;
% maxV = max(temp(:));
minV = min(temp(:));

Centers = minV:minV+1000;

hist(temp(:),Centers);
clear maxV minV Centers

%% Substract Background for scan data

BKG = 7;
temp_BKG = temp - BKG;
temp_BKG(temp_BKG < 0) = 0;

% plotAllScatters_Bin(temp_BKG(:,:,1:3:end),0.25,0.1);

%% thresholding
threshold = 2;
temp_BKG(temp_BKG < threshold)=0;

% dataStackBKG =  dataTensor;
% dataStackBKG(dataTensor < 0.034)=0;


% Should be subtracting first peak, thresholding the devation point
% figure;
% imagesc(dataStackBKG(:,:,36).^(0.25));
plotAllScatters_Bin(temp_BKG(:,:,1:5:end),0.25,0.1);

%% accept temp_BKG
dataTensor = temp_BKG.^0.5;

%% this dataset has 20*20 scan positions, and (1:20:end), (2:20:end), ..., (13:20:end) all have
%   serious back reflection mostly from the AFTP sample (it's like a super reflective metallic
%   mirror). So from now on, we take out the 14-20 rows and all columns of
%   the dataset

% temp = reshape(dataTensor, 1024,1280,20,20);
% dataTensor_2 = temp(:,:,14:end,:);
% 
% plotAllScatters_Bin(dataTensor_2,0.25,0.1);
% 
% % reshape scan positions
% xPositionVector = reshape(xPositionVector, 20,20);
% yPositionVector = reshape(yPositionVector, 20,20);
% 
% % only use part of the scan positions
% xPositionVector = xPositionVector(14:end,:);
% yPositionVector = yPositionVector(14:end,:);
% 
% % reshape back to 1D array
% xPositionVector = reshape(xPositionVector, 1, size(xPositionVector,1)*size(xPositionVector,2));
% yPositionVector = reshape(yPositionVector, 1, size(yPositionVector,1)*size(yPositionVector,2));

%% histogram of scan data

% close all;
% 
% temp = dataTensor_2(:,:,round(end/2));
% % maxV = max(temp(:));
% minV = min(temp(:));
% 
% Centers = minV:0.001:minV+0.1;
% 
% hist(temp(:),Centers);
% clear temp maxV minV Centers

%% Substract Background for scan data

% dataStackBKG =  dataTensor_2;
% 
% % BKG
% BKG = 0.0254;
% dataStackBKG = dataStackBKG - BKG;
% dataStackBKG(dataStackBKG < 0) = 0;
% 
% % thresholding
% threshold = 0.01;
% dataStackBKG(dataStackBKG < threshold)=0;


% % Should be subtracting first peak, thresholding the devation point
% % figure;
% % imagesc(dataStackBKG(:,:,36).^(0.25));
% plotAllScatters_Bin(dataStackBKG(264:775,384:895,:),0.5,0.1);

% %% histogram of MEP data
% 
% % close all;
% 
% temp = dataTensor0;
% % maxV = max(temp(:));
% minV = min(temp(:));
% 
% Centers = minV:0.001:minV+0.1;
% 
% hist(temp(:),Centers);
% clear temp maxV minV Centers
% 
% %% Subtract Background for MEP data
% 
% dataStackBKG0 = dataTensor0;
% dataStackBKG0(dataTensor0 < 0.3) = 0;
% 
% figure;
% imagesc(dataStackBKG0.^0.25);

%% Keep background value

% dataTensor = dataStackBKG(264:775,384:895,:);
% 
% % mask out more noise
% dataTensor(481:end,331:end,:) = 0;
% plotAllScatters_Bin(dataTensor,0.25,0.1);
% dataTensor0 = dataStackBKG0;

% clear dataStackBKG % dataStackBKG0

%% Crop the data
% 
[M,N,~] = size(dataTensor);
% croppedData = zeros(M,M,100);
% croppedData(129:1152,1:1280,:) = dataTensor;%(:,N/2-M/2:N/2+M/2-1,:);

croppedData = dataTensor(:,N/2-M/2:N/2+M/2-1,:);
% croppedData0 = dataTensor0(:,N/2-M/2:N/2+M/2-1);

figure;
subplot(1,2,1);
imagesc(croppedData(:,:,36).^(0.25));axis image;
subplot(1,2,2);
% imagesc(croppedData0.^(0.25));axis image;

% figure;
% imagesc(croppedData0.^0.25);

clear M N

%% no crop
croppedData = dataTensor;

%% bin the data
% 
binF = 2;

% [M,N,L] = size(croppedData);

% binnedData = zeros(M/binF,N/binF,L);
% 
% parfor ii = 1:L,
% binnedData(:,:,ii) = bindata(croppedData(:,:,ii), binF);
% end

binnedData = binPtych(croppedData,binF);
% binnedData0 = binPtych(croppedData0,binF);

clear M N L binF


%% Bin by 1

binnedData = croppedData;
% binnedData0 = croppedData0;

%% Look through all the data

plotAllScatters_Bin(binnedData(:,:,1:5:end),1/4,0.1);
% plotAllScatters(binnedData0,1/8,0.1);
%displayPtychographyScans_Bin(binnedData.^(1/8), xPositionVector, yPositionVector);

%% manually clear some noise
% % support for scan data
% % support0 = zeros(320,320,100);
% % support0(101:220,101:220,:) = 1;
% support = ones(512,512,100);
% support(:,421:end,:) = 0;
% % support(1:50,171:230,:) = 0;
% binnedData_p = binnedData .* support;
% % support0 = zeros(512,512);
% % support0(151:350,151:320) = 1;
% % binnedData0_p = binnedData0 .* support0;
% plotAllScatters(binnedData_p(:,:,:),1/8,0.1);
% % plotAllScatters(binnedData0_p,1/8,0.1);

%% support for MEP data
% support0 = zeros(512,512);
% support0(210:300,210:300) = 1;
% binnedData0 = binnedData0.*support0;
% plotAllScatters(binnedData0,1/8,0.1);

%% Sum in third dimenstion to get the center of the diffraction patterns

% close all;
% artificalBeamData = sum(binnedData,3);
% imagesc(artificalBeamData);
% [yc, xc] = find(artificalBeamData == max(artificalBeamData(:)));
% clear artificalBeamData 
% 
% %% crop data to be smaller
% binnedData = binnedData0;
% croppedData2 = cropDiffraction_Bin(binnedData,151,163,160,160,1);
% A = zeros(512,512,100);
% A(57:456,57:456,:) = croppedData2;
% croppedData2 = A;
% plotAllScatters(croppedData2(:,:,:),1/8,0.1);
% clear A

%% get the center of the MEP data

% close all;
% artificalBeamData = binnedData0;
% imagesc(artificalBeamData);
% [yc, xc] = find(artificalBeamData == max(artificalBeamData(:)));
% clear artificalBeamData

%% crop data to be smaller
% croppedData3 = cropDiffraction_Bin(binnedData0,253,257,200,200,1);
% A = zeros(512,512);
% A(57:456,57:456,:) = croppedData3;
% croppedData3 = A;
% plotAllScatters(croppedData3,1/8,0.1);
% clear A

%% Look through all the data
% binnedData = binnedData_p;
% % binnedData0 = binnedData0_p;
% % binnedData0 = croppedData3;
% % plotAllScatters(binnedData2,1/8,0.1);

%% use a circular disc as the probe guess
% [a,~] = size(binnedData(:,:,1));
% x1 = -a/2:a/2-1;
% [x1,y1] = meshgrid(x1);
% probeGuess = double((x1.^2+y1.^2)<(50)^2);

%% use a OAM beam as probe input
probeGuess = LaguerreGaussianBeam_v00(0, 4, 20, [], 0, 200);

% add random noise
probeGuess = probeGuess + rand(size(probeGuess)) * max(abs(probeGuess(:))) * 0.01;

% figure(2);
% subplot(121);imagesc(abs(probeGuess));axis image;
% subplot(122);imagesc(angle(probeGuess));axis image;

%% scan position pre-processing

I = binnedData;
% I0 = binnedData0;
%plotAllScatters(I,1/8,0.1);
p = transpose([-xPositionVector;-yPositionVector]);

% lambda = 791.4*10^-9;
% D2D = 0.02;
% camerapixel = 5.2*10^-6;
% objpixel = lambda*D2D/size(I,1)/camerapixel;
p = p * 4.7 * 10^-9;

%% extend the I0 to the same size as object grid
% [M,N] = size(binnedData(:,:,1));

% c(M/2+1:3*M/2,N/2+1:3*N/2) = I0;
% I0 = c;
% plotAllScatters(I0,1/8,0.1);
% 
% clear c

%% load the previously reconstructed pinhole
% addpath '/imaging/imaging/Yuka_dataruns/20170726 SR test 6';
% load('prb.mat');
% A = gpuArray.zeros(512,512);
% A(17:496,17:496) = abs(prb);
% prb_0 = A;
% figure;
% imagesc(prb_0);axis image;
% clear A


%% clear variables
clearvars -except dataTensor3 I p probeGuess pro

%% run Ptychography code

% start MEP very late, so that we can compare the difference between with
%   and without MEP
[obj,pro,error] = ePIE_Multicolor_Pty_Bin_V3_20171212(I,[],p,10,Inf,395*10^-9,pro,[]);



%% use part of the dataset for reconstruction
index = 1:300;
index = reshape(index, 15, 20);
index = index(3:end-3, 5:end-6);
index = reshape(index, length(index(:)),1);

%%
[obj,pro,error] = ePIE_Multicolor_Pty_Bin_V3_20171212(I(:,:,index),[],p(index,:),10,Inf,395*10^-9,pro,[]);


%% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - %
% Pull data out of GPU array -> The GATHER section
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - %

% the object reconstruction
obj = gather(obj);

% the probe reconstruction
pro = gather(pro);

% error
error = gather(error);

%% save reconstructions
save 'single color object in pinhole plane.mat' 'obj';
save 'single color probe in pinhole plane.mat' 'pro';
save 'single color error in pinhole plane.mat' 'error';

%% back propagation to sample plane
%distance to propagate
z = -0.0046:0.0001:-0.0038;
figure(2);
[a,b] = size(obj);
E2 = zeros(a,b,size(z,2));
lambda = 783 * 10^-9;
objpixel = lambda * 0.02 / 1024 / 5.2 * 10^6;
for i = 1:size(z,2)
    E2(:,:,i) = FSTF_Bin(obj,objpixel,lambda,z(i));
    subplot(3,4,i);
    imagesc(abs(E2(:,:,i)));axis xy image;
    title(['propagation distance ',num2str(z(i)*1000),' mm']);
end
subplot(3,4,12);
imagesc(abs(obj));axis xy image;
title('propagetion distance 0 meter');

%% plot the phase
figure(3);
for i = 1:size(z,2)
    %E2(:,:,i) = FSTF_Bin(obj,objpixel,lambda,z(i));
    subplot(3,4,i);
    imagesc(angle(E2(:,:,i)));axis xy image;
    title(['propagation distance ',num2str(z(i)*1000),' mm']);
end
subplot(3,4,12);
imagesc(angle(obj));axis xy image;
title('propagetion distance 0 meter');


%% save the back propagated object & corresponding distance
save 'back propagated object.mat' 'E2';
save 'back propagation distance.mat' 'z';

%% find the resolution (of amplitude)
line = zeros(1800,size(z,2));
figure(4);
for i = 1: size(z,2)
    line(:,i) = E2(:,850,i);
    subplot(3,4,i);
    plot(abs(line(700:1100,i)));%axis xy image;
    title(['propagation distance ',num2str(z(i)),' meter']);
end
line0 = obj(:,850);
subplot(3,4,12);
plot(abs(line0(700:1100)));%axis xy image;
title('propagetion distance 0 meter');

%% find the resolution (of phase)
%line = zeros(1800,size(z,2));
figure(5);
for i = 1: size(z,2)
    %line(:,i) = E2(:,890,i);
    subplot(3,4,i);
    plot(angle(line(700:1100,i)));%axis xy image;
    title(['propagation distance ',num2str(z(i)),' meter']);
end
%line0 = obj(:,890);
subplot(3,4,12);
plot(angle(line0(700:1100)));%axis xy image;
title('propagetion distance 0 meter');











