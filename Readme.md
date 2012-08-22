## Connect-Offline

While searching for some connect middleware to handle generating a cache
manifest, I discovered that the CacheManifest middleware had been
removed from the 1.0 release of Connect. I'm not sure why that is, but
it inspired me to create a new one.

## Installation

```
  npm install connect-offline
```

## What It Does

Pretty simple right now, no automation out of the box. connect-offline
simple compiles the arguments you pass into a properly formatted cache
manifest file. The main convenience it provides is automatically making
sure the cache gets re-downloaded by the browser when you update the
files that are being cached. This is done using the modified-at
timestamps on the files.

## Check It Out

Given a directory structure:

```
├── app.js
└── public
    ├── css
    │   └── style.css
    └── js
        └── hello.js
```

And this app.js:

```
  offline = require('connect-offline')
  app = require('connect').createServer()
  app.use(offline
    manifest_path: "/application.manifest"
    files: [
      { dir: '/public/css', prefix: '/css/' },
      { dir: '/public/js', prefix: '/js/' }
    ]
  )
  app.listen 3590
```

You'll get an `application.manifest` that looks like this:

```
  CACHE MANIFEST
  # Wed, 22 Aug 2012 03:24:19 GMT

  CACHE:
  /css/style.css
  /js/hello.js
```
