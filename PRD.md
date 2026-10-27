# Tharsis — PRD

MVP: M0–M6 — Tharsis v0.1

| Field | Value |
|-------|-------|
| Document | Product Requirements Document, version 1.0 |
| Date | 2026-10-27 |
| Status | Draft, awaiting maintainer review |
| Codename | **Tharsis** (approved 2026-10-27). Directory `tharsis/`; repository Spacecraft-Software/Tharsis |
| Product | Memory-safe Rust port of the *Quake* engine (WinQuake / GLQuake GPL release) with a GPU-first renderer written in Rust end to end, host and shaders, playing *Quake* from user-supplied game data |
| Class | **Game** (Standard §18.5); exempt from §18 and §10 |
| Assurance category | **D — Incidental** (Standard §19.1: games) |
| Posture | Personal / Hobby (Standard §5.1) |
| Engine licence | `GPL-3.0-or-later`; inherited id Software code `GPL-2.0-or-later` (§4.2) |
| Document licence | `CC-BY-SA-4.0` (Standard §4.1.1) |
| Governing standard | The Steelbore Standard v2.14 |
| Maintainer | Mohamed Hammad — <Mohamed.Hammad@SpacecraftSoftware.org> |

> **Trademark.** *Quake* is a trademark of id Software / ZeniMax Media.
> Tharsis is an independent engine that reads Quake data files. It ships no
> id Software assets and no id Software logos, and claims no endorsement.

## Summary

Tharsis is one Rust codebase, with no C in the shipped binary. It plays
*Quake* from the shareware or registered `id1` data, and the free LibreQuake
data, and later the two mission packs. The server, the QuakeC virtual machine,
and the physics are transliterated by hand from the GPL source release, so a
trace of entity state can be compared frame by frame with the original engine.

The renderer is where Tharsis differs from every earlier port. Its shaders are
written in Rust with **Rust GPU** (`spirv-std`, built by `cargo-gpu`), not in
GLSL or WGSL. The same `no_std` shading code compiles to SPIR-V for the GPU
and to ordinary machine code for the CPU, so it is unit-tested on the CPU and
shared with the software reference renderer. Frames are drawn through
**wgpu 30** on Vulkan, Metal, DX12, or GL. The renderer is GPU-driven: static
world geometry lives on the GPU, visibility culling runs in a compute pass
that writes indirect draws, and Quake's light styles and dynamic lights are
evaluated on the GPU instead of by rebuilding lightmaps on the CPU every frame.
Mesh shaders and hardware ray queries are used where the adapter offers them,
and never required.

A port of the WinQuake software renderer stays in the tree as the reference
for how the game looks. CI checks the GPU renderer against it.

## Why this port, and what it learns from others

| Prior work | State (2026-10) | What Tharsis takes |
|------------|-----------------|--------------------|
| id Software GPL release (WinQuake, GLQuake, QuakeC 1.06) | Reference source | The code being ported, and the behavioural oracle (built out of tree, test-only) |
| Quakespasm, vkQuake, Ironwail | Mature C ports | Limit-removing behaviour, protocol 666, BSP2, decoupled server and render rates, music file conventions. vkQuake and Ironwail show the GPU-driven ideas pay off for Quake |
| Richter | Rust, abandoned, nightly-only | Proof that a Rust Quake client is practical; warning about depending on nightly for the whole build |
| Seismon | Rust, Bevy-based rewrite of Richter | Separating the QuakeC VM into its own crate; plays demos of id1, Hipnotic, Rogue |
| Quake-SRP | Rust port checked against a headless build of id's C source | The differential method: run both engines on the same demo and compare pixels, audio, and game state |

No Rust port yet combines a complete single-player game, a differential
fidelity gate, and shaders written in Rust. That combination is the product.

## Needs

*Players* want to play *Quake* on current Linux systems at high frame rates
and resolutions, with the original look available, their own data files found
automatically, and mods that never crash the engine.

*The maintainer* wants a showcase of current Rust GPU technology in a real,
well-known workload. The simulation shall be safe Rust, the shaders shall be
Rust, and every claim of fidelity or speed shall be backed by a test anyone can
rerun.

## Target game data

| Data | Source | MVP | Available in CI |
|------|--------|-----|-----------------|
| `id1/pak0.pak` shareware (episode 1) | Redistributable shareware | Yes | Yes, fetched by pinned SHA-256 |
| `id1/pak0.pak` + `pak1.pak` registered | User-supplied | Yes | No — local only |
| LibreQuake | Free data set | Yes | Yes, fetched by pinned SHA-256 |
| `hipnotic/` *Scourge of Armagon* | User-supplied | No (M8) | No |
| `rogue/` *Dissolution of Eternity* | User-supplied | No (M8) | No |
| 2021 re-release `id1` and add-ons | User-supplied | No (M8, optional) | No |

## Goals

