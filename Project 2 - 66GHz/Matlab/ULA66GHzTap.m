c=3e8;
f=66e9;
l=c/f;
n=input('enter no of element: ');
s=input('enter spacing factor: ');
d=s*l;
azu=input('enter azimuthal angle: ');
% Create a uniform linear array
h = phased.ULA;
h.NumElements = n;
h.ElementSpacing = d;
h.ArrayAxis = 'y';
%Calculate Taper
sll = input('enter taper: ');
wind = chebwin(n, sll)';
h.Taper = wind;
%Create Isotropic Antenna Element
el = phased.IsotropicAntennaElement;
el.BackBaffled = true;
h.Element = el;
%Assign steering angles, frequencies and propagation speed
SA = [azu;0];
%Assign number of phase shift quantization bits
PSB = 0;
F = f;
PS = c;
%Create figure, panel, and axes
fig = figure;
panel = uipanel('Parent',fig);
hAxes = axes('Parent',panel,'Color','none');
%Calculate Steering Weights
w = zeros(getNumElements(h), length(F));
SV = phased.SteeringVector('SensorArray',h, 'PropagationSpeed', PS);
%Find the weights
for idx = 1:length(F)
    w(:, idx) = step(SV, F(idx), SA(:, idx));
end
%Plot 3d graph
fmt = 'polar';
pattern(h, F(1), 'PropagationSpeed', PS, 'Type','directivity', ...
    'CoordinateSystem', fmt,'weights', w(:,1));
%Adjust the view angles
hSmallAxes = axes('Parent', panel, 'Position', [0 0.8 0.2 0.2]);
hlink = linkprop([hAxes hSmallAxes],'View');
setappdata(fig, 'Lin1', hlink);
viewArray(h,'AxesHandle', hSmallAxes)
view(hAxes,[90 0]);
title = get(hAxes, 'title');
title_str = get(title, 'String');
%Modify the title
[Fval, ~, Fletter] = engunits(f);
title_str = [title_str newline num2str(Fval) ' ' Fletter 'Hz '];
set(title, 'String', title_str);
