% Computes motion vectors using Simple and Efficient TSS method
%
% Based on the paper by Jianhua Lu and Ming L. Liou
% IEEE Trans. on Circuits and Systems for Video Technology
% Volume 7, Number 2, April 1997 :  Pages 429:433
%
% Input
%   imgP : The image for which we want to find motion vectors
%   imgI : The reference image
%   mbSize : Size of the macroblock
%   p : Search parameter  (read literature to find what this means)
%
% Ouput
%   motionVect : the motion vectors for each integral macroblock in imgP
%   SESTSScomputations: The average number of points searched for a macroblock
%
% Written by Aroh Barjatya


function [motionVect, SESTSScomputations] = motionEstSESTSS(imgP, imgI, mbSize, stride, p)

if(size(imgP, 3)>1)
    imgP = rgb2gray(imgP);
end

if(size(imgI, 3)>1)
    imgI = rgb2gray(imgI);
end

[row col] = size(imgI);

vectors = zeros(2,floor(((row-mbSize+1)/stride))*floor(((col-mbSize+1)/stride)));


% we now take effectively log to the base 2 of p
% this will give us the number of steps required

L = floor(log10(p+1)/log10(2));  
stepMax =  2^(L-1);
costs = ones(1,6)*65537;

computations = 0;

% we start off from the top left of the image
% we will walk in steps of mbSize
% for every marcoblock that we look at we will look for
% a close match p pixels on the left, right, top and bottom of it

mbCount = 1;

xrange = 1: stride : row-mbSize+1;
if(xrange(end) ~= row-mbSize+1)
    xrange = [xrange row-mbSize+1];
end
    
yrange = 1: stride : col-mbSize+1;
if(yrange(end) ~= col-mbSize+1)
    yrange = [yrange col-mbSize+1];
end


