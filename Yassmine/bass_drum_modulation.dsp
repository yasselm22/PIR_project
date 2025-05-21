import("stdfaust.lib");
bd808 = bassdrum, bassdrum
with {
    gate = button("[1]gate");
    
    levelKnob = hgroup("Main Parameters", hslider("[1]level[style:knob]", 0.5, 0, 1, 0.01));    
    toneKnob = hgroup("Main Parameters", hslider("[2]tone[style:knob]", 0.5, 0, 1, 0.01));       
    decayKnob = hgroup("Main Parameters", hslider("[3]decay[style:knob]", 1, 0, 2, 0.01));
    
    levelMod = hgroup("Modulation", hslider("[1]level mod[style:knob]", 0, 0, 1, 0.01));
    toneMod = hgroup("Modulation", hslider("[2]tone mod[style:knob]", 0, 0, 1, 0.01));
    decayMod = hgroup("Modulation", hslider("[3]decay mod[style:knob]", 0, 0, 1, 0.01));
    
    levelLfo = (os.osc(0.2)+1)/2;
    toneLfo = (os.osc(0.2)+1)/2;
    decayLfo = (os.osc(0.2)+3)/2;

    level = levelKnob + (levelLfo * levelMod) : min(1);
    tone = toneKnob + (toneLfo * toneMod) : min(1);
    decay = decayKnob + (decayLfo * decayMod) : min(2);
    
    gateEnv = gate : en.ar(0.001, 0.001); 
    resonator = os.osc(freq) * ampEnv
    with {
        pitchEnv = gateEnv : en.ar(0.001, 0.05);
        freq = 70 * (1 + 2 * pitchEnv);
        ampEnv = gateEnv : en.ar(0.001, decay);
    };
    
    lowPass = resonator : fi.lowpass(3, 150);
    highPass = resonator : fi.highpass(3, 500) * 1.5;
    filteredSound = lowPass * (1.0 - tone) + highPass * tone;
    bassdrum = filteredSound * level;
};

bpm(n) = hgroup("BPM", (1-pause) * beat
    with {
        pause = hslider("[2]pause[style:knob]",0,0,1,1);
        freq = hslider("[1]bpm[style:knob][unit:bpm][scale:log]", 60, 6, 1200, 1)/60;
        length= hslider("width[style:knob][unit:%]",10,0,99,1)/100;
        phasor(f) = f/ma.SR : (+,1:fmod)~_;
        start = * <: mem,* : >;
        beat = phasor(freq) <: start | <(length);
    });

gateCheck = bpm(1)*checkbox("[1]gate");

process = hgroup("Bass Drum", ["gate":gateCheck -> bd808]);