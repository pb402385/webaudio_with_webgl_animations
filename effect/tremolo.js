// tremolo-autopan-processor.js → Version finale définitive (2025)
class TremoloAutopanProcessor extends AudioWorkletProcessor {
  static get parameterDescriptors() {
    return [
      { name: 'rate',     defaultValue: 4,    minValue: 0.01, maxValue: 40,   automationRate: 'a-rate' },
      { name: 'depth',    defaultValue: 0.5,  minValue: 0,    maxValue: 1,    automationRate: 'a-rate' },
      { name: 'shape',    defaultValue: 0,    minValue: 0,    maxValue: 5,    automationRate: 'k-rate' },   // 0=sin 1=tri 2=sq 3=saw↑ 4=saw↓ 5=S&H
      { name: 'stereo',   defaultValue: 1,    minValue: 0,    maxValue: 1,    automationRate: 'k-rate' },   // 0=tremolo 1=autopan
      { name: 'smooth',   defaultValue: 0.92, minValue: 0,    maxValue: 0.999,automationRate: 'k-rate' }
    ];
  }

  constructor() {
    super();
    this.phase = 0;
    this.lastL = 0.5;
    this.lastR = 0.5;
    this.randomHold = 0.5;
  }

  process(inputs, outputs, parameters) {
    const input = inputs[0];
    const output = outputs[0];

    if (!input || !output || input.length === 0 || output.length === 0 || input[0].length === 0) {
      return true;
    }

    const blockSize = 128;
    const channelCount = output.length;
    const isAutopan = parameters.stereo[0] > 0.5;
    const shape = Math.round(parameters.shape[0]);
    const smooth = parameters.smooth[0];

    let phase = this.phase;

    for (let i = 0; i < blockSize; ++i) {
      // Rate & Depth (a-rate support)
      const rate = parameters.rate.length > 1 ? parameters.rate[i] : parameters.rate[0];
      const depth = parameters.depth.length > 1 ? parameters.depth[i] : parameters.depth[0];

      // Avance de phase
      phase += (2 * Math.PI * rate) / sampleRate;
      if (phase >= 2 * Math.PI) phase -= 2 * Math.PI;

      // LFO brut (0.0 → 1.0)
      let raw = 0.5;
      switch (shape) {
        case 0: raw = 0.5 + 0.5 * Math.sin(phase); break;
        case 1: raw = Math.abs((phase * 0.6366197723675814) % 2 - 1); break;           // triangle
        case 2: raw = phase < Math.PI ? 1 : 0; break;                                 // square
        case 3: raw = phase * 0.15915494309189535; break;                             // saw up
        case 4: raw = 1 - phase * 0.15915494309189535; break;                         // saw down
        case 5: // Sample & Hold
          if (phase < (2 * Math.PI * rate) / sampleRate + 0.0001) {
            this.randomHold = Math.random();
          }
          raw = this.randomHold;
          break;
      }

      // Lissage one-pole (très doux, zéro clic)
      if (isAutopan) {
        this.lastL += smooth * (raw - this.lastL);
        this.lastR += smooth * (raw - this.lastR);
      } else {
        this.lastL += smooth * (raw - this.lastL);
        this.lastR = this.lastL;
      }

      const modL = 1 - depth * this.lastL;
      const modR = 1 - depth * this.lastR;

      // Constant-power pan (sin/cos rapide)
      const panAngle = phase * 0.15915494309189535; // phase / (2π)
      const leftPan  = Math.cos(panAngle * Math.PI * 0.5);
      const rightPan = Math.sin(panAngle * Math.PI * 0.5);

      for (let ch = 0; ch < channelCount; ++ch) {
        const sample = input[Math.min(ch, input.length - 1)][i];

        if (!isAutopan) {
          output[ch][i] = sample * modL;
        } else {
          const gain = ch === 0 ? leftPan : rightPan;
          output[ch][i] = sample * (ch === 0 ? modL : modR) * gain * 1.41421356237; // ×√2
        }
      }
    }

    this.phase = phase;
    return true;
  }
}

registerProcessor('tremolo', TremoloAutopanProcessor);