various apps, tools, and crazy experiments.  
usage encouraged! issues welcome! provided "as is"! we do not accept prs at this time.

## for users

these softwares can be installed from ~paldev as landscape tiles:

- **pals**: friendlist, for manual peer discovery.
- **face**: see your pals.
- **rumors**: gossip among pals-of-pals.
- **fafa**: 2fa otp authenticator.
- **cliff**: filesystem explorer & editor.
- **scooore**: local scoreboard for chat reacts.
- **picture**: a picture frame for the homescreen.
- **verse**: daily random bible verse for the homescreen.

## for powerusers

these softwares are for manual, local installation & configuration:

- **chat-stream**: allows unauthenticated randos to partake in chats over http.
- **emblemish**: provides an http endpoint for emblemish data.

## for developers

### userspace infrastructure

- **fakeid**: store + helpers for generating and tracking fake local identities.
- **podium**: helper app for exposing subscriptions over unauthenticated http. (maybe broken?)

### libraries

- **rudder**: framework for routing & serving simple web frontends.
- **gossip**: wrapper for p2p data discovery & sharing.
- **multipart**: parsing for http multipart form-data.
- **sigil**: sigil-js but in hoon.
- **emblemish**: alternative sigils & names, based on emoji, currently in beta.
- **twemoji**: subset of the twemoji.twitter.com svgs used by emblemish.
- **markov**: dumb markov chain text generation.
- **bbcode**: bbcode parsing and rendering.
- **benc**: b-encoding and -decoding.
- **torn**: parsing and rendering of torrent files & magnet links.
- **word**: kjv structured for easy lookup.
- **otp**: one-time password (rfc4226, rfc6238) utilities.
- **ppm**: mark and utilities for using `.ppm` image files.
- **pal**: miscellaneous bits and pieces.

## freezer

these softwares are outdated, unmaintained, or unused, but remain in the repository for reference:

- **serval**: a torrent tracker: implements the bittorrent http tracker protocol. (2020.09 - 2021.11)
- **duiker**: a torrent "tracker": enables sharing/discovery of bittorrent magnet links, for use through `|link`. (2020.09 - 2021.11)
- **bard**: interactive storyteller for use with `|link`. (2020.07 - 2021.11)
- **djay**: backend for synced viewing of youtube videos, sourced from a chat channel. (2020.04)
- **biblebot**: watches (chat) graphs for mention of bible verses, then posts them. (2021.01 - 2023.01)
