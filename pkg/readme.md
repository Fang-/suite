





Folders herein contain files and symlinks to files whose source lives in this
repository, that together form the first-party portion of their respective
packages. They (read: some, for now) also contain a `dep.txt` file, which
specifies their third-party dependencies. `copy.sh` can be used to copy all
the required files into a target desk.

`copy.sh` takes two required arguments, and two optional ones:
- The directory to copy from. (`$from`)
- The directory to copy into. (`$into`)
- Optionally, a root directory to pull dependencies from. (`$root`)
  - The default, `../..`, assumes you are running the script from within this
    `/pkg` directory, and have other urbit repositories checked out as sibling
    directories to suite's, under their official names.  
    At the very least, the `dep.txt` files assume that the dependency
    repositories are all siblings of each other, and are named identical to
    their Github pages. If your setup does not satisfy this requirement,
    everything herein will be useless to you.
- Optionally, a dependency file to read "base" dependencies from. (`$base`)
  - The default, `dep.txt`, intends to point to the `/pkg/dep.txt` file, which
    specifies generic dependencies needed for all of suite's packages.

Running from inside `/pkg` might look like:

```bash
./copy.sh pals ~/piers/paldev/pals
```

Running from `/` might look like:

```bash
pkg/copy.sh pkg/pals ~/piers/paldev/pals .. pkg/dep.txt
```

`dep.txt` files are interpreted line-by-line. Syntax is based on leading
characters.
- `#` starts a comment line.
- `> ` specifies the directory within `$into` we will copy into. (`$deep`) If
  it doesn't yet exist, it will be created.
- `< ` specifies the directory within `$from` we will copy from. (`$goal`)
- Blank lines are ignored.
- All other lines are interpreted as paths (`$line`) that will be copied as
  follows: `cp -RL $root/$deep/$line $into/$goal`.

`copy.sh` first copies the `$base` dependencies, then the `$from` dependencies,
and lastly the `$from` contents themselves. It also removes the `pkg.txt` from
the target directory.

(This is mostly here for my own purposes, to help me distribute most-minimal
desks consistently. This is clearly not The Urbit Dependency Management Story.
Any DMs asking for support on this will be laughed at.)
