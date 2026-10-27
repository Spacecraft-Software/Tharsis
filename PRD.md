<!-- SPDX-FileCopyrightText: 2026 Mohamed Hammad <Mohamed.Hammad@SpacecraftSoftware.org> -->
<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
<!-- Generated from PRD.texi by 'make PRD.md'. Edit the Texinfo source, not this file. -->

# Tharsis — PRD

MVP: M0–M8 — Tharsis v0.1

## Overview

| Field | Value |
|----|----|
| Document | Product Requirements Document, version 2.0. Replaces PRD version 1.0 and the four drafts archived in `docs/drafts/` |
| Date | 2026-10-27 |
| Status | Draft, decisions approved by the maintainer on 2026-10-27; requirements not yet baselined |
| Codename | **Tharsis** (approved 2026-10-27). Directory `tharsis/`; repository Spacecraft-Software/Tharsis |
| Product | Memory-safe Rust port of the *Quake* engine (WinQuake / GLQuake GPL release) with a GPU-driven renderer whose shaders are written in Rust, playing *Quake* and QuakeSpasm-level community content from user-supplied data on Linux, Windows, macOS and the web browser |
| Class | **Game** (Standard §18.5); exempt from §18 and §10 |
| Assurance category | **D — Incidental** (Standard §19.1: games), declared at M0 (R-306) |
| Posture | Personal / Hobby (Standard §5.1) |
| Engine licence | `GPL-3.0-or-later`; inherited id Software code `GPL-2.0-or-later` (§4.2), checked file by file (R-304) |
| Document licence | `CC-BY-SA-4.0` (Standard §4.1.1) |
| Governing standard | The Steelbore Standard v2.14. The local Texinfo masthead read v2.13 on 2026-10-27; R-302 rechecks before baselining |
| Maintainer | Mohamed Hammad, <Mohamed.Hammad@SpacecraftSoftware.org> |

> **Trademark:** *Quake* is a trademark of id Software / ZeniMax Media. Tharsis is an independent engine that reads Quake data files. It ships no id Software assets and no id Software logos, and claims no endorsement.

### Summary

Tharsis is one Rust codebase that plays the original *Quake* campaign and large modern community releases such as *Arcane Dimensions*. It runs on Linux, Windows and macOS, and in a web browser through WebAssembly and WebGPU. The QuakeC virtual machine, the server and the physics are transliterated by hand from the GPL source release. A command-driven harness compares them with the original C engine: discrete events must match exactly, and continuous values must stay within tolerances frozen before the comparison runs.

The renderer is the showcase. Its shaders are written in Rust with Rust GPU and built by `cargo-gpu`. The same `no_std` shading code runs on the GPU, in CPU unit tests, and in the software reference renderer. Frames are drawn through wgpu 30. Static world geometry stays on the GPU, a compute pass culls it and writes indirect draws, and light styles and dynamic lights are evaluated in shaders instead of by rebuilding lightmaps on the CPU. Everything advanced is probed at run time and has a simpler equivalent; mesh shaders, ray queries, path tracing and HDR are optional experiments after the MVP.

The bet on Rust GPU is guarded. M0 ends with a go/no-go gate: the Rust shaders must compile, translate and draw a real map slice on every MVP platform before the rest of the plan proceeds. If the gate fails, switching to hand-written WGSL needs the maintainer’s written approval.

### Decision record

