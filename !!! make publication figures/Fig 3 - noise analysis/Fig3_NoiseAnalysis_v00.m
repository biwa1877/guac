% This script makes all the images needed for the noise analysis figure, which
% contains, so far,:
%   1. results at various noise levels

%% add path

PATH = '/home/imaging/binw/Documents/KM_JILA/Ptychography using Structured Illumination/Defect Inspection Using OAM Beams';
addpath(genpath(PATH));
%% 1. phase (and amplitude, as inserts) images of +/- OAM beams
load('OAM beam l=p=1.mat');

% number of OAM charge, if set to 0, it generates Gaussian beams
N_OAM = 1;

prb1 = zeros(257);prb1(1:end-1, 1:end-1) = LGBeams;

phase = angle(prb1) ;
phase = mod(phase * N_OAM, 2*pi);

prb1 = abs(prb1) .* exp(1i * phase);

% prb2 = conj(prb1);
prb2 = fliplr(prb1);

% prb1 = abs(prb1);
% prb2 = abs(prb2);

figure(21);
subplot(221);imagesc(abs(prb1));axis image off;colormap hot;%title('OAM +1 Amplitude');
subplot(222);imagesc(abs(prb2));axis image off;%title('OAM -1Amplitude');
subplot(223);imagesc(angle(prb1));axis image off;%title('OAM +1 Phase');
subplot(224);imagesc(angle(prb2));axis image off;%title('OAM -1 Phase');

% figure position and size
posi = [811 95 890 871];
set(gcf, 'Position', posi);

%%   2. an example sample with defects, maybe the 2D contact array one;

temp1 = ones(8);
% figure(17);imagesc(abs(temp1));axis image;pause
temp1(3:5,3:5) = 1+1i;
% figure(17);imagesc(abs(temp1));axis image;pause
temp1 = repmat(temp1, 32, 32);
% figure(17);imagesc(abs(temp1));axis image;pause
temp2 = ones(257);
temp2(2:end,2:end) = temp1;
% figure(17);imagesc(abs(temp2));axis image;

maskClean = temp2;

% defect position
rangex = 98:99;   % centered on a contact
rangey = 116:118;

defect = 0.25 * (1 + 1i);

maskDefect1 = temp2;
maskDefect1(rangex,rangey) = maskDefect1(rangex,rangey) - defect;   %exp(1i*pi/4) * (1 + 1i) * 0.5;
% maskDefect1(rangex+5,rangey+5) = maskDefect1(rangex+5,rangey+5) + defect;
% maskDefect1(123:128,123:128) = 1+1i;
% maskDefect1(130:135,130:135) = -(1+1i);

maskDefect2 = temp2;
% maskDefect2(144:146, 144:146) = 1 + 1i;
maskDefect2(rangex,rangey) = maskDefect2(rangex,rangey) + defect;

% maskClean = temp1;
% 
% maskDefect1 = temp2;
% 
% maskDefect2 = temp3;

cmin = min(abs([maskClean(:); maskDefect1(:); maskDefect2(:)]));
cmax = max(abs([maskClean(:); maskDefect1(:); maskDefect2(:)]));

figure(22);
ax(1) = subplot(221);imagesc(abs(maskClean));axis image off;caxis([cmin cmax]);colormap bone;
ax(2) = subplot(222);imagesc(abs(maskDefect1));axis image off;caxis([cmin cmax]);
ax(3) = subplot(223);imagesc(abs(maskDefect2));axis image off;caxis([cmin cmax]);

linkaxes(ax);

posi = [811 95 890 871];
set(gcf, 'Position', posi);

%%   3. far-field diffraction patterns from +/- OAM beams;
%  + 4. the difference between the diffraction patterns;
%  + 5. iFFT{the difference}, both amplitude and phase.

% shift object in x
xshifts = 0;
% xshifts = -30:2:40;

Nshifts = length(xshifts);

% shift object in y
yshift =0;

% Gaussian noise level, relative to max(abs(diff(:)))
wgnLevel = 0.002 * (1:100);
Nnoise = length(wgnLevel);

% plot figure    
nrow = 2;
ncol = 5;
    
% make tight subplot
ha = tight_subplot(nrow, ncol ,[.01 .03],[.1 .01],[.01 .01]);

% make a video
videoFlag = input('>> save a video??? [0/1]');
if videoFlag == 1
    videoName = input('>> Please name the video (AS A STRING, with .avi extension,): ');
    v = VideoWriter(videoName);
    v.FrameRate = 5;
    open(v);
end

h1 = figure(33);

% for i = 1:Nshifts
for i = 1:Nnoise
    
    % ================= OAM = +1 ========================