| ID | Goal |
|----|------|
| G1 | Play the full single-player game of the MVP data sets from start to finish |
| G2 | Server state and software-rendered frames match the C oracle on the free data |
| G3 | Safe Rust; `unsafe` forbidden in the simulation, VM, and data crates |
| G4 | Untrusted PAK, BSP, model, progs, demo, save, and config input never crashes the engine |
| G5 | Shaders written in Rust with Rust GPU, tested on the CPU, shared with the software renderer |
| G6 | GPU-driven wgpu renderer reaching ≥ 240 frames per second at 2560×1440 on the reference machine |
| G7 | Ships through Guix, Nix, and Arch packaging with a Texinfo manual, built on stable Rust |

## Non-goals

| ID | Non-goal | Reason |
|----|----------|--------|
| NG-1 | QuakeWorld (`qwsv`, `qwcl`) and its protocol | Different engine branch; needs its own PRD |
| NG-2 | *Quake II*, *Quake III*, Hexen II | Different engines |
| NG-3 | DarkPlaces or FTE extensions (CSQC, Q3 shaders, skeletal models) | Scope; Quakespasm-level extensions (M8) are the ceiling |
| NG-4 | Distributing registered or re-release data | Legal |
| NG-5 | Console, mobile, VR | Platform and certification cost |
| NG-6 | Telemetry of any kind | §9 |
| NG-7 | Linking C or C++ into the shipped binary | Product identity; the C oracle is test-only and out of tree |
| NG-8 | Requiring a nightly toolchain to build or package the engine | §24 pinned stable toolchain; see Shader pipeline |

## Product principles

1. **Correctness before cleverness.** Where gameplay depends on a behaviour,
   vanilla behaviour wins, including documented bugs.
2. **The server is the source of truth.** As in the original, even single
   player runs a server and a client joined by a loopback channel. The
   client, renderer, and audio read what the server sends and never write
   back.
3. **Floating point is ported, not approximated.** The original game logic
   uses IEEE `float`, with some expressions promoted to `double` by C's rules.
   The port keeps every promotion explicit, never fuses multiply and add, and
   evaluates in the same order, so server state can match the oracle bit for
   bit at a fixed time step.
4. **One shading source.** Every lighting, palette, warp, and fog function is
   written once in `tharsis-shade` and runs on both the CPU and the GPU.
5. **Capabilities are probed, never assumed.** Every advanced GPU feature has
   a baseline path; losing the GPU entirely falls back to the software
   renderer.
6. **Untrusted by default.** Every byte of game data, and every QuakeC
   instruction, is checked before it is trusted.

## Architecture

### Porting strategy

Tharsis uses **manual transliteration** for the server, the QuakeC VM, and
the shared physics (`sv_*`, `pr_*`, `world.c`, `mathlib.c`, `host*.c`,
`model.c` loaders). Function boundaries and evaluation order are kept, so a
diff against the GPL source stays readable and float results stay identical.
The software renderer (`r_*`, `d_*`) keeps its algorithms but uses idiomatic
data structures. The client front end (`cl_*`, `sbar`, `menu`, `console`,
`keys`, `cmd`, `cvar`) is ported with idiomatic types. Platform code
(`sys_*`, `vid_*`, `snd_*`, `in_*`, `net_*`) is rewritten from scratch.

`c2rust` and a C shim were rejected for the same reasons as in the Phobos
PRD: both leave C-shaped `unsafe` code or C in the tree, which G3 and NG-7
forbid.

### Crate layout

```
tharsis/
├── crates/
│   ├── tharsis-math/      # vec3, angles, C-faithful float helpers, anorms table
│   ├── tharsis-fs/        # PAK reader, search paths, -game directories
│   ├── tharsis-data/      # BSP29/BSP2, MDL, SPR, WAD2, LMP, palette, colormap, WAV
│   ├── tharsis-qc/        # QuakeC VM and builtins (#![forbid(unsafe_code)])
│   ├── tharsis-sv/        # Server: world, hull traces, physics, movement, saves
│   ├── tharsis-proto/     # NetQuake messages (15, later 666), loopback channel
│   ├── tharsis-cl/        # Client state, interpolation, temp entities, particles
│   ├── tharsis-console/   # Command buffer, cvars, console, cfg scripts, bindings
│   ├── tharsis-ui/        # Status bar, HUD, menus, intermission, finale
│   ├── tharsis-shade/     # no_std shading code shared by CPU and GPU
│   ├── tharsis-shaders/   # Rust GPU shader entry points; built by cargo-gpu
│   ├── tharsis-soft/      # Software reference renderer (WinQuake port)
│   ├── tharsis-gpu/       # wgpu renderer, presenter, capability probing
│   ├── tharsis-audio/     # Mixer, spatialisation, music decoding
│   ├── tharsis-app/       # winit event loop, CLI, host loop, input
│   └── tharsis-tools/     # `tharsis-tools pak|bsp|progs|demo` inspection and CI checks
├── shaders-out/           # Generated SPIR-V and WGSL, committed, REUSE-covered
└── fuzz/                  # cargo-fuzz targets
```

Dependency rules, enforced by `cargo deny` bans and checked at review:

