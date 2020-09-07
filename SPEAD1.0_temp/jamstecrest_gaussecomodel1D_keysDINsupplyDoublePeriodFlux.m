function [keyTraitAxis,keyModelResol,keyFastNumericalSolving,keyPhysics,keySinking,keyPARseasonality,keyPARextinction,keyNutrientSupplyFlux,keyKTW,keyTraitDiffusion,keyGalfaConstant,keyTraitDiffusionConstant,keyLogBase,keyNutrientSupplyFrequencyConstant] = jamstecrest_gaussecomodel1D_keysDINsupplyDoublePeriodFlux()

%========================================================================
%........................................................................
keyTraitAxis = 'ESD';
%........................................................................
keyModelResol='1D'; %Depth-resolved (several nodes in depth).
%........................................................................
keyFastNumericalSolving='yes';
%........................................................................
keyPhysics='not'; %If you do *not* want physical processes (turbulent diffusion).
%........................................................................
keySinking='not'; %If you do *not* want advective processes (vertical sinking).
%........................................................................
keyPARseasonality='not'; %If you do *not* want seasonal solar radiation (PAR).
%........................................................................
keyPARextinction='not'; %If you want depth-constant solar radiation (PAR).
%........................................................................
keyNutrientSupplyFlux = 'yes';
%........................................................................
keyKTW = 'yes';
%........................................................................
keyTraitDiffusion = 'not';
%........................................................................
keyGalfaConstant = 'yes';
%........................................................................
keyTraitDiffusionConstant = 'yes';
%........................................................................
keyLogBase = 'BaseExp'; 
%........................................................................
keyNutrientSupplyFrequencyConstant = 'not'; %If you want depth-increasing pulse frequency. 
%........................................................................
%========================================================================
%************************************************************************
return


