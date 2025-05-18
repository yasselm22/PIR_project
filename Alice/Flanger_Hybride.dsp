import("stdfaust.lib");

process = flanger329(1);

flanger329(n) = hgroup("%n.329_PHASE_FLANGE", ba.bypass2(bypass, par(i, 2, flanger_core)))
with {
  
    // UI
    outLevel = hslider("[6] Output Level [unit:dB] [style:knob]", 0, -60, 10, 0.1) : ba.db2linear : si.smoo;
    bypass   = checkbox("[7] Bypass [tooltip: Désactive le module]");

    // Manual controls
    lfoRate_m   = hslider("[1] LFO Rate [unit:Hz] [style:knob]", 0.2, 0.01, 10.0, 0.01);
    lfoDepth_m  = hslider("[2] LFO Depth [style:knob]", 0.7, 0, 1, 0.01);
    feedback_m  = hslider("[3] Feedback [style:knob]", 0.3, 0, 0.99, 0.01);
    mix_m       = hslider("[4] Mix Dry/Wet [style:knob]", 0.5, 0, 1, 0.01);
    modRange_m  = hslider("[5] Modulation Range [unit:Hz] [style:knob]", 300, 0, 1000, 1);

    // Auto-mode switches
    autoRate    = checkbox("[A1] Auto LFO Rate");
    autoDepth   = checkbox("[A2] Auto LFO Depth");
    autoFB      = checkbox("[A3] Auto Feedback");
    autoMix     = checkbox("[A4] Auto Mix");
    autoModR    = checkbox("[A5] Auto ModRange");

    // Auto LFOs
    lfoRate_a   = (os.osc(0.03)+1)/2 * (10.0 - 0.01) + 0.01;
    lfoDepth_a  = (os.osc(0.02)+1)/2 * 1.0;
    feedback_a  = (os.osc(0.015)+1)/2 * 0.99;
    mix_a       = (os.osc(0.01)+1)/2 * 1.0;
    modRange_a  = (os.osc(0.025)+1)/2 * 1000;

    // Selection (manual vs auto)
    lfoRate     = si.smoo((1 - autoRate) * lfoRate_m + autoRate * lfoRate_a);
    lfoDepth    = si.smoo((1 - autoDepth) * lfoDepth_m + autoDepth * lfoDepth_a);
    feedback    = si.smoo((1 - autoFB) * feedback_m + autoFB * feedback_a);
    mix         = si.smoo((1 - autoMix) * mix_m + autoMix * mix_a);
    modRange    = si.smoo((1 - autoModR) * modRange_m + autoModR * modRange_a);

    // LFO Modulation (triangle)
    lfo = os.triangle(lfoRate) * lfoDepth;
    baseFreq = 400;
    modFreq = baseFreq + (lfo * modRange);

    // Convert to delay in samples
    modDelay = ma.SR / modFreq;

    // Flanger: 2 delay stages
    stage(d) = de.delay(2048, d);
    flanger_chain = stage(modDelay) : stage(modDelay);

    // Core
    flanger_core = x : (+ ~ *(feedback)) : flanger_chain <: x, _ : mix_drywet : *(outLevel)
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