- `tharsis-sv` and `tharsis-qc` depend only on `tharsis-math`, `tharsis-data`,
  and `tharsis-proto`.
- No renderer depends on `tharsis-fs`. Renderers receive decoded resources.
- Only `tharsis-gpu` depends on wgpu; only `tharsis-app` depends on winit.
- `tharsis-shade` is `no_std`, has no dependencies beyond `spirv-std`'s math
  types, and contains no `unsafe`.

### State ownership

The C engine keeps its state in globals (`sv`, `svs`, `cl`, `pr_globals`,
`edicts`). Tharsis keeps it in owned structs:

- `Server` owns the loaded `Level` (BSP, hulls, PVS), the edict arena, the
  QuakeC `Vm`, and the area-node tree for entity links. A server frame is
  `fn frame(&mut Server, dt: Seconds) -> Vec<Message>`.
- **Edicts** keep vanilla's flat, index-addressed layout, because QuakeC
  addresses entity fields by byte offset. Every field access by the VM is
  bounds-checked against the entity size the progs declare.
- Area-node link lists keep vanilla link order, because touch order decides
  which trigger fires first.
- `Client` owns only what the server has sent, plus interpolation history.
  A `RenderSnapshot` is built from it each frame and is read-only to every
  renderer.

### QuakeC virtual machine

- Loads `progs.dat` version 6, checks the header CRC against the engine's
  field definitions, and refuses mismatched progs with a message.
- Every instruction checks its operands: global and field offsets, string
  indices, function numbers, and edict numbers. A bad access ends the
  QuakeC call with a `PR_RunError`-style report, as vanilla's checked
  paths do, and the server continues or drops to the console. It never
  reads outside its arrays.
- A per-call instruction budget (vanilla's runaway limit, 100 000 by default,
  configurable) stops infinite loops.
- File builtins and `localcmd` are restricted to the active game directory
  and to a safe command list. Mods cannot run shell commands or write
  outside the game directory.
