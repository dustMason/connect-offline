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

*connect-offline* simply compiles the arguments you pass into a properly formatted cache
manifest file. The main convenience it provides is automatically making
sure the cache gets re-downloaded by the browser when you update the
files that are being cached. This is done using the modified-at
timestamps on the files.

## Options

`manifest_path` is the url you want to serve your cache manifest from.
This should match the `manifest` attribute of your html tag. For example: `<html manifest="example.appcache">`

`networks` is a simple array of values for the `NETWORK` section of the
manifest.

`fallbacks` is an object to populate the `FALLBACK` section of the
manifest. Its keys become the urls to handle while its values represent
the redirects for those urls.

`files` expects an array of objects describing directories of files to
add to the cache. See below for an example.

`use_fs_watch` is a boolean that indicates whether or not you want node
to call fs.watch() on each file you are including in the cache manifest
with a callback that will update the "cache buster" timestamp when any
of those files change. You might want to use this option to ease
development - you won't have to restart your server process every time
you change a file and want browsers to download the new cache manifest.
See the tests for more info.

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

And this app.coffee:

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
