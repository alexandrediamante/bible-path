(() => {
  const utterances = [];
  const voices = [
    {voiceURI: 'device-en', name: 'English device', lang: 'en-US'},
    {voiceURI: 'device-br-one', name: 'Português 1', lang: 'pt-BR'},
    {voiceURI: 'device-br-two', name: 'Português 2', lang: 'pt-BR'},
  ];
  const h = window.voiceHarness = {
    calls: 0, lastVoice: '', lastText: '', requests: 0, maxRequestLength: 0,
    rejectResume: false, playbackSession: false, holdFetch: false, playCalls: 0,
    releaseFetch() { if (h.resolveFetch) { h.resolveFetch(); h.resolveFetch = null; } },
    emit(kind, index) { utterances[index].dispatchEvent(new Event(kind)); },
  };
  class TestUtterance extends EventTarget {
    constructor(text) { super(); this.text = text; }
  }
  const synthesis = new EventTarget();
  synthesis.getVoices = () => voices;
  synthesis.speaking = false;
  synthesis.pending = false;
  synthesis.paused = false;
  synthesis.speak = (utterance) => {
    utterances.push(utterance); h.calls++;
    h.lastVoice = utterance.voice?.voiceURI || '';
    h.lastText = utterance.text;
    synthesis.speaking = true;
  };
  synthesis.cancel = () => { synthesis.speaking = false; synthesis.paused = false; };
  synthesis.pause = () => { synthesis.paused = true; };
  synthesis.resume = () => { synthesis.paused = false; };
  Object.defineProperty(window, 'speechSynthesis', {configurable: true, value: synthesis});
  Object.defineProperty(window, 'SpeechSynthesisUtterance', {configurable: true, value: TestUtterance});
  Object.defineProperty(navigator, 'audioSession', {configurable: true, value: {
    set type(value) { h.playbackSession = value === 'playback'; },
  }});
  HTMLMediaElement.prototype.load = function() {};
  HTMLMediaElement.prototype.pause = function() {};
  HTMLMediaElement.prototype.play = function() {
    h.playCalls++;
    if (h.rejectResume) return Promise.reject(new Error('fixture autoplay rejection'));
    queueMicrotask(() => this.dispatchEvent(new Event('playing')));
    return Promise.resolve();
  };
  const wav = new Uint8Array(45);
  wav.set([82,73,70,70], 0); wav.set([87,65,86,69], 8);
  window.fetch = async (url, options) => {
    h.requests++;
    const payload = JSON.parse(options.body);
    h.maxRequestLength = Math.max(h.maxRequestLength, payload.text.length);
    if (h.holdFetch) await new Promise(resolve => { h.resolveFetch = resolve; });
    return new Response(wav, {status:200, headers:{'content-type':'audio/wav'}});
  };
})();