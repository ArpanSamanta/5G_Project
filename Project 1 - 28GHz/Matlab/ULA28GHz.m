c=3e8;
f=28e9;
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
NumCurves = length(F);
%Calculate Steering Weights
w = zeros(getNumElements(h), length(F));
SV = phased.SteeringVector('SensorArray',h, 'PropagationSpeed', PS);
%Find the weights
for idx = 1:length(F)
    w(:, idx) = step(SV, F(idx), SA(:, idx));
end
%Plot 3d graph
fmt = 'polar';
figure; pattern(h, F(1), 'PropagationSpeed', PS, 'Type','directivity', ...
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
%Plot 2d graph
figure;
fmt = 'rectangular';
cutAngle = 0;
pattern(h, F, -180:180, cutAngle, 'PropagationSpeed', PS, 'Type', ...
    'directivity', 'CoordinateSystem', fmt ,'weights', w);
axis(hAxes,'square')
%Create legend
legend_string = cell(1,NumCurves);
lines = findobj(gca,'Type','line');
for idx = 1:NumCurves
    [Fval, ~, Fletter] = engunits(F(idx));
    if size(SA, 2) == 1
        az_str = num2str(SA(1,1));
        elev_str = num2str(SA(2,1));
    else
        az_str = num2str(SA(1, idx));
        elev_str = num2str(SA(2, idx));
    end
    if PSB(idx)>0
        legend_string{idx} = [num2str(Fval) Fletter 'Hz;' num2str(SA(1, ...
            idx)) 'Az' ' ' elev_str 'El' ';' ...
            num2str(PSB(idx)) '-bit Quantized'];
    else
        legend_string{idx} = [num2str(Fval) Fletter 'Hz;' num2str(SA(1, ...
            idx)) 'Az' ' ' elev_str 'El'];
    end
end
legend(legend_string, 'Location', 'southeast');
