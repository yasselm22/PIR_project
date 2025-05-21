import("stdfaust.lib");

// UI : fréquence et type d'accord

main_group(x) = hgroup("[0] Generateur d'accords", x);
group_param(x) = main_group(vgroup("[0] Paramètres", x));
// group_vit(x) = main_group(hgroup("[1] Vitesse", x));
// vit = group_vit(vslider("Variation", 0.5, 0, 1, 0.01));

group_vit(x) = hgroup("[0] Vitesse", x);
vit = group_vit(hslider("Variation", 0.5, 0, 1, 0.01));


root = group_param(hslider("[0] freq [Hz]", 440, 50, 2000, 1));
chordType = group_param(hslider("[1] Chord Type [style:menu{'Maj':0;'Min':1;'7':2;'Min7':3;'Maj7':4;'Dim':5;'Aug':6;'Sus2':7;'Sus4':8}]", 0, 0, 8, 1));

// Sliders de délai (en secondes) pour chaque voix
delayS1 = group_param(hslider("[2] Delay Voix 1 [unit:s]", 0.0, 0.0, 2.0, 0.01));
delayS2 = group_param(hslider("[3] Delay Voix 2 [unit:s]", 0.0, 0.0, 2.0, 0.01));
delayS3 = group_param(hslider("[4] Delay Voix 3 [unit:s]", 0.0, 0.0, 2.0, 0.01));
delayS4 = group_param(hslider("[5] Delay Voix 4 [unit:s]", 0.0, 0.0, 2.0, 0.01));

// Convertir les délais en nombre d’échantillons
delay1 = int(delayS1 * ma.SR);
delay2 = int(delayS2 * ma.SR);
delay3 = int(delayS3 * ma.SR);
delay4 = int(delayS4 * ma.SR);


// Intervalles en rapports de fréquence
M2 = pow(2, 2.0/12.0);   m3 = pow(2, 3.0/12.0);   M3 = pow(2, 4.0/12.0);
J4 = pow(2, 5.0/12.0);   J5 = pow(2, 7.0/12.0);   m7 = pow(2, 10.0/12.0);
M7 = pow(2, 11.0/12.0);  d5 = pow(2, 6.0/12.0);   a5 = pow(2, 8.0/12.0);

// Fréquences des voix selon le type d’accord
freq1 = root;

freq2 =
  (chordType == 0) * root * M3 + (chordType == 1) * root * m3 +
  (chordType == 2) * root * M3 + (chordType == 3) * root * m3 +
  (chordType == 4) * root * M3 + (chordType == 5) * root * m3 +
  (chordType == 6) * root * M3 + (chordType == 7) * root * M2 +
  (chordType == 8) * root * J4;

freq3 =
  ((chordType == 0) + (chordType == 1) + (chordType == 2) +
   (chordType == 3) + (chordType == 4) + (chordType == 7) +
   (chordType == 8)) * root * J5 +
  (chordType == 5) * root * d5 +
  (chordType == 6) * root * a5;

has7th = (chordType == 2) + (chordType == 3) + (chordType == 4);
freq4 = (chordType == 2) * root * m7 + (chordType == 3) * root * m7 + (chordType == 4) * root * M7;

// Gate ADSR
gate = group_param(button("gate"));
env_adsr = en.adsr(0.01, 0.1, 0.7, 0.3, gate);

// Génération différée de chaque voix
sig1 = os.osc(freq1) * (gate : @(delay1));
sig2 = os.osc(freq2) * (gate : @(delay2));
sig3 = os.osc(freq3) * (gate : @(delay3));
sig4 = has7th * os.osc(freq4) * (gate : @(delay4));

// Mix final avec enveloppe et gain
sig = (sig1 + sig2 + sig3 + sig4) * env_adsr * group_param(hslider("gain", 0.5, 0, 1, 0.01)) * 0.25;

// process = sig <: _, _;

process_ini = sig <: _, _;


//////////// VERSIONS

// Non modulaire
// process = process_ini


// Delays modulés par oscillateurs
// process = ["Delay Voix 1" : (os.osc(0.5)+1), "Delay Voix 2": (os.osc(0.1)+1), "Delay Voix 3": (os.osc(0.8)+1), "Delay Voix 4": (os.osc(0.7)+1) -> process_ini];


// Fréquence modulée par oscillateur, délais en slider
// process = ["freq" : ((os.osc(0.01)+1)*700+100) -> process_ini];

// Fréquence modulée par oscillateur calibré via slider, délais en slider
process = ["freq" : ((os.osc(vit)+1)*700+100) -> process_ini];

