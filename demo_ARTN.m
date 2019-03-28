% =========================================================================
% Test code
% Reduction of Video Compression Artifacts Based on Deep Temporal Networks (ARTN)
% 
% Reference
% Jae Woong Soh et al. "Reduction of Video Compression Artifacts Based on Deep Temporal Networks."
% IEEE Access 6 (2018): 63094-63106.
%
% Jae Woong Soh
% Department of ECE, INMC
% Seoul National University, Seoul, Korea
% 
% https://github.com/JWSoh/ARTN
% =========================================================================

%%
clear; close all;

addpath('../../../caffe/matlab/'); % add path to matcaffe
caffe.reset_all();

use_gpu=1;

% Set caffe mode
if exist('use_gpu', 'var') && use_gpu
    caffe.set_mode_gpu();
    gpu_id = 0;  % we will use the first gpu
    caffe.set_device(gpu_id);
else
    caffe.set_mode_cpu();
end

Par.mbSize = 64; % Patch size
Par.stride = 48; % Stride

Par.net_model = 'ARTN_Deploy.prototxt';

codec='MPEG2';
QP=30;

Par.net_weights = sprintf('Model/Model_%s%d.caffemodel',codec,QP);
currframe = 0;
prevframe = 0;
postframe = 0;

Net = caffe.Net(Par.net_model, Par.net_weights, 'test');

imgPath='Input';
filelists=dir(fullfile(imgPath,'*.png'));
NumberOfFrame=length(filelists);


for i=1:NumberOfFrame
    if i==1;
        postframe = im2double(imread(fullfile(imgPath,filelists(i+1).name)));
        currframe = im2double(imread(fullfile(imgPath,filelists(i).name)));
        [~,~,ch] = size(postframe);
        
        prevframe = currframe;
        
    elseif(i==NumberOfFrame)
        prevframe = currframe;
        currframe = postframe;
        
    else
        prevframe = currframe;
        currframe = postframe;
        
        postframe = im2double(imread(fullfile(imgPath,filelists(i+1).name)));
        
        [~,~,ch] = size(postframe);
        
    end
    
    resultframe = Frameprocess(Net, prevframe, currframe, postframe, Par);
    resultframe = min(max(double(resultframe), 0), 1);
    
    imwrite(resultframe,sprintf('Processed/%02d.png',i));
end
