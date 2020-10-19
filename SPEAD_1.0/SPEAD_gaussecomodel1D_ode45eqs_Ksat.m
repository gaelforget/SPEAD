function [Vdot] = SPEAD_gaussecomodel1D_ode45eqs_K(iTime,V0)
global galfa gbeta 
global gzmax kgz mz betaz mpower 
global mp Isat InhFac numutx
global alp0 mup0 
global amup aknp 
global Q10a Q10h % Distinct partition coefficients for auto and heterotrophic processes
global ntot0 
global temp0 temp 
global jcounter  
global  keyPhysics 
global omePhy epsZoo omeZoo md 
global deltat
global zdepths ndepths deltaz
global jday
global Ixave_K Ixxvar_K
global Iphy Izoo Idin Ipon Ibox %continuous model
global KZ
global parz0
global kw wsink
%...................................................................................
global todedotday 
%...................................................................................
global UXout GXout
global todedotout 
%...................................................................................
global FPHYToutcont MPHYToutcont GPHYToutcont %OUTPUTS 
global FZOOoutcont  EZOOoutcont  MZOOoutcont 
global FDINoutcont  FPONoutcont
%...................................................................................

%%%%%%%%%%%%%%%%%
%STATE VARIABLES:
%%%%%%%%%%%%%%%%%
%===================================================================================
%...................................................................................
% eps constraint added by Le Gland (21/11/2019)
phy  = max(V0(Iphy),sqrt(eps));
zoo  = max(V0(Izoo),sqrt(eps));
din  = max(V0(Idin),sqrt(eps));
pon  = max(V0(Ipon),sqrt(eps));
box  = max(V0(Ibox),sqrt(eps));
%...................................................................................
%===================================================================================
%VERTICAL MIXING OF STATISTICAL MOMENTS:
%...................................................................................
if strcmp(keyPhysics,'not')
    %...............................................................................
    xave  = V0(Ixave_K) ;
    xxvar = V0(Ixxvar_K);
    %...............................................................................
elseif strcmp(keyPhysics,'yes')
    %...............................................................................
    xave_star  = V0(Ixave_K) ;
    xxvar_star = V0(Ixxvar_K);
    %...............................................................................
    xave  = (xave_star ./phy);
    xxvar = (xxvar_star./phy) - xave.^2;
    %...............................................................................
end
% Protection against negative variances and out-of-range correlations (Le Gland, 21/11/2019)
xxvar = max(10*sqrt(eps), xxvar); 

%...................................................................................
%===================================================================================
%................................................................................... 
VNPZD0 = [phy;zoo;din;pon]; 
%...................................................................................
%VSTAT0 = [xave,xxvar];
%................................................................................... 
%===================================================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%DAY OF SIMULATION ANT TIME COUNTER:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%===================================================================================
%...................................................................................
[jday,newday] = SPEAD_1D_daycounter(jday,iTime); % I simplify the function (Le Gland, 13/09/2019)
%...................................................................................
jcounter = floor(iTime/deltat); %For ode4.
%% jcounter = floor(iTime/deltat) + 1; %For ode1.
%...................................................................................
%===================================================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%CHECK FOR NEGATIVE CONCENTRATIONS:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%========================================================================
%........................................................................
Ineg = find(VNPZD0 < 0);
%........................................................................
if ~isempty(Ineg > 0)
    iTime
    disp(['P , Z , N , D']);
    wconcs = [phy,zoo,din,pon]
    wconcsNeg = VNPZD0(Ineg);
    disp('Error!!! there are NEGATIVE concentrations!')
    pause
end
%........................................................................
%========================================================================

%%%%%%%%%%%%%%%%%%%
%MASS CONSERVATION:
%%%%%%%%%%%%%%%%%%%
%===================================================================================
%...................................................................................
ntoti = sum(phy + zoo + din + pon + box); %Checking mass conservation.
%...................................................................................
%%ydistmax = 1d-6; %original. 
ydistmax = 1; %less strict level (for fast-numerical-solving)
ydist = abs(ntoti - ntot0);
%...................................................................................
%%if strcmp(keyNutrientSupply,'not') 
if abs(ydist) > ydistmax 
    masscheck_N = [iTime,jday,ntot0,ntoti,ydist]
    disp('Error!!! mass is NOT conserved!')
    pause
