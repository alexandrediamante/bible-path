{{flutter_js}}
{{flutter_build_config}}

async function registerOfflineSupport() {
  if ('serviceWorker' in navigator) {
    try {
      await navigator.serviceWorker.register(
        new URL('flutter_service_worker.js', document.baseURI),
      );
    } catch (error) {
      console.warn('Offline support is unavailable:', error);
    }
  }
}

_flutter.loader.load();
registerOfflineSupport();
