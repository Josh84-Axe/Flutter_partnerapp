{{flutter_js}}
{{flutter_build_config}}

// Safe target version accessor
var activeVersion = (typeof targetVersion !== 'undefined' && targetVersion) ? targetVersion : '1.2.313';

_flutter.loader.load({
  serviceWorkerSettings: {
    serviceWorkerVersion: activeVersion,
  },
  onEntrypointLoaded: async function(engineInitializer) {
    try {
      let appRunner = await engineInitializer.initializeEngine();
      await appRunner.runApp();
      if (typeof window.hideAppLoading === 'function') {
        window.hideAppLoading();
      }
    } catch(err) {
      console.error('❌ Flutter Engine initialization error:', err);
      if (typeof window.hideAppLoading === 'function') {
        window.hideAppLoading();
      }
    }
  }
});
