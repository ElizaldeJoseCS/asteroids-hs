# asteroids-hs

An Asteroids arcade game written in Haskell, using SDL2 for windowing, rendering, audio and text.

This README covers everything you need to install to build and work on the game.

---

## What you need

| Tool / library | Version used | What it's for |
|---|---|---|
| [Stack](https://docs.haskellstack.org/) | 3.x (any recent) | Build tool. Downloads the right GHC and Haskell packages for you |
| GHC | **9.10.3** (installed by Stack automatically) | Haskell compiler |
| Stackage snapshot | **LTS 24.65** (set in `stack.yaml`) | Pins every Haskell package version |
| **SDL 2** | 2.0.6 or newer (2.30.x recommended) | Window, input, rendering |
| SDL2_mixer | 2.x | Sound effects / music |
| SDL2_ttf | 2.x | Font rendering (score, text) |
| pkg-config | any | Lets the Haskell SDL bindings find the C libraries |

> **SDL 2, not SDL 3.** The Haskell `sdl2` bindings only work with the SDL 2 API. Don't install SDL3 dev packages by themselves. (On distros where `sdl2` is now `sdl2-compat` running on top of SDL3, that's fine: it provides the SDL 2 API.)

Haskell packages Stack pulls in for you (from LTS 24.65), so you don't install these by hand:

| Package | Version |
|---|---|
| `sdl2` | 2.5.6.1 |
| `sdl2-mixer` | 1.2.0.0 |
| `sdl2-ttf` | 2.1.3 |
| `linear` | 1.23.3 |
| `vector` | 0.13.2.0 |
| `deque` | 0.4.4.2 |
| `random` | 1.2.1.3 |
| `mersenne-random-pure64` | 0.2.2.0 |
| `containers`, `text` | ship with GHC |
| `hspec`, `QuickCheck`, `quickcheck-classes` | tests only |

---

## 1. Install Stack

The recommended way on every OS is **GHCup**, which installs Stack (and optionally the Haskell Language Server).

**Linux / macOS / WSL:**

```sh
curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh
```

Accept the defaults, then restart your shell (or `source ~/.ghcup/env`).

