import("stdfaust.lib");

bd808 = bassdrum, bassdrum
with {
    gate = button("[1]gate");                                    
    level = hslider("level[style:knob]", 0.5, 0, 1, 0.01);    
    tone = hslider("tone[style:knob]", 0.5, 0, 1, 0.01);       
    decay = hslider("decay[style:knob]", 1, 0, 2, 0.01);
    
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

    bassdrum = filteredSound * level ;
};

bpm(n) = hgroup("%n.BPM", (1-pause) * beat
    with {
		pause = vslider("[2]pause[style:knob]",0,0,1,1);
		freq = vslider("[1]bpm[style:knob][unit:bpm][scale:log]", 60, 6, 1200, 1)/60;
		length= vslider("width[style:knob][unit:%]",10,0,99,1)/100;
        phasor(f) = f/ma.SR : (+,1:fmod)~_;
        start = _ <: mem,_ : >;
        beat = phasor(freq) <: start | <(length);
    });

levelLfo = (os.osc(0.2)+1)/2;
toneLfo = (os.osc(0.2)+1)/2;
decayLfo = (os.osc(0.2)+1)/2;

gateCheck = bpm(1)*checkbox("gate");

process = hgroup("Bass drum", bd808);
