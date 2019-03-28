% Computes the Mean Absolute Difference (MAD) for the given two blocks
% Input
%       currentBlk : The block for which we are finding the MAD
%       refBlk : the block w.r.t. which the MAD is being computed
%       n : the side of the two square blocks
%
% Output
%       cost : The MAD for the two blocks
%
% Written by Aroh Barjatya


function cost = costFuncMAD(currentBlk,refBlk, n)
dif = abs(currentBlk - refBlk);
cost = sum(dif(:)) / (n*n);