end 
%%end 
%...................................................................................
if mod(jday,10) == 0 % jjday is useless and can be replaced by jday (Le Gland, 13/09/2019)
    if strcmp(newday,'yes')
    masscheck = [iTime,jday,ntot0,ntoti,ydist]
    % disp('-------------------------------------------------')
    end
end
%...................................................................................
%===================================================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%MEAN TRAIT (j) OF THE GAUSSIAN DISTRIBUTION:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%===================================================================================
%...................................................................................
xj = xave; 
%xmj = xave; 
%...................................................................................
sigmaxj = sqrt(xxvar);
%...................................................................................
%===================================================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%CHECK FOR NEGATIVE VARIANCE:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%===================================================================================
%...................................................................................
Inegx = xxvar < 0;
%...................................................................................
xxvar(Inegx) = sqrt(eps);
%...................................................................................
Jnegx = find(xxvar < 0);
%...................................................................................
if ~isempty(Jnegx > 0)
    iTime
    x_ave_var = [xave,xxvar]
    disp('Error!!! x_variance is negative!!!')
    pause 
end
%...................................................................................
%===================================================================================

%%%%%%%%%%%%%%%%%%%%%%%
%GAUSSIAN DISTRIBUTION:
%%%%%%%%%%%%%%%%%%%%%%%
%fxj = (1.0 ./ (sigmaxj * sqrt(2*pi))) .* exp( -(xj - xmj).^2 ./ (2*sigmaxj.^2) ); %Okay.
fxj = (1.0 ./ (sigmaxj * sqrt(2*pi))); % since xj=xmj (Le Gland, 22/11/2019) 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%PHYTOPLANKTON BIOMASS GAUSSIAN DISTRIBUTION:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Ptot = phy;
Pxj = Ptot .* fxj;
Pxjalfa = Pxj.^galfa;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%ANALYTICAL INTEGRATION OF PHYTOPLANKTON GASSIAN DISTRUBUTION:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%===================================================================================
%...................................................................................
intPxalfadx = (Ptot.^galfa ./ sqrt(galfa)) .* (sigmaxj*sqrt(2*pi)).^(1-galfa);
%...................................................................................
%===================================================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%GRAZING FUNCTIONAL RESPONSE KTW:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%===================================================================================
%...................................................................................
tempj = temp(:,jday); % (Le Gland, 04/11/2019)
Vmax = (gzmax*zoo).*(Q10h.^((tempj - temp0)/10));
Qswitchj = (Pxjalfa ./ intPxalfadx);
Qfeeding = (Ptot.^gbeta ./ (Ptot.^gbeta + kgz^gbeta));
%...................................................................................
Gxj = Qswitchj .* Qfeeding .* Vmax;
%===================================================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%BIOMASS SPECIFIC GRAZING FUNCTIONAL RESPONSE KTW:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%...................................................................................
gxj = Gxj./Pxj; %[d-1] 
%...................................................................................

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%ANALYTICAL DERIVATIVES OF BIOMASS SPECIFIC GRAZING FUNCTIONAL RESPONSE KTW:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%===================================================================================
%...................................................................................
% d1gxdx = gxj .* (galfa - 1) .* (-(xj - xmj) ./ sigmaxj.^2 ); 
d1gxdx = 0*galfa; % Value at xj=xmj (Le Gland, 25/11/2019)
%...................................................................................
% d2gxdx = gxj .* (galfa - 1) .* ( (galfa - 1) .* (-(xj - xmj) ./ sigmaxj.^2).^2 - (1./sigmaxj.^2) );
d2gxdxdx = -gxj .* (galfa-1) ./ (sigmaxj.^2); % Value at xj=xmj (Le Gland, 25/11/2019)
%...................................................................................
%===================================================================================

%%%%%%%%%%%%%%%%%%%%%
%TURBULENT DIFFUSION:
%%%%%%%%%%%%%%%%%%%%%
%===================================================================================
%...................................................................................
if ndepths > 1
kz  = KZ (:,jday);
end
%...................................................................................
%===================================================================================
%STATISTICAL MOMENTS:
if strcmp(keyPhysics,'yes')
    %...................................................................................
    DIFFxave_star  = zeros(ndepths,1);
    DIFFxxvar_star = zeros(ndepths,1);
    %...................................................................................
    if ndepths > 1
        [DIFFxave_star]  = SPEAD_1D_TurbulentDiffusion(xave_star,deltat,deltaz,kz,ndepths,'Implicit',100);
        [DIFFxxvar_star] = SPEAD_1D_TurbulentDiffusion(xxvar_star,deltat,deltaz,kz,ndepths,'Implicit',100);
    end
