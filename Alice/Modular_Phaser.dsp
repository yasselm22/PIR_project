import("stdfaust.lib");


//=======================================
// Phaser/Flanger 329 inspired (10 stages)
//=======================================

// Différence avec phaser classique : 10 filtres allpass filters en série modulés par un LFO + boucle de rétroaction (+ ~ *(feedback)) comme les flangers + mix dry wet

process = ["Auto LFO Rate":*((os.osc(0.5)+1)/2), "Auto LFO Depth":*((os.osc(0.5)+1)/2),  "Auto Feedback":*((os.osc(0.5)+1)/2), "Auto Mix":*((os.osc(0.5)+1)/2), "Auto ModRange":*((os.osc(0.5)+1)/2) -> phaser329(1)];
// process = phaser329(1);

phaser329(n) = hgroup("%n.329_PHASER10", ba.bypass2(bypass, par(i, 2, phaser_core)))
with {
    // Manual controls
    lfoRate_m   = hslider("[1] LFO Rate [unit:Hz] [style:knob]", 0.2, 0.01, 10.0, 0.01);
    lfoDepth_m  = hslider("[2] LFO Depth [style:knob]", 0.7, 0, 1, 0.01);
    feedback_m  = hslider("[3] Feedback [style:knob]", 0.3, 0, 0.99, 0.01);
    mix_m       = hslider("[4] Mix Dry/Wet [style:knob]", 0.5, 0, 1, 0.01);
    modRange_m  = hslider("[5] Modulation Range [unit:Hz] [style:knob]", 300, 0, 1000, 1);
    outLevel = hslider("[6] Output Level [unit:dB] [style:knob]", 0, -60, 10, 0.1) : ba.db2linear : si.smoo;
    bypass   = checkbox("[7] Bypass [tooltip: Désactive le module]");

    // Auto-mode switches
    autoRate    = checkbox("[A1] Auto LFO Rate");
    autoDepth   = checkbox("[A2] Auto LFO Depth");
    autoFB      = checkbox("[A3] Auto Feedback");
    autoMix     = checkbox("[A4] Auto Mix");
    autoModR    = checkbox("[A5] Auto ModRange");

    // Contrôle automatique via oscillateurs
    lfoRate_a = (os.osc(0.03) + 1)/2 * (10.0 - 0.01) + 0.01 : si.smoo;      // 0.01 – 10 Hz
    lfoDepth_a = (os.osc(0.02) + 1)/2 * (1.0 - 0.0) + 0.0 : si.smoo;        // 0 – 1
    feedback_a = (os.osc(0.015) + 1)/2 * (0.99 - 0.0) + 0.0 : si.smoo;      // 0 – 0.99
    mix_a = (os.osc(0.01) + 1)/2 * (1.0 - 0.0) + 0.0 : si.smoo;             // 0 – 1
    modRange_a = (os.osc(0.025) + 1)/2 * (1000 - 0) + 0 : si.smoo;          // 0 – 1000 Hz

    // Selection (manual ou auto)
    lfoRate     = si.smoo((1 - autoRate) * lfoRate_m + autoRate * lfoRate_a);
    lfoDepth    = si.smoo((1 - autoDepth) * lfoDepth_m + autoDepth * lfoDepth_a);
    feedback    = si.smoo((1 - autoFB) * feedback_m + autoFB * feedback_a);
    mix         = si.smoo((1 - autoMix) * mix_m + autoMix * mix_a);
    modRange    = si.smoo((1 - autoModR) * modRange_m + autoModR * modRange_a);

    // LFO pour allpass
    lfo = os.triangle(lfoRate) * lfoDepth;
    baseFreq = 400;
    modFreq = baseFreq + (lfo * modRange);
    modDelay  = ma.SR / modFreq;


    // Allpass stage using allpass_fcomb (one delay line)
    stage(d) = fi.allpass_fcomb(2048, d, -0.7);
    // allpass_fcomb(taille_max_buffer, delay (modDelay), coef_retroaction)
    // allpass_fcomb(maxdel,del,aN)

    // Chain of 10 allpass stages, each modulated by the same LFOO
    allpass_chain = stage(modDelay) : stage(modDelay) : stage(modDelay) : stage(modDelay) : stage(modDelay) : stage(modDelay) : stage(modDelay) : stage(modDelay) : stage(modDelay) : stage(modDelay);

    phaser_core = x : (+ ~ *(feedback)) : allpass_chain <: x, _ : mix_drywet : *(outLevel)
    with {
        x = _;
    };

    // Dry/wet mix
    mix_drywet(wet) = dry_with(wet)
    with {
        dry_with(w) = dry * x + wet * y
        with {
            dry = 1 - mix;
            x = _;
            y = w;
        };
    };
};
