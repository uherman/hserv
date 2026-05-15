# hserv

A tiny framework for building static-site web servers in [HolyC](https://holyc-lang.com/).

You write HTML in `pages/`, run `hserv build`, and get a single binary that serves your site.

## Performance

### Memory
```
󰣇 ~ ❯ kubectl top pods
NAME                                         CPU(cores)   MEMORY(bytes)   
hserv-app                                    1m           5Mi             
nextjs-app                                   1m           68Mi
```

## Install

You need the HolyC compiler [`hcc`](https://github.com/Jamesbarford/holyc-lang) on `PATH`. Then pick one:

**One-liner (recommended for users):**

```sh
curl -fsSL https://raw.githubusercontent.com/uherman/hserv/main/install.sh | sh
# user-only install (no sudo):
curl -fsSL https://raw.githubusercontent.com/uherman/hserv/main/install.sh | PREFIX=$HOME/.local sh
```

**From a checkout:**

```sh
make install                       # installs to /usr/local (needs sudo)
make install PREFIX=$HOME/.local   # user-only install
make uninstall                     # remove
```

**During development (live):**

```sh
ln -s "$PWD/hserv" ~/.local/bin/hserv   # symlink points at the repo
```

## Quick start

```sh
hserv create my-site
cd my-site
hserv run        # builds, then runs ./server on http://localhost:8080
```

## Commands

| Command            | What it does                                                       |
| ------------------ | ------------------------------------------------------------------ |
| `hserv create <n>` | Scaffold a new project in `./<n>/`                                 |
| `hserv build`      | Generate `.hserv/`, vendor the framework sources, run `hcc`        |
| `hserv run`        | `build`, then exec the resulting `./server`                        |

## Project layout

After `hserv create my-site`:

```
my-site/
├── hserv.conf          # config
├── pages/              # one folder per route, each containing index.html
│   └── index.html
├── public/             # global static assets (CSS, images, fonts, ...)
│   └── style.css
└── .gitignore
```

After `hserv build`, a `.hserv/` build dir and a `./server` binary appear. Both are gitignored.

## Routing

URLs map to filesystem paths under `pages/`. For a request like `/foo/bar`, hserv tries in order:

1. **Page:** `pages/foo/bar/index.html`
2. **Public asset:** `public/foo/bar`
3. **Page-local asset:** `pages/foo/bar`
4. **404** if none of the above exist.

`/` resolves to `pages/index.html`. A trailing slash (`/foo/`) is equivalent to `/foo` — both serve the same file.

### Favicon

A request for `/favicon.ico` is served from `public/favicon.ico` if present. If not, hserv falls back to the first match of `public/favicon.{png,svg,jpg,jpeg,gif,webp}` and serves it with the right content-type — so dropping a single `favicon.png` in `public/` is enough.

### Example

```
my-site/
├── pages/
│   ├── index.html              # served at /
│   ├── about/
│   │   ├── index.html          # served at /about and /about/
│   │   └── picture.png         # served at /about/picture.png
│   └── blog/
│       └── hello/
│           └── index.html      # served at /blog/hello
└── public/
    ├── style.css               # served at /style.css
    └── favicon.png             # served at /favicon.png
```

## Configuration

`hserv.conf` is a flat `key = value` file (`#` starts a comment). All keys have defaults:

| Key          | Default  | Meaning                                      |
| ------------ | -------- | -------------------------------------------- |
| `port`       | `8080`   | TCP port to listen on                        |
| `host`       | `*`      | Bind address (`*` = all interfaces)          |
| `pages_dir`  | `pages`  | Folder containing page directories           |
| `public_dir` | `public` | Folder containing global static assets       |

## Safety

Every request path is validated before any filesystem lookup. Requests are rejected (404) if they contain:

- empty segments (`//`)
- any segment beginning with `.` — blocks `..`, `.git`, `.env`, dotfiles
- characters outside `[A-Za-z0-9._/-]`

This means hidden files in your project directory are never reachable over HTTP.

## How it works

`hserv build` generates `.hserv/main.HC` and `.hserv/router.HC` from templates (substituting your config), vendors the framework HolyC sources into `.hserv/framework/`, and compiles the whole thing with `hcc`. The framework code is the same on every build — only `main.HC` and `router.HC` are configured per-project.

## Cutting a release (maintainers)

```sh
scripts/release.sh 0.1.0     # tags v0.1.0, builds tarball, pushes, creates GitHub release
```

Requires `gh` (GitHub CLI) and a clean working tree.
