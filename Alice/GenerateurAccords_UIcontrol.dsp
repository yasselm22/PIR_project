import("stdfaust.lib");

// UI
root = hslider("[1] Tonic [Hz]", 440, 50, 2000, 1);
chordType = hslider("[2] Chord Type [style:menu{'Maj':0;'Min':1;'7':2;'Min7':3;'Maj7':4;'Dim':5;'Aug':6;'Sus2':7;'Sus4':8}]", 0, 0, 8, 1);

// Intervalles en rapports de fréquence
M2 = pow(2, 2.0/12.0);   // Seconde majeure
m3 = pow(2, 3.0/12.0);   // Tierce mineure
M3 = pow(2, 4.0/12.0);   // Tierce majeure
J4 = pow(2, 5.0/12.0);   // Quarte juste
J5 = pow(2, 7.0/12.0);   // Quinte juste
m7 = pow(2, 10.0/12.0);  // Septième mineure
M7 = pow(2, 11.0/12.0);  // Septième majeure
d5 = pow(2, 6.0/12.0);   // Quinte diminuée
a5 = pow(2, 8.0/12.0);   // Quinte augmentée


// Voix 1 (tonique)
freq1 = root;

// Voix 2 (tierce ou autre)
freq2 =
  (chordType == 0) * root * M3 + // Maj
  (chordType == 1) * root * m3 + // Min
  (chordType == 2) * root * M3 + // 7
  (chordType == 3) * root * m3 + // Min7
  (chordType == 4) * root * M3 + // Maj7
  (chordType == 5) * root * m3 + // Dim
  (chordType == 6) * root * M3 + // Aug
  (chordType == 7) * root * M2 + // Sus2
  (chordType == 8) * root * J4;  // Sus4

// Voix 3 (quinte ou autre)
freq3 =
  ((chordType == 0) + (chordType == 1) + (chordType == 2) +
   (chordType == 3) + (chordType == 4) + (chordType == 7) +
   (chordType == 8)) * root * J5 +
  (chordType == 5) * root * d5 + // Dim
  (chordType == 6) * root * a5;  // Aug

// Voix 4 (septième si applicable)
has7th = (chordType == 2) + (chordType == 3) + (chordType == 4);
freq4 =
  (chordType == 2) * root * m7 + // 7
  (chordType == 3) * root * m7 + // Min7
  (chordType == 4) * root * M7;  // Maj7

// Génération sinusoïdale
sig =
  os.osc(freq1) +
  os.osc(freq2) +
  os.osc(freq3) +
  has7th * os.osc(freq4);

// Sortie normalisée
process = sig * 0.25;
