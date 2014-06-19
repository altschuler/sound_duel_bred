Sound-Duel-VM-Football
======================

Sound-Duel-VM-Football is a audio-based pop quiz games, using the
[Sound-Duel-Core](https://github.com/bitblueprint/Sound-Duel-Core)
front-end.


## Installation

### Notes

 * Make sure you have `npm` installed.

 * The installation assumes you are running on a UNIX-based system
   (e.g. Linux/Mac OS X), but there is a `Vagrantfile` included for
   those that aren't. In that case, skip the first two steps
   installing Meteor and Meteorite.

### Install

 * First, install [Meteor](https://www.meteor.com/):

        $ curl https://install.meteor.com | /bin/sh

    Manual installation (for developers) can be found at their
    [GitHub repo](https://github.com/meteor/meteor).

 * Then install [Meteorite](https://github.com/oortcloud/meteorite)
   with `npm`:

        $ npm install -g meteorite

 * Clone this repo and update submodules:

        $ git clone https://github.com/bitblueprint/Sound-Duel-VM-Football.git
        $ cd Sound-Duel-VM-Football
        $ git submodule init
        $ git submodule update

 * Install dependencies with `npm`:

        $ npm install

 * Run the app with grunt:

        $ grunt


## How it works

Grunt's main task (default) merges the `src` directory and the
`lib/core/app` directory into a build directory `dist/build`. In the
`build` directory you can run `meteor` as usual -- which is exactly
what the `grunt` command does after having merged the directories and
installed smart packages with Meteorite.

_Note: You should NOT run `meteor` in any other directory than
`build`. Doing so might create unwanted files and can break the build
step._

### Forking

To make your own game, here is some tips on how to get started.

All the back-end logic, including public assets, lives in the `src`
directory.

 * In `private/data.ejson` the markup of the several quizzes,
   with associated questions, alternatives, sounds etc.

 * Each question's alternative specifies a sound file. These sound
   files are looked up in `public/audio` and should be in `.mp3` format.

 * The start- and end dates of each quiz is set as *milliseconds*
   since epoch.

 * The models' controllers are defined in the `server` directory
   (there's not necessarily one for each). Here you will also find the
   `main.coffe` file, which is run on startup, and can be used to set
   up different tasks server-side.

To customize the front-end of the application, please see the
[Sound-Duel-Core](https://github.com/bitblueprint/Sound-Duel-Core)
project. Here you will find all client-side logic, including the
declaration of the MongoDB collections with their publishing and
permissions. As default, all insert, update and remove calls are
blocked.


## License

The suits are working on it...
