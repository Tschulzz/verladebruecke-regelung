%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% berechne Butterworthfilter
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Parameter

% minimale Seill�nge
L_min = 0.05; % m
T = 2*pi*sqrt(L_min / 9.81); % sek

order = 1;
cutofffreq = (1/T) * 10; % in Hz
% f�r geringe Phasenverschiebung wird als cutoff die 10 fache Frequenz der
% h�chstfrequenten auftretenden Schwingung verwendet

%% berechne Tierpassfilter

[A_b_angel, B_b_angel, C_b_angel, D_b_angel] = butter(order, 2*pi*cutofffreq, 's');

