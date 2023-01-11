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

%% denoising
VST_ABC_denoising='A'; 
if 1
    disp(' * Applying variance-stabilizing transformation')
    %fz = riceVST(z,sigma_hat,VST_ABC_denoising);   %%  apply variance-stabilizing transformation
    #fileID = fopen('fz.bin');
    #fz2 = reshape(fread(fileID,'float64'),[1,217,181]);
    fz2 =  load('/Users/augustus/Documents/alg_vst/transformed.mat').fz;
    sigma_hat_2 = load('/Users/augustus/Documents/alg_vst/sigma_hat.mat','sigma_hat').sigma_hat(1);
    
    nu_hat = riceVST_EUI(fz2,sigma_hat_2,VST_ABC_denoising);  
    
    fileID = fopen('nu_hat_res.bin','w');
    %b = reshape(nu,[1,2500]);
    fwrite(fileID,nu_hat,'float64');
    fclose(fileID);
    save('/Users/augustus/Documents/alg_vst/nu_hat.mat','nu_hat')
    
    
    fz2 =  load('/Users/augustus/Documents/alg_vst/transformed_ksvd.mat').fz;
    sigma_hat_2 = load('/Users/augustus/Documents/alg_vst/sigma_hat.mat','sigma_hat').sigma_hat(1);
    
    nu_hat = riceVST_EUI(fz2,sigma_hat_2,VST_ABC_denoising);  
    
    fileID = fopen('nu_hat_ksvd.bin','w');
    %b = reshape(nu,[1,2500]);
    fwrite(fileID,nu_hat,'float64');
    fclose(fileID);
    
end

 %% VST pair to be used before and after denoising (for forward and inverse transformations)

%
