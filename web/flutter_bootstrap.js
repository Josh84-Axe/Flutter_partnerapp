{{flutter_js}}
{{flutter_build_config}}

// FORCE CACHE BUST FOR MAIN DART JS
if (_flutter && _flutter.buildConfig && _flutter.buildConfig.builds && _flutter.buildConfig.builds.length > 0) {
  _flutter.buildConfig.builds[0].mainJsPath = "main.dart.js?v=" + targetVersion;
}

_flutter.loader.load({
  serviceWorkerSettings: {
    serviceWorkerVersion: targetVersion,
  },
  onEntrypointLoaded: async function(engineInitializer) {
    let appRunner = await engineInitializer.initializeEngine();
    var loadingDiv = document.getElementById('loading');
    if (loadingDiv) {
      loadingDiv.remove();
    }
    await appRunner.runApp();
  }
});
