import("stdfaust.lib");

ma = library("maths.lib");
fi = library("filters.lib");
si = library("signals.lib");
os = library("oscillators.lib");



//=======================================
// Phaser/Flanger 329 inspired (10 stages)
//=======================================

process = phaser329(1);

phaser329(n) = hgroup("%n.329_PHASER10", ba.bypass2(bypass, par(i, 2, phaser_core)))
with {
    // UI
    outLevel = hslider("[6] Output Level [unit:dB] [style:knob]", 0, -60, 10, 0.1) : ba.db2linear : si.smoo;
    bypass = checkbox("[7] Bypass [tooltip: Désactive le module]");

    // Contrôle automatique via oscillateurs
    lfoRate = (os.osc(0.03) + 1)/2 * (10.0 - 0.01) + 0.01 : si.smoo;      // 0.01 – 10 Hz
    lfoDepth = (os.osc(0.02) + 1)/2 * (1.0 - 0.0) + 0.0 : si.smoo;        // 0 – 1
    feedback = (os.osc(0.015) + 1)/2 * (0.99 - 0.0) + 0.0 : si.smoo;      // 0 – 0.99
    mix = (os.osc(0.01) + 1)/2 * (1.0 - 0.0) + 0.0 : si.smoo;             // 0 – 1
    modRange = (os.osc(0.025) + 1)/2 * (1000 - 0) + 0 : si.smoo;          // 0 – 1000 Hz

    // LFO pour allpass
    lfo = os.triangle(lfoRate) * lfoDepth;
    baseFreq = 400;
    modFreq = baseFreq + (lfo * modRange);
    modDelay  = ma.SR / modFreq;

    // Allpass modulaire
    stage(d) = fi.allpass_fcomb(2048, d, -0.7);
    allpass_chain = stage(modDelay) : stage(modDelay) : stage(modDelay)
                  : stage(modDelay) : stage(modDelay) : stage(modDelay)
                  : stage(modDelay) : stage(modDelay) : stage(modDelay)
                  : stage(modDelay);

    // Phaser core
    phaser_core = x : (+ ~ *(feedback)) : allpass_chain <: x, _ : mix_drywet : *(outLevel)
    with { x = _; };

    // Mix dry/wet
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
