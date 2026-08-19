{{flutter_js}}
{{flutter_build_config}}

// Safe target version accessor
var activeVersion = (typeof targetVersion !== 'undefined' && targetVersion) ? targetVersion : '1.3.068';

_flutter.loader.load({
  serviceWorkerSettings: {
    serviceWorkerVersion: activeVersion,
  },
  onEntrypointLoaded: async function(engineInitializer) {
    try {
      let appRunner = await engineInitializer.initializeEngine();
      var loadingDiv = document.getElementById('loading');
      if (loadingDiv) {
        loadingDiv.remove();
      }
      await appRunner.runApp();
    } catch(err) {
      console.error('❌ Flutter Engine initialization error:', err);
      var loadingDiv = document.getElementById('loading');
      if (loadingDiv) {
        loadingDiv.remove();
      }
    }
  }
});
