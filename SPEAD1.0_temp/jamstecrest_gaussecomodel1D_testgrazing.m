%===================================================================================
%...................................................................................
galfa = 2; 
gbeta = 2; 
%...................................................................................
gzmax = 1.0; %Zoo maximum grazing rate [d-1]
kgz = 0.75; %Zoo half-sat grazing [mmolN*m-3]
%...................................................................................
zoo = 0.1; 
Ptot = 0.1; 
Pxj = 0.057555; 
%...................................................................................
xstd0 = log( 2.0); %Phy diameter deviate [log(um)]
sigmaxj = xstd0;
%...................................................................................
Pxjalfa = Pxj^galfa 
intPxalfadx = (Ptot.^galfa ./ sqrt(galfa)) .* (sigmaxj*sqrt(2*pi)).^(1-galfa); 
%...................................................................................
Qswitchj = (Pxjalfa / intPxalfadx) 
Qfeeding = (Ptot^gbeta / (kgz^gbeta + Ptot^gbeta)) 
%...................................................................................
Vmax = gzmax*zoo 
%...................................................................................
Gxj = Qswitchj*Qfeeding*Vmax 
Gx = Qfeeding*Vmax 
%...................................................................................
gxj = Gxj/Pxj 
gx = Gx/Ptot 
%...................................................................................
%===================================================================================

