CONTRIBUTING
============

Setting up a local development instance of this can be tricky, since it depends on [Pleiades Static Search](https://github.com/ryanfb/pleiades-static-search/) and [Pleiades GeoJSON](https://github.com/ryanfb/pleiades-geojson/).

Here's what I do on a Mac:

* Set up [Pow](http://pow.cx/)
* Make a "pleiades" app to serve static content: `mkdir -p ~/.pow/pleiades/public`
* Set up symlinks that serve static content out of your `pleiades-static`, `pleiades-static-search`, and `pleiades-geojson` directories
  * `cd ~/.pow/pleiades/public`
  * `ln -s ~/source/pleiades-static`
  * `ln -s ~/source/pleiades-static-search`
  * `ln -s ~/source/pleiades-geojson`
* Make sure you're on the `gh-pages` branch and open up <http://pleiades.dev/pleiades-static/>

### `pleiades-static.rb`

Takes [Pleiades CSV dumps](http://atlantides.org/downloads/pleiades/dumps/) as arguments and generates static HTML representations in `places/`.

### `pleiades-hierarchical.rb`

Takes [Pleiades CSV dumps](http://atlantides.org/downloads/pleiades/dumps/) as arguments and generates hierarchical representaitons (output not currently used on "live" site).

### `update-cron.sh`

Downloads latest Pleiades CSV dump, runs `pleiades-static.rb`, and commits/pushes the result automatically.
