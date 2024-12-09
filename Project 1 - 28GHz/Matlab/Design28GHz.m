%28GHz patch
clc;
clear;
close all;
c=3e8; %lightspeed
f=28e9; %operating frequency
fr = (25:0.05:31) * 1e9; %frequency range centring f
s=c/f; %wavelength
%unit radiating patch element
e=patchMicrostrip; %e is an instance variable, patchMicrostrip is the instance
%radiating material, all measurements are in unit meter
e.Length=0.00512;
e.Width=0.007;
e.Height=0.000107;
%ground material
e.GroundPlaneLength=0.010707;
e.GroundPlaneWidth=0.010707;
e.PatchCenterOffset=[0 0];
%substrate
e.Substrate.Name='Air';
e.Substrate.EpsilonR=1;
e.Substrate.LossTangent=0;
e.Substrate.Thickness=0.000107;
%offsets
e.PatchCenterOffset=[0 0]; %where radiator is situated wrt ground
e.FeedOffset=[0.001082 0];
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