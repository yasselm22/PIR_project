import("stdfaust.lib");

ma = library("maths.lib");
ba = library("basics.lib");
fi = library("filters.lib");
si = library("signals.lib");
os = library("oscillators.lib");



//=======================================
// Phaser/Flanger 329 inspired (10 stages)
//=======================================

// Différence avec phaser classique : 10 filtres allpass filters en série modulés par un LFO + boucle de rétroaction (+ ~ *(feedback)) comme les flangers + mix dry wet
// Pour faire en flanger : mettre delays simples à la place des allpass ?

process = phaser329(1);

phaser329(n) = hgroup("%n.329_PHASER10", ba.bypass2(bypass, par(i, 2, phaser_core))) //par(i, 2, phaser_core))) pour "stereo", phaser_core est appliqué en parallèle à deux canaux (cohérence entrée/sortie)
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

    // Allpass stage using allpass_fcomb (one delay line)
    stage(d) = fi.allpass_fcomb(2048, d, -0.7);
    // allpass_fcomb(taille_max_buffer, delay (modDelay), coef_retroaction)
    // allpass_fcomb(maxdel,del,aN)

    // Chain of 10 allpass stages, each modulated by the same LFOO
    allpass_chain = stage(modDelay) : stage(modDelay) : stage(modDelay) : stage(modDelay) : stage(modDelay) : stage(modDelay) : stage(modDelay) : stage(modDelay) : stage(modDelay) : stage(modDelay);

    // Core phaser effect with feedback
    // Applies a phaser effect with a feedback loop (+~), passes the signal through 10 modulated allpass filters, splits the dry and wet paths (<:) for mixing, and controls output level
    phaser_core = x : (+ ~ *(feedback)) : allpass_chain <: x, _ : mix_drywet : *(outLevel)
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
