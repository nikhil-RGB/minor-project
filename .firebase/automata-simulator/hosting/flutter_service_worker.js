'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "7d5d57fc5a2da622e852747bce675d76",
"assets/AssetManifest.bin.json": "54956d76b80cab9a9afa71e6aeda5f0e",
"assets/AssetManifest.json": "257acfa1d6bd0032e0ed7db9f7e435e5",
"assets/assets/images/FLA.png": "ab4ff2bed409ef3516441916b90429ba",
"assets/assets/images/machine.png": "5fe97a692975bdad5ce958d58771ecc5",
"assets/assets/images/TMG.png": "d391f47cc963c590504b290e571ec3d4",
"assets/FontManifest.json": "ec8a82ec184cf6cd45fbf68291b1fe6b",
"assets/fonts/MaterialIcons-Regular.otf": "4e9f872947935accbe21a940e953d411",
"assets/google_fonts/SourceCodePro-Black.ttf": "15314c03e3648f6e6531abccea341e99",
"assets/google_fonts/SourceCodePro-BlackItalic.ttf": "408c7a66c3e2d66e72817074c373c596",
"assets/google_fonts/SourceCodePro-Bold.ttf": "bcb5e0a6c22cd10aac69f14bb5b0ecb1",
"assets/google_fonts/SourceCodePro-BoldItalic.ttf": "80a4fd1c5e5e623e1e3832ae6498b8cf",
"assets/google_fonts/SourceCodePro-ExtraBold.ttf": "7afda4e5d499dc2da6d3c2fa8f9016d3",
"assets/google_fonts/SourceCodePro-ExtraBoldItalic.ttf": "25561e896616c51ed806aebe5aa9510e",
"assets/google_fonts/SourceCodePro-ExtraLight.ttf": "f989325b91b155aea1fe1785d1ca29b9",
"assets/google_fonts/SourceCodePro-ExtraLightItalic.ttf": "d9475166f2926f93171962fe03e9b670",
"assets/google_fonts/SourceCodePro-Italic-VariableFont_wght.ttf": "95fadb75180fc99901b586e7f056ad62",
"assets/google_fonts/SourceCodePro-Italic.ttf": "c9ef71914ebe8752dd0ce7955aae6733",
"assets/google_fonts/SourceCodePro-Light.ttf": "ce3df95ccba87a5ccee17327835d631f",
"assets/google_fonts/SourceCodePro-LightItalic.ttf": "e3983972193585ce141501e361a89602",
"assets/google_fonts/SourceCodePro-Medium.ttf": "818bd08e02b082f895e71061311eeced",
"assets/google_fonts/SourceCodePro-MediumItalic.ttf": "eb8a356fcb1d818b46ebbefa193ef4ab",
"assets/google_fonts/SourceCodePro-Regular.ttf": "846ad017921bac28ddb313763eb7c6ad",
"assets/google_fonts/SourceCodePro-SemiBold.ttf": "e1fdaf4f876a2473d978bdeced8dd701",
"assets/google_fonts/SourceCodePro-SemiBoldItalic.ttf": "61eef3e9bcac16ef556abdc362a30a72",
"assets/google_fonts/SourceCodePro-VariableFont_wght.ttf": "f978629a3cb76772c18c0293b29a8722",
"assets/NOTICES": "7adf6f78f86428c01441dd64122c8ba4",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "e986ebe42ef785b27164c36a9abc7818",
"assets/packages/simple_icons/fonts/SimpleIcons.ttf": "36006a2aee699bab11e4562e9bd81963",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "c86fbd9e7b17accae76e5ad116583dc4",
"canvaskit/canvaskit.js.symbols": "38cba9233b92472a36ff011dc21c2c9f",
"canvaskit/canvaskit.wasm": "3d2a2d663e8c5111ac61a46367f751ac",
"canvaskit/chromium/canvaskit.js": "43787ac5098c648979c27c13c6f804c3",
"canvaskit/chromium/canvaskit.js.symbols": "4525682ef039faeb11f24f37436dca06",
"canvaskit/chromium/canvaskit.wasm": "f5934e694f12929ed56a671617acd254",
"canvaskit/skwasm.js": "445e9e400085faead4493be2224d95aa",
"canvaskit/skwasm.js.symbols": "741d50ffba71f89345996b0aa8426af8",
"canvaskit/skwasm.wasm": "e42815763c5d05bba43f9d0337fa7d84",
"canvaskit/skwasm.worker.js": "bfb704a6c714a75da9ef320991e88b03",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "c71a09214cb6f5f8996a531350400a9a",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "835ed7178cd399d5b41689d7b31ce2e1",
"/": "835ed7178cd399d5b41689d7b31ce2e1",
"main.dart.js": "d8768fa6bd69bcf63a86384752a06140",
"manifest.json": "c15d0357978e4ee59bec0499d7402487",
"version.json": "958c03d63883b1bd001888e1b628af92"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
