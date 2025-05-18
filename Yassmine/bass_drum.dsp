import("stdfaust.lib");

//-------------------------------bass drum sans widget modulation----------------------------------
process = hgroup("BD808", bd808) <: _,_
with {
    gate = button("gate");                                    
    accent = button("accent");                                
    level = hslider("level[style:knob]", 0.5, 0, 1, 0.01);    
    tone = hslider("tone[style:knob]", 0.5, 0, 1, 0.01);       
    decay = hslider("decay[style:knob]", 0.5, 0, 1, 0.01);
    accentAmount = hslider("accent_amount[style:knob]", 0.5, 0, 1, 0.01);
    
    gateEnv = gate : en.ar(0.001, 0.001);
    accentEnv = accent : en.ar(0.001, 0.001);

    accentGain = 1 + (accentAmount * 3 * accentEnv);

    resonator = os.osc(freq) * ampEnv
    with {
        pitchEnv = gateEnv : en.ar(0.001, 0.05);
        freq = 55 * (1 + 2 * pitchEnv);
        actualDecay = 0.1 + decay * 1.9;
        ampEnv = gateEnv * accentGain : en.ar(0.001, actualDecay);
    };
    
    filteredSound = resonator : fi.lowpass(1, 200 + tone * 4000) : fi.highpass(1, 20);

    bd808 = filteredSound * level * 4 : ma.tanh * 0.7;
};