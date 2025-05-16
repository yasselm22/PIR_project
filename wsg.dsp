import("stdfaust.lib");

//─────────VOICE A─────────
wacky_a_freq = hslider("h:[0]WSG/v:[0]VOICE A/[style:knob][0]Wacky Freq", 440, 0, 4000, 1) : si.smoo;
zany_a_freq = hslider("h:[0]WSG/v:[0]VOICE A/[style:knob][0]Zany Freq", 2, 0.00, 20, 0.001) : si.smoo;
zaniness_a = hslider("h:[0]WSG/v:[0]VOICE A/[style:knob][0]Zaziness", 0, 0.0, 1.0, 0.01) : si.smoo;
weird_a_freq = hslider("h:[0]WSG/v:[0]VOICE A/[style:knob][0]Weird Freq", 440, 0, 2500, 1) : si.smoo;
wackiness_a = checkbox("h:[0]WSG/v:[1]VOICE A/Wackiness");
wacky_too_a = checkbox("h:[0]WSG/v:[1]VOICE A/Wacky too");
unusual_a = checkbox("h:[0]WSG/v:[1]VOICE A/unusual");

// "Zaniness" FM
zany_ramp_a   = os.triangle(zany_a_freq);    // –1 to +1
zany_square_a = os.square(zany_a_freq);           // ±1
zany_a_osc = select2(unusual_a, zany_square_a, zany_ramp_a);

// Base Square OSC
weird_a_osc = os.square(weird_a_freq + zany_a_osc*weird_a_freq*zaniness_a);

wacky_a = os.square(wacky_a_freq);
wacky_gate_a = (wacky_a > 0);

voice_a = weird_a_osc*select2(wackiness_a, 1, wacky_gate_a) + wacky_a*wacky_too_a;

//─────────VOICE B─────────
wacky_b_freq = hslider("h:[0]WSG/v:[1]VOICE B/[style:knob][0]Wacky Freq", 440, 0, 4000, 1) : si.smoo;
zany_b_freq = hslider("h:[0]WSG/v:[1]VOICE B/[style:knob][0]Zany Freq", 2, 0, 20, 0.001) : si.smoo;
zaniness_b= hslider("h:[0]WSG/v:[1]VOICE B/[style:knob][0]Zaziness", 0, 0.0, 1, 0.01) : si.smoo;
weird_b_freq = hslider("h:[0]WSG/v:[1]VOICE B/[style:knob][0]Weird Freq", 440, 0, 2500, 1) : si.smoo;
wackiness_b = checkbox("h:[0]WSG/v:[0]VOICE B/Wackiness");
wacky_too_b = checkbox("h:[0]WSG/v:[0]VOICE B/Wacky too");
unusual_b = checkbox("h:[0]WSG/v:[0]VOICE B/unusual");

// "Zaniness" FM
zany_ramp_b   = os.triangle(zany_b_freq);    // –1 to +1
zany_square_b = os.square(zany_b_freq);           // ±1
zany_b_osc = select2(unusual_b, zany_square_b, zany_ramp_b);

// Base Square OSC
weird_b_osc = os.square(weird_b_freq + zany_b_osc*weird_b_freq*zaniness_b);

wacky_b = os.square(wacky_b_freq);
wacky_gate_b = (wacky_b > 0);

voice_b = weird_b_osc*select2(wackiness_b, 1, wacky_gate_b) + wacky_b*wacky_too_b;

//─────────ODDNESS  FILTER─────────
cutoff = hslider("h:[1]WSG/[style:knob][0]Cutoff", 200, 0, 2000, 1) : si.smoo;
reso = hslider("h:[1]WSG/[style:knob][0]Res", 1, 0, 10, 0.1) : si.smoo;


gain = 1 + (reso * 0.1); // Adjust constant to taste
filter = fi.resonlp(cutoff, reso, gain);

process = (voice_a*0.5+voice_b*0.5) : filter;//_*wacky_a_freq*zany_a_freq*zaniness_a*weird_a_freq*wackiness_a: _*wacky_b_freq*zany_b_freq*zaniness_b_freq*weird_b_freq*cutoff*reso*unusual_a*wacky_too_a*wackiness_a*unusual_b*wacky_too_b*wackiness_b;
