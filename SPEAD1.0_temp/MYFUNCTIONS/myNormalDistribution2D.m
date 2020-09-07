function [GaussXY] = myNormalDistribution2D(varargin)
%%function [GaussXY]=myGaussDistribution2D(varargin)
%**********************************************************************
%Use: [GaussXY]=myNormalDistribution2D(xrng,yrng,sigmaPcnt,xlag,ylag);
%----------------------------------------------------------------------
%sigmaXci = sqrt(0.01*xmax);
%GaussX = (1/(sigmaX*sqrt(2*pi))) * exp(-(xrng-xmean).^2/(2*sigmaX^2));
%----------------------------------------------------------------------
%**********************************************************************

%............................................    
nvarargin=length(varargin);
%............................................
if nvarargin==0
    %........................................
    x=[-2:0.1:+2];
    y=[-2:0.1:+2];
    SigmaPcnt=0.2;
    xlag=0;
    ylag=0;
    %........................................
elseif nvarargin==3
    %........................................
    x=varargin{1};
    y=varargin{2};
    SigmaPcnt=varargin{3};
    xlag=0;
    ylag=0;
    %........................................
elseif nvarargin==5
    %........................................
    x=varargin{1};
    y=varargin{2};
    SigmaPcnt=varargin{3};
    xlag=varargin{4};
    ylag=varargin{5};
    %........................................
end
%............................................    
if isempty(x)==1
    xmax=inf;
end
%............................................    
if isempty(y)==1
    ymax=inf;
end
%............................................    
xmax=max(x);
ymax=max(y);
%............................................    
xmean=mean(x)+xlag;
ymean=mean(y)+ylag;
%............................................    
[X,Y]=meshgrid(x,y);
%............................................    

%%%%%%%%%%%%%%%%%%
%GAUSSIAN SURFACE:
%%%%%%%%%%%%%%%%%%
%............................................    
% $$$ sigmaX = sqrt(SigmaPcnt*xmax);
% $$$ sigmaY = sqrt(SigmaPcnt*ymax);
%............................................    
SigmaX = sigmaPcnt*(xmax-xmin); %Okay. 
SigmaY = sigmaPcnt*(ymax-ymin); %Okay. 
%............................................    
A = 1 / (sigmaX*sqrt(2*pi));
%............................................    
Bx = (X-xmean).^2 / (2*sigmaX^2);
By = (Y-ymean).^2 / (2*sigmaY^2);
%............................................    
GaussXY = A * exp(-(Bx+By));
%............................................    
[m,n]=size(GaussXY);
%............................................

%%%%%%
%PLOT:
%%%%%%
%............................................    
% $$$ figure(1)
% $$$ if min([m,n])==1
% $$$     plot(x,GaussXY,'b-')
% $$$     hold on
% $$$     plot(x,GaussXY,'r*')
% $$$     hold off
% $$$ else
% $$$     surf(X,Y,GaussXY)
% $$$ end
%............................................    

%%%%%%%%
%OUTPUT:
%%%%%%%%
%............................................    
if min([m,n])==1
    GaussXY = GaussXY(:);
end
%............................................    