These decisions were taken by the maintainer on 2026-10-27 after comparing five drafts (see [Sources](#Sources)).

| Topic | Decision | Origin |
|----|----|----|
| Codename | Tharsis | PRD v1.0; also used by both Texinfo drafts. Slipgate, quake-rs, InSight, Cerberus and Wormhole were considered |
| Shaders | Rust GPU for all shaders; generated SPIR-V and WGSL committed; M0 go/no-go gate on every MVP platform | Rust-GPU draft 1.2 (gate), PRD v1.0 (committed artifacts) |
| Fidelity | Exact discrete events; per-field tolerances frozen in M0; bit-exact only where a test qualifies it | Rust-GPU draft 1.2 |
| Server clock | Fixed 72 Hz server tick; rendering uncapped with interpolation | PRD v1.0, Rust-GPU draft 1.2, Slipgate draft |
| MVP platforms | Linux, Windows, macOS and browser (WebGPU) | Qwen and Slipgate drafts, widened |
| MVP content | `id1` campaign, LibreQuake subset, and QuakeSpasm-level community formats (BSP2, 2PSB, protocol 666, raised limits, fog, skybox, alpha, `.lit`) | Slipgate draft, narrowed to QuakeSpasm level |
| Browser scope | Full single-player, same as desktop | Maintainer |
| Browser delivery | Release download only; players serve it locally; no public page | Maintainer |
| Multiplayer | Post-MVP milestone after licence, assurance and threat review | PRD v1.0, both Texinfo drafts |
| Advanced GPU | Mesh shaders, ray queries, path tracing and HDR are optional experiments after the MVP | Four of five drafts |
| Renderer modes | Classic and Enhanced presets. The Slipgate draft’s “Abrash Mode” is not used, because it names a real person | Rust-GPU drafts |
| Document format | `PRD.texi` is canonical; `PRD.md` is generated | Maintainer |

### Identifiers

Items in this version use `R-301` to `R-400`. PRD v1.0 used `R-001` to `R-118`, and the two archived Texinfo drafts used `R-201` onwards. Those identifiers stay reserved and are never reused. No earlier item is ticked, so no crosswalk carries progress forward.

## Product

### Needs

**Players**  
want to play *Quake* and current community releases on modern hardware at high frame rates, with the original look available, their own data found or picked easily, and saves that never get corrupted.

**Mod players**  
want large community maps to load within published limits, and a clear message, not a crash, when content goes beyond them.

**Speedrunners and demo users**  
want movement and timing that match the original, and demos that record and play back.

**The maintainer**  
wants a real workload that exercises current Rust GPU technology across desktop and web, with every fidelity and performance claim backed by a test anyone can rerun.

**Packagers**  
want to build from a clean checkout on stable Rust, with no nightly compiler and no asset download.

### Target content

| Content | Source | MVP | Public CI |
|----|----|----|----|
| Shareware `id1/pak0.pak` | User-supplied | Yes | Only if R-311 confirms the redistribution terms |
| Registered `id1` (`pak0`, `pak1`) | User-supplied | Yes | No; local acceptance only |
| LibreQuake subset | Free data set | Yes | Yes, pinned release and SHA-256, licence audited (R-311) |
| Project-owned fixtures | Written in tree | Yes | Yes |
| *Arcane Dimensions*, *Copper*, *Alkaline* | User-supplied | Yes (M6) | No; local acceptance only |
| *Scourge of Armagon*, *Dissolution of Eternity* | User-supplied | No (M9) | No |
| 2021 re-release data | User-supplied | No (M9, optional) | No |

### Platforms

| Platform | GPU backend | Notes |
|----|----|----|
| Linux x86-64 | Vulkan | Wayland and X11; the home platform; Guix, Nix and Arch packages |
| Windows x86-64 | DX12; Vulkan secondary | Release archive |
| macOS (Apple silicon) | Metal | Release archive |
| Web browser | WebGPU | `wasm32-unknown-unknown`; released as a downloadable bundle that players serve from `localhost` |

Every platform also has Tier 0, the software renderer, for when no usable GPU adapter exists. OpenGL is not an MVP backend: the compute-driven renderer cannot assume every GL adapter has the capabilities it needs. Mobile, consoles, VR and 32-bit targets are out of scope.

### Goals

| ID | Goal |
|----|----|
| G1 | Complete every map of the MVP content on every MVP platform, from new game to finale |
| G2 | Match the C oracle on the fidelity contract: exact discrete events, and continuous values within frozen tolerances |
| G3 | Safe Rust: `unsafe` forbidden in the data, filesystem, QuakeC, server, protocol and shading crates |
| G4 | Untrusted PAK, map, model, progs, demo, save and config input never crashes, hangs or escapes its sandbox |
| G5 | All shaders written in Rust with Rust GPU, tested on the CPU and shared with the software renderer |
| G6 | GPU-driven rendering on capable adapters, with a tested baseline path on all others |
| G7 | Meet the approved frame-time, load, memory and soak targets on recorded reference machines |
| G8 | Build and package on pinned stable Rust, without a nightly compiler and without downloading assets |

### Non-goals

| ID | Non-goal | Reason |
|----|----|----|
| NG-1 | QuakeWorld, *Quake II*, *Quake III*, Hexen II, the 2021 Kex engine | Different engines; each needs its own PRD |
| NG-2 | QuakeSpasm-Spiked and FTE extended QuakeC opcodes and builtins, CSQC, DarkPlaces features | Large, loosely specified surface; QuakeSpasm level is the ceiling |
| NG-3 | Distributing registered, shareware, mission-pack or re-release data | Legal; the GPL covers the code, not the data |
| NG-4 | A hosted web page or server for the browser build | Maintainer decision; the browser build is a release download |
| NG-5 | Telemetry, accounts, advertising, automatic downloads | §9 |
| NG-6 | Linking C or C++ that the project writes into the shipped program | Product identity; the C oracle is test-only. Platform libraries and drivers are native code and are not claimed otherwise |
| NG-7 | A nightly compiler for ordinary builds or packages | §24 pinned toolchain; see [Technology](#Technology) |
| NG-8 | Mandatory ray tracing, mesh shaders or vendor-specific APIs (CUDA) | Cross-vendor baseline; experiments stay optional |
| NG-9 | A remake: new weapons, rebalancing, replacement campaign, mandatory high-resolution assets | The product is a port |

### Product principles

1.  **Classic gameplay first, modern rendering second.** No enhancement may change weapon timing, physics, monster decisions, trigger order, network messages or demo playback.

2.  **The server is the source of truth.** Even single player runs a server and a client joined by the protocol-15 loopback. Renderers, audio and UI read snapshots and never write back.

3.  **Evidence over assertion.** Every fidelity, safety and speed claim names the test that proves it, with its inputs and environment recorded.

4.  **One shading source.** Lighting, palette, warp, fog and tone functions are written once in Rust and run on the CPU and the GPU.

5.  **Probe, never assume.** Every GPU feature beyond the baseline is detected at run time, and losing the GPU falls back to software rendering.

6.  **Untrusted by default.** Every byte of content and every QuakeC instruction is checked before it is trusted.

## Technology

Versions were checked on 2026-10-27. M0 freezes exact versions after the shader spike, and every upgrade replays the shader, fidelity and benchmark corpora.

| Technology | Baseline | Role |
|----|----|----|
| wgpu | 30.0.1 | The only GPU API: Vulkan, DX12, Metal and browser WebGPU |
| naga | wgpu 30 family | Validates SPIR-V and translates it to WGSL, MSL and HLSL |
| Rust GPU (`spirv-std`) | 0.11.0 | Compiles Rust shader crates to SPIR-V |
| `cargo-gpu` | Pinned with Rust GPU | Builds shaders with Rust GPU’s pinned nightly, isolated from the stable host build |
| winit | Pinned at M0 | Windows, input and event loop on every platform |
| cpal, symphonia | Pinned at M0, §24 audit | Audio output (including WebAudio) and pure-Rust music decoding |
| softbuffer | Pinned at M0 | Tier 0 presentation without a GPU, including a browser canvas |
| wasm-bindgen | Pinned at M0 | Browser shell, Web Worker and storage bindings |

### Shader pipeline

- Shading functions live in `tharsis-shade`, a `no_std` crate: colormap lighting, light-style blending, dynamic-light falloff, turbulent warp, sky scroll, fog, gamma and tone mapping. Shader entry points in `tharsis-shaders` call them on the GPU; the software renderer and the unit tests call them on the CPU. Shared types have explicit size and alignment tests.
- `cargo-gpu` compiles the entry points to SPIR-V. naga validates the SPIR-V and translates it to WGSL for the browser. Metal and DX12 receive naga translations inside wgpu at pipeline creation.
- The generated SPIR-V and WGSL are **committed** under `shaders-out/` with a hash manifest and REUSE coverage. Ordinary builds and all packages use them on stable Rust and never download or install a nightly compiler.
- A CI job provisions the pinned shader toolchain through a checksum-verified step, regenerates every artifact offline, and fails if a byte or hash differs. Toolchain upgrades are separate, reviewed commits.

### The M0 shader gate

M0 ends with a go/no-go test (R-308, R-309). Before running it, the maintainer names the reference adapters, operating systems, drivers and browser versions, and freezes the fixture, sample vectors, tolerances, image thresholds and expected output. The gate passes only if, on every named target:

- the Rust vertex, fragment and compute shaders compile, translate and pass naga and wgpu validation;
- a textured, lightmapped BSP fixture draws through an indirect draw; and
- the frozen CPU/GPU sample comparisons and image comparisons pass.

The targets are a Linux integrated adapter, a Linux discrete adapter, one Windows machine, one macOS machine, and one browser. A failed gate blocks M0. A failure does not pass the gate just because it is documented. The maintainer may approve, in writing, a narrower platform commitment, a hand-written WGSL substitution, or a delay; the gate then reruns against the revised scope.

### Evaluated and rejected

**Bevy**  
Not used as the engine. Quake’s entity layout, QuakeC order and timing are compatibility contracts that small purpose-built crates keep visible. This is an architecture judgment, not a claim that Bevy cannot run Quake.

**ash (direct Vulkan)**  
Not the baseline. It would add backend-specific work and break the browser target. A direct-backend spike needs a measured missing capability.

**CubeCL**  
A second GPU runtime is not needed to render Quake. Evaluated after the MVP for load-time compute only (R-395).

**Rust CUDA**  
Single-vendor; never needed to build, play or test.

**WGSL as the main language**  
Proposed by the Qwen and Slipgate drafts. Rejected as the default because the product is a Rust GPU showcase; kept as the gate’s approved fallback.

## Architecture

### Porting strategy

The server, the QuakeC VM and the shared physics (`sv_*`, `pr_*`, `world.c`, `mathlib.c`, `host*.c`, the model loaders) are **transliterated by hand**. Function boundaries and evaluation order are kept, so a diff against the GPL source stays readable. Globals and pointers become owned state, checked indices and explicit lifetimes. The software renderer (`r_*`, `d_*`) keeps its algorithms with idiomatic data structures. The client front end (`cl_*`, `sbar`, `menu`, `console`, `keys`, `cmd`, `cvar`) is ported with idiomatic types. Platform code is new.

`c2rust` and a C shim were rejected: both leave C-shaped `unsafe` code or C in the tree, which G3 and NG-6 forbid. No ECS rewrite happens during the compatibility work.

### Crates

| Crate | Responsibility |
|----|----|
| `tharsis-math` | C-faithful scalar, vector and angle helpers; explicit float promotion |
| `tharsis-fs` | PAK access, search paths, `-game` layering, read-only mounts, confined writes; native and browser storage backends |
| `tharsis-data` | Bounded parsers: BSP29, BSP2, 2PSB, MDL, SPR, WAD2, LMP, WAV, palette, colormap, `.lit` |
| `tharsis-qc` | QuakeC loader, VM, builtins, instruction budget, run-error boundary |
| `tharsis-sv` | Server: edicts, hull traces, area links, physics, movement, saves |
| `tharsis-proto` | Protocols 15 and 666, demo codec, loopback transport |
| `tharsis-cl` | Client state, interpolation, temporary entities, particles, render snapshots |
| `tharsis-console` | Command buffer, cvars, aliases, `.cfg` scripts, bindings |
| `tharsis-ui` | Status bar, HUD, menus, console view, intermission, finales |
| `tharsis-shade` | `no_std` shading functions shared by CPU and GPU |
| `tharsis-shaders` | Rust GPU entry points, built by `cargo-gpu`; no game rules |
| `tharsis-soft` | Software reference renderer and headless capture |
| `tharsis-gpu` | wgpu resources, passes, capability probing, tiers, recovery |
| `tharsis-audio` | Mixer, spatialisation, music decoding |
| `tharsis-app` | Native host loop, winit, command line, platform paths |
| `tharsis-web` | Browser shell: Web Worker server, storage, file picking |
| `tharsis-tools` | Headless inspection, trace and demo diff, golden capture, benchmarks |

Rules, enforced by `cargo deny` bans and review:

- `tharsis-sv` and `tharsis-qc` depend only on `tharsis-math`, `tharsis-data` and `tharsis-proto`; they never see a renderer.
- No renderer depends on `tharsis-fs`; renderers receive decoded resources.
- Only `tharsis-gpu` depends on wgpu. Only `tharsis-app` and `tharsis-web` depend on windowing, audio-device or browser crates.
- Public interfaces do not expose third-party lock or channel types.

### State ownership

- `Server` owns the loaded level (BSP, hulls, PVS), the edict arena, the QuakeC `Vm` and the area-node tree. A server frame is a function from the server state, a fixed time step and ordered client commands to outgoing messages.
- **Edicts** keep vanilla’s flat, index-addressed layout, because QuakeC addresses fields by offset. Every VM field access is bounds-checked against the entity size the progs declare. Free-list reuse follows vanilla’s rules.
- Area-node link lists keep vanilla link order, because touch order decides which trigger fires first.
- `Client` owns only what the server sent plus interpolation history. A read-only render snapshot is built from it for each presented frame.

### QuakeC virtual machine

- Loads `progs.dat` version 6 and checks the header CRC against the engine’s field definitions.
- Every instruction checks its global, field, string, function and edict operands. A bad access ends the call with a run error; partially executed world changes are never treated as a successful call.
- A per-call instruction budget, 100 000 by default and configurable, stops runaway loops.
- File builtins are confined to the active game directory. `localcmd` and `stuffcmd` pass through the same command allowlist as user scripts; no content string reaches a shell or a process.
- QuakeSpasm-level extensions needed by the M6 corpus are added only when the manifest names them (R-311). QSS and FTE extensions are out of scope (NG-2).

### Server clock

The server ticks at a fixed 72 Hz. Rendering runs uncapped and interpolates between the two latest server frames. Catch-up work per presented frame is capped; local play pauses on suspend and the interpolation clock resets on resume. Slow rendering never changes the simulation step. This is a product setting, not a claim that every original mode ran at 72 Hz; the fidelity harness feeds both engines the same explicit time steps ([Quality](#Quality)).

### Concurrency model (Standard §3.2)

| Work | Model | Decision and trade-off |
|----|----|----|
| Server frame (QuakeC, physics) | **Serial**, one dedicated server thread | QuakeC order, link order and float evaluation order are game behaviour. A frame costs about 1 ms or less, so Amdahl’s law leaves little to gain and splitting it would risk fidelity. Serial is chosen and documented here |
| Server and client | Joined by the loopback: bounded SPSC queues natively, `postMessage` between a Web Worker and the page in the browser | The loopback is already the protocol boundary, so a separate thread costs no fidelity and lets simulation overlap rendering. Reliable messages are never dropped; a full queue applies back-pressure at a safe point |
| Client and render | Main thread drives the event loop; render snapshots are double-buffered | winit and the browser require the main thread |
| Command encoding | World, model and effect passes on parallel encoders (Rayon), native only | Adopted only if a benchmark beats one encoder without raising frame-time variance (R-355) |
| GPU culling | Compute pass over all surfaces and entities | Parallel by nature; removes a per-frame CPU loop on Tier 2 |
| Level load | Bounded worker pool over lumps, textures, mips, lightmap atlas packing | Kept only if it beats serial on the reference machine. In the browser it runs serially, because the bundle must not need `SharedArrayBuffer` |
| Audio mixing | Audio callback thread fed by a bounded lock-free queue | The client never blocks on audio. On overflow, disposable one-shot effects are dropped and counted; stop, volume and channel updates are never dropped. No I/O, locks or allocation in the callback |
| CI corpus | One process per demo, trace or scene | Shared-nothing parallelism |

## Rendering

### Capability tiers

| Tier | Content | Availability |
|----|----|----|
| Tier 0 — software | Ported WinQuake renderer, presented through softbuffer. Oracle captures and the no-GPU fallback. Preserves playability, not the GPU performance targets | All platforms |
| Tier 1 — portable GPU | Indexed rasterisation, CPU BSP/PVS and frustum visibility, ordinary texture bindings, GPU light styles and dynamic lights, GPU model interpolation, shader sky and liquids. The correctness baseline for every optimised path | All platforms, including WebGPU |
| Tier 2 — GPU-driven | Compute PVS and frustum culling writing bounded indirect draws; multi-draw and draw-count where present; binding arrays where present; GPU timestamps; pipeline caching | Native platforms with full features; on WebGPU with single indirect draws per batch and no binding arrays |
| Tier 3 — experimental | Mesh shaders, ray queries, path tracing, HDR display output | Optional, after the MVP (M10) |

Device creation requests only the features the selected tier uses. Startup logs the adapter, backend, limits, selected tier and every optional feature it rejected. A failure in an optional tier falls back one tier; a failure in the portable path is reported, not hidden.

**Tier 2 adoption gate.** Tier 2 is fully implemented and can always be forced. It is selected automatically for an adapter class only if it passes the correctness corpus, improves median frame time by at least 5 percent beyond run-to-run variance, does not worsen the 99th percentile by more than 2 percent, and stays within resource targets. Otherwise Tier 1 stays the default and the result is recorded. Small vanilla maps may favour CPU culling.

### The GPU frame

- **Static world on the GPU.** Every world surface is triangulated at load into large vertex and index buffers and one lightmap atlas, uploaded once per map. Moving brush models are dynamic instances.
- **Compute visibility.** The client walks the BSP to the camera leaf and uploads the PVS as a bitmask. A compute pass tests surface bounds against the PVS and frustum and writes draw commands. Missing or invalid visibility data falls back to a conservative visible set; moving doors and teleports never cause false occlusion.
- **Bounded indirect buffers.** Before dispatch, an upper bound on candidate commands is compared with buffer capacity; if it does not fit, the frame draws through Tier 1. An overflow on the GPU suppresses the partial result and draws a complete conservative frame before presentation. A partly culled frame is never presented as a success.
- **Light styles on the GPU.** Each surface keeps up to four style lightmaps; the 64 style values are a small per-frame array blended in the fragment shader. The CPU never rebuilds a lightmap when a light flickers.
- **Dynamic lights on the GPU.** Muzzle flashes, rockets and explosions are a storage buffer of lights evaluated with the classic falloff equation and checked against reference samples.
- **Textures.** Binding arrays where supported; batching by material otherwise. Atlases are an optimisation that needs mip gutters, not a mandatory fallback.
- **Alias models.** Vertex frames live in storage buffers; frame interpolation and instancing happen in the vertex shader.
- **Frame resources.** Per-frame data uses a bounded ring with explicit fence lifetimes. No per-frame path allocates without bound, waits on a worker, or reads back the indirect buffer.

### Presets

**Classic**  
Nearest filtering, original palette and colormap rules, documented fullbright handling, software-style sky and water warp, sprites, particles, view blends, and an optional low internal resolution. Compared with the software reference renderer in CI.

**Enhanced**  
Linear filtering, mipmaps, anisotropy where available, MSAA, interpolated models and full-precision lighting. Enhanced presentation never shows entities that the original visibility rules would hide.

Neither preset changes simulation traces. Benchmark records include every preset setting.

### Device loss

On device loss the CPU state is kept and local play pauses. The renderer makes one bounded rebuild and re-uploads from retained CPU data. If that fails, the player is offered Tier 0 or save-and-exit. Recovery from a driver hang is best effort; no claim is made that every GPU fault is recoverable.

## Platforms

### Desktop

- Per-user data follows each platform’s convention: XDG directories on Linux, Known Folders on Windows, Application Support on macOS. Saves, configs, demos, screenshots, traces and logs go there. Game data directories are mounted read-only and never written.
- Game data is found through `-basedir`, `QUAKE_BASEDIR`, the platform data directories, then the current directory. If nothing is found, the no-data screen explains where to put legally obtained files and offers a directory picker. Tharsis never downloads game data.
- Linux ships through Guix, Nix and Arch packages (§5.5). Windows and macOS ship as release archives with checksums.

### Browser

- The engine compiles to `wasm32-unknown-unknown`. The page runs the client and renderer on the main thread; the server runs in a Web Worker and speaks protocol 15 over `postMessage`.
- The bundle needs no `SharedArrayBuffer` and therefore no cross-origin isolation headers. Work that is parallel on desktop runs serially in the browser; this trade-off is documented here per §3.2.
- The player picks PAK files or a game folder. Copies are kept only in the browser’s own storage (Origin Private File System or IndexedDB) on the player’s machine. Saves, configs and demos live there too, with export and import. Nothing is sent over the network.
- The bundle is a release download (NG-4). Players serve it from `localhost`, which browsers treat as a secure context, so WebGPU is available. The release notes give a one-line way to serve it.
- All fonts, scripts and shaders ship inside the bundle; nothing is fetched from a third-party host (§9.1).
- If WebGPU is unavailable, the page falls back to Tier 0 on a canvas, or explains which browsers and settings are supported.

### Input and interface

- Keyboard and mouse input through winit (pointer lock in the browser); bindings set with vanilla `bind` commands and remappable. Gamepads are optional.
- Configuration stays in vanilla `.cfg` form. Unknown commands and cvars produce bounded warnings.
- Menus are keyboard-complete. Defaults do not capture `Insert`, `CapsLock` or assistive-technology chords.
- Adopted from §18.5.2 although games are exempt: remappable controls, HUD and text scaling, independent sound and music volumes, and a reduced-flash and reduced-motion option (view bob, damage tilt, screen flashes).
- The no-data screen and debug overlay use the `steelbore` theme and bundled OFL fonts (§11, §12). In-game text uses the game’s own font data.

## Compatibility

### Compatibility manifest

M0 creates a versioned manifest (R-311). It lists:

- the accepted shareware and registered data editions, with release, origin and SHA-256 of every PAK;
- the qualified LibreQuake release and subset, with its licence audit;
- the community corpus — *Arcane Dimensions*, *Copper* and *Alkaline* — with versions, hashes, and the formats, protocols, extensions and limits each needs;
- the limits table: entities, edicts, models, sounds, lightmaps, visible surfaces, message sizes, file sizes, VM memory, recursion depth, each a bounded number with a diagnostic when exceeded; and
- for each claimed entry, the test, platform, input hash, result, known deviations, and whether it may be used in public CI.

A release claims compatibility only for entries in the manifest with a passing regression test. Licensed data and results that contain protected material stay in the maintainer’s local acceptance environment.

### Community formats

The MVP supports what QuakeSpasm-level ports support and the M6 corpus needs: BSP2 and 2PSB maps, protocol 666 for the loopback and demos, raised limits, fog, skyboxes, entity alpha and `.lit` coloured lighting. Protocol 999 is added only if the manifest shows the corpus needs it. Mission packs and the 2021 re-release follow in M9.

### Bug compatibility

A documented vanilla behaviour is preserved when gameplay, speedruns, demos or mods depend on it, even when it is a bug. A behaviour that only permits memory corruption, reading freed memory, arbitrary file access or unbounded computation is replaced by a checked error and recorded as an intentional safety difference.

## Quality

### Fidelity contract

The oracle is the id Software GPL WinQuake source built out of tree at a pinned commit, headless, with SSE2 and floating-point contraction disabled. Its build flags, CPU and harness changes are recorded.

- A command-driven harness feeds both engines the same ordered commands, random seed and explicit time-step sequence. M0 freezes a constant 1/72-second sequence and representative variable-step sequences.
- **Exact:** entity spawn and removal order, discrete state, trigger activation order, map transitions, QuakeC opcode results and protocol bytes.
- **Within frozen tolerances:** positions, velocities, angles and event times, with limits set per field in M0 and recorded with the float encoding, reference build, seed and inputs.
- **Bit-exact** only where a test in a qualified environment shows it. It is not inferred from transliteration or from banning fused multiply-add, though both practices are kept because they make it likely.
- Demo checks cover message decoding, rendered client state and record-and-replay. Demos alone never discharge server requirements.
- A difference from the oracle in the default fixed-step mode needs a maintainer-approved exception and a regression fixture before release. A known difference never counts as a passing parity test.

### Visual checks

- Software reference frames: exact palette-index checks against oracle captures for frozen scenes covering opaque geometry, light styles, dynamic lights, water and sky, models and sprites, particles and the HUD. Resolution, viewport, gamma, filtering and interpolation are fixed per capture.
- Classic GPU frames against software references: starting thresholds of SSIM at least 0.99 and at most 0.5 percent of pixels off by more than 8/255 per channel. After the first working renderer, per-scene thresholds and masks are measured and frozen by the maintainer. HUD text and visibility keep exact region checks.
- Enhanced mode and intentional rasterisation differences use separately approved GPU golden images, each recording its adapter, driver and rationale.
- Images derived from licensed content stay in the local environment.

### Performance targets

These are proposed engineering targets, not measurements. M0 names the machines and freezes CPU, GPU, RAM, OS, driver, browser, power mode and display settings (R-313). Runs are at least five 120-second runs after a 30-second warm-up, reporting median, 95th, 99th percentile and worst frame interval, CPU time, GPU timestamps where available, and allocations. Timestamps that are unavailable are reported as unavailable, never as zero.

| Measure | Workload | Target |
|----|----|----|
| Frame interval, integrated GPU | 1920×1080, Tier 1 Classic, original maps | Median ≤ 8.33 ms; p99 ≤ 16.67 ms |
| Frame interval, discrete GPU | 2560×1440, Tier 2 Enhanced, original maps | Median ≤ 4.17 ms; p99 ≤ 8.33 ms |
| Frame interval, discrete GPU | 2560×1440, Tier 2 Enhanced, largest corpus map | Median ≤ 8.33 ms; p99 ≤ 16.67 ms |
| Frame interval, browser | 1920×1080, Tier 1 Classic, original maps, integrated GPU | Median ≤ 16.67 ms |
| Windows and macOS | Same workloads on their reference machines | Targets of the matching GPU class |
| Server step | Busiest approved fixture | p99 ≤ 1 ms original; ≤ 2 ms corpus |
| CPU submission | Tier 2, discrete profile | p95 ≤ 1 ms |
| Map load | Largest map, local SSD, warm cache | ≤ 1 s original; ≤ 3 s corpus; cold load reported |
| Memory | Steady play | RSS ≤ 512 MiB original, ≤ 1.5 GiB corpus; GPU ≤ 512 MiB original |
| Browser bundle | WASM, script and shaders, compressed | ≤ 15 MiB |
| Soak | Four hours of demos and map transitions | No crash; RSS growth after warm-up ≤ 5% |

A target changes only with a dated justification, old and new values, measurements and maintainer approval; release evidence reports both.

### Untrusted input and failure handling

- Files, decoded counts, recursion, VM instructions, config expansion and allocations are bounded. Lengths, offsets and indices are checked before use. Malformed input never reaches `unwrap`, `expect` or panicking indexing.
- Content mounts are read-only. Absolute paths, traversal and symlink escapes are rejected. Native plugins and replacement shaders are out of scope.
- Every loader, the VM, demos, saves and config commands have fuzz targets with a minimised permanent regression corpus. A release has no open, reproducible crash in that corpus.
- Writes use a temporary file and atomic replace; a failed write keeps the last valid save. No audio means silence with one warning; no GPU means Tier 0; no data means the no-data screen.

### Privacy

No analytics, crash upload, accounts, tracking or advertising. Logs and traces stay local. Data discovery checks documented locations only. Test-data fetching is opt-in, pinned, and never part of a player build.

### Licensing and identity

The upstream source carries GPL-2.0-or-later grants; new engine code is GPL-3.0-or-later and upstream notices are kept verbatim with per-file provenance. Generated shader artifacts, fixtures and third-party content each carry REUSE provenance. Game data is separate: the GPL release keeps its data restrictions, so nothing is bundled, mirrored or cached publicly without confirmed permission. id Software and substantial third-party work are credited in `CREDITS.md`.

## Standard compliance map

| § | Applies | How Tharsis meets it |
|----|----|----|
| §2 | Yes | Tharsis, Mars’s volcanic plateau whose stress drives marsquakes (astronomy); registered by R-306 |
| §3.1 | Yes | Rust; `#![forbid(unsafe_code)]` in data, fs, qc, sv, proto and shade crates; typed errors; bounded VM |
| §3.2 | Yes | Concurrency table; serial server and serial browser work documented; release flags noted in `Cargo.toml`; Tier 2 benchmark gate |
| §3.3 | Partly | No network in the MVP; QuakeC sandboxed; PQC N/A until M11 |
| §4 | Yes | GPL-3.0-or-later; inherited notices kept; REUSE; `LICENSES/` |
| §5.2, §5.7 | Yes | Posture files, `AGENTS.md` and `CLAUDE.md` (R-302) |
| §5.5 | Yes | Guix, Nix and Arch packages on stable Rust from committed shaders (R-382) |
| §6.3, §6.4 | Yes | Signed commits; no upstream contributions without per-contribution approval |
| §6.5 | Yes | `.gitattributes`, `.editorconfig`; CR bytes rejected (R-303) |
| §8 | Yes | `doc/tharsis.texi` (R-381); this PRD is Texinfo |
| §9, §9.1 | Yes | No network, no telemetry, local storage; browser bundle self-contained |
| §10, §18 | No | Game carve-out §18.5; §18.5.2 practices adopted ([Platforms](#Platforms)) |
| §11, §12 | Chrome only | No-data screen and overlay use `steelbore` and OFL fonts; the game world uses the game palette |
| §13 | Tailored | Menus are the game’s own; recorded in the README register |
| §14 | Yes | ISO 8601 UTC in saves metadata, logs, traces and reports |
| §15 | Yes | `--version`, README, `CREDITS.md` |
| §17.5 | Yes | This document; `PRD.md` is generated from it |
| §19 | Yes | Category D declared in README, `AGENTS.md`, `PROJECTS.md` |
| §20–§23, §25 | None owed | Category D |
| §24 | Audit | `cargo audit`, `cargo deny`; pinned stable and shader toolchains; SBOM per release (R-385) |
| §26 | Yes | `SECURITY.md` (R-302) |

## M0 — Foundation and shader feasibility

- [ ] R-301 Stable Rust workspace with `rust-toolchain.toml`, lockfile, `cargo deny` policy and CI building for Linux, Windows, macOS and `wasm32`
- [ ] R-302 Posture files, `AGENTS.md`, `CLAUDE.md`, `SECURITY.md`, `CREDITS.md` and REUSE coverage checked against the current Standard; `reuse lint` gates CI
- [ ] R-303 `.gitattributes` and `.editorconfig` per §6.5; CI rejects CR bytes
- [ ] R-304 GPL-2.0-or-later grant confirmed for every inherited file and recorded in `NOTICE.md`
- [ ] R-305 C oracle built reproducibly out of tree at a pinned commit, headless, with contraction disabled; test-only
- [ ] R-306 Codename and game class registered in the Standard §2.1 and §18.5 registries; Category D declared
- [ ] R-307 wgpu 30.0.1, naga, Rust GPU 0.11.0, `cargo-gpu` and the shader-only nightly pinned; ordinary builds never fetch nightly
- [ ] R-308 Shader gate: Rust vertex, fragment and compute shaders compile and pass naga and wgpu validation for every MVP backend
- [ ] R-309 Shader gate: lightmapped BSP slice with an indirect draw passes frozen sample and image checks on all five named targets
- [ ] R-310 Offline shader regeneration reproduces committed SPIR-V and WGSL byte for byte against a hash manifest
- [ ] R-311 Compatibility manifest: data editions, LibreQuake subset and licence audit, community corpus, limits table
- [ ] R-312 Fidelity contract: time-step corpus, exact-event list, per-field tolerances, trace format, and a demonstrated failing mismatch
- [ ] R-313 Reference machines, browsers, capture settings and approved performance targets recorded

## M1 — Resources and QuakeC VM

- [ ] R-314 PAK, search paths and `-game` layering with read-only mounts and confined writes; traversal and symlink tests
- [ ] R-315 BSP29 loader: planes, nodes, leaves, clipnodes, hulls, faces, texinfo, lightmaps, visibility, entities
- [ ] R-316 MDL, SPR, WAD2, LMP, palette, colormap, conchars and WAV loaders
- [ ] R-317 Every loader returns typed errors with bounded allocation and never panics
- [ ] R-318 `progs.dat` v6 loader with CRC check; every opcode with checked operands
- [ ] R-319 Vanilla builtins with confined file access and an allowlist for content-issued commands
- [ ] R-320 Instruction budget (100 000 default) and a run error that never commits a partial call
- [ ] R-321 Fuzz targets for every loader and the VM with a minimised regression corpus
- [ ] R-322 `tharsis-tools` PAK, BSP and progs inspection with `--json`

## M2 — Simulation and gameplay

- [ ] R-323 C-faithful float helpers: explicit promotion, no fused multiply-add, enforced by lint
- [ ] R-324 Edict arena with vanilla layout, free-list reuse and field-offset checks
- [ ] R-325 Hull tracing, point contents, area-node linking and vanilla touch order
- [ ] R-326 Movetypes, pushers, water, player movement and client think
- [ ] R-327 Spawning, level change, difficulty, secrets, intermission, episodes and endings
- [ ] R-328 Fixed 72 Hz server on its own thread, with catch-up cap and pause on suspend
- [ ] R-329 Protocol 15 loopback over bounded queues; reliable messages never dropped
- [ ] R-330 Headless scripted runner with seeds, time-step sequences and first-divergence trace diff
- [ ] R-331 Free-data corpus passes the M0 fidelity contract against the oracle

## M3 — Client and reference renderer

- [ ] R-332 Client messages, interpolation, temporary entities, beams, particles, light styles and dynamic lights
- [ ] R-333 Command buffer, cvars, aliases, `exec`, `config.cfg`, `autoexec.cfg` and bindings
- [ ] R-334 Console, HUD, centre prints, keyboard-complete menus, intermission and finale screens
- [ ] R-335 No-data screen with a directory picker, in the `steelbore` theme
- [ ] R-336 Software renderer port: edges, spans, surface cache, sky, warp, models, sprites, particles, blends
- [ ] R-337 Headless software capture passes exact palette-index checks on frozen oracle scenes
- [ ] R-338 Tier 0 presentation through softbuffer, independent of wgpu
- [ ] R-339 Remappable keyboard and mouse, HUD scaling and reduced flash and motion options
- [ ] R-340 Gamepad input (optional)

## M4 — Rust GPU renderer

- [ ] R-341 `tharsis-shade` shared functions with CPU unit tests, used by the software renderer
- [ ] R-342 GPU compute harness matches CPU shade results over boundary and random inputs
- [ ] R-343 Committed SPIR-V and WGSL regenerated and compared in CI; layout and alignment tests
- [ ] R-344 Capability probe, logged report, automatic tier choice and forced tier switches
- [ ] R-345 Tier 1: world and lightmap atlas uploaded once; models, sprites, particles, sky, liquids, view model, HUD
- [ ] R-346 Light styles and dynamic lights on the GPU with classic falloff; no CPU lightmap rebuilds
- [ ] R-347 Alias-model interpolation and instancing in the vertex shader
- [ ] R-348 Tier 2 compute culling into bounded indirect draws with preflight and same-frame fallback
- [ ] R-349 Tier 2 enabled automatically only for adapter classes that pass the adoption gate
- [ ] R-350 Classic and Enhanced presets; Classic passes frozen thresholds; traces unchanged
- [ ] R-351 Binding arrays where supported; material batching otherwise
- [ ] R-352 GPU timestamps where supported, CPU fallback metrics, shader warm-up, safe pipeline cache
- [ ] R-353 Device-loss recovery: one bounded rebuild, then Tier 0 or save-and-exit
- [ ] R-354 Uncapped rendering with interpolation, decoupled from the server tick
- [ ] R-355 Parallel command encoding, kept only if benchmarked faster (optional)

## M5 — Audio, saves and demos

- [ ] R-356 Audio thread on a bounded lock-free queue; no I/O, locks or allocation in the callback
- [ ] R-357 Sound effects with vanilla channels, attenuation, ambient and static sounds, spatialisation
- [ ] R-358 Music from `music/` via symphonia, independent volumes, silent fallback
- [ ] R-359 Vanilla saves with atomic writes; corrupt saves refused and the previous one kept
- [ ] R-360 Protocol 15 demo playback and recording; timedemo with a versioned JSON report
- [ ] R-361 Built-in demos play on shareware and registered data
- [ ] R-362 Fuzz targets for demos, saves and config scripts

## M6 — Community formats and limits

- [ ] R-363 BSP2 and 2PSB loaders with fuzz targets
- [ ] R-364 Protocol 666 for loopback and demos; protocol 999 only if the manifest requires it
- [ ] R-365 Raised limits from the M0 table, each bounded with a diagnostic
- [ ] R-366 Fog, skyboxes, entity alpha and `.lit` lighting in both presets and Tier 0
- [ ] R-367 Corpus releases completed locally with recorded evidence and known deviations
- [ ] R-368 Corpus performance measured on the reference machines against approved targets

## M7 — Windows, macOS and browser

- [ ] R-369 Windows build on DX12 passes golden scenes and input, audio and filesystem tests
- [ ] R-370 macOS build on Metal passes golden scenes and input, audio and filesystem tests
- [ ] R-371 Browser build with the server in a Web Worker and no `SharedArrayBuffer` requirement
- [ ] R-372 Browser data picked by the player and kept only in local browser storage; no network fetch
- [ ] R-373 Browser saves, configs and demos in local storage with export and import
- [ ] R-374 Browser Tier 1 and Tier 2 pass golden scenes in the pinned browsers
- [ ] R-375 Browser audio through WebAudio and input with pointer lock
- [ ] R-376 Browser bundle size and start-up measured against approved targets
- [ ] R-377 Per-platform data paths implemented and documented

## M8 — Validation and v0.1 release

- [ ] R-378 Every MVP map completed on all four platforms (registered and corpus data locally)
- [ ] R-379 Fidelity, visual, shader, fuzz, save and demo suites pass in the release configuration
- [ ] R-380 Performance results against approved targets; each miss resolved or approved
- [ ] R-381 Texinfo user manual `doc/tharsis.texi` building to Info, HTML and PDF
- [ ] R-382 Guix, Nix and Arch packages on stable Rust with `install-info`; clean installs verified
- [ ] R-383 Windows and macOS archives and browser bundle with checksums and source offer
- [ ] R-384 `--help` and `--version` per `spacecraft-cli-standard` with §15 attribution
- [ ] R-385 SBOM, `cargo audit`, `cargo deny`, release flags noted and benchmarked
- [ ] R-386 Signed release tag with notes listing known anomalies and the conformance claim

## M9 — Mission packs and re-release

- [ ] R-387 *Scourge of Armagon* engine behaviour, HUD and endings
- [ ] R-388 *Dissolution of Eternity* engine behaviour, HUD and endings
- [ ] R-389 2021 re-release data and its QuakeC extensions (optional)
- [ ] R-390 External replacement textures (optional)

## M10 — GPU experiments: optional only

Every item here is optional, so this milestone has no required work and reports 100 percent for that reason alone. Each experiment is capability-gated, off by default, and must be removable without affecting saves, simulation or Tier 1.

- [ ] R-391 Mesh-shader world rendering benchmarked against Tier 2 (optional)
- [ ] R-392 Ray-query shadows and ambient occlusion with acceleration-structure budgets (optional)
- [ ] R-393 Path-traced lighting with denoising and history reset on cuts (optional)
- [ ] R-394 HDR display output with an SDR fallback and a luminance policy (optional)
- [ ] R-395 CubeCL for load-time compute, kept only if measured faster (optional)

## M11 — Network play

- [ ] R-396 Licence (AGPL), assurance category and threat model reviewed before any listener
- [ ] R-397 NetQuake UDP client and server interoperating on protocols 15 and 666
- [ ] R-398 Cooperative and deathmatch tested under latency, loss and malformed packets
- [ ] R-399 Confined headless server with rate limits; legacy protocol documented as unauthenticated
- [ ] R-400 Browser multiplayer transport (optional)

## Risks

| Risk | Impact | Likelihood | Mitigation |
|----|----|----|----|
| Rust GPU lacks a needed feature or backend translation | High | Medium | M0 gate on every platform; committed artifacts; written WGSL fallback decision |
| SPIR-V to WGSL translation fails for the browser | High | Medium | Browser is a named gate target in R-309; Tier 1 shaders kept simple |
| Fidelity drift through floats, order or timing | High | High | Transliteration keeps expression shape; no-FMA lint; command-driven oracle from M0; first-divergence diff |
| Four platforms in the MVP multiply testing | High | High | CI builds every target from M0; one reference machine per platform; platform work concentrated in M7 |
| Browser storage or WebGPU behaviour differs between browsers | Medium | High | Pinned browser versions; Tier 0 canvas fallback; export and import of saves |
| Community corpus needs extensions beyond QuakeSpasm level | Medium | Medium | Manifest records each need in M0; anything beyond NG-2 is a scope decision |
| GPU-driven path slower on small maps or integrated GPUs | Medium | Medium | Tier 1 default unless the adoption gate passes |
| Malicious mods attack the VM or filesystem | High | Medium | Checked operands, budget, confinement, allowlist, fuzzing |
| Registered and corpus data cannot enter public CI | Medium | Certain | Fixtures and LibreQuake in CI; scripted local acceptance gate |
| Experimental wgpu APIs change | Low | High | Confined to M10, off by default, wgpu pinned |
| Trademark complaint | Medium | Low | Codename, no assets, no logos, disclaimer |

## Open questions

| ID | Question | Recommendation |
|----|----|----|
| OQ-301 | Which machines and browsers are the references? Resolve in M0 (R-313). | An integrated Linux laptop, the maintainer’s discrete workstation, one Windows and one Apple-silicon machine, current Chromium and Firefox |
| OQ-302 | Which LibreQuake release and subset, and may shareware data enter public CI? Resolve in M0 (R-311). | Prefer project fixtures plus audited LibreQuake; shareware only if its terms clearly allow CI use |
| OQ-303 | Does the corpus need protocol 999? Resolve in M0. | Add it only if a corpus map needs it |
| OQ-304 | Should Windows and macOS releases be code-signed or notarised? Resolve before M8. | Ship unsigned with checksums for v0.1; revisit if friction is high |
| OQ-305 | May code be adapted from QuakeSpasm (GPL-2.0-or-later)? Resolve per file. | Yes, after notice review and with file-level credit |
| OQ-306 | Should a hosted web page come later? Not before v0.1 (NG-4). | Revisit after release; it would need a §15.1 subdomain |

## Sources

### Drafts merged

All are archived unchanged in `docs/drafts/`.

- `PRD-v1.0.md`, the former `PRD.md` (Claude): crate layout, Rust GPU with committed shader artifacts, GPU light styles, fixed 72 Hz tick. Its R-001 to R-118 identifiers are retired.
- `PRD-Rust-GPU.texi`, version 1.2-draft: capability tiers, the M0 shader gate, the event-and-tolerance fidelity contract, the Tier 2 adoption gate, indirect-buffer overflow rules, performance method.
- `PRD-rust-gpu.texi`, version 0.1.0: product scope and user stories, threat model, presets, SDR and HDR policy, soak target, rejected defaults.
- `ProductRequirementsDocumentQuakeRS_CodenameSl.html` (Slipgate): browser play, community formats, GPU light and particle ideas, a ray-tracing vision. Its statement that Rust GPU was archived refers to the old Embark repository; the Rust-GPU project released `spirv-std` 0.11.0 on 2026-10-13.
- `quake-by-qwen.md`: personas, multiplayer and speedrun requirements, bug compatibility toggles, feature policy for advanced GPU work.

### Research

- id Software, [Quake GPL source release](https://github.com/id-Software/Quake); its `readme.txt` separates GPL code from game data.
- [wgpu](https://wgpu.rs/) 30.0.1, released 2026-08-22, and its [feature list](https://docs.rs/wgpu/30.0.1/wgpu/struct.Features.html).
- [Rust GPU](https://github.com/Rust-GPU/rust-gpu) and `cargo-gpu`; `spirv-std` 0.11.0, released 2026-10-13.
- [CubeCL](https://github.com/tracel-ai/cubecl) 0.11.3, released 2026-10-22.
- [LibreQuake](https://github.com/lavenderdotpet/LibreQuake).
- QuakeSpasm, vkQuake and Ironwail as references for limits, protocol 666 and GPU-driven rendering.
- Prior Rust art: [Richter](https://github.com/cormac-obrien/richter), [Seismon](https://github.com/eira-fransham/seismon), and Quake-SRP ([write-up](https://runtimewire.com/article/quake-srp-rust-port-claude-browser)).
- *Phobos — PRD* (`doom-rs/PRD.md`), the sibling id Tech port.
- The Steelbore Standard v2.14, §2, §3, §4, §9, §17.5, §18.5, §19 and §24.