%...................................................................................
end
%===================================================================================
%PLANKTON BIOMASSES:
%...................................................................................
DIFFphy = zeros(ndepths,1);
DIFFzoo = zeros(ndepths,1);
DIFFdin = zeros(ndepths,1);
DIFFpon = zeros(ndepths,1);
%...................................................................................
%pon
if ndepths > 1
    [DIFFphy] = SPEAD_1D_TurbulentDiffusion(phy,deltat,deltaz,kz,ndepths,'Implicit',100);
    [DIFFzoo] = SPEAD_1D_TurbulentDiffusion(zoo,deltat,deltaz,kz,ndepths,'Implicit',100);
    [DIFFdin] = SPEAD_1D_TurbulentDiffusion(din,deltat,deltaz,kz,ndepths,'Implicit',100);
    [DIFFpon] = SPEAD_1D_TurbulentDiffusion(pon,deltat,deltaz,kz,ndepths,'Implicit',100);
end
%...................................................................................
%===================================================================================

%%%%%%%%%%%%%%%%%%
%VERTICAL SINKING:
%%%%%%%%%%%%%%%%%%
%========================================================================
%........................................................................
[ADVpon] = SPEAD_1D_SinkingAdvection(pon,deltaz,wsink,ndepths);
% Transform PON to DIN at bottom to avoid PON accumulation (Le Gland, 11/12/2019)
ADVdin = zeros(ndepths,1);
ADVdin(end) = (wsink/deltaz)*pon(end);
%........................................................................
%========================================================================

%%%%%%%
%LIGHT:
%%%%%%%
%========================================================================
%........................................................................
jpar0 = parz0(jday); %Photo. Active. Radiation at the surface [W*m-2]
%........................................................................
jPAR  = jpar0*exp(-kw*zdepths(:)); %[W*m-2] PAR profile.
%........................................................................
% Qpar = (jPAR / Isat).*exp(1 - (jPAR/Isat)); %Phy light limitation [n.d.] values between 0 and 1.
% Use normalized Follows (2007) formula, with photoinhibition of large cells
Kpar   = log(InhFac+1) / Isat;
Kinhib = Kpar / InhFac; 
Fmax   = (Kpar+Kinhib)/Kpar * exp( -(Kinhib/Kpar) * log(Kinhib/(Kpar+Kinhib)) );  
% Qpar is normalized to have a maximum of 1 at Isat
Qpar = Fmax * (1 - exp(-Kpar*jPAR)) .* exp(-Kinhib*jPAR);
%........................................................................
%========================================================================
%------------------------------------------------------------------------
%NOTE: To keep the same DIN trade-off, both "mup" and "alp" ** must ** be 
%multiplied by the environmental limitation factor (eg. Qpar or Qsst) 
%Otherwise, if Qpar or Qsst only multiplies "mup", the optimal size for a 
%given DIN value will shift up and down instead of remaining always at 
%the same ESDphy value. 
%------------------------------------------------------------------------
%........................................................................
%% alp = alp0*ones(ndepths,1); 
%% mup = mup0*ones(ndepths,1);
%........................................................................
alp = alp0*Qpar; 
mup = mup0*Qpar;
%........................................................................
%========================================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%PHYTOPLANKTON NUTRIENT UPTAKE:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%PHYTOPLANKTON GROWTH UPTAKE RATE MICHAELIS MENTEN FUNCTION:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%===============================================================================
%...............................................................................
knp = (mup./alp);
%...............................................................................
%===============================================================================
%EXPONENTIAL UPTAKE AFFINITY: 
%...............................................................................
knxj = knp .* exp(aknp*xj); %Phy half-sat uptake as a function of cell size [mmolN*m-3]
%...............................................................................
%===============================================================================
%EXPONENTIAL MAXIMUM GROWTH RATE: 
%...............................................................................
muxj = mup .* exp(amup*xj); %Phy maximum grazing rate as a function of cell size [d-1]
%...............................................................................
%===============================================================================
%...............................................................................
lxj = (knxj ./ (knxj + din)); %[n.d.]
qxj = (din  ./ (din + knxj)); %[n.d.]
%...............................................................................
q10 = Q10a.^((tempj-temp0)/10); % q10 for single trait
uxj = muxj .* qxj .* q10; % Uptke rate at mean size
%...............................................................................
%===============================================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%ANALYTICAL DERIVATIVES OF GROWTH UPTAKE RATE MICHAELIS MENTEN FUNCTION:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%===============================================================================
%MY DERIVATIONS FOR MICHAELIS MENTEN: 
%...............................................................................
d1qxdx = - qxj .* (aknp * lxj);
d1lxdx = - d1qxdx; 
%...............................................................................
d2qxdx = -aknp * (d1lxdx .* qxj + d1qxdx .* lxj); 
%...............................................................................
%===============================================================================
%FROM BINGZANG CHEN FOR MAXIMUM GROWTH RATE WITH SIZE: 
%...............................................................................
cff = amup;
%...............................................................................
d1muxdx = muxj.*cff;
d2muxdx = muxj.*cff.^2;
%...............................................................................
%===============================================================================
%FROM BINGZANG CHEN FOR NUTRIENT UPTAKE USING UNIMODAL MAXIMUM GROWTH RATE: 
%...............................................................................
d1uxdx = q10 .* ( (d1muxdx .* qxj) + (muxj .* d1qxdx) );
%...............................................................................
d2uxdxdx = q10 .* ( ((d2muxdx .*    qxj) + (d1muxdx .* d1qxdx)) + ...
          ((d1muxdx .* d1qxdx) + (muxj    .* d2qxdx)) );
