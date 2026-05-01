class CompressorProcessor extends AudioWorkletProcessor {
  static get parameterDescriptors() {
    return [
      { name: 'threshold', defaultValue: -24,  minValue: -60, maxValue: 0,    automationRate: 'a-rate' }, // dB
      { name: 'ratio',     defaultValue: 4,    minValue: 1,   maxValue: 20,   automationRate: 'a-rate' },
      { name: 'attack',    defaultValue: 5,    minValue: 0.1, maxValue: 200,  automationRate: 'a-rate' }, // ms
      { name: 'release',   defaultValue: 100,  minValue: 10,  maxValue: 1000, automationRate: 'a-rate' }, // ms
      { name: 'knee',      defaultValue: 6,    minValue: 0,   maxValue: 30,   automationRate: 'a-rate' }, // dB (soft knee)
      { name: 'makeup',    defaultValue: 0,    minValue: -20, maxValue: 30,   automationRate: 'a-rate' }, // dB
      { name: 'mix',       defaultValue: 100,  minValue: 0,   maxValue: 100,  automationRate: 'a-rate' }  // % wet
    ];
  }

  constructor() {
    super();
    this.level = 0;           // smoothed level (ballistics)
    this.gainReduction = 1;  // current reduction gain
  }

  // Ultra-fast dB to linear conversion (pre-calculated if needed)
  dbToLin(db) { return Math.exp(db * 0.115129254); } // ≈ db/8.685889638
  linToDb(lin) { return Math.log(lin) * 8.685889638; }

  process(inputs, outputs, parameters) {
    const input = inputs[0];
    const output = outputs[0];
    if (!input.length) return true;

    const threshold = parameters.threshold;
    const ratio = parameters.ratio;
    const attack = parameters.attack;
    const release = parameters.release;
    const knee = parameters.knee;
    const makeup = parameters.makeup;
    const mix = parameters.mix;

    for (let ch = 0; ch < output.length; ++ch) {
      const inp = input[ch];
      const out = output[ch];

      // Attack/release coefficients (calculated per sample for perfect a-rate)
      for (let i = 0; i < out.length; ++i) {
        const thresh = threshold.length > 1 ? threshold[i] : threshold[0];
        const rat    = Math.max(1, ratio.length > 1 ? ratio[i] : ratio[0]);
        const att    = attack.length  > 1 ? attack[i]  : attack[0];
        const rel    = release.length > 1 ? release[i] : release[0];
        const kn     = knee.length    > 1 ? knee[i]    : knee[0];
        const make   = makeup.length  > 1 ? makeup[i]  : makeup[0];
        const mx     = Math.min(100, Math.max(0, mix.length > 1 ? mix[i] : mix[0])) / 100;

        const absSample = Math.abs(inp[i]);
        let peakDb = absSample > 0 ? this.linToDb(absSample) : -100;

        // === Soft knee ===
        let gainDb = 0;
        if (kn > 0 && peakDb > thresh - kn/2) {
          const x = (peakDb - (thresh - kn/2)) / kn; // 0 → 1
          gainDb = (1 - 1/rat) * kn/2 * (x * x);     // gentle parabolic curve
        } else if (peakDb > thresh) {
          gainDb = (peakDb - thresh) * (1 - 1/rat);
        }

        const targetGain = this.dbToLin(-gainDb);

        // === Ballistics attack/release (one-pole) ===
        const alphaA = att  === 0 ? 1 : Math.exp(-1 / (sampleRate * att  * 0.001));
        const alphaR = rel  === 0 ? 1 : Math.exp(-1 / (sampleRate * rel  * 0.001));
        const alpha = targetGain < this.gainReduction ? alphaA : alphaR;

        this.gainReduction = this.gainReduction + alpha * (targetGain - this.gainReduction);

        // === Appliance ===
        const dry = inp[i];
        const wet = dry * this.gainReduction * this.dbToLin(make);
        out[i] = dry * (1 - mx) + wet * mx;
      }
    }
    return false;
  }
}

registerProcessor('compressor', CompressorProcessor);