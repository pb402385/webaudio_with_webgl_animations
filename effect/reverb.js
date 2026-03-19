class AlgorithmicReverbProcessor extends AudioWorkletProcessor {
  static get parameterDescriptors() {
    return [
      { name: 'roomSize',  defaultValue: 0.7,  minValue: 0,    maxValue: 1,     automationRate: 'a-rate' },
      { name: 'damping',   defaultValue: 0.5,  minValue: 0,    maxValue: 1,     automationRate: 'a-rate' },
      { name: 'wet',       defaultValue: 0.3,  minValue: 0,    maxValue: 1,     automationRate: 'a-rate' },
      { name: 'dry',       defaultValue: 0.7,  minValue: 0,    maxValue: 1,     automationRate: 'a-rate' },
      { name: 'width',     defaultValue: 0.9,  minValue: 0,    maxValue: 1,     automationRate: 'a-rate' },
      { name: 'freeze',    defaultValue: 0,    minValue: 0,    maxValue: 1,     automationRate: 'k-rate' }
    ];
  }

  constructor() {
    super();
    this.sampleRate = 44100;

    // === Delay sizes in samples (prime numbers = good diffusion) ===
    const sr = this.sampleRate;
    this.delayLengths = {
      preDelay:    Math.floor(0.030 * sr), // 30 ms
      tankIn1:     Math.floor(0.089 * sr),
      tankIn2:     Math.floor(0.071 * sr),
      diff1:       3371,
      diff2:       7123,
      diff3:       9113,
      diff4:       13567,
      damp1:       2311,
      damp2:       4567,
      damp3:       3191,
      damp4:       5413,
      outL:        9871,
      outR:        11299
    };

    // Circular buffers
    this.buffers = {};
    Object.keys(this.delayLengths).forEach(key => {
      this.buffers[key] = new Float32Array(this.delayLengths[key]).fill(0);
    });
    this.writePos = {};
    Object.keys(this.delayLengths).forEach(key => this.writePos[key] = 0);

    // Low-pass filter states (damping) and allpass
    this.dampState = {
      damp1L: 0, damp1R: 0,
      damp2L: 0, damp2R: 0,
      damp3L: 0, damp3R: 0,
      damp4L: 0, damp4R: 0
    };
  }

  // One-pole lowpass for damping
  onePoleLP(input, prev, coeff) {
    return prev + coeff * (input - prev);
  }

  // Allpass simple (Schroeder style)
  allpass(buf, wp, len, input, feedback) {
    const readPos = (wp + len - 200) % len; // 200 samples delay arbitrary
    const delayed = buf[readPos];
    const out = delayed + input * (-feedback);
    buf[wp] = input + delayed * feedback;
    return out;
  }

  process(inputs, outputs, parameters) {
    const input = inputs[0];
    const output = outputs[0];
    const channels = input.length; // 1 ou 2

    if (!input.length || !input[0].length) return true;

    const blockSize = 128;
    const room = parameters.roomSize;
    const damp = parameters.damping;
    const wet = parameters.wet;
    const dry = parameters.dry;
    const width = parameters.width;
    const freeze = parameters.freeze[0] > 0.5;

    for (let i = 0; i < blockSize; i++) {
      // Settings a-rate or k-rate
      const curRoom = room.length > 1 ? room[i] : room[0];
      const curDamp = damp.length > 1 ? damp[i] : damp[0];
      const curWet  = wet.length > 1 ? wet[i] : wet[0];
      const curDry  = dry.length > 1 ? dry[i] : dry[0];

      // Sum of input channels (pre-delay)
      let inL = input[0][i];
      let inR = channels > 1 ? input[1][i] : inL;
      let monoIn = (inL + inR) * 0.5;

      // Pre-delay
      const pdPos = this.writePos.preDelay;
      this.buffers.preDelay[pdPos] = monoIn;
      const preDelayed = this.buffers.preDelay[(pdPos + this.delayLengths.preDelay - Math.floor(0.03 * this.sampleRate)) % this.delayLengths.preDelay];
      this.writePos.preDelay = (pdPos + 1) % this.delayLengths.preDelay;

      // Injection into both tanks
      let tankL = preDelayed;
      let tankR = preDelayed;

      // === TANK LEFT ===
      tankL = this.allpass(this.buffers.tankIn1, this.writePos.tankIn1, this.delayLengths.tankIn1, tankL, 0.6);
      this.writePos.tankIn1 = (this.writePos.tankIn1 + 1) % this.delayLengths.tankIn1;

      // Diffusion + damping
      for (let j = 1; j <= 4; j++) {
        const wp = this.writePos[`diff${j}`];
        tankL = this.allpass(this.buffers[`diff${j}`], wp, this.delayLengths[`diff${j}`], tankL, 0.7);
        this.writePos[`diff${j}`] = (wp + 1) % this.delayLengths[`diff${j}`];

        const dampWp = this.writePos[`damp${j}`];
        const damped = this.onePoleLP(tankL, this.dampState[`damp${j}L`], freeze ? 0 : curDamp);
        this.dampState[`damp${j}L`] = damped;
        tankL = damped;
        this.buffers[`damp${j}`][dampWp] = tankL;
        this.writePos[`damp${j}`] = (dampWp + 1) % this.delayLengths[`damp${j}`];
      }

      // === TANK RIGHT === (same structure, different lengths)
      tankR = this.allpass(this.buffers.tankIn2, this.writePos.tankIn2, this.delayLengths.tankIn2, tankR, 0.6);
      this.writePos.tankIn2 = (this.writePos.tankIn2 + 1) % this.delayLengths.tankIn2;

      for (let j = 1; j <= 4; j++) {
        const wp = this.writePos[`diff${j}`];
        tankR = this.allpass(this.buffers[`diff${j}`], wp, this.delayLengths[`diff${j}`], tankR, 0.7);
        this.writePos[`diff${j}`] = (wp + 1) % this.delayLengths[`diff${j}`];

        const damped = this.onePoleLP(tankR, this.dampState[`damp${j}R`], freeze ? 0 : curDamp);
        this.dampState[`damp${j}R`] = damped;
        tankR = damped;
      }

      // === Final outputs (multiple taps for density) ===
      let wetL = 0;
      let wetR = 0;

      const tapsL = [111, 523, 2131, 4489];
      const tapsR = [67,  839, 3021, 5111];

      tapsL.forEach(offset => {
        const pos = (this.writePos.outL + this.delayLengths.outL - offset) % this.delayLengths.outL;
        wetL += this.buffers.outL[pos];
      });
      tapsR.forEach(offset => {
        const pos = (this.writePos.outR + this.delayLengths.outR - offset) % this.delayLengths.outR;
        wetR += this.buffers.outR[pos];
      });

      // Normalisation
      wetL *= 0.03;
      wetR *= 0.03;

      // Width (stéréo spread)
      const mid = (wetL + wetR) * 0.5;
      const side = (wetL - wetR) * 0.5;
      wetL = mid + side * width;
      wetR = mid - side * width;

      // Mix final
      output[0][i] = inL * curDry + wetL * curWet;
      if (channels > 1) {
        output[1][i] = inR * curDry + wetR * curWet;
      } else {
        output[0][i] = output[0][i]; // mono
      }

      // Recirculation in large output buffers
      this.buffers.outL[this.writePos.outL] = tankL * (freeze ? 1.0 : curRoom);
      this.buffers.outR[this.writePos.outR] = tankR * (freeze ? 1.0 : curRoom);
      this.writePos.outL = (this.writePos.outL + 1) % this.delayLengths.outL;
      this.writePos.outR = (this.writePos.outR + 1) % this.delayLengths.outR;
    }

    return true;
  }
}

registerProcessor('reverb', AlgorithmicReverbProcessor);