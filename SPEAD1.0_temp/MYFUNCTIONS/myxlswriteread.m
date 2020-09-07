%********************************************************************
%<https://www.mathworks.com/help/matlab/ref/xlsread.html> 
%<https://es.mathworks.com/matlabcentral/answers/21477-matlab-excell>
%********************************************************************
%====================================================================
%....................................................................
close all
clear all
%....................................................................
% $$$ values = {1, 2, 3 ; 4, 5, 'x' ; 7, 8, 9};
% $$$ headers = {'First','Second','Third'};
% $$$ xlswrite('myxlswriteread_Example.xlsx',[headers; values]);
%....................................................................
filename = 'myxlswriteread_Example.xlsx';
A = xlsread(filename)
%....................................................................
filename = 'myxlswriteread_Example.xlsx';
sheet = 1;
xlRange = 'B2:C3';
subsetA = xlsread(filename,sheet,xlRange)
%....................................................................
%====================================================================
%********************************************************************
return


