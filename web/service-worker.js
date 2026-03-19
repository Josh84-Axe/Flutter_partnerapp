const CACHE_NAME = 'tiknet-partner-v1.1.34';
const RESOURCES_TO_CACHE = [
    './',
    './index.html',
    './manifest.json',
    './favicon.png',
    './icons/Icon-192.png',
    './icons/Icon-512.png',
    './flutter.js',
    './flutter_bootstrap.js'
];

// Install Event
self.addEventListener('install', (event) => {
    event.waitUntil(
        caches.open(CACHE_NAME).then((cache) => {
            console.log('📦 [Service Worker] Caching critical assets');
            return cache.addAll(RESOURCES_TO_CACHE);
        })
    );
    self.skipWaiting();
});

// Activate Event
self.addEventListener('activate', (event) => {
    event.waitUntil(
        caches.keys().then((cacheNames) => {
            return Promise.all(
                cacheNames.map((cacheName) => {
                    if (cacheName !== CACHE_NAME) {
                        console.log('🧹 [Service Worker] Cleaning old cache:', cacheName);
                        return caches.delete(cacheName);
                    }
                })
            );
        })
    );
    return self.clients.claim();
});

// Message Event
self.addEventListener('message', (event) => {
  if (event.data && event.data.type === 'SKIP_WAITING') {
    self.skipWaiting();
  }
});

// Fetch Event
self.addEventListener('fetch', (event) => {
    if (event.request.method !== 'GET') return;

    // Navigation requests (index.html) should be Network First
    if (event.request.mode === 'navigate') {
        event.respondWith(
            fetch(event.request).catch(() => {
                return caches.match('./index.html');
            })
        );
        return;
    }

    // Other requests: Cache First then Network
    event.respondWith(
        caches.match(event.request).then((response) => {
            if (response) {
                return response;
            }
            return fetch(event.request).then((networkResponse) => {
                // Don't cache everything, just valid responses
                if (!networkResponse || networkResponse.status !== 200 || networkResponse.type !== 'basic') {
                    return networkResponse;
                }
                return networkResponse;
            }).catch((err) => {
                console.error('❌ [Service Worker] Fetch failed:', event.request.url, err);
                // Return a failure response or fallback if appropriate
                return new Response('Offline or Content Blocked', { status: 503, statusText: 'Service Unavailable' });
            });
        })
    );
});
