function [Apcntile] = myPercentileAboveAverage(A,Pcntile)
%************************************************************************
%Use: [Apcntile] = myPercentileAboveAverage(Pcntile) 
%************************************************************************
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%OBTAIN A GIVEN PERCENTILE OF THE DATA THAT ARE ABOVE THE MEAN:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%========================================================================
%........................................................................
% $$$ %%Pcntile = 80; %Percentile 80.0%
% $$$ Pcntile = 99.9; %Percentile 99.9%
%........................................................................
B = A(:);
%........................................................................
B = B(B > 0); %Use only positive values (no zero or nan)
%........................................................................
B(B < mean(B)) = []; %Remove points below mean average.
%........................................................................
A50mean = B; %Only data points above mean value.
%........................................................................
Apcntile = prctile(B,Pcntile);
%........................................................................
%========================================================================
%************************************************************************
return
