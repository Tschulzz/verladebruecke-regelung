%
% Identifikation der PT1-Parameter
%

%%

clear all

%% Parameter
R = 0.046;
ue = 6;

K_K = 1;
T_K = 0.1;

strecke_ges = 2.54; % Strecke zwischen linkem und rechtem Endschalter

%% read Data
sample_time = 1e-3; % sekunden

start_zeit = [13 13 13 13 13]; % in sekunden
end_zeit = [21 21 20 22 22];

% Messungen f�r Identifikation (Absolutwertgeber geht hier nicht in Begrenzung)
measurement_nr = ['2','3','4','5','6'];

%% 1. Messung
k = 1;
[eingangs_sig_1, ausgangs_sig_1, resolver_sig_1] = loadadaptData(k, measurement_nr, start_zeit, end_zeit, strecke_ges, R, ue);
% Daten f�r Greybox Identifikation
avg = sum(ausgangs_sig_1(1:10))/10; % bilde Mittel der ersten 10 Werte
ausgangs_sig_1 = ausgangs_sig_1(1:end) - avg; % Setze Anfangswert des Ausgangssignals auf Null
data1_grey = iddata(ausgangs_sig_1,eingangs_sig_1,sample_time);

% Resolverdaten
avg = sum(resolver_sig_1(1:10))/10; % bilde Mittel der ersten 10 Werte
resolver_sig_1 = resolver_sig_1(1:end) - avg; % Setze Anfangswert des Ausgangssignals auf Null
data1_resolver = iddata(resolver_sig_1,eingangs_sig_1,sample_time);

% Daten f�r PT1 Identifikation
eingangs_sig_1(end) = []; % entferne letzten Eintrag da durch diff der ausgangsdaten Vektor um einen Eintrag reduziert wird
ausgangs_sig_1 = diff(ausgangs_sig_1)/sample_time;
ausgangs_sig_1 = ausgangs_sig_1 .* (ue/(2*pi*R)); % Umrechnung in Drehzahl
data1_pt1 = iddata(ausgangs_sig_1,eingangs_sig_1,sample_time);

%% 2. Messung
k = 2;
[eingangs_sig_2, ausgangs_sig_2, resolver_sig_2] = loadadaptData(k, measurement_nr, start_zeit, end_zeit, strecke_ges, R, ue);
% Daten f�r Greybox Identifikation
avg = sum(ausgangs_sig_2(1:10))/10; % bilde Mittel der ersten 10 Werte
ausgangs_sig_2 = ausgangs_sig_2(1:end) - avg; % Setze Anfangswert des Ausgangssignals auf Null
data2_grey = iddata(ausgangs_sig_2,eingangs_sig_2,sample_time);

% Resolverdaten
avg = sum(resolver_sig_2(1:10))/10; % bilde Mittel der ersten 10 Werte
resolver_sig_2 = resolver_sig_2(1:end) - avg; % Setze Anfangswert des Ausgangssignals auf Null
data2_resolver = iddata(resolver_sig_2,eingangs_sig_2,sample_time);

% Daten f�r PT1 Identifikation
eingangs_sig_2(end) = []; % entferne letzten Eintrag da durch diff der ausgangsdaten Vektor um einen Eintrag reduziert wird
ausgangs_sig_2 = diff(ausgangs_sig_2)/sample_time;
ausgangs_sig_2 = ausgangs_sig_2 .* (ue/(2*pi*R)); % Umrechnung in Drehzahl
data2_pt1 = iddata(ausgangs_sig_2,eingangs_sig_2,sample_time);

%% 3. Messung
k = 3;
[eingangs_sig_3, ausgangs_sig_3, resolver_sig_3] = loadadaptData(k, measurement_nr, start_zeit, end_zeit, strecke_ges, R, ue);
% Daten f�r Greybox Identifikation
avg = sum(ausgangs_sig_3(1:10))/10; % bilde Mittel der ersten 10 Werte
ausgangs_sig_3 = ausgangs_sig_3(1:end) - avg; % Setze Anfangswert des Ausgangssignals auf Null
data3_grey = iddata(ausgangs_sig_3,eingangs_sig_3,sample_time);

% Resolverdaten
avg = sum(resolver_sig_3(1:10))/10; % bilde Mittel der ersten 10 Werte
resolver_sig_3 = resolver_sig_3(1:end) - avg; % Setze Anfangswert des Ausgangssignals auf Null
data3_resolver = iddata(resolver_sig_3,eingangs_sig_3,sample_time);

% Daten f�r PT1 Identifikation
eingangs_sig_3(end) = []; % entferne letzten Eintrag da durch diff der ausgangsdaten Vektor um einen Eintrag reduziert wird
ausgangs_sig_3 = diff(ausgangs_sig_3)/sample_time;
ausgangs_sig_3 = ausgangs_sig_3 .* (ue/(2*pi*R)); % Umrechnung in Drehzahl
data3_pt1 = iddata(ausgangs_sig_3,eingangs_sig_3,sample_time);

