%66GHz patch
clc;
clear;
close all;
c=3e8; %lightspeed
f=66e9; %operating frequency
fr = (63:0.05:69) * 1e9; %frequency range centring f
s=c/f; %wavelength
%unit radiating patch element
e=patchMicrostrip; %e is an instance variable, patchMicrostrip is the instance
%radiating material, all measurements are in unit meter
e.Length=0.0021803;
e.Width=0.0028389;
e.Height=4.5423e-05;
%ground material
e.GroundPlaneLength=0.0045423;
e.GroundPlaneWidth=0.0045423;
e.PatchCenterOffset=[0 0];
%substrate
e.Substrate.Name='Air';
e.Substrate.EpsilonR=1;
e.Substrate.LossTangent=0;
e.Substrate.Thickness=4.54230996969697e-05;
%offsets
e.PatchCenterOffset=[0 0]; %where radiator is situated wrt ground
e.FeedOffset=[0.00045901 0];
e.Tilt=0;
e.TiltAxis=[1 0 0];
%plots radiating unit
figure; show(e) %physical look
figure; impedance(e, fr) %impedance responses
figure; s11 = sparameters(e, fr); rfplot(s11) %reflection coeff
figure; patternAzimuth(e, f)
figure; patternElevation(e, f)
figure; current(e, f) % current distribution
figure; pattern(e, f) %3d pattern