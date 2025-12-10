// Version Pink + Lowpass intégré (très demandé)
class PinkNoiseWithFilterProcessor extends AudioWorkletProcessor {
  static get parameterDescriptors() {
    return [{
      name: 'cutoff',
      defaultValue: 800,
      minValue: 20,
      maxValue: 8000,
      automationRate: 'a-rate'
    }];
  }

  constructor() {
    super();
    this.b0=this.b1=this.b2=this.b3=this.b4=this.b5=this.b6=0;
    this.z = 0; // filtre lowpass
  }

  process(inputs, outputs, parameters) {
    const output = outputs[0];
    const cutoff = parameters.cutoff;

    for (let ch = 0; ch < output.length; ch++) {
      const out = output[ch];
      let z = this.z;

      for (let i = 0; i < out.length; i++) {
        const white = Math.random() * 2 - 1;

        this.b0 = 0.99886 * this.b0 + white * 0.0555179;
        this.b1 = 0.99332 * this.b1 + white * 0.0750759;
        this.b2 = 0.96900 * this.b2 + white * 0.1538520;
        this.b3 = 0.86650 * this.b3 + white * 0.3104856;
        this.b4 = 0.55000 * this.b4 + white * 0.5329522;
        this.b5 = -0.7616 * this.b5 - white * 0.0168980;
        this.b6 = white * 0.115926;

        let pink = (this.b0 + this.b1 + this.b2 + this.b3 + this.b4 + this.b5 + this.b6 + white * 0.5362) * 0.11;

        // One-pole lowpass doux
        const c = Math.max(0.001, cutoff[i] || cutoff[0]) / sampleRate * 4;
        z += c * (pink - z);

        out[i] = z;
      }
      this.z = z;
    }
    return true;
  }
}

registerProcessor('pink-noise-filtered', PinkNoiseWithFilterProcessor);