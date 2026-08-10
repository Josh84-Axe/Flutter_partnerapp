{{flutter_js}}
{{flutter_build_config}}

// Safe target version accessor
var activeVersion = (typeof targetVersion !== 'undefined' && targetVersion) ? targetVersion : '1.2.284';

// FORCE CACHE BUST FOR MAIN DART JS
if (_flutter && _flutter.buildConfig && _flutter.buildConfig.builds && _flutter.buildConfig.builds.length > 0) {
  _flutter.buildConfig.builds[0].mainJsPath = "main.dart.js?v=" + activeVersion;
}

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
