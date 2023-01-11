% --------------------------------------------------------------------------------------------
%
%     Demo software for Rician noise removal via variance stabilization
%               Release ver. 1.21  (17 July 2016)
%
% --------------------------------------------------------------------------------------------
%
% The software implements the algorithm and methods published in the paper:
%
%  A. Foi, "Noise Estimation and Removal in MR Imaging: the Variance-Stabilization Approach",
%  in Proc. 2011 IEEE Int. Sym. Biomedical Imaging, ISBI 2011, Chicago (IL), USA, April 2011.
%  doi:10.1109/ISBI.2011.5872758
%
% --------------------------------------------------------------------------------------------
%
%
% author:                Alessandro Foi
%
% web page:              http://www.cs.tut.fi/~foi/RiceOptVST
%
% contact:               firstname.lastname@tut.fi
%
% --------------------------------------------------------------------------------------------
% Copyright (c) 2010-2016 Tampere University of Technology.
% All rights reserved.
% This work should be used for nonprofit purposes only.
% --------------------------------------------------------------------------------------------
%
% Disclaimer
% ----------
%
% Any unauthorized use of these routines for industrial or profit-oriented activities is
% expressively prohibited. By downloading and/or using any of these files, you implicitly
% agree to all the terms of the TUT limited license (included in the file Legal_Notice.txt).
% --------------------------------------------------------------------------------------------
%

%%
clear all
warning ('off', 'Octave:data-file-in-path')
%% main options in this demo

percentNoise=5;   %% percent noise (sigma expressed as percentage value with respect to the maximum value of the original noise-free signal)

estimate_noise=0.1;  %% estimate noise level from data using recursive algorithm with VST+Gaussian MAD

% denoising algorithm to be used for filtering the variance-stabilized data
denMethod='bm4d';      %% BM4D (Maggioni & Foi)
% denMethod='onlm3d';    %% OB-NLM-3D-WM (Manjon & Coup�)

%% --------------------------------------------------------------------------------------------

%% load BrainWeb T1 phantom
name ='t1_icbm_normal_1mm_pn0_rf0.rawb';
fid = fopen(name,'r');
nu = reshape(fread(fid,inf,'uchar'),[181,217,181]);
fclose(fid);

#nu = nu(40,51:150,1:100);
fileID = fopen('nu.bin','w');

#fwrite(fileID,nu(80,51:150,1:100),'float64');
fwrite(fileID,nu(80,:,:),'float64');
fclose(fileID);

%% uncomment some of the following lines to test on small subvolume
 %nu=nu(:,:,91-25:91+25);
% nu=nu(91-25:91+25,120:217,26-25:26+25);
% nu=nu(1:2:end,1:2:end,1:2:end);
% nu=nu(1:end/2,1:end/2,1:end/2);
% nu=nu(50:150,50:150,91-25:91+25);



%% create noisy data (spatially homogeneus Rician noise)
sigma=percentNoise*max(nu(:))/100;    % get sigma from percentNoise
randn('seed',0);  rand('seed',0);     % fixes pseudo-random noise
z=sqrt((nu+sigma*randn(size(nu))).^2 + (sigma*randn(size(nu))).^2);   % raw magnitude MR data

fileID = fopen('z.bin','w');

#fwrite(fileID,z(80,51:150,1:100),'float64');
fwrite(fileID,z(80,:,:),'float64');
fclose(fileID);
%%
disp(' ');disp(' ');disp( '---------------------------------------------------------------');
disp(['Size of data is ', num2str(size(z,1)),'x',num2str(size(z,2)),'x',num2str(size(z,3)),'  (total ',num2str(numel(z)),' voxel)']);
%% compute PSNR of observations
if exist('nu','var')
    if exist('sigma','var')&&exist('percentNoise','var')
        disp(['input nu range = [',num2str(min(nu(:))),' ',num2str(max(nu(:))),'],  noise sigma = ',num2str(sigma),' (',num2str(percentNoise),'%)']);
    else
        disp(['input nu range = [',num2str(min(nu(:))),' ',num2str(max(nu(:))),']']);
    end
    
    if 1
        ind=find(nu>10);   %% compute PSNR over foreground only
    else
        ind=1:numel(nu);   %% compute PSNR over every voxel in the volume
    end
    
    range_for_PSNR=255;
    psnr_z=10*log10(range_for_PSNR^2/(mean((z(ind)-nu(ind)).^2)));
    disp(['PSNR of noisy input z is ',num2str(psnr_z),' dB'])
end

%% noise-level estimation
if estimate_noise||~exist('sigma','var')
    disp( '---------------------------------------------------------------');
    disp(' * Estimating noise level sigma   [ model  z ~ Rice(nu,sigma) ]');
    estimate_noise_printout=1;   %% print-out estimate at each iteration.
    
    sigma_hat=riceVST_sigmaEst(z,estimate_noise_printout);
    disp( ' --------------------------------------------------------------');
    
    
    if ~exist('sigma','var')
        disp([' sigma_hat = ',num2str(sigma_hat)]);
    else
        disp([' sigma_hat = ',num2str(sigma_hat), '  (true sigma = ',num2str(sigma),')']);
        disp([' Relative estimation accuracy (1-sigma_hat/sigma) = ',num2str(1-sigma_hat/sigma)]);
    end
    disp( '---------------------------------------------------------------');
else
    sigma_hat=sigma;
end

%% denoising
VST_ABC_denoising='A';  %% VST pair to be used before and after denoising (for forward and inverse transformations)



if 1
    disp(' * Applying variance-stabilizing transformation')
    fz = riceVST(z,sigma_hat,VST_ABC_denoising);   %%  apply variance-stabilizing transformation
    save('/Users/augustus/Documents/alg_vst/fz.mat','fz')
    fileID = fopen('fz.bin','w');
    %b = reshape(nu,[1,2500]);
    #fwrite(fileID,fz(80,51:150,1:100),'float64');
    fwrite(fileID,fz(80,:,:),'float64');
    fclose(fileID);
    save('/Users/augustus/Documents/alg_vst/sigma_hat.mat','sigma_hat')

end




%disp(['   completed in ',num2str(toc),' seconds']);
disp( '---------------------------------------------------------------');



disp( '---------------------------------------------------------------');  disp(' ');