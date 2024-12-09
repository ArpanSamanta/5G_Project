clc;
clear;
close all;
c=3e8; %lightspeed
f=66e9; %operating frequency
fr = (63:0.25:69) * 1e9; %frequency range centring f
s=c/f; %wavelength
n=input('number of elements: '); %number of elements in the array
d=input('enter spacing factor: ');
%unit radiating patch element
%use "antenna designer" to get the parameter's value
e=patchMicrostrip; %e is an instance variable, patchMicrostrip is the instance
%dimensions
%radiating material
e.Length=0.0021803;
e.Width=0.0028389;
e.Height=4.5423e-05;
%ground material
e.GroundPlaneLength=0.0045423;
e.GroundPlaneWidth=0.0045423;
e.PatchCenterOffset=[0 0]; %where radiator is situated wrt ground, x y offset
%substrate
e.Substrate.Name='Air'; %area same as ground
e.Substrate.EpsilonR=1;
e.Substrate.LossTangent=0;
e.Substrate.Thickness=4.54230996969697e-05;
%offsets
e.PatchCenterOffset=[0 0]; %where radiator is situated wrt ground
e.FeedOffset=[0.00045901 0]; %where feed is situated between ground and radiator
e.Tilt=0;
e.TiltAxis=[1 0 0];
%linear array
a=linearArray;
a.Element=e; %individual element is e
a.NumElements=n; %number of elements
a.ElementSpacing=s*d; %distance between 2 radiating elements
a.AmplitudeTaper=1;
a.PhaseShift=0;
a.Tilt=0;
a.TiltAxis=[1 0 0];
%linear array
figure; show(a) %physical look
figure; pattern(a, f) %3d pattern
%to export in mat file
Spars = sparameters(a,linspace(60e9,70e9,21));
smithplot(Spars);
save('antenna66GHz.mat','Spars');