**Windows (PowerShell, not as admin):**

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force;[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; try { & ([ScriptBlock]::Create((Invoke-WebRequest https://www.haskell.org/ghcup/sh/bootstrap-haskell.ps1 -UseBasicParsing))) -Interactive -DisableCurl } catch { Write-Error $_ }
```

Check it worked:

```sh
stack --version
```

> On Arch/Manjaro, prefer GHCup over `pacman -S stack`. The pacman build is dynamically linked against Arch's Haskell packages and breaks on updates.

You don't need to install GHC yourself: Stack downloads GHC 9.10.3 the first time you build.

---

## 2. Install the SDL2 libraries

### Arch / Manjaro

```sh
sudo pacman -S --needed sdl2 sdl2_mixer sdl2_ttf pkgconf
```

(`sdl2` resolves to `sdl2-compat` on current Arch, which is fine.)

### Ubuntu / Debian / Pop!_OS / WSL

```sh
sudo apt update
sudo apt install libsdl2-dev libsdl2-mixer-dev libsdl2-ttf-dev pkg-config
```

### Fedora

```sh
sudo dnf install SDL2-devel SDL2_mixer-devel SDL2_ttf-devel pkgconf-pkg-config
```

### macOS (Homebrew)

```sh
brew install sdl2 sdl2_mixer sdl2_ttf pkg-config
```

### Windows

Stack ships its own MSYS2 environment. Install SDL2 into **that** one, not a separate MSYS2:

```sh
stack setup
stack exec -- pacman -Syu
stack exec -- pacman -S mingw-w64-x86_64-pkgconf mingw-w64-x86_64-SDL2 mingw-w64-x86_64-SDL2_mixer mingw-w64-x86_64-SDL2_ttf
```

(If `pacman -Syu` asks you to restart, run it a second time.)

### Check SDL is visible

```sh
pkg-config --modversion sdl2 SDL2_mixer SDL2_ttf
```

On Windows, prefix it: `stack exec -- pkg-config --modversion sdl2 SDL2_mixer SDL2_ttf`.

You should get three version numbers back. If you get "not found", the build will fail at the `sdl2` package.

---

## 3. Clone and build

```sh
git clone https://github.com/ElizaldeJoseCS/asteroids-hs.git
cd asteroids-hs
stack build
```

The first build takes a while: Stack downloads GHC 9.10.3 and compiles all the dependencies. After that, builds are incremental.

## 4. Run

```sh
stack run asteroids
```

A black "Asteroids" window should open. Press **Q** or close the window to quit.

---

## Project layout

```
asteroids-hs/
├── app/Main.hs        # entry point, just calls Game.run
├── src/Game.hs        # window setup, game state, main loop, rendering
├── package.yaml       # dependencies + build settings (edit THIS)
├── Asteroids.cabal    # generated from package.yaml by Stack (don't edit by hand)
├── stack.yaml         # pins the Stackage snapshot (LTS 24.65)
└── stack.yaml.lock
```

**Adding a dependency:** add it under `dependencies:` in `package.yaml`, then run `stack build`. Stack regenerates `Asteroids.cabal` for you.

---

## Useful commands

| Command | What it does |
|---|---|
| `stack build` | Compile |
| `stack run asteroids` | Compile and run the game |
| `stack build --file-watch` | Rebuild automatically on save |
| `stack ghci` | REPL with the project loaded (`:r` to reload) |
| `stack test` | Run the test suite (see note below) |
| `stack clean` | Delete build output |
| `stack install --local-bin-path ./bin` | Copy the built `asteroids` executable into `./bin` |

> **Tests:** `package.yaml` defines a test suite at `test/Spec.hs`, but that file doesn't exist yet, so `stack test` will fail until it's added. `stack build` and `stack run` are unaffected.

---

## Editor setup (optional)

For autocomplete, type info and errors in your editor, install the **Haskell Language Server** with a version that supports GHC 9.10.3:

```sh
ghcup install hls recommended
```

Then point your editor's Haskell/LSP plugin at it:

- **VS Code:** install the *Haskell* extension.
- **Neovim:** use `haskell-language-server-wrapper` via `nvim-lspconfig` (`hls`) or `haskell-tools.nvim`.

Run `stack build` once before opening the project so HLS can find everything.

---

## Building a Windows `.exe` to share

```sh
stack install --local-bin-path dist-win
```

This produces `dist-win\asteroids.exe`. To run it on a machine without the dev setup, copy the SDL DLLs next to the `.exe`. Find Stack's MSYS2 folder with:

```sh
stack path --programs
```

and copy these from `msys2-*\mingw64\bin\`:

- `SDL2.dll`
- `SDL2_mixer.dll`
- `SDL2_ttf.dll`
- any DLLs those depend on (for example `libfreetype-6.dll`, `libharfbuzz-0.dll`, `libogg-0.dll`, `libvorbis*.dll`, `libmpg123-0.dll`, `zlib1.dll`)

To check for anything still missing, run this inside Stack's MSYS2 shell: `ldd dist-win/asteroids.exe | grep mingw64`. Every DLL it lists needs to sit next to the `.exe`.

Also copy any `assets/` folder (sounds, fonts) the game loads at runtime.

---

## Troubleshooting

**`Missing dependency on a foreign library: sdl2` / `pkg-config` not found**
SDL2 dev packages or `pkg-config` aren't installed (step 2), or on Windows they went into a different MSYS2 than Stack's. Re-run the Windows commands using `stack exec -- pacman ...`.

**`Could not find module 'SDL'`**
You're compiling outside Stack (plain `ghc`). Use `stack build` / `stack ghci`.

**Window opens then immediately closes / black screen on Wayland**
Try forcing X11: `SDL_VIDEODRIVER=x11 stack run asteroids`.

**HLS says the GHC version isn't supported**
Run `ghcup tui` and install an HLS version that lists GHC 9.10.3.

**Stuck on an old snapshot after pulling**
`stack build` picks up `stack.yaml` changes automatically. If something looks stale, run `stack clean` and rebuild.
