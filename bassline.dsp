import("stdfaust.lib");

//──────────────────OSCILLATOR──────────────────
tune = hslider("h:[0]Bassline/[style:knob][0]Tune", 200, 20, 2000, 1) : si.smoo;
sub_level = hslider("h:[0]Bassline/[style:knob][1]Sub Level", 0.5, 0, 1, 0.01);
drive = hslider("h:[0]Bassline/[style:knob][2]Drive", 0.1, 0.01, 40, 0.01);
wform = hslider("h:[3]Bassline/Signal[style:menu{'Triangle':0;'Saw':1;'Square':2}]", 0, 0, 2, 1);

overdrive(gain) = *(gain) : hardclip : *(1.0 / gain);
hardclip(x) = min(max(x, -1.0), 1.0);


tri_osc    = os.triangle(tune);
saw_osc    = os.sawtooth(tune);
square_osc = os.square(tune);
sub_osc = os.square(tune/2) * sub_level;
bassline_osc = (select3(wform, tri_osc, saw_osc, square_osc) + sub_osc) : overdrive(drive);

//──────────────────FILTER──────────────────
cutoff = hslider("h:[1]Bassline/[style:knob][0]Cutoff", 800, 50, 5000, 1) : si.smoo;
resonance = hslider("h:[1]Bassline/[style:knob][1]Resonance", 0.7, 0.1, 10, 0.1) : si.smoo;
vcf_mode = hslider("h:[3]Bassline/Filter mode[style:menu{'Bandpass':0;'Lowpass':1}][0]", 0, 0, 1, 1);

gain = 1 + (resonance * 0.1); // Adjust constant to taste
lowpass = fi.resonlp(cutoff, resonance, gain);
bandpass = fi.resonlp(cutoff, resonance, gain);
vcf = select2(vcf_mode, bandpass, lowpass);

// ───────────────────── FINAL PROCESS ─────────────────────
filtered = bassline_osc <: vcf;
process = filtered;


//process = _*tune*sub_level*drive*cutoff*resonance*vcf_mode*wform*decay*vcf_env:_;
vcf_env = hslider("h:[2]Bassline/[style:knob][1]vcf env", 1, 1, 5, 1);
decay = hslider("h:[2]Bassline/[style:knob][2]Decay", 1, 1, 5, 1);
