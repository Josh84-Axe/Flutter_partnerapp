const CACHE_NAME = 'tiknet-pwa-v1.3.062';
const RESOURCES_TO_CACHE = [
    './',
    './index.html',
    './manifest.json',
    './favicon.png',
    './flutter.js',
    './flutter_bootstrap.js'
];

// Install Event
self.addEventListener('install', (event) => {
    console.log('📦 [Service Worker] Installing v1.3.062');
    event.waitUntil(
        caches.open(CACHE_NAME).then((cache) => {
            return cache.addAll(RESOURCES_TO_CACHE);
        })
    );
});

// Activate Event: Clean old caches (NO self.clients.claim() to prevent controllerchange reload loops)
self.addEventListener('activate', (event) => {
    console.log('🧹 [Service Worker] Activating & cleaning old caches');
    event.waitUntil(
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
    );
});

// Message Event: Only activate new worker when explicitly requested by user via PWA Update prompt
self.addEventListener('message', (event) => {
  if (event.data && event.data.type === 'SKIP_WAITING') {
    console.log('⚡ [Service Worker] User triggered update activation');
    self.skipWaiting();
  }
});

// Fetch Event: Network first for navigation & code, cache fallback for assets
self.addEventListener('fetch', (event) => {
    if (event.request.method !== 'GET') return;

    const url = new URL(event.request.url);
    
    // Bypass Service Worker for external APIs, cross-origin hosts, and local IP addresses
    if (url.hostname !== self.location.hostname) return;
    
    // Navigation & JS scripts & manifests MUST be Network First
    if (event.request.mode === 'navigate' || url.pathname.endsWith('.js') || url.pathname.endsWith('.json')) {
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

    // Static assets: Cache First
    event.respondWith(
        caches.match(event.request).then((response) => {
            if (response) {
                return response;
            }
            return fetch(event.request).then((networkResponse) => {
                if (!networkResponse || networkResponse.status !== 200 || networkResponse.type !== 'basic') {
                    return networkResponse;
                }
                return networkResponse;
            }).catch((err) => {
                console.error('❌ [Service Worker] Fetch failed:', event.request.url, err);
                return new Response('Offline or Content Unavailable', { status: 503, statusText: 'Service Unavailable' });
            });
        })
    );
});
