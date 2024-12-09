%Pulse
clear;
close all;
t = 0:0.001:0.3;                % Time, sampling frequency is 1kHz
s = zeros(size(t));  
s = s(:);                       % Signal in column vector
s(201:205) = s(201:205) + 1;    % Define the pulse
figure; plot(t,s);
title('Pulse');xlabel('Time (s)');ylabel('Amplitude (V)');
carrierFreq = 100e6;
wavelength = physconst('LightSpeed')/carrierFreq;
ula = phased.ULA('NumElements',10,'ElementSpacing',wavelength/2);
ula.Element.FrequencyRange = [90e5 110e6];
inputAngle = [45; 0]; %target angle
x = collectPlaneWave(ula,s,inputAngle,carrierFreq);
rs = RandStream.create('mt19937ar','Seed',2008);
noisePwr = .5;   % noise power 
noise = sqrt(noisePwr/2)*(randn(rs,size(x))+1i*randn(rs,size(x)));
rxSignal = x + noise;

%Phase Shift
psbeamformer = phased.PhaseShiftBeamformer('SensorArray',ula,'OperatingFrequency',carrierFreq,'Direction',inputAngle,'WeightsOutputPort', true);
[yCbf,w] = psbeamformer(rxSignal);
figure; clf; plot(t,abs(yCbf)); axis tight;
title('Output of Phase Shift Beamformer');
xlabel('Time (s)');ylabel('Magnitude (V)');
figure; pattern(ula,carrierFreq,-180:180,0,'Weights',w,'Type','powerdb','PropagationSpeed',physconst('LightSpeed'),'Normalize',false,'CoordinateSystem','rectangular');
axis([-90 90 -60 0]);

% interference at 30 degrees and 50 degrees
nSamp = length(t);
s1 = 10*randn(rs,nSamp,1);
s2 = 10*randn(rs,nSamp,1);
interference = collectPlaneWave(ula,[s1 s2],[30 50; 0 0],carrierFreq);
noisePwr = 0.00001;   % noise power, 50dB SNR 
noise = sqrt(noisePwr/2)*(randn(rs,size(x))+1i*randn(rs,size(x)));
rxInt = interference + noise;        % total interference + noise
rxSignal = x + rxInt;                % total received Signal
yCbf = psbeamformer(rxSignal);

%Phase shift incase of interference
figure;
plot(t,abs(yCbf)); axis tight;
title('Output of Phase Shift Beamformer With Presence of Interference');
xlabel('Time (s)');ylabel('Magnitude (V)');

% MVDR incase of interference
mvdrbeamformer = phased.MVDRBeamformer('SensorArray',ula,'Direction',inputAngle,'OperatingFrequency',carrierFreq,'WeightsOutputPort',true);
mvdrbeamformer.TrainingInputPort = true;
[yMVDR, wMVDR] = mvdrbeamformer(rxSignal,rxInt);
figure;
plot(t,abs(yMVDR)); axis tight;
title('Output of MVDR Beamformer With Presence of Interference');
xlabel('Time (s)');ylabel('Magnitude (V)');

% MVDR vs Phase Shift
figure;
pattern(ula,carrierFreq,-180:180,0,'Weights',wMVDR,'Type','powerdb','PropagationSpeed',physconst('LightSpeed'),'Normalize',false,'CoordinateSystem','rectangular');
axis([-90 90 -80 20]);
hold on;
pattern(ula,carrierFreq,-180:180,0,'Weights',w,'PropagationSpeed',physconst('LightSpeed'),'Normalize',false,'Type','powerdb','CoordinateSystem','rectangular');
hold off;
legend('MVDR','PhaseShift');

%self nulling in MVDR
mvdrbeamformer_selfnull = phased.MVDRBeamformer('SensorArray',ula,'Direction',inputAngle,'OperatingFrequency',carrierFreq,'WeightsOutputPort',true,'TrainingInputPort',false);
expDir = [43; 0];
mvdrbeamformer_selfnull.Direction = expDir;
[ySn, wSn] = mvdrbeamformer_selfnull(rxSignal);
figure; plot(t,abs(ySn)); axis tight;
title('Output of MVDR Beamformer With Signal Direction Mismatch');
xlabel('Time (s)');ylabel('Magnitude (V)');
figure; pattern(ula,carrierFreq,-180:180,0,'Weights',wSn,'Type','powerdb','PropagationSpeed',physconst('LightSpeed'),'Normalize',false,'CoordinateSystem','rectangular');
axis([-90 90 -40 25]);

%LCMV
lcmvbeamformer = phased.LCMVBeamformer('WeightsOutputPort',true);
steeringvec = phased.SteeringVector('SensorArray',ula);
stv = steeringvec(carrierFreq,[43 41 45]);
lcmvbeamformer.Constraint = stv;
lcmvbeamformer.DesiredResponse = [1; 1; 1];
[yLCMV,wLCMV] = lcmvbeamformer(rxSignal);
figure; plot(t,abs(yLCMV)); axis tight;
title('Output of LCMV Beamformer With Signal Direction Mismatch');
xlabel('Time (s)');ylabel('Magnitude (V)');

%LCMV vs MVDR
figure;
pattern(ula,carrierFreq,-180:180,0,'Weights',wLCMV,'Type','powerdb','PropagationSpeed',physconst('LightSpeed'),'Normalize',false,'CoordinateSystem','rectangular');
axis([0 90 -40 35]);
hold on;
pattern(ula,carrierFreq,-180:180,0,'Weights',wSn,'PropagationSpeed',physconst('LightSpeed'),'Normalize',false,'Type','powerdb','CoordinateSystem','rectangular');
hold off;
legend('LCMV','MVDR');