for i = xrange
    for j = yrange
        
        % the Simple and Efficient three step search starts here
        %
        % each step is divided into two phases
        % in the first phase we evaluate the cost in two ortogonal
        % directions at a distance of stepSize away
        % based on a certain relationship between the three points costs
        % we select the remaining TSS points in the second phase
        % At the end of the second phase, which ever point has the least
        % cost becomes the root for the next step.
        % Please read the paper to find out more detailed information

        stepSize = stepMax;
        x = j;
        y = i;
        while (stepSize >= 1)
            refBlkVerPointA = y;
            refBlkHorPointA = x;
            
            refBlkVerPointB = y;
            refBlkHorPointB = x + stepSize;
            
            refBlkVerPointC = y + stepSize;
            refBlkHorPointC = x;
            
            if ( refBlkVerPointA < 1 || refBlkVerPointA+mbSize-1 >= row ...
                    || refBlkHorPointA < 1 || refBlkHorPointA+mbSize-1 >= col)
                % do nothing %
                
            else
                costs(1) = costFuncMAD(imgP(i:i+mbSize-1,j:j+mbSize-1), ...
                              imgI(refBlkVerPointA:refBlkVerPointA+mbSize-1, ...
                                 refBlkHorPointA:refBlkHorPointA+mbSize-1), mbSize);
                computations = computations + 1;
            end
            
            if ( refBlkVerPointB < 1 || refBlkVerPointB+mbSize-1 >= row ...
                    || refBlkHorPointB < 1 || refBlkHorPointB+mbSize-1 >= col)
                % do nothing %
                
            else
                costs(2) = costFuncMAD(imgP(i:i+mbSize-1,j:j+mbSize-1), ...
                        imgI(refBlkVerPointB:refBlkVerPointB+mbSize-1, ...
                            refBlkHorPointB:refBlkHorPointB+mbSize-1), mbSize);
                computations = computations + 1;
            end
                       

            if ( refBlkVerPointC < 1 || refBlkVerPointC+mbSize-1 >= row ...
                    || refBlkHorPointC < 1 || refBlkHorPointC+mbSize-1 >= col)
                % do nothing %
                
            else
                costs(3) = costFuncMAD(imgP(i:i+mbSize-1,j:j+mbSize-1), ...
                        imgI(refBlkVerPointC:refBlkVerPointC+mbSize-1, ...
                            refBlkHorPointC:refBlkHorPointC+mbSize-1), mbSize);
                computations = computations + 1;
            end
                        

                        
            if (costs(1) >= costs(2) && costs(1) >= costs(3))
                quadrant = 4;
            elseif (costs(1) >= costs(2) && costs(1) < costs(3))
                quadrant = 1;
            elseif (costs(1) < costs(2) && costs(1) < costs(3))
                quadrant = 2;
            elseif (costs(1) < costs(2) && costs(1) >= costs(3))
                quadrant = 3;
            end
            
            switch quadrant
                case 1
                    refBlkVerPointD = y - stepSize;
                    refBlkHorPointD = x;
                    
                    refBlkVerPointE = y - stepSize;
                    refBlkHorPointE = x + stepSize;
                    
                    if ( refBlkVerPointD < 1 || refBlkVerPointD+mbSize-1 >= row ...
                            || refBlkHorPointD < 1 || refBlkHorPointD+mbSize-1 >= col)
                        % do nothing %
                        
                    else
                        costs(4) = costFuncMAD(imgP(i:i+mbSize-1,j:j+mbSize-1), ...
                                    imgI(refBlkVerPointD:refBlkVerPointD+mbSize-1, ...
                                        refBlkHorPointD:refBlkHorPointD+mbSize-1), mbSize);
                        computations = computations + 1;
                    end
                    
                    if ( refBlkVerPointE < 1 || refBlkVerPointE+mbSize-1 >= row ...
                            || refBlkHorPointE < 1 || refBlkHorPointE+mbSize-1 >= col)
                        % do nothing %
                        
                    else
                        costs(5) = costFuncMAD(imgP(i:i+mbSize-1,j:j+mbSize-1), ...
                                    imgI(refBlkVerPointD:refBlkVerPointD+mbSize-1, ...
                                        refBlkHorPointD:refBlkHorPointD+mbSize-1), mbSize);
                        computations = computations + 1;
                    end
                    
                         
                case 2
                    refBlkVerPointD = y - stepSize;
                    refBlkHorPointD = x;
                    
                    refBlkVerPointE = y - stepSize;
                    refBlkHorPointE = x - stepSize;
                    
                    refBlkVerPointF = y;
                    refBlkHorPointF = x - stepSize;
                    
            
                    if ( refBlkVerPointD < 1 || refBlkVerPointD+mbSize-1 >= row ...
                            || refBlkHorPointD < 1 || refBlkHorPointD+mbSize-1 >= col)
                        % do nothing %
                        
                    else
                        costs(4) = costFuncMAD(imgP(i:i+mbSize-1,j:j+mbSize-1), ...
                                    imgI(refBlkVerPointD:refBlkVerPointD+mbSize-1, ...
                                        refBlkHorPointD:refBlkHorPointD+mbSize-1), mbSize);
                        computations = computations + 1;
                    end
                    
                    if ( refBlkVerPointE < 1 || refBlkVerPointE+mbSize-1 >= row ...
                            || refBlkHorPointE < 1 || refBlkHorPointE+mbSize-1 >= col)
                        % do nothing %
                        
                    else
                        costs(5) = costFuncMAD(imgP(i:i+mbSize-1,j:j+mbSize-1), ...
                                    imgI(refBlkVerPointE:refBlkVerPointE+mbSize-1, ...
                                        refBlkHorPointE:refBlkHorPointE+mbSize-1), mbSize);
                        computations = computations + 1;
                    end
                    
                    if ( refBlkVerPointF < 1 || refBlkVerPointF+mbSize-1 >= row ...
                            || refBlkHorPointF < 1 || refBlkHorPointF+mbSize-1 >= col)
                        % do nothing %
                        
                    else
                        costs(6) = costFuncMAD(imgP(i:i+mbSize-1,j:j+mbSize-1), ...
                                    imgI(refBlkVerPointF:refBlkVerPointF+mbSize-1, ...
                                        refBlkHorPointF:refBlkHorPointF+mbSize-1), mbSize);
                        computations = computations + 1;
                    end

                   
                case 3
                    refBlkVerPointD = y;
                    refBlkHorPointD = x - stepSize;
                    
                    refBlkVerPointE = y - stepSize;
                    refBlkHorPointE = x - stepSize;
                    
                    if ( refBlkVerPointD < 1 || refBlkVerPointD+mbSize-1 >= row ...
                            || refBlkHorPointD < 1 || refBlkHorPointD+mbSize-1 >= col)
                        % do nothing %
                        
                    else
                        costs(4) = costFuncMAD(imgP(i:i+mbSize-1,j:j+mbSize-1), ...
                                    imgI(refBlkVerPointD:refBlkVerPointD+mbSize-1, ...
                                        refBlkHorPointD:refBlkHorPointD+mbSize-1), mbSize);
                        computations = computations + 1;
                    end
                    
                    if ( refBlkVerPointE < 1 || refBlkVerPointE+mbSize-1 >= row ...
                            || refBlkHorPointE < 1 || refBlkHorPointE+mbSize-1 >= col)
                        % do nothing %
                        
                    else
                        costs(5) = costFuncMAD(imgP(i:i+mbSize-1,j:j+mbSize-1), ...
                                    imgI(refBlkVerPointD:refBlkVerPointD+mbSize-1, ...
                                        refBlkHorPointD:refBlkHorPointD+mbSize-1), mbSize);
                        computations = computations + 1;
                    end

                    
                 case 4
                    refBlkVerPointD = y + stepSize;
                    refBlkHorPointD = x + stepSize;
                    
                    if ( refBlkVerPointD < 1 || refBlkVerPointD+mbSize-1 >= row ...
                            || refBlkHorPointD < 1 || refBlkHorPointD+mbSize-1 >= col)
                        % do nothing %
                        
                    else
                        costs(4) = costFuncMAD(imgP(i:i+mbSize-1,j:j+mbSize-1), ...
                                    imgI(refBlkVerPointD:refBlkVerPointD+mbSize-1, ...
                                        refBlkHorPointD:refBlkHorPointD+mbSize-1), mbSize);
                        computations = computations + 1;
                    end
                otherwise
                    

            end

            
            % Now we find the vector where the cost is minimum
            % and store it ... this is what will be passed back.
            % we use the matlab function min() in this case and not the one 
            % that is written by author: minCosts()
                    
            
            [cost, dxy] = min(costs);      % finds which macroblock in imgI gave us min Cost
            
            switch dxy
                 case 1
                     % x = x; y = y;  
                 case 2
                     x = refBlkHorPointB; 
                     y = refBlkVerPointB;
                 case 3
                     x = refBlkHorPointC;
                     y = refBlkVerPointC; 
                 case 4
                     x = refBlkHorPointD;
                     y = refBlkVerPointD; 
                 case 5
                     x = refBlkHorPointE;
                     y = refBlkVerPointE;
                 case 6
                     x = refBlkHorPointF;
                     y = refBlkVerPointF;
                     
             end
        
            costs = ones(1,6) * 65537  ;
            stepSize = stepSize / 2;
            
        end
        
        vectors(1,mbCount) = y - i;    % row co-ordinate for the vector
        vectors(2,mbCount) = x - j;    % col co-ordinate for the vector            
        mbCount = mbCount + 1;
    end
end

motionVect = vectors;
SESTSScomputations = computations/(mbCount - 1);

                    