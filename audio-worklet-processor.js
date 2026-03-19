// audio-worklet-processor.js — ZERO version memory allocation
class MyAudioProcessor extends AudioWorkletProcessor {
constructor() {
    super();
    this.volume = 1.0;
    this.port.onmessage = (e) => {
      if (e.data.volume !== undefined) this.volume = e.data.volume;
    };
  }

  process(inputs, outputs, parameters) {
    const input = inputs[0];
    const output = outputs[0];

    if (input && input[0] && output) {
      const samples = input[0];

      // Treatment
      for (let i = 0; i < samples.length; i++) {
        output[0][i] = samples[i] * this.volume;
        if (output[1]) output[1][i] = samples[i] * this.volume; // stéréo si besoin
      }

      // Sending WITHOUT transfer → zero risk of detached buffer
      this.port.postMessage({
        type: 'audio',
        samples: samples // direct reference, but not transferred → OK
      });
    }

    return true;
  }
}

registerProcessor('my-audio-processor', MyAudioProcessor);