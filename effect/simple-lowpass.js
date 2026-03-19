class SimpleLowpassProcessor extends AudioWorkletProcessor {
  static get parameterDescriptors() {
    return [
      {
        name: "cutoff",
        defaultValue: 800,      // Hz
        minValue: 20,
        maxValue: 20000,        // We're going a little higher (Nyquist safe)
        automationRate: "a-rate" // essential for soft sweeps
      }
    ];
  }

  constructor() {
    super();
    // One z-register per channel (stereo, 5.1, etc.)
    this._z = [0, 0, 0, 0, 0, 0, 0, 0]; // 8 channels max (more than enough)
  }

  process(inputs, outputs, parameters) {
    const input = inputs[0] || [];
    const output = outputs[0];
    const channelCount = output.length;
    const blockSize = output[0].length;
    const cutoff = parameters.cutoff;

    const isA_Rate = cutoff.length === blockSize;

    for (let ch = 0; ch < channelCount; ch++) {
      const inp = input.length > ch && input[ch] ? input[ch] : null;
      const out = output[ch];
      let z = this._z[ch];

      if (isA_Rate) {
        // A-rate version (perfect sweeps)
        for (let i = 0; i < blockSize; i++) {
          const c = Math.max(0.0001, 2 * Math.PI * cutoff[i] / sampleRate);
          const sample = inp ? inp[i] : 0;
          z += c * (sample - z);
          out[i] = z;
        }
      } else {
        // K-rate version (single coefficient for the block → faster)
        const c = Math.max(0.0001, 2 * Math.PI * cutoff[0] / sampleRate);
        for (let i = 0; i < blockSize; i++) {
          const sample = inp ? inp[i] : 0;
          z += c * (sample - z);
          out[i] = z;
        }
      }
      this._z[ch] = z; // save state for the next block
    }

    return true; // keep the node alive
  }
}

registerProcessor("simple-lowpass", SimpleLowpassProcessor);