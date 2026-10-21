{{flutter_js}}
{{flutter_build_config}}

async function waitForController(registration) {
  const updatePending = registration.installing || registration.waiting;
  if (navigator.serviceWorker.controller && !updatePending) return;
  await Promise.race([
    new Promise((resolve) => {
      navigator.serviceWorker.addEventListener('controllerchange', resolve, {
        once: true,
      });
    }),
    new Promise((resolve) => setTimeout(resolve, 5000)),
  ]);
}

async function startBiblePath() {
  if ('serviceWorker' in navigator) {
    try {
      const registration = await navigator.serviceWorker.register(
        new URL('flutter_service_worker.js', document.baseURI),
      );
      await navigator.serviceWorker.ready;
      await waitForController(registration);
    } catch (error) {
      console.warn('Offline support is unavailable:', error);
    }
  }

  await _flutter.loader.load();
}

startBiblePath();
