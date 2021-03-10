Foodsoft
=========
[![Docker Status](https://img.shields.io/docker/cloud/build/vokomokum/foodsoft.svg)](https://hub.docker.com/r/vokomokum/foodsoft)

This is [Vokomokum](http://www.vokomokum.nl/)'s image for [Foodsoft](https://github.com/foodcoops/foodsoft).
It adds on top of upstream Foodsoft some plugins:

- [Foodsoft-shop](https://github.com/foodcoops/foodsoft-shop) as a plugin, see [`plugins/shop`](plugins/shop) (and also [foodcoops PR#581](https://github.com/foodcoops/foodsoft/pull/581)).
- Integration with the Vokomokum-specific member system, see [`plugins/vokomokum`](plugins/vokomokum).


Deploying
---------

Please see [vkmkm-deploy](https://github.com/vokomokum/vkmkm-deploy) for our deployment setup.


Development
-----------

As for development (of the vokomokum plugin) you need the members app, this almost ends up
being the same as the production setup. It _would_ be useful however to provide a minimal
development environment (with the plugins mounted as a volume). Pending.

If you'd like to test other plugins, you can symlink/copy them in a Foodsoft installation
and work on them there.


License
-------

Foodsoft is licensed under the [AGPL](https://www.gnu.org/licenses/agpl-3.0.html)
license (version 3 or later). Practically this means that you are free to use,
adapt and redistribute the software, as long as you publish any changes you
make to the code.

For private use, there are no restrictions, but if you give others access to
Foodsoft (like running it open to the internet), you must also make your
changes available under the same license. This can be as easy as
[forking](https://github.com/vokomokum/foodsoft/fork) the project on Github and
pushing your changes. You are not required to integrate your changes back (but
if you're up for it that would be very welcome).

To make it a little easier, configuration files are exempt, so you can just
install and configure Foodsoft without having to publish your changes. These
files are marked as public domain in the file header.

Please see [LICENSE](https://github.com/foodcoops/foodsoft/blob/master/LICENSE.md)
for the full and authoritative text. Some bundled third-party components have
[other licenses](https://github.com/foodcoops/foodsoft/blob/master/vendor/README.md).

Thanks to [Icons8](http://icons8.com/) for letting us use their icons.