%     % clean mask
%     maskCleanShifted =  circshift(maskClean, [xshifts(i) yshift]);
% %     ESW1_c = maskCleanShifted .* (prb1);
%     ESW1_c = maskCleanShifted .* (prb1);
%     Fesw1_c = fftshift(fft2(ifftshift(ESW1_c)));
    
    % point defect #1
    maskDefectShifted1 = circshift(maskDefect1, [xshifts yshift]);
    ESW1_d1 = maskDefectShifted1 .* (prb1);
    Fesw1_d1 = fftshift(fft2(ifftshift(ESW1_d1)));
    I1_d1 = abs(Fesw1_d1).^2;
    
%     % point defect #2
%     maskDefectShifted2 = circshift(maskDefect2, [xshifts(i) yshift]);
%     ESW1_d2 = maskDefectShifted2 .* (prb1);
%     Fesw1_d2 = fftshift(fft2(ifftshift(ESW1_d2)));

    % ================= OAM = -1 ========================
%     % clean mask
%     ESW2_c = maskCleanShifted .* (prb2);
%     Fesw2_c = fftshift(fft2(ifftshift(ESW2_c)));
        
    % point defect #1
    ESW2_d1 = maskDefectShifted1 .* (prb2);
    Fesw2_d1 = fftshift(fft2(ifftshift(ESW2_d1)));
    I2_d1 = abs(Fesw2_d1).^2;
    
%     % point defect #2
%     ESW2_d2 = maskDefectShifted2 .* (prb2);
%     Fesw2_d2 = fftshift(fft2(ifftshift(ESW2_d2)));
    
    % ========== plot #3: far-field diffraction patterns ==========
    
    subplot(nrow, ncol, [1, 1+ncol]);imagesc(abs(ESW1_d1));axis image off;colormap hot;
    title(['WGN level = ', num2str(wgnLevel(i)*100),'%']);
    
    subplot(nrow, ncol, 2);imagesc(abs(Fesw1_d1));axis image off;colormap hot;
    subplot(nrow, ncol, 2 + ncol);imagesc(abs(Fesw2_d1));axis image off;
    
    colormap hot;
    % ========== plot #4: difference between far-field diffraction patterns ==========
    
    diff = I1_d1 - fliplr(I2_d1);
    
    % ============= add noise ====================
    
    % === Poisson noise
    
    
    % === Gaussian noise
    
    diff = diff + randn(size(diff)) * max(abs(diff(:))) * wgnLevel(i);
    
    % crop out the DC only
    mask = zeros(size(diff));
    mask(109:147,109:147) = 1;
    diff_crop = diff .* mask;
    
    subplot(nrow, ncol, 3);imagesc(abs(diff).^0.5 .* sign(diff));axis image off;colormap hot;
    subplot(nrow, ncol, 3 + ncol);imagesc(abs(diff_crop).^0.5 .* sign(diff_crop));axis image off;
        
    % ========== plot #5: iFFT of the difference ==========
    IFFTdiff = fftshift(ifft2(ifftshift(diff)));
    IFFTdiff_crop = fftshift(ifft2(ifftshift(diff_crop)));
    
    subplot(nrow, ncol, 4);imagesc(abs(IFFTdiff));axis image off;colormap hot;
    subplot(nrow, ncol, 4 + ncol);imagesc(angle(IFFTdiff));axis image off;
    subplot(nrow, ncol, 5);imagesc(abs(IFFTdiff_crop));axis image off;
    subplot(nrow, ncol, 5 + ncol);imagesc(angle(IFFTdiff_crop));axis image off;
    
    posi = [4 87 1897 879];
    set(gcf, 'Position', posi);
    
