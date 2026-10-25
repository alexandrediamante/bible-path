(() => {
  const writes = [];
  const events = [];
  let type = 'auto';
  const audioSession = {};

  Object.defineProperty(audioSession, 'type', {
    configurable: true,
    get: () => type,
    set: (value) => {
      type = value;
      writes.push(value);
      events.push(`audio-session:${value}`);
    },
  });
  Object.defineProperty(navigator, 'audioSession', {
    configurable: true,
    value: audioSession,
  });
  Object.defineProperty(window, '__audioSessionWrites', {
    configurable: true,
    value: writes,
  });
  Object.defineProperty(window, '__audioRouteEvents', {
    configurable: true,
    value: events,
  });

  const originalPlay = HTMLMediaElement.prototype.play;
  HTMLMediaElement.prototype.play = function patchedPlay() {
    events.push('media-play');
    return originalPlay.call(this);
  };

  const synthesis = window.speechSynthesis;
  if (synthesis) {
    const originalSpeak = synthesis.speak.bind(synthesis);
    synthesis.speak = (utterance) => {
      events.push('speech-speak');
      return originalSpeak(utterance);
    };
  }
})();
