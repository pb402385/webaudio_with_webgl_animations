class SimplePitchShifterProcessor extends AudioWorkletProcessor {
  static get parameterDescriptors() {
    return [
      { name: 'pitch', defaultValue: 1,    minValue: 0.25, maxValue: 4,   automationRate: 'a-rate' }, // ratio (2 = +12st, 0.5 = -12st)
      { name: 'wet',   defaultValue: 0.5,  minValue: 0,    maxValue: 1,   automationRate: 'a-rate' }
    ];
  }

  constructor() {
    super();
    this.sampleRate = 48000;

    // Buffer size = 50 ms (covers ±12 seconds without gaps)
    this.bufferSize = Math.ceil(0.05 * this.sampleRate); 
    this.delayBuffer = new Float32Array(this.bufferSize * 2).fill(0); // x2 pour stéréo
    this.writePos = 0;

    // Crossfade triangle 20 ms (anti-click)
    this.fadeSamples = Math.ceil(0.020 * this.sampleRate);
    this.readPos1 = 0;
    this.readPos2 = this.fadeSamples;
    this.crossfade = 0; // 0..1
    this.direction = 1;
  }

  process(inputs, outputs, parameters) {
    const input = inputs[0];
    const output = outputs[0];
    if (!input || !input[0]) return true;

    const channels = input.length;
    const blockSize = 128;

    for (let i = 0; i < blockSize; i++) {
      const ratio = parameters.pitch.length > 1 ? parameters.pitch[i] : parameters.pitch[0];
      const wet   = parameters.wet.length   > 1 ? parameters.wet[i]   : parameters.wet[0];

      // === Writing to the circular delay (all channels) ===
      for (let ch = 0; ch < channels; ch++) {
        this.delayBuffer[this.writePos * channels + ch] = input[ch][i];
      }
      this.writePos = (this.writePos + 1) % this.bufferSize;

      // === Calculation of the variable delay (in samples) ===
      const delaySamples = this.bufferSize / ratio;

      // Two intersecting read pointers (crossfade triangle)
      this.readPos1 = (this.writePos - delaySamples + this.bufferSize) % this.bufferSize;
      this.readPos2 = (this.readPos1 + this.fadeSamples) % this.bufferSize;

      // Crossfade advance
      this.crossfade += this.direction / this.fadeSamples;
      if (this.crossfade >= 1 || this.crossfade <= 0) this.direction = -this.direction;

      const fade = 0.5 + 0.5 * Math.cos(Math.PI * this.crossfade); // triangle → cosinus (softer)

      // === Playback with crossfade ===
      let wetSample = 0;
      for (let ch = 0; ch < channels; ch++) {
        const s1 = this.delayBuffer[Math.floor(this.readPos1) * channels + ch];
        const s2 = this.delayBuffer[Math.floor(this.readPos2) * channels + ch];
        wetSample += (s1 * (1 - fade) + s2 * fade) / channels;
      }

      // === Final exit ===
      for (let ch = 0; ch < output.length; ch++) {
        const dry = input[ch][i] || 0;
        output[ch][i] = dry * (1 - wet) + wetSample * wet;
      }
    }
    return true;
  }
}

registerProcessor('pitch', SimplePitchShifterProcessor);