%...............................................................................
%===============================================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%ORDINARY DIFFERENTIAL EQUATIONS (ODEs):
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%===================================================================================
%...................................................................................
ux = uxj + (1/2)*(sigmaxj.^2).*d2uxdxdx; %Community upake rate gain.
%...................................................................................
%===================================================================================
%...................................................................................
gx = (1./phy) .* Qfeeding .* Vmax; %Community grazing rate loss [d-1]. %WRONG!!!!
%...................................................................................
%===================================================================================
%...................................................................................
Fphy = ux .* phy; %Phy primary production [mmolN * m-3 * d-1]
Gphy = gx .* phy; %Phy grazing mortality [mmolN * m-3 * d-1]
Mphy = mp * phy .* (Q10h.^((tempj - temp0)/10)); % Temperature dependence on mortality (Le Gland, 11/11/2019)
%...................................................................................
Fzoo = Gphy; %Zoo second production [mmolN * m-3 * d-1]
Ezoo = (1-betaz) * Fzoo; %Zoo exudation [mmolN * m-3 * d-1] 
Mzoo = mz * (zoo.^mpower) .* (Q10h.^((tempj - temp0)/10)); % Temperature dependence on mortality (Le Gland, 11/11/2019)
%...................................................................................
% Temperature-dependent detritus degradation, based on heterotrophic Q10
mdt = md*Q10h.^((tempj-temp0)/10);
Mpon = mdt.*pon;
%...................................................................................
%===================================================================================
%...................................................................................
dPHYdt =   Fphy - Gphy - Mphy; 
%...................................................................................
dZOOdt =   Fzoo - Ezoo - Mzoo; 
%...................................................................................
dDINdt = - Fphy + omePhy*Mphy + epsZoo*Ezoo + omeZoo*Mzoo + Mpon; 
%...................................................................................
dPONdt = (1-omePhy)*Mphy + (1-epsZoo)*Ezoo + (1-omeZoo)*Mzoo - Mpon;
%...................................................................................
%===================================================================================
%...................................................................................
dXAVEdt = xxvar .* (d1uxdx - d1gxdx);
%....................................................................................
dXXVARdt = (xxvar.^2) .* (d2uxdxdx - d2gxdxdx) + numutx .* (2.*ux); %
%................................................................................... 
%===================================================================================
%...................................................................................
FPHYToutcont(:,jcounter) = Fphy;
GPHYToutcont(:,jcounter) = Gphy;
MPHYToutcont(:,jcounter) = Mphy;
%...................................................................................
FZOOoutcont(:,jcounter) = Fzoo;
EZOOoutcont(:,jcounter) = Ezoo;
MZOOoutcont(:,jcounter) = Mzoo;
%...................................................................................
FDINoutcont(:,jcounter) = omePhy*Mphy + epsZoo*Ezoo + omeZoo*Mzoo + Mpon; 
FPONoutcont(:,jcounter) = + (1-omePhy)*Mphy + (1-epsZoo)*Ezoo + (1-omeZoo)*Mzoo;
%...................................................................................
%===================================================================================
%................................................................................... 
if strcmp(keyPhysics,'yes')
    dXAVE_STARdt = (dPHYdt .* xave) + (dXAVEdt .* phy);
    dXXVAR_STARdt = (dPHYdt .* xxvar) + (dXXVARdt .* phy) + (dPHYdt .* xave .* xave) + 2*(dXAVEdt .* xave .* phy);