%% 4. Messung
k = 4;
[eingangs_sig_4, ausgangs_sig_4, resolver_sig_4] = loadadaptData(k, measurement_nr, start_zeit, end_zeit, strecke_ges, R, ue);
% Daten f�r Greybox Identifikation
avg = sum(ausgangs_sig_4(1:10))/10; % bilde Mittel der ersten 10 Werte
ausgangs_sig_4 = ausgangs_sig_4(1:end) - avg; % Setze Anfangswert des Ausgangssignals auf Null
data4_grey = iddata(ausgangs_sig_4,eingangs_sig_4,sample_time);

% Resolverdaten
avg = sum(resolver_sig_4(1:10))/10; % bilde Mittel der ersten 10 Werte
resolver_sig_4 = resolver_sig_4(1:end) - avg; % Setze Anfangswert des Ausgangssignals auf Null
data4_resolver = iddata(resolver_sig_4,eingangs_sig_4,sample_time);

% Daten f�r PT1 Identifikation
eingangs_sig_4(end) = []; % entferne letzten Eintrag da durch diff der ausgangsdaten Vektor um einen Eintrag reduziert wird
ausgangs_sig_4 = diff(ausgangs_sig_4)/sample_time;
ausgangs_sig_4 = ausgangs_sig_4 .* (ue/(2*pi*R)); % Umrechnung in Drehzahl
data4_pt1 = iddata(ausgangs_sig_4,eingangs_sig_4,sample_time);

%% 5. Messung % nicht in Identifikationsdatensatz enthalten
k = 5;
[eingangs_sig_5, ausgangs_sig_5, resolver_sig_5] = loadadaptData(k, measurement_nr, start_zeit, end_zeit, strecke_ges, R, ue);
% Daten f�r Greybox Identifikation
avg = sum(ausgangs_sig_5(1:10))/10; % bilde Mittel der ersten 10 Werte
ausgangs_sig_5 = ausgangs_sig_5(1:end) - avg; % Setze Anfangswert des Ausgangssignals auf Null
data5_grey = iddata(ausgangs_sig_5,eingangs_sig_5,sample_time);

% Resolverdaten
avg = sum(resolver_sig_5(1:10))/10; % bilde Mittel der ersten 10 Werte
resolver_sig_5 = resolver_sig_5(1:end) - avg; % Setze Anfangswert des Ausgangssignals auf Null
data5_resolver = iddata(resolver_sig_5,eingangs_sig_5,sample_time);

% Daten f�r PT1 Identifikation
eingangs_sig_5(end) = []; % entferne letzten Eintrag da durch diff der ausgangsdaten Vektor um einen Eintrag reduziert wird
ausgangs_sig_5 = diff(ausgangs_sig_5)/sample_time;
ausgangs_sig_5 = ausgangs_sig_5 .* (ue/(2*pi*R)); % Umrechnung in Drehzahl
data5_pt1 = iddata(ausgangs_sig_5,eingangs_sig_5,sample_time);

%% Filterung der Messdaten (nur f�r Daten zur PT1 Identifikation)
% Filterung mit Tiefpass: Grenzfrequenz: 36 Hz
% Filter: Butterworthfilter 5. Ordnung

data1_pt1_f = idfilt(data1_pt1,5,0.072); % Bandpass 36Hz
data2_pt1_f = idfilt(data2_pt1,5,0.072);
data3_pt1_f = idfilt(data3_pt1,5,0.072);
data4_pt1_f = idfilt(data4_pt1,5,0.072);

% ersetze gefilterte Eingangsdaten durch ungefilterte Eingangsdaten
data1_pt1_f.u = data1_pt1.u;
data2_pt1_f.u = data2_pt1.u;
data3_pt1_f.u = data3_pt1.u;
data4_pt1_f.u = data4_pt1.u;

%% Identifikation des PT1-Gliedes
% Daten hierzu: datax_pt1_f
data_pt1_f = merge(data1_pt1_f,data2_pt1_f,data3_pt1_f,data4_pt1_f);

%systemIdentification

%% Identifikation des gesamten Teilsystems
% Daten hierzu: datax_grey
data_abswg = merge(data1_grey,data2_grey,data3_grey,data4_grey); % Ausgangsdaten: Absolutwertgeber
data_resolver = merge(data1_resolver,data2_resolver,data3_resolver,data4_resolver); % Ausgangsdaten: Resolver

% stelle Greyboxmodell auf
aux(1) = R;
aux(2) = ue;
aux(3) = K_K;

par_guess = 0.1;

ts = 0; % kontinuierliches Modell
model_greybox = idgrey('calcSysMatrixId', par_guess, 'c', aux, 0);

% Identifikation
model = greyest(data_resolver, model_greybox, greyestOptions('Display','on','InitialState','zero','DisturbanceModel','none'));

%systemIdentification