%     nrow = 3;
%     ncol = 4;
%     
%     x_plotRange = 1:255;
%     y_plotRange = 1:255;
%     
%     % ========== ESW: clean mask ===========
%     subplot(nrow, ncol, 1);imagesc(abs(ESW1_c(x_plotRange, x_plotRange)));axis image;
%     title({[num2str(i), ' out of ', num2str(Nshifts)], 'flat substrate'});
% %     caxis([0 0.4])
%     
%     % ========== ESW: a small point defect on a flat substrate ===========
%     subplot(nrow, ncol, ncol+1);imagesc(abs(ESW1_d1(x_plotRange, x_plotRange)));axis image;
%     title('a negative point defect on flat substrate');
% %     caxis([0.5 0.9])
%     
%     % ========== ESW: a large point defect on a flat substrate ===========
%     subplot(nrow, ncol, 2*ncol+1);imagesc(abs(ESW1_d2(x_plotRange, x_plotRange)));axis image;
%     title('a positive point defect on flat substrate');
% %     caxis([0 0.4])
%     
%     % ========== difference in diffraction patterns: clean mask ===========
% %     temp1 = abs(rot90(Fesw2_c,2)).^2 - abs(Fesw1_c).^2;
%     temp1 = abs(fliplr(Fesw2_c)).^2 - abs(Fesw1_c).^2;
% %     temp1 = abs(flipud(Fesw2_c)).^2 - abs(Fesw1_c).^2;
% %     temp1 = abs(Fesw2_c).^2 - abs(Fesw1_c).^2;
%     subplot(nrow, ncol, 2);imagesc(temp1(x_plotRange, x_plotRange));axis image;
%     title(['max value ', num2str(max(abs(temp1(:))))]);
% %     title(['difference in diff patts, clean mask; max value ', num2str(max(abs(temp1(:))))]);
%     
%     % ========== difference in diffraction patterns: a small point defect on a flat substrate ===========
% %     temp2 = abs(rot90(Fesw2_d1,2)).^2 - abs(Fesw1_d1).^2;
% %     temp2 = abs(Fesw2_d1).^2 - abs(Fesw1_d1).^2;
%     temp2 = abs(fliplr(Fesw2_d1)).^2 - abs(Fesw1_d1).^2;
% %     temp2 = abs(flipud(Fesw2_d1)).^2 - abs(Fesw1_d1).^2;
%     subplot(nrow, ncol, ncol+2);imagesc(temp2(x_plotRange, x_plotRange));axis image;
%     title(['max value ', num2str(max(abs(temp2(:))))]);
% %     title(['a small point defect on a flat substrate; max value ', num2str(max(abs(temp2(:))))]);
%     
%     % ========== difference in diffraction patterns: a large point defect on a flat substrate ===========
% %     temp3 = abs(rot90(Fesw2_d2,2)).^2 - abs(Fesw1_d2).^2;
% %     temp3 = abs(Fesw2_d2).^2 - abs(Fesw1_d2).^2;
%     temp3 = abs(fliplr(Fesw2_d2)).^2 - abs(Fesw1_d2).^2;
% %     temp3 = abs(flipud(Fesw2_d2)).^2 - abs(Fesw1_d2).^2;
%     subplot(nrow, ncol, 2*ncol+2);imagesc(temp3(x_plotRange, x_plotRange));axis image;
%     title(['max value ', num2str(max(abs(temp3(:))))]);
% %     title(['a large point defect on a flat substrate; max value ', num2str(max(abs(temp3(:))))]);
%     
%     % ========== difference in diffraction patterns: clean mask ===========
%     temp11 = fftshift(ifft2(ifftshift(-temp1)));
%     subplot(nrow, ncol, 3);imagesc( abs(temp11(x_plotRange, x_plotRange)) );axis image;
%     title(['max value ', num2str(max(abs(temp11(:))))]);
%         
%     % ========== difference in diffraction patterns: a small point defect on a flat substrate ===========
%     temp22 = fftshift(ifft2(ifftshift(-temp2)));
% %     subplot(nrow, ncol, ncol+3);imagesc( abs(temp22(80:178, 80:178)).*(mod( angle(temp22(80:178, 80:178)) - pi/2, pi)-pi/2<0));axis image;
%     subplot(nrow, ncol, ncol+3);imagesc( abs(temp22(x_plotRange, x_plotRange)) );axis image;
%     title(['max value ', num2str(max(abs(temp22(:))))]);
%     
%     % ========== difference in diffraction patterns: a large point defect on a flat substrate ===========
%     temp33 = fftshift(ifft2(ifftshift(-temp3)));
% %     subplot(nrow, ncol, 2*ncol+3);imagesc( abs(temp33(80:178, 80:178)).*(mod( angle(temp33(80:178, 80:178)) - pi/2, pi)-pi/2<0));axis image;
%     subplot(nrow, ncol, 2*ncol+3);imagesc( abs(temp33(x_plotRange, x_plotRange)));axis image;
%     title(['max value ', num2str(max(abs(temp33(:))))]);
%     
%     subplot(nrow, ncol, 4);imagesc( mod(angle(temp11) + pi/2, pi) );axis image;
%     
% %     subplot(nrow, ncol, ncol+4);imagesc( mod( angle(temp22) - pi/2, pi));axis image;
%     subplot(nrow, ncol, ncol+4);imagesc( angle(temp22));axis image; 
% %     subplot(nrow, ncol, 2*ncol+4);imagesc( mod(angle(temp33) + pi/2, pi) );axis image;
%     subplot(nrow, ncol, 2*ncol+4);imagesc( angle(temp33));axis image;
    
%     pause(0.1)
    pause
    
    if videoFlag == 1
        frame = getframe(h1);
        writeVideo(v, frame);
    end
end

if videoFlag == 1
    close(v);
end








