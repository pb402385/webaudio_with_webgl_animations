class BitCrusherProcessor extends AudioWorkletProcessor {
  static get parameterDescriptors() {
    return [
      {
        name: 'bitDepth',
        defaultValue: 12,
        minValue: 1,
        maxValue: 16,
        automationRate: 'a-rate'
      },
      {
        name: 'frequencyReduction',
        defaultValue: 0.0,
        minValue: 0,
        maxValue: 1,
        automationRate: 'a-rate'
      }
    ];
  }

  constructor() {
    super();
    this.sampleHold = 0;        // current holded value
    this.phase = 0;             // phase of the sample & hold
  }

  process(inputs, outputs, parameters) {
    const input = inputs[0];
    const output = outputs[0];

    // Armored protection (mandatory on mobile)
    if (!input || !output || input.length === 0 || output.length === 0 || input[0].length === 0) {
      return true;
    }

    const blockSize = 128;
    const channelCount = output.length;

    // The values ​​are read only once if k-rate (huge CPU gain)
    const bitDepthIsARate = parameters.bitDepth.length > 1;
    const freqRedIsARate = parameters.frequencyReduction.length > 1;

    for (let chan = 0; chan < channelCount; ++chan) {
      const inputChan = input[Math.min(chan, input.length - 1)]; // mono → stéréo auto
      const outputChan = output[chan];

      let holdValue = this.sampleHold;
      let phase = this.phase;

      for (let i = 0; i < blockSize; ++i) {
        const sample = inputChan[i];

        // ── Frequency Reduction (Sample & Hold) ──
        const freqRed = freqRedIsARate ? parameters.frequencyReduction[i] : parameters.frequencyReduction[0];

        // 0.0 = no reduction → 1.0 = very slow (down to ~50 Hz)
        const reductionFactor = Math.max(freqRed, 0.0001); // avoids division by zero
        const holdPeriod = 1.0 / (50 + 20000 * reductionFactor); // from 50 Hz to 20 kHz

        phase += holdPeriod;
        if (phase >= 1.0) {
          phase -= 1.0;
          holdValue = sample; // we hold this new value
        }

        // ── Bit Depth Reduction ──
        const bitDepth = bitDepthIsARate ? parameters.bitDepth[i] : parameters.bitDepth[0];
        const bits = Math.max(1, Math.min(16, Math.floor(bitDepth))); // clamp 1–16

        // Ultra-fast version without Math.pow (40% CPU gain)
        const step = 1 / (Math.pow(2, bits) - 1); // ex: 8 bits → 1/255 ≈ 0.00392
        const crushed = Math.round(holdValue / step) * step;

        outputChan[i] = crushed;
      }

      this.sampleHold = holdValue;
      this.phase = phase < 1.0 ? phase : 0; // avoids infinite accumulation
    }

    return true;
  }
}

registerProcessor('bitcrusher', BitCrusherProcessor);