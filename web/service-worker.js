const CACHE_NAME = 'tiknet-pwa-cache-v1.2.313';
const RESOURCES_TO_CACHE = [
    './',
    './index.html',
    './manifest.json',
    './favicon.png',
    './flutter.js',
    './flutter_bootstrap.js',
    './version.json'
];

// Install Event
self.addEventListener('install', (event) => {
    console.log('📦 [Service Worker] Installing v1.2.313');
    self.skipWaiting();
    event.waitUntil(
        caches.open(CACHE_NAME).then((cache) => {
            return cache.addAll(RESOURCES_TO_CACHE).catch((err) => {
                console.warn('⚠️ [Service Worker] Pre-cache non-critical error:', err);
            });
        })
    );
});

// Activate Event: Clean old caches & claim clients immediately
self.addEventListener('activate', (event) => {
    console.log('🧹 [Service Worker] Activating & claiming clients v1.2.313');
    event.waitUntil(
        Promise.all([
            self.clients.claim(),
            caches.keys().then((cacheNames) => {
                return Promise.all(
                    cacheNames.map((cacheName) => {
                        if (cacheName !== CACHE_NAME) {
                            console.log('🗑️ [Service Worker] Deleting old cache:', cacheName);
                            return caches.delete(cacheName);
                        }
                    })
                );
            })
        ])
    );
});

// Message Event: Allow explicit skipWaiting from PWA banner
self.addEventListener('message', (event) => {
  if (event.data && event.data.type === 'SKIP_WAITING') {
    console.log('⚡ [Service Worker] User triggered update activation');
    self.skipWaiting();
  }
});

// Fetch Event
self.addEventListener('fetch', (event) => {
    if (event.request.method !== 'GET') return;

    const url = new URL(event.request.url);
    
    // Bypass Service Worker for external APIs, cross-origin hosts, and payment gateways
    if (url.hostname !== self.location.hostname) return;

    // Navigation, index.html, version.json, service-worker.js, & flutter_bootstrap.js: Network First
    const isNetworkFirst = event.request.mode === 'navigate' || 
                           url.pathname.endsWith('index.html') || 
                           url.pathname.endsWith('version.json') || 
                           url.pathname.endsWith('service-worker.js') || 
                           url.pathname.endsWith('flutter_bootstrap.js');

    if (isNetworkFirst) {
        event.respondWith(
            fetch(event.request).then((networkResponse) => {
                if (networkResponse && networkResponse.status === 200) {
                    const responseClone = networkResponse.clone();
                    caches.open(CACHE_NAME).then((cache) => cache.put(event.request, responseClone));
                }
                return networkResponse;
            }).catch(() => {
                return caches.match(event.request);
            })
        );
        return;
    }

    // Heavy app bundles & static assets (main.dart.js, assets/*, canvaskit/*): Stale-While-Revalidate
    event.respondWith(
        caches.match(event.request).then((cachedResponse) => {
            const fetchPromise = fetch(event.request).then((networkResponse) => {
                if (networkResponse && networkResponse.status === 200 && networkResponse.type === 'basic') {
                    const responseClone = networkResponse.clone();
                    caches.open(CACHE_NAME).then((cache) => cache.put(event.request, responseClone));
                }
                return networkResponse;
            }).catch(() => null);

            // Instant load from cache if available, else wait for network
            return cachedResponse || fetchPromise;
        })
    );
});
