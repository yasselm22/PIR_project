import("stdfaust.lib");

process = flanger329(1);

flanger329(n) = vgroup("%n.329_FLANGER", ba.bypass2(bypass, par(i, 2, flanger_core))) //par(i, 2, phaser_core))) pour "stereo", phaser_core est appliqué en parallèle à deux canaux (cohérence entrée/sortie)
with {
  
    // UI
    lfoRate = hslider("[1] LFO Rate [unit:Hz] [style:knob]", 0.2, 0.01, 10.0, 0.01) : si.smoo; //si.smoo pour lissage ; freq
    lfoDepth = hslider("[2] LFO Depth [style:knob]", 0.7, 0, 1, 0.01) : si.smoo;
    feedback = hslider("[3] Feedback [style:knob]", 0.3, 0, 0.99, 0.01) : si.smoo;
    mix = hslider("[4] Mix Dry/Wet [style:knob]", 0.5, 0, 1, 0.01) : si.smoo; 
    modRange = hslider("[5] Modulation Range [unit:Hz] [style:knob]", 300, 0, 1000, 1) : si.smoo;
    outLevel = hslider("[6] Output Level [unit:dB] [style:knob]", 0, -60, 10, 0.1) : ba.db2linear : si.smoo;
    bypass = checkbox("[7] Bypass [tooltip: Désactive le module]");


    // LFO Modulation (triangle)
    lfo = os.triangle(lfoRate) * lfoDepth;
    baseFreq = 400;     // base frequency of the allpass filters
    //modRange = 300;     // Hz
    modFreq = baseFreq + (lfo * modRange);// varie de 100 à 700 Hz


    // Convert modulation frequency to delay in samples (période en échantillons)
    modDelay  = ma.SR / modFreq;

    stage(d) = de.delay(2048, d);  // delay max 2048 samples, d = valeur modulée


    flanger_chain = stage(modDelay) : stage(modDelay); // 2 suffisent souvent

    flanger_core = x : (+ ~ *(feedback)) : flanger_chain <: x, _ : mix_drywet : *(outLevel)
    with {
        x = _;
    };
    

    // Mix dry and wet signals
    mix_drywet(wet) = dry_with(wet)
    with {
        dry_with(w) = dry*x + wet*y
        with {
            dry = 1 - mix;
            x = _; // dry input
            y = w; // wet input
        };
    };

    // Sinon, directement (mais moi easy modulable):
    // mix_drywet(wet) = (1 - mix) * _ + mix * wet;

};