end
%...................................................................................
dBOXdt = dPHYdt + dZOOdt + dDINdt + dPONdt; %Virtual box to check mass conservation.
%...................................................................................
%===================================================================================

%%%%%%%%%%%%%%%%%%%%%%%%
%ADD PHYSICAL PROCESSES:
%%%%%%%%%%%%%%%%%%%%%%%%
%===================================================================================
%...................................................................................
phydot = dPHYdt + DIFFphy;
zoodot = dZOOdt + DIFFzoo;
dindot = dDINdt + DIFFdin + ADVdin; % Bottom remineralization (ADVdin) added (Le Gland, 11/12/2019)
pondot = dPONdt + DIFFpon + ADVpon; %Only PON has vertical sinking.
%...................................................................................
boxdot = dBOXdt; 
%...................................................................................
%===================================================================================
if strcmp(keyPhysics,'not')
    %...............................................................................
    xavedot  = dXAVEdt;
    xxvardot = dXXVARdt;
    %...............................................................................
elseif strcmp(keyPhysics,'yes')
    %...............................................................................
    xave_stardot  = dXAVE_STARdt  + DIFFxave_star;
    xxvar_stardot = dXXVAR_STARdt + DIFFxxvar_star;
    %...............................................................................
end
%...................................................................................
%===================================================================================
%...................................................................................

%%%%%%%%%%
%STOCKAGE:
%%%%%%%%%%
%===================================================================================
%...................................................................................
todedotday(1,jday) = jday;
%...................................................................................
%Xavedotday(:,jday) = dXAVEdt;
%Xvardotday(:,jday) = dXVARdt;

%Xstddotday(:,jday) = dXSTDdt;
%...................................................................................
%d1UXdxday(:,jday) = d1uxdx;
%d1GXdxday(:,jday) = d1gxdx;
%...................................................................................
%d2UXdxday(:,jday) = d2uxdx;
%d2GXdxday(:,jday) = d2gxdx;
%...................................................................................
%UXday(:,jday) = ux;
%GXday(:,jday) = gx;
%...................................................................................
%===================================================================================
%...................................................................................
todedotout(1,jcounter) = jcounter*deltat;
%...................................................................................
%Xavedotout(:,jcounter) = dXAVEdt;
%Xvardotout(:,jcounter) = dXVARdt;
%Xstddotout(:,jcounter) = dXSTDdt;
%...................................................................................
%d1UXdxout(:,jcounter) = d1uxdx;
%d1GXdxout(:,jcounter) = d1gxdx;
%...................................................................................
%d2UXdxout(:,jcounter) = d2uxdx;
%d2GXdxout(:,jcounter) = d2gxdx;
%...................................................................................
UXout(:,jcounter) = ux;
GXout(:,jcounter) = gx;
%...................................................................................
%===================================================================================
%...................................................................................

%%%%%%%%
%OUTPUT:
%%%%%%%%
%===================================================================================
%...................................................................................
if strcmp(keyPhysics,'not')
    %...............................................................................
    Vdot = [phydot;zoodot;dindot;pondot;boxdot;xavedot;xxvardot];
    %...............................................................................
elseif strcmp(keyPhysics,'yes')
    %...............................................................................
    Vdot = [phydot;zoodot;dindot;pondot;boxdot;xave_stardot;xxvar_stardot];
    %...............................................................................
end

return
%...................................................................................
%===================================================================================
%***********************************************************************************
