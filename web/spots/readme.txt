Web client code for spots.

Since this is the first serious JS addition to the suite repo, some thoughts and guiding principles, in approximate order of importance:
- TypeScript or bust.
- Dependency minimalism, for both code and tooling.
  - Use the simplest/smallest possible dependencies.
    - The smallest dependency is one you don't install.
    - If it's small enough, you can handroll it. Ownership -> flexibility.
  - Prefer dependencies that don't (intend to) change much.
  - Prefer dependencies that have performance as an explicit goal.
  - Prefer dependencies built by smaller teams.
- Prefer "native" standards. So, `bigint` > bn.js, ESM > CJS, etc.
- Keep bundle sizes down.
  - The smallest file is the one you don't serve. Structure & split files to make optimal use of browser caching.
- Tree-shaking good, it lets you shave down dependency impact even further.

We don't make good on all of that yet, we're still exploring...
