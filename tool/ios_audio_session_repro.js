(() => {
  const writes = [];
  let type = 'auto';
  const audioSession = {};

  Object.defineProperty(audioSession, 'type', {
    configurable: true,
    get: () => type,
    set: (value) => {
      type = value;
      writes.push(value);
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
})();
