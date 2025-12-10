// audio-worklet-noise.js
// White, Pink, Brownian, Blue, Violet + filtre passe-bas premier ordre contrôlable
class NoiseProcessor extends AudioWorkletProcessor {
  static get parameterDescriptors() {
    return [
      {
        name: 'type',           // 0=white, 1=pink, 2=brown, 3=blue, 4=violet
        defaultValue: 1,
        minValue: 0,
        maxValue: 4,
        automationRate: 'a-rate'
      },
      {
        name: 'cutoff',         // fréquence de coupure du filtre passe-bas (Hz), 0 = pas de filtre
        defaultValue: 800,
        minValue: 0,
        maxValue: 22050,        // un peu au-dessus de Nyquist
        automationRate: 'a-rate'
      },
      {
        name: 'gain',
        defaultValue: 0.25,     // niveau de sortie global
        minValue: 0,
        maxValue: 1,
        automationRate: 'a-rate'
      }
    ];
  }

  constructor() {
    super();
    
    // État pour chaque type de bruit
    this.pinkB0 = this.pinkB1 = this.pinkB2 = this.pinkB3 = this.pinkB4 = this.pinkB5 = this.pinkB6 = 0;
    this.brown = 0;
    
    // Pour blue (+3 dB/oct) : simple différentiateur
    this.lastWhite = 0;
    
    // Pour violet (+6 dB/oct) : seconde différence
    this.whiteM1 = 0;
    this.whiteM2 = 0;
    
    // Filtre passe-bas 1er ordre (exponentiel moving average)
    this.z = 0;
    
    // Dernière valeur de cutoff pour détecter les changements
    this.lastCutoff = 0;
  }

  process(inputs, outputs, parameters) {
    const output = outputs[0];
    const typeParam = parameters.type;
    const cutoffParam = parameters.cutoff;
    const gainParam = parameters.gain;
    const applyFilter = cutoffParam[0] > 20; // on ignore les très basses fréquences

    for (let channel = 0; channel < output.length; ++channel) {
      const out = output[channel];

      for (let i = 0; i < out.length; ++i) {
        // Récupération des paramètres (a-rate support)
        const type = Math.round(typeParam.length > 1 ? typeParam[i] : typeParam[0]) | 0;
        const cutoff = cutoffParam.length > 1 ? cutoffParam[i] : cutoffParam[0];
        const gain = gainParam.length > 1 ? gainParam[i] : gainParam[0];

        let noise = Math.random() * 2 - 1; // bruit blanc [-1, 1]

        switch (type) {
          case 0: // White - rien à faire
            break;

          case 1: // Pink - méthode Voss (7 accumulateurs)
            this.pinkB0 = this.pinkB0 * 0.99886 + noise * 0.055;
            this.pinkB1 = this.pinkB1 * 0.99332 + noise * 0.075;
            this.pinkB2 = this.pinkB2 * 0.96900 + noise * 0.153;
            this.pinkB3 = this.pinkB3 * 0.86650 + noise * 0.310;
            this.pinkB4 = this.pinkB4 * 0.55000 + noise * 0.532;
            this.pinkB5 = this.pinkB5 * 0.31000 + noise * 0.775;
            this.pinkB6 = this.pinkB6 * 0.11500 + noise * 0.923;
            
            noise = (this.pinkB0 + this.pinkB1 + this.pinkB2 + this.pinkB3 +
                     this.pinkB4 + this.pinkB5 + this.pinkB6 + noise * 0.125) * 0.125;
            break;

          case 2: // Brownian (Brown / Red)
            this.brown += noise * 0.02;
            this.brown *= 0.99;
            noise = this.brown;
            break;

          case 3: // Blue - différentiateur simple
            noise = noise - this.lastWhite;
            this.lastWhite = noise * 0.5 + this.lastWhite * 0.5; // léger lissage pour éviter l'explosion
            noise *= 4.0; // compensation de gain
            break;

          case 4: // Violet - seconde différence
            const secondDiff = noise - 2 * this.whiteM1 + this.whiteM2;
            this.whiteM2 = this.whiteM1;
            this.whiteM1 = noise;
            noise = secondDiff * 8.0; // compensation de gain
            break;
        }

        // Filtre passe-bas 1er ordre (si cutoff > 20 Hz)
        if (applyFilter && cutoff > 20) {
          const normalizedCutoff = Math.min(cutoff / (sampleRate * 0.5), 0.99);
          const alpha = normalizedCutoff < 0.001 ? 0.001 : 1 - Math.exp(-2 * Math.PI * normalizedCutoff * 0.1);
          
          this.z += alpha * (noise - this.z);
          noise = this.z;
        }

        out[i] = noise * gain;
      }
    }

    return true;
  }
}

registerProcessor('noise', NoiseProcessor);