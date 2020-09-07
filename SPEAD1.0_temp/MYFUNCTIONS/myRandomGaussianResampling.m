function [PDF,BIN] = myRandomGaussianResampling(Xdata)

%===================================================================
%...................................................................
nptos = length(Xdata);
nsampling = 1000;
%...................................................................
BIN = []; %[RandomBin]
PDF = []; %[XdataPDFs]
%...................................................................
% $$$ deltaBin = 0.1;
deltaBin = 0.01;
%...................................................................
%===================================================================
for jSampling = 1:nsampling
    jSampling 
    %===============================================================
    %...............................................................
    jGaussBin = myRandomBin('Gaussian',nptos,1.0,deltaBin);
    %...............................................................
    jXdataPDF = Xdata.*jGaussBin;
    %...............................................................
    jBIN = jGaussBin(:);
    jPDF = jXdataPDF(:);
    %...............................................................
    BIN(:,jSampling) = jBIN;
    PDF(:,jSampling) = jPDF;
    %...............................................................
    %===============================================================
end
return
xrandBin = myRandomBin('Gaussian',1000,1,0.1);