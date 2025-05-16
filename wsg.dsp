import("stdfaust.lib");

//─────────VOICE A─────────
wacky_a_freq = hslider("h:[0]WSG/v:[0]VOICE A/[style:knob][0]Wacky Freq", 440, 1, 4000, 1) : si.smoo;
zany_a_freq = hslider("h:[0]WSG/v:[0]VOICE A/[style:knob][0]Zany Freq", 2, 0.05, 20, 0.01) : si.smoo;
zaniness_a = hslider("h:[0]WSG/v:[0]VOICE A/[style:knob][0]Zaziness", 0, 0.0, 1.0, 0.01) : si.smoo;
weird_a_freq = hslider("h:[0]WSG/v:[0]VOICE A/[style:knob][0]Weird Freq", 440, 20, 2500, 1) : si.smoo;
wackiness_a = checkbox("h:[0]WSG/v:[1]VOICE A/Wackiness");
wacky_too_a = checkbox("h:[0]WSG/v:[1]VOICE A/Wacky too");
unusual_a = checkbox("h:[0]WSG/v:[1]VOICE A/unusual");

// "Zaniness" FM
zany_ramp   = os.phasor(zany_a_freq) * 2 - 1;    // –1 to +1
zany_square = os.square(zany_a_freq);           // ±1
zany_a_osc = select2(zaniness_a,
                   zany_ramp,
                   zany_square);

// Base Square OSC
weird_a_osc = os.square(weird_a_freq + zany_a_osc*weird_a_freq*zaniness_a);

wacky_a = os.square(wacky_a_freq);

voice_a = weird_a_osc;
//voice_a = weird_a*zany_a*zaniness_a;
//─────────VOICE B─────────
wacky_b_freq = hslider("h:[0]WSG/v:[1]VOICE B/[style:knob][0]Wacky Freq", 200, 20, 2000, 1) : si.smoo;
zany_b_freq = hslider("h:[0]WSG/v:[1]VOICE B/[style:knob][0]Zany Freq", 200, 20, 2000, 1) : si.smoo;
zaniness_b_freq = hslider("h:[0]WSG/v:[1]VOICE B/[style:knob][0]Zaziness", 200, 20, 2000, 1) : si.smoo;
weird_b_freq = hslider("h:[0]WSG/v:[1]VOICE B/[style:knob][0]Weird Freq", 200, 20, 2000, 1) : si.smoo;
wackiness_b = checkbox("h:[0]WSG/v:[0]VOICE B/Wackiness");
wacky_too_b = checkbox("h:[0]WSG/v:[0]VOICE B/Wacky too");
unusual_b = checkbox("h:[0]WSG/v:[0]VOICE B/unusual");


//─────────ODDNESS  FILTER─────────
cutoff = hslider("h:[1]WSG/[style:knob][0]Cutoff", 200, 20, 2000, 1) : si.smoo;
reso = hslider("h:[1]WSG/[style:knob][0]Res", 200, 20, 2000, 1) : si.smoo;


process = voice_a;//_*wacky_a_freq*zany_a_freq*zaniness_a*weird_a_freq*wackiness_a: _*wacky_b_freq*zany_b_freq*zaniness_b_freq*weird_b_freq*cutoff*reso*unusual_a*wacky_too_a*wackiness_a*unusual_b*wacky_too_b*wackiness_b;