- Builtins are table-driven. The 2021 re-release extensions and common
  community extensions (`checkextension`, Quakespasm's set) are optional
  (M8).

### Concurrency model (Standard §3.2)

| Work | Model | Decision and trade-off |
|------|-------|------------------------|
| Server frame (QuakeC, physics) | **Serial**, one dedicated server thread | QuakeC execution order and link order decide behaviour. A frame costs well under 1 ms (budget below), so by Amdahl's law splitting it could save little and would break fidelity. Serial is chosen and documented here |
| Server ↔ client | Server thread and client thread joined by the loopback channel (bounded SPSC message queues) | The loopback channel already exists as the protocol boundary, so moving the server to its own thread costs nothing in fidelity and lets simulation overlap rendering |
| Server tick rate | Fixed, default 72 Hz, decoupled from the render rate | Vanilla physics depends on frame time and was tuned at up to 72 fps. A fixed step keeps physics stable at any render rate and makes traces reproducible |
| Client and render | Main thread drives winit; render uncapped with interpolation between server frames | winit needs the main thread on several platforms |
| Command encoding | World, model, and particle passes recorded on separate encoders in parallel with Rayon | Adopted only if a benchmark shows a gain over one encoder; wgpu 30 encoders are `Send` |
| GPU culling | Compute pass over all world surfaces and entities | The GPU does this in parallel by nature; removes a per-frame CPU loop |
| Level load | Rayon over BSP lumps, textures, mip generation, and lightmap atlas packing | Embarrassingly parallel; kept only if it beats serial on the reference machine |
| Audio mixing | cpal callback thread fed by a bounded lock-free queue | The client never blocks on audio. If the queue fills, the oldest command is dropped and counted |
| Software reference renderer | Serial at 320×200; optional banded drawing at higher resolutions | It exists for fidelity, not speed |
| CI differential corpus | One process per demo | Shared-nothing parallelism over the corpus |

### Rendering

#### Shader pipeline (Rust GPU)

- Shaders are Rust crates compiled to SPIR-V by **Rust GPU** (`spirv-std`
  0.11 at the time of writing) through **`cargo-gpu`**. `cargo-gpu` manages
  Rust GPU's pinned nightly in isolation, so the host engine builds on the
  pinned stable toolchain.
- The SPIR-V is also translated to WGSL with naga, for wgpu backends that do
  not take SPIR-V (GL, WebGPU).
- **Both outputs are committed** under `shaders-out/` as generated files.
  Packaging and ordinary builds use them, so Guix, Nix, and Arch never need a
  nightly compiler (NG-8). A CI job regenerates them with the pinned
  `cargo-gpu` and fails if a single byte differs.
- `tharsis-shade` holds the shading functions as plain `no_std` Rust:
  colormap lighting, light-style blending, dynamic-light falloff, turbulent
  water warp, sky scroll, fog, gamma. Shader entry points call them on the
  GPU; the software renderer and the unit tests call them on the CPU.
- If Rust GPU stops being viable, the fallback is hand-written WGSL behind
  the same `tharsis-gpu` interface (R-108, risk table).

#### GPU renderer (wgpu 30)

- **Static world on the GPU.** All world surfaces are triangulated at load
  into one vertex buffer, one index buffer, and one lightmap atlas. Nothing
  about the world is uploaded again during play.
- **GPU-driven visibility.** The client computes the PVS leaf set on the CPU
  (a cheap BSP walk) and uploads it as a bitmask. A compute shader tests every
  surface against the PVS and the view frustum and writes
  `multi_draw_indexed_indirect` commands. Where `MULTI_DRAW_INDIRECT_COUNT`
  is unavailable, a fixed-size indirect buffer with empty draws is used.
- **Light styles on the GPU.** Each surface keeps up to four style lightmaps
  in the atlas. The 64 current style values are a uniform array, and the
  fragment shader blends them. The CPU never rebuilds a lightmap when a light
  flickers.
- **Dynamic lights on the GPU.** Muzzle flashes, rockets, and explosions are
  a storage buffer of lights. The shader adds Quake's falloff per texel with
  the same maths as `R_AddDynamicLights`, so the result matches the software
  renderer.
- **Textures.** Bindless texture arrays (`TEXTURE_BINDING_ARRAY`) where
  available; a texture atlas with per-surface UV rectangles otherwise.
- **Alias models (MDL).** Vertex frames live in a storage buffer; frame
  interpolation and instancing happen in the vertex shader.
- **Classic look mode.** Nearest filtering, palette quantisation through the
  colormap in the fragment shader, software-style water warp and sky, and an
  optional 320×200-class internal resolution. This mode is compared with the
  software reference renderer in CI.
- **Modern look mode.** Linear filtering, full-precision lighting, MSAA,
  HDR output where the surface supports a float format. Neither mode changes
  gameplay.
- **Optional advanced features (M9).** Mesh-shader world rendering
  (`EXPERIMENTAL_MESH_SHADER`), ray-query shadows and ambient occlusion
  (`EXPERIMENTAL_RAY_QUERY`), and a path-traced mode. Each is enabled only
  when the adapter reports the feature, is off by default, and has a
  baseline equivalent.
- **Measurement.** GPU timestamp queries report per-pass times in the debug
  overlay and in `-timedemo` output.
- **Device loss.** A lost device recreates the renderer. If that fails, the
  game switches to the software renderer and keeps running.

#### Software reference renderer

A port of the WinQuake span renderer (edge lists, surface cache, alias model
rasteriser, particles) drawing palette indices to a framebuffer. It renders
headless to PNG for CI, and it is the comparison target for the classic GPU
mode. At run time it is presented through wgpu, or `softbuffer` when no GPU
adapter exists.

### Audio

- **Sound effects.** WAV lumps resampled to the output rate, with vanilla's
  channel allocation, ambient and static sounds, distance attenuation, and
  stereo spatialisation (`snd_dma.c`, `snd_mix.c`).
- **Music.** Original CD tracks are not present in data files. Tharsis plays
  `music/trackNN.{ogg,flac,mp3,wav}` from the game directories, following the
  Quakespasm convention, decoded by symphonia (pure Rust; §24 audit before
  adoption).
- **Degraded mode.** If no audio device is available, the game runs silent
  and logs one warning.

### Platform and files

- Windowing and input use winit; gamepads use gilrs (optional).
- File locations follow XDG. `config.cfg`, saves, demos, and screenshots go in
  `$XDG_DATA_HOME/tharsis/<gamedir>/`. Game data is found through `-basedir`,
  `QUAKE_BASEDIR`, the XDG data directories plus `quake/`, then the current
  directory.
- Configuration stays in vanilla `.cfg` script form (`bind`, cvars,
  `exec`), so existing configs keep working. Unknown cvars and commands are
  warned about and ignored.
- No network access in any MVP build (§9). Network play is M10.
- The engine uses no fonts of its own except on the no-data screen and the
  debug overlay. Those use bundled Share Tech Mono / Inconsolata (OFL, §12)
  and the `steelbore` theme (§11, §11.6). In-game text uses the game's
  `conchars`.

## Interfaces

### Command line

Vanilla arguments are accepted as written. `--help` and `--version` follow
`spacecraft-cli-standard`, and `--version` carries the §15 attribution.

| Argument | Purpose |
|----------|---------|
| `-basedir <dir>` | Root holding `id1/` and mod directories |
| `-game <dir>` | Mod directory, layered over `id1` |
| `+map <name>`, `+<command>` | Run console commands at start |
| `-skill <0–3>`, `+coop`, `+deathmatch` | Gameplay switches (coop and deathmatch need M10) |
| `-width`, `-height`, `-fullscreen`, `-window` | Display |
| `-renderer <gpu\|soft>` | Choose renderer |
| `-gpu-backend <vulkan\|metal\|dx12\|gl>` | Force a wgpu backend |
| `+record <name>`, `+playdemo <name>`, `+timedemo <name>` | Demo record, playback, benchmark |
| `-trace <file>` | Write per-frame server state trace for differential testing |
| `-fixedstep` | Lock the host to the server tick for reproducible runs |

`tharsis-tools` is non-interactive and supports `--json`: `pak ls`,
`bsp stats`, `progs info`, `progs disasm`, `demo check`, `demo diff`,
`trace diff`, `shaders check`. CI and agents use it.

### Data formats read

PAK, WAD2, BSP29 (and BSP2 / 2PSB in M8), MDL, SPR, LMP, WAV, `progs.dat`
v6, NetQuake demos `.dem` (protocol 15; 666 in M8), vanilla `.sav` text saves,
`.cfg` scripts, and music files. All are untrusted input.

## Verification

Category D owes a smoke test (§21.2). Fidelity is the product, so Tharsis sets
a higher bar for itself. This is a choice, not a Standard obligation.

| Layer | Evidence | Runs in |
|-------|----------|---------|
| Maths and float semantics | Unit tests against values produced by the C oracle; a lint denies `mul_add` and float reassociation in simulation crates | CI |
| PAK, BSP, MDL, SPR, WAD2, progs, demo, save, cfg parsers | Unit tests plus `cargo-fuzz` targets; no panic, no unbounded allocation | CI (time-boxed fuzz) |
| QuakeC VM | Opcode tests; fuzzed progs; budget and bounds tests | CI |
| Server | `-trace` at `-fixedstep` compared per frame with the C oracle running the same commands | CI on shareware and LibreQuake; locally on registered data |
| Software renderer | Demo frames compared pixel for pixel with the C oracle's software renderer | CI |
| Shading code | `tharsis-shade` unit tests on the CPU; the same functions on the GPU checked through a compute harness | CI |
| GPU renderer | Classic mode compared with the software renderer on golden scenes within a declared tolerance; wgpu validation on; headless adapter (lavapipe) in CI | CI |
| Generated shaders | `shaders-out/` regenerated and compared byte for byte | CI |
| Performance | Criterion benchmarks; `-timedemo` with GPU timestamp breakdown | CI sample, full run before releases |

### Performance targets (should)

Category D has no §22 budget obligation. These targets guide the work and gate
optimisation decisions. The reference machine is still to be chosen (OQ-3).

| Measure | Target |
|---------|--------|
| Server frame, 99th percentile, busiest MVP map | ≤ 1 ms |
| GPU renderer frame, 2560×1440, modern mode, `demo1`–`demo3` | ≤ 4.2 ms (≥ 240 fps) |
| CPU time per rendered frame (client + encoding) | ≤ 1 ms |
| Draw calls submitted by the CPU per frame for the world | 1 indirect call per pass |
| Map load, largest MVP map | ≤ 300 ms |
| Resident memory | ≤ 512 MiB |
| Added input latency | No sleep beyond vsync and frame pacing |

## Standard compliance map

| § | Applies | How Tharsis satisfies it |
|---|---------|--------------------------|
| §2 | Yes | Codename Tharsis (Mars's volcanic plateau whose tectonic stress drives marsquakes; astronomy domain), approved 2026-10-27 |
| §3.1 | Yes | Rust; `#![forbid(unsafe_code)]` in `tharsis-math`, `-fs`, `-data`, `-qc`, `-sv`, `-proto`, `-shade`; typed errors; no `unwrap` on input; bounded VM |
| §3.2 | Yes | Concurrency table above; serial server documented; release flags noted in `Cargo.toml` |
| §3.3 | Partly | No network in MVP; QuakeC sandboxed; PQC N/A. M10 adds a network listener and must revisit this row |
| §4 | Yes | GPL-3.0-or-later; inherited GPL-2.0-or-later notices kept verbatim; REUSE; `LICENSES/` |
| §5.2 | Yes | Posture files (R-002) |
| §5.5 | Yes | `packaging/guix.scm`, `default.nix`, `PKGBUILD` built on stable Rust from committed shaders (R-094) |
| §5.7 | Yes | `AGENTS.md` + `CLAUDE.md` (R-003) |
| §6.3, §6.4 | Yes | Signed commits; no upstream contributions to Quakespasm, Rust GPU, wgpu, or others without per-contribution approval |
| §6.5 | Yes | `.gitattributes`, `.editorconfig` (R-005) |
| §8 | Yes | `doc/tharsis.texi` (R-093) |
| §9 | Yes | No network in MVP, no telemetry, local files only, no third-party subresources |
| §10, §18 | No | Game carve-out §18.5. Adopted anyway from §18.5.2: remappable controls, no capture of `Insert` or `CapsLock` |
| §11, §11.6 | Chrome only | No-data screen and debug overlay. The game world uses the game palette |
| §12 | Yes | Bundled OFL fonts for chrome text |
| §13 | Tailored | Menus are the game's own; recorded in the README register |
| §14 | Yes | ISO 8601 UTC in save metadata, logs, traces, timedemo reports |
| §15 | Yes | `--version`, README, `CREDITS.md` (id Software, Quakespasm, LibreQuake, Rust GPU, prior Rust art if adapted) |
| §17 | Yes | This file follows §17.5 |
| §19 | Yes | Category D declared in README, AGENTS.md, PROJECTS.md |
| §20–§23, §25 | None owed | Category D |
| §24 | Audit tooling | `cargo audit`, `cargo deny` in CI; pinned stable toolchain plus pinned `cargo-gpu` nightly for shaders only; SBOM per release (R-092) |
| §26 | Yes | `SECURITY.md` (R-010) |

## M0 — Foundation and compliance

- [ ] R-001 Cargo workspace with `rust-toolchain.toml` (stable) and committed `Cargo.lock`
- [ ] R-002 Posture files: `README.md` (posture, game declaration, Category D, conformance claim), `NOTICE.md`, `CONTRIBUTING.md`, `LICENSE`, `LICENSES/`
- [ ] R-003 `AGENTS.md` and `CLAUDE.md` per §5.7
- [ ] R-004 REUSE headers on every file, `REUSE.toml` coverage for `shaders-out/`; `reuse lint` gates CI
- [ ] R-005 `.gitattributes` and `.editorconfig` per §6.5; CI rejects CR bytes
- [ ] R-006 CI runs `cargo fmt --check`, `cargo clippy --all-targets --all-features --locked -- -D warnings`, tests, doc tests, `cargo audit`, `cargo deny`
- [ ] R-007 Codename registered in `PROJECTS.md`, the §2.1 registry, and the §18.5 games registry
- [ ] R-008 "Or later" grant verified against the GPL source release headers and recorded in `NOTICE.md`
- [ ] R-009 `CREDITS.md` listing id Software, Quakespasm, LibreQuake, and prior Rust art consulted
- [ ] R-010 `SECURITY.md` with reporting channel and support window
- [ ] R-011 C oracle (GPL WinQuake, headless, SSE2, `-ffp-contract=off`) built reproducibly out of tree with Nix at a pinned commit, used by CI only
- [ ] R-012 CI fetches shareware `pak0.pak` and LibreQuake by pinned SHA-256; LibreQuake licence recorded
- [ ] R-013 `cargo-gpu` and its Rust GPU nightly pinned; shader build job wired into CI

## M1 — Filesystem and resource layer

- [ ] R-014 PAK reader and search paths with vanilla override order and `-game` layering
- [ ] R-015 Game data search in the documented order; no-data screen when nothing is found
- [ ] R-016 BSP29 loader: planes, nodes, leaves, clipnodes, hulls, faces, texinfo, lightmaps, visibility, entities string
- [ ] R-017 MDL and SPR loaders, including skins, groups, and frame groups
- [ ] R-018 WAD2, LMP, palette, colormap, and conchars decoding
- [ ] R-019 WAV sound decoding with loop points
- [ ] R-020 `progs.dat` v6 loader with header CRC check
- [ ] R-021 Every loader returns typed errors on malformed input and never panics
- [ ] R-022 Fuzz targets for PAK, BSP, MDL, SPR, WAD2, and progs loading
- [ ] R-023 `tharsis-tools pak ls`, `bsp stats`, `progs info`, `progs disasm` with `--json`

## M2 — QuakeC VM and server core

- [ ] R-024 C-faithful float helpers: explicit `f32`/`f64` promotion matching the C source, no fused multiply-add (enforced by lint)
- [ ] R-025 QuakeC interpreter covering every v6 opcode with bounds-checked operands
- [ ] R-026 Per-call instruction budget and a recoverable run-error path
- [ ] R-027 All vanilla builtins, with file and command builtins confined to the game directory
- [ ] R-028 Edict arena with vanilla layout, free-list reuse rules, and field-offset checks
- [ ] R-029 Hull tracing and point contents (`SV_RecursiveHullCheck`) faithful to `world.c`
- [ ] R-030 Area-node linking with vanilla touch order
- [ ] R-031 Physics: walk, step, toss, bounce, fly, noclip, push movers, water
- [ ] R-032 Player movement and `SV_ClientThink`
- [ ] R-033 Server spawning, `changelevel`, intermission, and episode progression
- [ ] R-034 Fixed-rate server tick (default 72 Hz) on its own thread
- [ ] R-035 Loopback channel carrying protocol 15 messages between server and client threads
- [ ] R-036 `-trace` per-frame server state output and `-fixedstep` reproducible runs
- [ ] R-037 Headless server run with no window, GPU, or audio
- [ ] R-038 Fuzz target for the QuakeC VM with generated progs

## M3 — Client, console and reference renderer

- [ ] R-039 Client message parsing, entity state, and interpolation between server frames
- [ ] R-040 Temp entities, beams, particles, dynamic lights, and light styles in client state
- [ ] R-041 Command buffer, cvars, aliases, `exec`, `config.cfg` and `autoexec.cfg`
- [ ] R-042 Drop-down console with history and completion
- [ ] R-043 Key bindings through `bind`, mouse look, and keyboard input via winit
- [ ] R-044 Status bar, HUD, centre prints, and intermission screens
- [ ] R-045 Menus: single player, load, save, options, keys, video, quit
- [ ] R-046 Episode finale texts and end screens
- [ ] R-047 Software reference renderer port: edges, spans, surface cache, sky, water warp
- [ ] R-048 Software alias-model and sprite drawing, particles, and view blends
- [ ] R-049 Headless software render to PNG for CI
- [ ] R-050 Software frames presented through wgpu, or `softbuffer` when no adapter exists
- [ ] R-051 No-data screen explaining how to supply game data, using the `steelbore` theme
- [ ] R-052 Gamepad input (optional)

## M4 — GPU renderer: wgpu and Rust GPU

- [ ] R-053 `tharsis-shade` no_std shading library shared by CPU and GPU code
- [ ] R-054 Rust GPU shader crate built by `cargo-gpu` to SPIR-V, translated to WGSL with naga
- [ ] R-055 Generated shaders committed in `shaders-out/` and checked byte for byte in CI
- [ ] R-056 Software renderer uses `tharsis-shade` for lighting, warp, and palette functions
- [ ] R-057 CPU-run unit tests for every `tharsis-shade` function
- [ ] R-058 Compute harness checking `tharsis-shade` GPU results against CPU results
- [ ] R-059 Adapter capability probing with a logged feature report and baseline fallbacks
- [ ] R-060 Static world geometry and lightmap atlas uploaded once per map
- [ ] R-061 Compute culling against PVS bitmask and frustum, writing indirect draws
- [ ] R-062 Light styles blended in the fragment shader; no CPU lightmap rebuilds
- [ ] R-063 Dynamic lights evaluated on the GPU with vanilla falloff
- [ ] R-064 Bindless textures where supported; atlas fallback otherwise
- [ ] R-065 Alias-model frame interpolation and instancing in the vertex shader
- [ ] R-066 Sky, turbulent water, lava, slime, and teleporter surfaces
- [ ] R-067 Sprites, particles, beams, and view blends
- [ ] R-068 Classic look mode compared with the software renderer on golden scenes
- [ ] R-069 Modern look mode with linear filtering and MSAA
- [ ] R-070 GPU timestamp queries in the debug overlay and `-timedemo` output
- [ ] R-071 Device loss recreates the renderer, or falls back to software without ending the game
- [ ] R-072 wgpu validation enabled in CI on a headless adapter
- [ ] R-073 Uncapped frame rate decoupled from the server tick
- [ ] R-074 Parallel command encoding with Rayon, kept only if benchmarked faster (optional)
- [ ] R-075 HDR surface output where the platform supports it (optional)

## M5 — Sound and music

- [ ] R-076 Audio output on a dedicated thread fed by a bounded lock-free queue that never blocks the client
- [ ] R-077 Sound effects with vanilla channel allocation, attenuation, and spatialisation
- [ ] R-078 Ambient and static sounds per leaf contents
- [ ] R-079 Music tracks from `music/` in OGG, FLAC, MP3, and WAV via symphonia
- [ ] R-080 Silent degraded mode with a single warning when no audio device is present
- [ ] R-081 Separate sound-effect and music volume cvars

## M6 — Demos, saves and fidelity gate

- [ ] R-082 Protocol 15 `.dem` playback
- [ ] R-083 Protocol 15 `.dem` recording
- [ ] R-084 `timedemo` reporting frames, wall time, frame rate, and per-pass GPU times
- [ ] R-085 Vanilla `.sav` save and load, refusing corrupt saves with a message
- [ ] R-086 Built-in `demo1`–`demo3` play on shareware, registered, and LibreQuake data
- [ ] R-087 CI differential check: server traces match the C oracle on the free-data corpus
- [ ] R-088 CI differential check: software frames match the C oracle on demo playback
- [ ] R-089 `tharsis-tools demo diff` and `trace diff` report the first divergent frame and field
- [ ] R-090 Every map of the MVP data completed in a scripted local acceptance run
- [ ] R-091 Fuzz targets for demo, save, and cfg parsing

## M7 — Release engineering v1.0

- [ ] R-092 SBOM generated from `Cargo.lock` in the release run and shipped with a checksum
- [ ] R-093 Texinfo manual `doc/tharsis.texi` building to Info, HTML, and PDF
- [ ] R-094 `packaging/guix.scm`, `packaging/default.nix`, `packaging/PKGBUILD` with `install-info`, built on stable Rust
- [ ] R-095 `--help` and `--version` per `spacecraft-cli-standard` with §15 attribution
- [ ] R-096 README compliance section with the tailoring register (§13)
- [ ] R-097 Release profile flags (LTO, `codegen-units = 1`) noted in `Cargo.toml`, benchmarked before and after
- [ ] R-098 Installation verified from each package definition in a clean environment
- [ ] R-099 Signed release tag
- [ ] R-100 macOS and Windows builds (optional)

## M8 — Mission packs and modern formats

- [ ] R-101 *Scourge of Armagon* (`hipnotic`) engine behaviour and HUD
- [ ] R-102 *Dissolution of Eternity* (`rogue`) engine behaviour and HUD
- [ ] R-103 Raised limits and protocol 666 (FitzQuake) for demos and the loopback
- [ ] R-104 BSP2 and 2PSB map formats
- [ ] R-105 Skyboxes, fog, entity alpha, and `.lit` coloured lighting
- [ ] R-106 2021 re-release data and its QuakeC extensions (optional)
- [ ] R-107 External replacement textures (optional)

## M9 — Advanced GPU features

- [ ] R-108 Hand-written WGSL fallback path kept buildable, behind the same renderer interface
- [ ] R-109 Mesh-shader world rendering when `EXPERIMENTAL_MESH_SHADER` is present (optional)
- [ ] R-110 Ray-query shadows and ambient occlusion when `EXPERIMENTAL_RAY_QUERY` is present (optional)
- [ ] R-111 Path-traced lighting mode with denoising (optional)
- [ ] R-112 WebGPU / WASM build using the WGSL outputs (optional)
- [ ] R-113 GPU compute through CubeCL for load-time work, kept only if it beats Rust GPU compute (optional)

## M10 — Network play

- [ ] R-114 Licence and assurance decision for a network listener recorded (OQ-5)
- [ ] R-115 UDP NetQuake client and server, protocol 15 and 666
- [ ] R-116 Cooperative and deathmatch modes
- [ ] R-117 Network message fuzz targets and rate limiting on the listener
- [ ] R-118 Sandboxed dedicated server process with no renderer or audio

## Risks

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Server traces drift from the oracle through float promotion or evaluation order | High | High | Transliteration that keeps expression shape; no-FMA lint; oracle built with SSE2 and `-ffp-contract=off`; `trace diff` names the first divergent field |
| Rust GPU stays nightly-only or stalls | High | Medium | Shaders compiled by pinned `cargo-gpu` and committed; ordinary builds stay stable; WGSL fallback kept buildable (R-108) |
| A Rust GPU or naga release changes generated output | Medium | High | Byte-for-byte check in CI; toolchain bumps are deliberate, reviewed commits |
| Experimental wgpu features change API between releases | Medium | High | Advanced features are optional, probed at run time, and isolated in `tharsis-gpu`; wgpu pinned |
| Malicious mods exploit the QuakeC VM | High | Medium | Bounds-checked operands, instruction budget, confined file and command builtins, fuzzing |
| Registered data absent from CI | Medium | Certain | Shareware and LibreQuake in CI; scripted local acceptance run before each release |
| GPU renderer and software look diverge | Medium | Medium | Shared `tharsis-shade` code; golden-scene comparison of classic mode |
| Scope creep toward DarkPlaces or FTE features | High | High | NG-3; Quakespasm-level extensions are the ceiling |
| Trademark complaint | Medium | Low | Codename, no assets, no logos, disclaimer |

## Open questions

| ID | Question | Recommendation |
|----|----------|----------------|
| OQ-1 | ~~Approve codename **Tharsis**?~~ | **Resolved 2026-10-27:** approved by the maintainer |
| OQ-2 | Are macOS and Windows required for v1.0? | Optional: wgpu and winit make them cheap, but CI cost and a Personal posture argue against requiring them |
| OQ-3 | Which reference machine anchors the performance targets? | The maintainer's main Steelbore OS workstation, recorded with CPU, GPU, driver, and RAM |
| OQ-4 | May the port adapt Quakespasm code (GPL-2.0-or-later), or only follow its documented behaviour? | Allow it with file-level credit; the licences are compatible |
| OQ-5 | Network play (M10) adds a listener: switch to `AGPL-3.0-or-later` (§4.1) and review the category (§19.2)? | Decide before M10 starts; keep the MVP free of any network code until then |
| OQ-6 | Should mission packs move into the MVP? | No; ship v0.1 on `id1` and LibreQuake, then M8 |

## References

- id Software, [id-Software/Quake](https://github.com/id-Software/Quake) (WinQuake, GLQuake, QuakeWorld GPL release) and the QuakeC 1.06 source.
- [Quakespasm](https://quakespasm.sourceforge.net/), [vkQuake](https://github.com/Novum/vkQuake), [Ironwail](https://github.com/andrei-drexler/ironwail).
- Prior Rust art: [Richter](https://github.com/cormac-obrien/richter), [Seismon](https://github.com/eira-fransham/seismon), Quake-SRP ([write-up](https://runtimewire.com/article/quake-srp-rust-port-claude-browser)).
- [Rust GPU](https://github.com/Rust-GPU/rust-gpu) and `cargo-gpu`; `spirv-std` 0.11.0 (2026-10-13).
- [wgpu](https://wgpu.rs/) 30.0.1 (2026-08-22) and naga.
- [CubeCL](https://github.com/tracel-ai/cubecl) 0.11.3 (2026-10-22).
- [LibreQuake](https://github.com/lavenderdotpet/LibreQuake).
- *Phobos — PRD* (`doom-rs/PRD.md`), the sibling id Tech port this document follows in shape.
- The Steelbore Standard v2.14, §2, §3, §4, §9, §11, §17.5, §18.5, §19, §24.
