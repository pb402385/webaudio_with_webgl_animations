// audio-worklet-simple-lowpass.js — Version définitive 2025
// One-pole lowpass ultra-stable, musical et CPU-friendly
class SimpleLowpassProcessor extends AudioWorkletProcessor {
  static get parameterDescriptors() {
    return [
      {
        name: "cutoff",
        defaultValue: 800,      // Hz
        minValue: 20,
        maxValue: 20000,        // on monte un peu plus haut (Nyquist safe)
        automationRate: "a-rate" // indispensable pour des sweeps doux
      }
    ];
  }

  constructor() {
    super();
    // Un registre z par canal (stéréo, 5.1, etc.)
    this._z = [0, 0, 0, 0, 0, 0, 0, 0]; // 8 canaux max (largement assez)
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
        // Version a-rate (sweeps parfaits)
        for (let i = 0; i < blockSize; i++) {
          const c = Math.max(0.0001, 2 * Math.PI * cutoff[i] / sampleRate);
          const sample = inp ? inp[i] : 0;
          z += c * (sample - z);
          out[i] = z;
        }
      } else {
        // Version k-rate (un seul coeff pour le bloc → plus rapide)
        const c = Math.max(0.0001, 2 * Math.PI * cutoff[0] / sampleRate);
        for (let i = 0; i < blockSize; i++) {
          const sample = inp ? inp[i] : 0;
          z += c * (sample - z);
          out[i] = z;
        }
      }
      this._z[ch] = z; // sauvegarde état pour le prochain bloc
    }

    return true; // garde le noeud vivant
  }
}

registerProcessor("simple-lowpass", SimpleLowpassProcessor);