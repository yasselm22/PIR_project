import("stdfaust.lib");

//-------------------------------bass drum sans widget modulation----------------------------------
process = hgroup("bass drum", bassdrum) <: _,_
with {
    gate = button("gate");                                    
    level = hslider("level[style:knob]", 0.5, 0, 1, 0.01);    
    tone = hslider("tone[style:knob]", 0.5, 0, 1, 0.01);       
    decay = hslider("decay[style:knob]", 0.5, 0, 1, 0.01);
    
    gateEnv = gate : en.ar(0.001, 0.001); 

    resonator = os.osc(freq) * ampEnv
    with {
        pitchEnv = gateEnv : en.ar(0.001, 0.05);
        freq = 55 * (1 + 2 * pitchEnv);
        actualDecay = 0.1 + decay * 1.9;
        ampEnv = gateEnv : en.ar(0.001, actualDecay);
    };
    
    lowPass = resonator : fi.lowpass(3, 150);
    highPass = resonator : fi.highpass(3, 500) * 1.5;
    filteredSound = lowPass * (1.0 - tone) + highPass * tone;

    saturation(x) = select2(abs(x) > 1.0, 
                           x, 
                           ma.signum(x) * (1.0 - (1.0/(abs(x) + 0.33))));


    bd808 = filteredSound * level * 4 : ma.tanh * 0.7;
};