\# Product Requirements Document    
\#\# Project: \`quake-rs\` — A Modern Rust Port of the Quake Engine Using Modern Rust GPU Technologies

\*\*Date:\*\* 2026-10-28    
\*\*Status:\*\* Draft v0.1    
\*\*Owner:\*\* Engine / Core Team    
\*\*Classification:\*\* Unofficial fan / community project    
\*\*Working Title:\*\* \`quake-rs\`    
\*\*Licensing Placeholder:\*\* MIT OR Apache-2.0 if clean-room; GPL-compatible if derived from GPL Quake source  

\---

\#\# 1\. Executive Summary

\`quake-rs\` is an unofficial Rust reimplementation of the classic Quake engine, focused on preserving the original gameplay, mod compatibility, and speedrunning utility while modernizing the rendering stack using current Rust GPU technologies.

The product will allow users to play legally owned Quake content, run classic maps and mods, record and play back demos, and host or join multiplayer games. Its renderer will be built primarily on \*\*\`wgpu\`\*\* and the broader Rust GPU ecosystem, enabling cross-platform GPU access through Vulkan, DirectX 12, Metal, OpenGL where needed, and WebGPU.

Unlike a minimal source port, \`quake-rs\` will take advantage of modern GPU capabilities where appropriate: GPU-driven culling, indirect drawing, compute-based light and particle systems, high-resolution texture support, optional dynamic lighting, optional ray-traced effects where hardware supports them, and modern upscaling/presentation features.

The project’s core principle is:

\> \*\*Classic Quake gameplay first, modern GPU rendering second.\*\*    
\> Enhancements must not break original movement, physics, mod behavior, demo compatibility, or map author intent unless explicitly toggled by the user.

\---

\#\# 2\. Problem Statement and Opportunity

\#\#\# 2.1 Problem

The original Quake engine is historically important, but its original renderer and architecture are constrained by late-1990s CPU/software rendering assumptions. Existing ports are mature and valuable, but many are written in C and are not structured around modern GPU-first rendering, safe parsing, Rust tooling, or WebGPU deployment.

There is an opportunity to create a Rust-based Quake engine that provides:

\- Memory-safe handling of untrusted assets, demos, mods, and network messages.  
\- A modern GPU rendering pipeline using \`wgpu\`, WGSL, compute shaders, and GPU-driven rendering.  
\- Strong cross-platform support, including desktop and potentially browser deployment via WebGPU.  
\- A clean, modular engine architecture suitable for experimentation, research, education, and community development.  
\- Modern rendering enhancements without compromising original compatibility.

\#\#\# 2.2 Opportunity

Rust’s GPU ecosystem in 2026 is mature enough for a project like this:

\- \`wgpu\` provides safe, portable GPU abstraction across Vulkan, DX12, Metal, OpenGL, and WebGPU.  
\- WGSL and \`naga\` enable cross-platform shader development.  
\- Rust compute shaders can be used for culling, lighting, particles, and model animation.  
\- \`ash\` and Vulkan extensions can be used for advanced desktop features such as ray tracing, mesh shaders, and bindless-style resource access where appropriate.  
\- Rust’s safety model is especially valuable for parsing legacy PAK/BSP/MDL/demo/network formats.

This creates an opportunity to build a Quake-compatible engine that is both faithful and future-looking.

\---

\#\# 3\. Vision

\`quake-rs\` will be a safe, portable, high-performance Rust engine for classic Quake content that:

1\. Plays the original game faithfully.  
2\. Supports mods, maps, and QuakeC behavior to the greatest practical extent.  
3\. Uses modern GPU rendering as a first-class design element.  
4\. Is easy to build from source using stable Rust and standard tooling.  
5\. Is suitable for speedrunning, casual play, mod development, multiplayer, and engine experimentation.  
6\. Can optionally run in the browser through WebGPU with a reduced feature set.

\---

\#\# 4\. Goals

\#\#\# 4.1 Primary Goals

\- Faithful Quake gameplay and physics.  
\- Support for original PAK assets and QuakeC \`progs.dat\`.  
\- Modern GPU renderer built on \`wgpu\`.  
\- Cross-platform desktop support: Windows, Linux, macOS.  
\- Safe parsing of legacy formats.  
\- Multiplayer support compatible with classic Quake/QuakeWorld expectations where feasible.  
\- Demo recording and playback.  
\- Mod compatibility.  
\- High-frame-rate, low-latency rendering.  
\- Optional enhanced rendering features that can be disabled.

\#\#\# 4.2 Secondary Goals

\- WebGPU browser playback for demos or limited single-player content.  
\- GPU-driven rendering pipeline for scalability.  
\- Optional ray tracing and upscaling features.  
\- Modern developer tooling: console, debug overlays, render passes, profiling.  
\- Headless dedicated server support.  
\- Support for community texture/model/music replacement packs.

\#\#\# 4.3 Non-Goals for Initial Release

\- Full ray-traced remake as the default experience.  
\- Quake II, Quake III, or other id Tech engine support.  
\- Official endorsement by id Software, Bethesda, or Microsoft.  
\- Distribution of proprietary Quake assets.  
\- Console release in the first version.  
\- VR support in the first version.  
\- A complete visual redesign of original maps and models.  
\- New gameplay or weapon systems outside compatibility requirements.

\---

\#\# 5\. Target Users and Personas

\#\#\# 5.1 Classic Player

Wants to play original Quake or purchased content with modern resolutions, high frame rates, and quality-of-life options.

\*\*Needs:\*\*

\- Easy setup.  
\- Original campaign support.  
\- Stable performance.  
\- Mouse/keyboard input.  
\- Save/load.  
\- Music and sound.

\#\#\# 5.2 Speedrunner / Demos User

Wants deterministic behavior, accurate physics, demo recording/playback, and low-latency input.

\*\*Needs:\*\*

\- Demo compatibility or predictable demo behavior.  
\- Fixed timestep simulation.  
\- Frame pacing controls.  
\- Command-line control.  
\- Timer/speedometer options.  
\- Minimal input latency.

\#\#\# 5.3 Modder / Map Tester

Wants to test custom maps, mods, and QuakeC behavior.

\*\*Needs:\*\*

\- PAK loading.  
\- Custom map support.  
\- QuakeC VM compatibility.  
\- Console commands.  
\- Hot reload or fast iteration.  
\- Detailed logging.

\#\#\# 5.4 Multiplayer User

Wants to join classic or QuakeWorld-style servers.

\*\*Needs:\*\*

\- Stable UDP networking.  
\- Client prediction where applicable.  
\- Server browser or direct connect.  
\- Low-latency interpolation.  
\- Compatibility with common protocol expectations.

\#\#\# 5.5 Engine Developer / Rust Graphics Enthusiast

Wants a modern Rust engine codebase to study or extend.

\*\*Needs:\*\*

\- Clean module separation.  
\- \`wgpu\`-based renderer.  
\- WGSL shader workflows.  
\- Profiling and debug overlays.  
\- Safe parsing and testing infrastructure.

\---

\#\# 6\. Product Principles

1\. \*\*Compatibility before enhancement.\*\*    
   Gameplay and mod behavior must not be sacrificed for visual novelty.

2\. \*\*GPU-first, but portable.\*\*    
   The renderer should be designed for modern GPUs while gracefully degrading on weaker or browser-based hardware.

3\. \*\*Safety around untrusted data.\*\*    
   PAK files, maps, models, demos, network packets, and QuakeC bytecode must be parsed defensively.

4\. \*\*Determinism where it matters.\*\*    
   Simulation, input, and demo systems should be deterministic within a given engine build and configuration.

5\. \*\*Optional modernization.\*\*    
   Enhanced rendering must be toggleable and must not corrupt original content behavior.

6\. \*\*No proprietary asset redistribution.\*\*    
   The engine must not ship id Software’s proprietary assets.

7\. \*\*Rust idioms without excessive purism.\*\*    
   Use safe Rust by default. Unsafe may be used only where necessary for GPU, OS, or performance-critical interop and must be isolated and reviewed.

\---

\#\# 7\. Scope

\#\#\# 7.1 In Scope

\- Rust engine core.  
\- Renderer using \`wgpu\`.  
\- Original Quake content compatibility.  
\- PAK file loading.  
\- BSP map loading and rendering.  
\- MDL alias model rendering.  
\- Sprite rendering.  
\- Lightmap support.  
\- QuakeC VM for \`progs.dat\`.  
\- Sound and music playback.  
\- Input handling.  
\- Console and command system.  
\- Save/load.  
\- Demo recording/playback.  
\- Single-player and multiplayer.  
\- Headless dedicated server.  
\- Modern GPU rendering features behind toggles.  
\- Basic WebGPU experimental support.

\#\#\# 7.2 Out of Scope for v1

\- Full Quake II/III support.  
\- Official trademark-branded product.  
\- Built-in content editor.  
\- Full mod creation SDK.  
\- Native mobile ports.  
\- Console ports.  
\- VR.  
\- Ray tracing as a required feature.  
\- AI-generated or remixed assets.

\---

\#\# 8\. Functional Requirements

Priorities:

\- \*\*P0:\*\* Required for minimum viable release.  
\- \*\*P1:\*\* Important for full product quality.  
\- \*\*P2:\*\* Desirable, may be post-release.

\#\#\# 8.1 Content and Asset Compatibility

\| ID \| Requirement \| Priority \|  
\|---\|---\|---\|  
\| FR-ASSET-01 \| Load original Quake \`.PAK\` archives provided by the user. \| P0 \|  
\| FR-ASSET-02 \| Support directory-based mod loading and PAK search-path ordering. \| P0 \|  
\| FR-ASSET-03 \| Parse BSP map data, including entities, geometry, textures, lightmaps, collision hulls, and visibility data. \| P0 \|  
\| FR-ASSET-04 \| Parse MDL alias models, including animation frames and skins. \| P0 \|  
\| FR-ASSET-05 \| Parse sprites. \| P0 \|  
\| FR-ASSET-06 \| Parse original sound assets. \| P0 \|  
\| FR-ASSET-07 \| Support external music replacement, such as OGG/FLAC/WAV tracks. \| P1 \|  
\| FR-ASSET-08 \| Support texture replacement packs. \| P1 \|  
\| FR-ASSET-09 \| Support model replacement packs. \| P2 \|  
\| FR-ASSET-10 \| Provide an asset cache to preprocess or upload GPU resources efficiently. \| P1 \|  
\| FR-ASSET-11 \| Do not ship proprietary assets with the engine. \| P0 \|

\#\#\# 8.2 Gameplay and Simulation

\| ID \| Requirement \| Priority \|  
\|---\|---\|---\|  
\| FR-GAME-01 \| Implement classic Quake movement and physics behavior. \| P0 \|  
\| FR-GAME-02 \| Implement fixed-timestep simulation. Default target should be classic-compatible, with configurable tick rate. \| P0 \|  
\| FR-GAME-03 \| Support original entity behavior through QuakeC VM. \| P0 \|  
\| FR-GAME-04 \| Support triggers, doors, plats, monsters, items, projectiles, and ambient entities. \| P0 \|  
\| FR-GAME-05 \| Support original save/load semantics, with modern serialization if strict compatibility is impractical. \| P1 \|  
\| FR-GAME-06 \| Preserve original gameplay bugs only when needed for compatibility; provide a toggle for bug-compatible mode where feasible. \| P2 \|  
\| FR-GAME-07 \| Support intermission, episode selection, and end-game flow. \| P0 \|  
\| FR-GAME-08 \| Support console commands essential to gameplay and testing. \| P0 \|  
\| FR-GAME-09 \| Support command-line options for content path, map launch, resolution, and configuration execution. \| P0 \|

\#\#\# 8.3 QuakeC and Mod Compatibility

\| ID \| Requirement \| Priority \|  
\|---\|---\|---\|  
\| FR-QC-01 \| Implement a QuakeC virtual machine capable of executing original \`progs.dat\`. \| P0 \|  
\| FR-QC-02 \| Support QuakeC globals, functions, built-ins, strings, floats, vectors, entities, and edicts. \| P0 \|  
\| FR-QC-03 \| Isolate QuakeC execution from engine internals. \| P0 \|  
\| FR-QC-04 \| Prevent infinite loops or runaway QuakeC execution via configurable instruction budgeting. \| P0 \|  
\| FR-QC-05 \| Support common mod-required QuakeC extensions where practical. \| P2 \|  
\| FR-QC-06 \| Provide compatibility profiles for popular mods and mission packs. \| P1 \|  
\| FR-QC-07 \| Support FTEQW-style CSQC only if it does not jeopardize core stability. \| P2 \|

\#\#\# 8.4 Rendering and GPU

\| ID \| Requirement \| Priority \|  
\|---\|---\|---\|  
\| FR-RENDER-01 \| Render original Quake maps, models, sprites, particles, and UI using a GPU-based renderer. \| P0 \|  
\| FR-RENDER-02 \| Use \`wgpu\` as the primary GPU abstraction layer. \| P0 \|  
\| FR-RENDER-03 \| Support Vulkan, DirectX 12, and Metal through \`wgpu\` where available. \| P0 \|  
\| FR-RENDER-04 \| Support OpenGL or compatibility fallback only if needed for platform coverage. \| P2 \|  
\| FR-RENDER-05 \| Support WebGPU as an experimental target. \| P1 \|  
\| FR-RENDER-06 \| Author primary shaders in WGSL and compile/translate through \`naga\`. \| P0 \|  
\| FR-RENDER-07 \| Support original lightmapped world rendering. \| P0 \|  
\| FR-RENDER-08 \| Support fullbright textures. \| P0 \|  
\| FR-RENDER-09 \| Support animated textures and liquids. \| P0 \|  
\| FR-RENDER-10 \| Support original fog where applicable. \| P1 \|  
\| FR-RENDER-11 \| Support dynamic lights with behavior compatible enough for original gameplay. \| P1 \|  
\| FR-RENDER-12 \| Support alpha-translucent surfaces such as water and windows. \| P0 \|  
\| FR-RENDER-13 \| Support sky rendering, including scrolling and skybox-style behavior where used. \| P0 \|  
\| FR-RENDER-14 \| Support viewmodel rendering with correct original behavior. \| P0 \|  
\| FR-RENDER-15 \| Support GPU-based alias model frame interpolation as an optional enhancement. \| P1 \|  
\| FR-RENDER-16 \| Support GPU-driven culling and indirect draw submission where hardware supports it. \| P1 \|  
\| FR-RENDER-17 \| Support high-resolution texture filtering and anisotropic filtering. \| P1 \|  
\| FR-RENDER-18 \| Support render scale and resolution controls. \| P0 \|  
\| FR-RENDER-19 \| Support VSync, frame limiter, and low-latency presentation options. \| P0 \|  
\| FR-RENDER-20 \| Support screenshots. \| P0 \|  
\| FR-RENDER-21 \| Support optional post-processing: FXAA/TAA, film grain off by default, color correction, and gamma. \| P1 \|  
\| FR-RENDER-22 \| Support optional upscaling such as FSR-style temporal upscaling where practical. \| P2 \|  
\| FR-RENDER-23 \| Support optional ray-traced shadows/reflections/GI only as an advanced experimental feature. \| P2 \|  
\| FR-RENDER-24 \| Provide graphics presets: Original, Enhanced, Ultra, and Experimental RT. \| P1 \|  
\| FR-RENDER-25 \| Provide GPU diagnostics: device name, backend, feature level, frame time, draw count, and GPU timings. \| P1 \|

\#\#\# 8.5 GPU Technology Requirements

\| ID \| Requirement \| Priority \|  
\|---\|---\|---\|  
\| FR-GPU-01 \| Renderer architecture must be data-oriented and GPU-friendly: batched resources, indirect drawing, and minimal CPU-side per-object overhead. \| P1 \|  
\| FR-GPU-02 \| Use compute shaders for at least one major rendering task, such as culling, light clustering, particle simulation, or model interpolation. \| P1 \|  
\| FR-GPU-03 \| Use GPU buffer uploads with staging buffers or queue-write strategies suitable for \`wgpu\`. \| P0 \|  
\| FR-GPU-04 \| Use indirect draw command generation where supported. \| P1 \|  
\| FR-GPU-05 \| Support timestamp queries or equivalent GPU profiling where available. \| P1 \|  
\| FR-GPU-06 \| Use bindless-style descriptor patterns only where supported; provide fallback bind group paths. \| P2 \|  
\| FR-GPU-07 \| Support optional Vulkan-specific advanced features through an \`ash\`-based extension layer without requiring Vulkan for baseline operation. \| P2 \|  
\| FR-GPU-08 \| Evaluate \`rust-gpu\` for experimental Rust-authored shaders, but do not make it a hard dependency for v1. \| P2 \|  
\| FR-GPU-09 \| Maintain a WebGPU-compatible renderer subset that avoids unsupported features. \| P1 \|  
\| FR-GPU-10 \| Recover gracefully from GPU device loss or shader compilation failure. \| P0 \|

\#\#\# 8.6 Audio

\| ID \| Requirement \| Priority \|  
\|---\|---\|---\|  
\| FR-AUDIO-01 \| Play original Quake sound effects. \| P0 \|  
\| FR-AUDIO-02 \| Support positional audio, attenuation, and volume mixing. \| P0 \|  
\| FR-AUDIO-03 \| Support music playback from replacement tracks. \| P1 \|  
\| FR-AUDIO-04 \| Support CD-audio fallback behavior only where legal and practical. \| P2 \|  
\| FR-AUDIO-05 \| Provide master, effects, and music volume controls. \| P0 \|  
\| FR-AUDIO-06 \| Maintain low-latency output suitable for fast gameplay. \| P0 \|  
\| FR-AUDIO-07 \| Optional HRTF or spatialization enhancement. \| P2 \|

\#\#\# 8.7 Input

\| ID \| Requirement \| Priority \|  
\|---\|---\|---\|  
\| FR-INPUT-01 \| Support keyboard and mouse input. \| P0 \|  
\| FR-INPUT-02 \| Support raw or relative mouse input with configurable sensitivity. \| P0 \|  
\| FR-INPUT-03 \| Support rebinding of keys and mouse buttons. \| P0 \|  
\| FR-INPUT-04 \| Support high-DPI mice and OS display scaling. \| P1 \|  
\| FR-INPUT-05 \| Support optional mouse acceleration controls, disabled by default. \| P1 \|  
\| FR-INPUT-06 \| Support gamepad input as an optional enhancement. \| P2 \|  
\| FR-INPUT-07 \| Input sampling must not block rendering or simulation. \| P0 \|

\#\#\# 8.8 Networking and Multiplayer

\| ID \| Requirement \| Priority \|  
\|---\|---\|---\|  
\| FR-NET-01 \| Support local single-player. \| P0 \|  
\| FR-NET-02 \| Support LAN and internet multiplayer over UDP. \| P1 \|  
\| FR-NET-03 \| Support listen servers. \| P1 \|  
\| FR-NET-04 \| Support headless dedicated servers. \| P1 \|  
\| FR-NET-05 \| Support classic NetQuake-compatible behavior where feasible. \| P1 \|  
\| FR-NET-06 \| Support QuakeWorld-style client prediction and server reconciliation where feasible. \| P1 \|  
\| FR-NET-07 \| Support IPv4; IPv6 support is desired. \| P1 \|  
\| FR-NET-08 \| Validate all network messages defensively. \| P0 \|  
\| FR-NET-09 \| Support direct IP connect via console/command line. \| P0 \|  
\| FR-NET-10 \| Server browser is optional for v1. \| P2 \|  
\| FR-NET-11 \| Anti-cheat is out of scope for v1, but server-authoritative design should be maintained. \| P0 \|

\#\#\# 8.9 Demos and Speedrunning

\| ID \| Requirement \| Priority \|  
\|---\|---\|---\|  
\| FR-DEMO-01 \| Record demos. \| P1 \|  
\| FR-DEMO-02 \| Play back demos. \| P1 \|  
\| FR-DEMO-03 \| Support classic demo formats best-effort. \| P2 \|  
\| FR-DEMO-04 \| Support timedemo benchmarking. \| P1 \|  
\| FR-DEMO-05 \| Provide deterministic simulation for a fixed engine build and configuration. \| P1 \|  
\| FR-DEMO-06 \| Provide speedometer and timer options. \| P2 \|  
\| FR-DEMO-07 \| Do not allow enhanced rendering features to alter simulation or demo timing. \| P0 \|

\#\#\# 8.10 User Interface and Console

\| ID \| Requirement \| Priority \|  
\|---\|---\|---\|  
\| FR-UI-01 \| Provide a main menu with Play, Options, Multiplayer, and Quit. \| P0 \|  
\| FR-UI-02 \| Provide in-game console with command history and autocomplete. \| P0 \|  
\| FR-UI-03 \| Provide graphics settings UI. \| P0 \|  
\| FR-UI-04 \| Provide audio settings UI. \| P0 \|  
\| FR-UI-05 \| Provide input settings UI. \| P0 \|  
\| FR-UI-06 \| Provide accessibility options such as UI scaling and readable fonts. \| P2 \|  
\| FR-UI-07 \| Support original-style menu behavior where practical. \| P1 \|  
\| FR-UI-08 \| Provide a debug overlay showing FPS, frame time, GPU backend, and draw statistics. \| P1 \|

\#\#\# 8.11 Configuration and Persistence

\| ID \| Requirement \| Priority \|  
\|---\|---\|---\|  
\| FR-CFG-01 \| Support configuration persistence. \| P0 \|  
\| FR-CFG-02 \| Support console-variable style configuration compatible with Quake workflows. \| P1 \|  
\| FR-CFG-03 \| Support separate modern settings file if needed for features not expressible in classic config. \| P1 \|  
\| FR-CFG-04 \| Support command-line options for common settings. \| P0 \|

\---

\#\# 9\. GPU Technology Strategy

This section defines how \`quake-rs\` will use modern Rust GPU technologies.

\#\#\# 9.1 Primary GPU Stack

\| Technology \| Role \| Maturity Assumption \| Adoption \|  
\|---\|---\|---\|---\|  
\| \`wgpu\` \| Primary safe GPU abstraction and rendering API. \| Mature in 2026 \| Required \|  
\| WGSL \| Primary shader language for portability. \| Mature with \`wgpu\` \| Required \|  
\| \`naga\` \| Shader translation/validation for WGSL/SPIR-V/MSL/HLSL/GLSL as needed. \| Mature \| Required \|  
\| \`ash\` \| Optional low-level Vulkan access for advanced extensions. \| Mature \| Optional \|  
\| \`rust-gpu\` \| Experimental Rust-authored shaders compiled to SPIR-V. \| Evolving/experimental \| Evaluate only \|  
\| \`egui\` \+ \`wgpu\` \| Debug UI, console, menus, overlays. \| Mature \| Recommended \|  
\| GPU timestamp queries \| Frame and pass profiling. \| Backend-dependent \| Recommended \|  
\| RenderDoc / PIX / Xcode GPU capture \| External GPU debugging. \| Mature \| Required workflow \|

\#\#\# 9.2 Rendering Philosophy

The renderer should not be a direct translation of the original software renderer. Instead, it should preserve the visual and gameplay semantics while restructuring data for GPUs.

Core design ideas:

1\. \*\*World geometry is converted into GPU-friendly meshes.\*\*  
   \- BSP surfaces become batched static meshes.  
   \- Texture and lightmap coordinates are precomputed.  
   \- Original surface order and transparency semantics are preserved where needed.

2\. \*\*Visibility is hybrid CPU/GPU.\*\*  
   \- CPU uses PVS to generate candidate surfaces/entities.  
   \- GPU compute performs frustum culling, optional occlusion culling, and indirect argument generation.

3\. \*\*Animation is GPU-friendly.\*\*  
   \- Alias model frames are uploaded as vertex data.  
   \- Vertex shaders or compute shaders perform frame interpolation.

4\. \*\*Particles can be GPU-simulated.\*\*  
   \- A GPU particle path may be used for enhanced mode.  
   \- A CPU-compatible or deterministic path must exist where gameplay/demo correctness matters.

5\. \*\*Lighting is layered.\*\*  
   \- Baseline: original lightmaps.  
   \- Enhanced: clustered or tiled forward dynamic lights.  
   \- Experimental: ray-traced shadows/reflections/GI.

\#\#\# 9.3 Feature Tiers

\#\#\#\# Tier 0 — Compatibility / WebGPU Baseline

Required for all supported platforms.

\- \`wgpu\` forward renderer.  
\- Static world meshes.  
\- Lightmapped rendering.  
\- Basic alpha blending.  
\- Sprites and alias models.  
\- Simple particles.  
\- No required compute features beyond what \`wgpu\` baseline supports.  
\- Suitable for integrated GPUs and browsers.

\#\#\#\# Tier 1 — Modern Desktop

Target for normal desktop releases.

\- GPU-driven indirect drawing where supported.  
\- Compute-based frustum culling.  
\- GPU model interpolation.  
\- Clustered dynamic lights.  
\- Improved texture streaming and mipmapping.  
\- Optional TAA/FXAA.  
\- Optional render-scale upscaling.

\#\#\#\# Tier 2 — Advanced Experimental

Optional features for high-end hardware.

\- Vulkan-specific extensions via \`ash\`.  
\- Mesh shaders where beneficial.  
\- Bindless-style descriptor indexing.  
\- Ray-traced shadows/reflections/GI where supported.  
\- Advanced upscaling integration.  
\- Hi-Z occlusion culling.  
\- GPU-driven particle systems with advanced sorting.

\#\#\# 9.4 Proposed Render Pass Structure

A high-level frame graph may look like:

1\. \*\*Scene Upload\*\*  
   \- Entity transforms.  
   \- Light data.  
   \- View data.  
   \- PVS candidate list.  
   \- Dynamic buffer updates.

2\. \*\*GPU Culling\*\*  
   \- Frustum culling.  
   \- Optional Hi-Z occlusion culling.  
   \- Generate indirect draw arguments.

3\. \*\*Shadow Pass\*\*  
   \- Optional cascaded or voxel shadows in enhanced mode.  
   \- Optional ray-traced shadows in experimental mode.

4\. \*\*Opaque World Pass\*\*  
   \- Static BSP meshes.  
   \- Alias models.  
   \- Opaque sprites.

5\. \*\*Sky Pass\*\*  
   \- Classic sky rendering.  
   \- Optional enhanced sky handling.

6\. \*\*Lighting / Dynamic Light Pass\*\*  
   \- Lightmap-only mode, or  
   \- Clustered forward dynamic lighting.

7\. \*\*Translucent Pass\*\*  
   \- Water, windows, translucent sprites, particles.  
   \- Sort according to original expectations where necessary.

8\. \*\*Post-Processing\*\*  
   \- Gamma.  
   \- Optional anti-aliasing.  
   \- Optional upscaling.  
   \- Optional color grading.

9\. \*\*UI / Console / HUD\*\*  
   \- egui or custom GPU UI.  
   \- Crosshair, menus, console.

\#\#\# 9.5 Shader Strategy

Primary path:

\- WGSL for all baseline shaders.  
\- \`naga\` handles backend translation.  
\- Feature-flagged shader permutations to avoid runtime branch overhead.

Experimental path:

\- \`rust-gpu\` may be used for selected compute passes if it provides maintainability or performance benefits.  
\- SPIR-V shaders from \`rust-gpu\` must be validated and optional.  
\- No release-critical path may depend solely on experimental shader tooling.

Shader requirements:

\- No undefined behavior from uninitialized GPU buffers.  
\- Deterministic culling results for a given input where possible.  
\- Shader permutations controlled by capability detection.  
\- Hot reloading in development builds.

\#\#\# 9.6 Advanced GPU Feature Policy

Advanced features must satisfy all of the following:

1\. They must not be required for baseline compatibility.  
2\. They must be disabled by default unless stable.  
3\. They must not alter simulation or demo timing.  
4\. They must fall back gracefully on unsupported hardware.  
5\. They must be clearly labeled in the UI.

\---

\#\# 10\. Non-Functional Requirements

\#\#\# 10.1 Performance

\| ID \| Requirement \| Target \|  
\|---\|---\|---\|  
\| NFR-PERF-01 \| Baseline renderer should run original content at high frame rates on modest hardware. \| 1080p 144 FPS on modern integrated or low-end dedicated GPU, where driver support is good \|  
\| NFR-PERF-02 \| Enhanced renderer should run original content smoothly on mid-range hardware. \| 1440p 120 FPS on mid-range GPU from recent generations \|  
\| NFR-PERF-03 \| Map load times should be fast. \| Typical original map load \< 2 seconds on SSD \|  
\| NFR-PERF-04 \| Engine startup to menu should be fast. \| \< 3 seconds on typical desktop \|  
\| NFR-PERF-05 \| Input latency should be minimized. \| No artificial frame queuing; low-latency swapchain where supported \|  
\| NFR-PERF-06 \| GPU frame debugging should be available. \| Frame time, pass timings, draw counts \|  
\| NFR-PERF-07 \| Experimental RT mode may have lower performance but should remain stable. \| 60 FPS target on supported hardware with upscaling \|

\#\#\# 10.2 Reliability

\| ID \| Requirement \|  
\|---\|---\|  
\| NFR-REL-01 \| The engine must not crash on malformed but parseable assets where safe recovery is possible. \|  
\| NFR-REL-02 \| GPU device loss should be handled gracefully with user-visible error and recovery attempt. \|  
\| NFR-REL-03 \| Save/load failure must not corrupt existing saves. \|  
\| NFR-REL-04 \| Network packet malformedness must not crash the server or client. \|  
\| NFR-REL-05 \| QuakeC execution errors must be reported without crashing unless fatal. \|  
\| NFR-REL-06 \| Automated smoke tests must cover startup, map load, input, demo record/playback, and shutdown. \|

\#\#\# 10.3 Security

\| ID \| Requirement \|  
\|---\|---\|  
\| NFR-SEC-01 \| PAK parsing must defend against path traversal, excessive allocations, invalid offsets, and corrupted archives. \|  
\| NFR-SEC-02 \| BSP/MDL/sprite parsers must validate indices and sizes before use. \|  
\| NFR-SEC-03 \| Demo playback must treat files as untrusted input. \|  
\| NFR-SEC-04 \| Network messages must be length-checked and semantically validated. \|  
\| NFR-SEC-05 \| QuakeC VM must sandbox built-ins and prevent direct arbitrary host filesystem access unless explicitly enabled. \|  
\| NFR-SEC-06 \| Unsafe Rust must be localized and audited. \|

\#\#\# 10.4 Portability

\| Platform \| Requirement \|  
\|---\|---\|  
\| Windows \| Primary support via Vulkan/DX12. \|  
\| Linux \| Primary support via Vulkan; Wayland/X11 through standard windowing stack. \|  
\| macOS \| Supported via Metal. \|  
\| Web \| Experimental WebGPU support for limited use cases. \|  
\| Consoles \| Out of scope for v1. \|  
\| Mobile \| Out of scope for v1. \|

\#\#\# 10.5 Build and Tooling

\| ID \| Requirement \|  
\|---\|---\|  
\| NFR-BUILD-01 \| Build with stable Rust unless a justified exception is made. \|  
\| NFR-BUILD-02 \| Use Cargo workspaces for engine, renderer, tools, and tests. \|  
\| NFR-BUILD-03 \| CI must run formatting, linting, tests, and dependency audits. \|  
\| NFR-BUILD-04 \| Provide development instructions without requiring proprietary tools. \|  
\| NFR-BUILD-05 \| Optional GPU validation layers must be enabled in debug builds. \|  
\| NFR-BUILD-06 \| Provide a CLI asset preprocessing tool. \|

\#\#\# 10.6 Maintainability

\| ID \| Requirement \|  
\|---\|---\|  
\| NFR-MAINT-01 \| Engine modules should be separated: core, filesystem, renderer, audio, input, net, qc, ui. \|  
\| NFR-MAINT-02 \| Renderer should not depend directly on QuakeC internals. \|  
\| NFR-MAINT-03 \| Legacy-format parsing should be isolated from gameplay logic. \|  
\| NFR-MAINT-04 \| Unsafe code should be denied in most crates and allowed only in specific low-level crates. \|  
\| NFR-MAINT-05 \| Major architectural changes should go through RFC/design review. \|

\#\#\# 10.7 Accessibility

\| ID \| Requirement \| Priority \|  
\|---\|---\|---\|  
\| NFR-ACC-01 \| UI text should be readable at multiple resolutions. \| P1 \|  
\| NFR-ACC-02 \| Support UI scaling. \| P1 \|  
\| NFR-ACC-03 \| Support color-blind-friendly crosshair or HUD colors where feasible. \| P2 \|  
\| NFR-ACC-04 \| Provide subtitle support for optional replacement content. \| P2 \|

\#\#\# 10.8 Legal and Trademark

\| ID \| Requirement \|  
\|---\|---\|  
\| NFR-LEGAL-01 \| Project must be clearly marked as unofficial and not imply endorsement by id Software, Bethesda, or Microsoft. \|  
\| NFR-LEGAL-02 \| No proprietary Quake assets may be distributed with the engine. \|  
\| NFR-LEGAL-03 \| The project should support user-provided legally owned content. \|  
\| NFR-LEGAL-04 \| If GPL Quake source code is used or consulted, licensing must be reviewed and the repository license adjusted accordingly. \|  
\| NFR-LEGAL-05 \| Clean-room implementation is preferred for maximum licensing flexibility. \|

\---

\#\# 11\. User Experience Requirements

\#\#\# 11.1 First-Time Experience

The first launch should:

1\. Detect available GPU backend.  
2\. Choose safe graphics defaults.  
3\. Prompt the user for content location if no PAK content is found.  
4\. Explain that proprietary assets are not included.  
5\. Offer to open a file picker or settings file location.  
6\. Allow launching into a demo or open-source replacement content if available.

\#\#\# 11.2 Menu Requirements

Main menu should include:

\- New Game / Episode Select  
\- Load Game  
\- Save Game  
\- Options  
\- Multiplayer  
\- Demos  
\- Quit

Options should include:

\- Resolution and fullscreen mode  
\- Graphics preset  
\- Render scale  
\- VSync / frame limiter  
\- Texture filtering  
\- Enhancement toggles  
\- Mouse sensitivity  
\- Key bindings  
\- Audio volumes  
\- Console access

\#\#\# 11.3 Console Requirements

The console must:

\- Toggle with a configurable key, default grave/tilde.  
\- Display log levels.  
\- Support command history.  
\- Support autocomplete.  
\- Support writing commands to configuration.  
\- Support common Quake commands such as:  
  \- \`map\`  
  \- \`connect\`  
  \- \`record\`  
  \- \`playdemo\`  
  \- \`timedemo\`  
  \- \`bind\`  
  \- \`sensitivity\`  
  \- \`volume\`  
  \- \`god\`, \`noclip\`, \`give\` where appropriate for single-player/testing

\---

\#\# 12\. Technical Architecture

\#\#\# 12.1 High-Level Crate Layout

A recommended Cargo workspace:

\`\`\`text  
quake-rs/  
  crates/  
    quake-core/        \# Game state, simulation, entities, physics  
    quake-fs/          \# PAK, VFS, paths, asset discovery  
    quake-bsp/         \# BSP parsing and conversion  
    quake-mdl/         \# MDL parsing  
    quake-sprite/      \# Sprite parsing  
    quake-pak/         \# PAK parsing  
    quake-qc/          \# QuakeC VM  
    quake-net/         \# Protocol, client/server networking  
    quake-demo/        \# Demo record/playback  
    quake-audio/       \# Mixer, spatialization, music  
    quake-input/       \# Keyboard/mouse/gamepad abstraction  
    quake-render/      \# Renderer API  
    quake-render-wgpu/ \# wgpu implementation  
    quake-ui/          \# Menus, console, HUD  
    quake-tools/       \# Asset preprocessing, validation tools  
    quake-app/         \# Binary, windowing, main loop  
\`\`\`

\#\#\# 12.2 Main Loop Architecture

Recommended model:

1\. \*\*Input Thread / Event Loop\*\*  
   \- Window events.  
   \- Keyboard/mouse events.  
   \- Command queue to engine.

2\. \*\*Simulation Thread\*\*  
   \- Fixed timestep.  
   \- Runs QuakeC VM.  
   \- Updates entities and physics.  
   \- Produces render scene snapshot.

3\. \*\*Render Thread\*\*  
   \- Consumes scene snapshot.  
   \- Encodes GPU commands.  
   \- Presents frame.

4\. \*\*Audio Thread\*\*  
   \- Mixer callback.  
   \- Consumes sound commands from simulation.

5\. \*\*Network Thread(s)\*\*  
   \- UDP socket send/receive.  
   \- Packet parsing and rate limiting.  
   \- Produces snapshots or commands for simulation.

The renderer must not block simulation indefinitely. Frame synchronization should use bounded queues and frame pacing controls.

\#\#\# 12.3 Determinism Rules

To support demos and speedrunning:

\- Simulation must run on a fixed timestep.  
\- Game logic must not depend on wall-clock time except for rendering interpolation.  
\- Rendering enhancements must not alter simulation state.  
\- Parallel systems must not introduce nondeterministic gameplay ordering.  
\- Network interpolation may affect presentation but not server-authoritative simulation.

\#\#\# 12.4 Filesystem and VFS

Requirements:

\- Support multiple search paths.  
\- Support PAK files and loose files.  
\- Respect Quake-style load order.  
\- Prevent path traversal.  
\- Normalize file names case-insensitively where required by legacy content behavior.  
\- Provide missing-asset warnings without crashing.

\#\#\# 12.5 Serialization

Use cases:

\- Save files.  
\- Demo metadata.  
\- Configuration.  
\- Asset cache.

Requirements:

\- Use stable serialization for saves and caches.  
\- Version all formats.  
\- Provide migration strategy.  
\- Do not use in-memory pointer addresses or unstable struct layouts.

\---

\#\# 13\. Compatibility Strategy

\#\#\# 13.1 Content Compatibility Targets

The engine should target compatibility with:

\- Original base game content.  
\- Official mission packs where behavior is known.  
\- Common community maps.  
\- Classic mods using standard QuakeC.  
\- Popular speedrunning and demo workflows, best-effort.

\#\#\# 13.2 Compatibility Modes

The engine should provide profiles:

\#\#\#\# Classic Mode

\- Original visual behavior.  
\- Minimal enhancements.  
\- Prioritizes compatibility and predictability.

\#\#\#\# Enhanced Mode

\- GPU-driven rendering.  
\- High-resolution textures.  
\- Dynamic lights.  
\- Improved filtering.  
\- No gameplay changes.

\#\#\#\# Experimental Mode

\- Ray tracing, upscaling, bindless, mesh shaders, or other advanced features.  
\- May have visual differences.  
\- Not required for demo correctness.

\#\#\# 13.3 Bug Compatibility

Some original engine bugs are part of speedruns or mods. The engine should support toggles such as:

\- Physics bug compatibility.  
\- Demo recording bug compatibility.  
\- Rendering quirks where practical.

However, security bugs and crash bugs should never be reproduced.

\---

\#\# 14\. Multiplayer Requirements Detail

\#\#\# 14.1 Modes

\- Single-player.  
\- Listen server.  
\- Dedicated server.  
\- Client-only mode.

\#\#\# 14.2 Tick Rate

\- Default should be classic-compatible.  
\- Server operator may configure tick rate.  
\- Demo and physics compatibility should be considered when changing tick rate.

\#\#\# 14.3 Protocol

The project should define:

\- Classic compatibility mode.  
\- Modernized protocol mode with versioned messages.  
\- Packet size limits.  
\- Sequence numbers.  
\- Delta compression where feasible.  
\- Connection handshake.  
\- Server info query.  
\- Player slots and chat.

\#\#\# 14.4 Prediction

For QuakeWorld-style play:

\- Client-side prediction.  
\- Server reconciliation.  
\- Entity interpolation.  
\- Lag compensation options for server.  
\- Configurable interpolation delay.

\#\#\# 14.5 Server Hardening

\- Rate-limit connections.  
\- Validate message sizes.  
\- Limit entity spam.  
\- Prevent malformed packets from crashing server.  
\- Log suspicious behavior.

\---

\#\# 15\. Testing and Quality Requirements

\#\#\# 15.1 Unit Tests

Required for:

\- PAK parsing.  
\- BSP parsing.  
\- MDL parsing.  
\- QuakeC VM operations.  
\- Math utilities.  
\- Config parsing.  
\- Network message serialization.

\#\#\# 15.2 Integration Tests

Required for:

\- Map load to first frame.  
\- Save/load cycle.  
\- Demo record/playback.  
\- Client/server loopback.  
\- QuakeC execution of sample programs.  
\- Renderer initialization on mock or headless device.

\#\#\# 15.3 Compatibility Tests

\- Run known maps from base game.  
\- Run known mods or test progs.  
\- Compare console output and entity behavior against reference where possible.  
\- Maintain a compatibility matrix.

\#\#\# 15.4 GPU Tests

\- Shader compilation tests.  
\- Headless render pass tests where possible.  
\- Screenshot golden tests with tolerance.  
\- Backend-specific smoke tests in CI where available.

\#\#\# 15.5 Fuzzing

Fuzz targets should include:

\- PAK files.  
\- BSP files.  
\- MDL files.  
\- Demo files.  
\- Network packets.  
\- QuakeC bytecode.

\#\#\# 15.6 Performance Tests

\- Timedemo benchmark.  
\- Map load time benchmark.  
\- GPU pass timing report.  
\- Frame time stability report.

\---

\#\# 16\. Metrics and Success Criteria

\#\#\# 16.1 Product Success Metrics

\| Metric \| Target \|  
\|---\|---\|  
\| Engine launches with valid user content \| \> 99% of test configurations \|  
\| Base game playable from start to finish \| 100% of tested episodes \|  
\| Crash-free desktop sessions \| \> 99.5% \|  
\| No memory unsafety in safe crates \| 0 confirmed issues \|  
\| Major mod compatibility in top test list \| \> 90% \|  
\| Average 1080p FPS in compatibility mode \| ≥ 144 on target mid-range hardware \|  
\| Map load time \| \< 2 seconds for typical original maps \|  
\| Demo playback stability \| No desyncs in supported test suite \|

\#\#\# 16.2 Technical Success Metrics

\| Metric \| Target \|  
\|---\|---\|  
\| Stable Rust build \| Yes \|  
\| CI passing on Windows/Linux/macOS \| Yes \|  
\| Shader compilation failures in release \| 0 expected \|  
\| GPU validation errors in debug tests \| 0 expected \|  
\| Unsafe crate surface \| Minimal and audited \|  
\| WebGPU experimental launch \| Yes, with limited feature set \|

\---

\#\# 17\. Release Plan

\#\#\# Milestone 0 — Project Foundation

\*\*Goal:\*\* Repository, tooling, and basic rendering.

Deliverables:

\- Cargo workspace.  
\- Window creation with \`winit\`.  
\- \`wgpu\` initialization.  
\- Triangle/clear color render.  
\- Logging and config skeleton.  
\- CI formatting/linting/testing.  
\- Legal and asset policy documented.

Exit Criteria:

\- Application opens a window on Windows, Linux, and macOS.  
\- \`wgpu\` selects a valid backend.  
\- Basic frame renders.

\---

\#\#\# Milestone 1 — Content Loading and Static Rendering

\*\*Goal:\*\* Load and render original maps.

Deliverables:

\- PAK reader.  
\- BSP parser.  
\- Texture loading.  
\- Lightmap loading.  
\- Basic world renderer.  
\- Camera controls.  
\- Console skeleton.

Exit Criteria:

\- User can point engine at legally owned PAK content.  
\- \`e1m1\` renders statically.  
\- No crashes from valid content.  
\- Basic texture and lightmap correctness.

\---

\#\#\# Milestone 2 — Playable Single-Player Core

\*\*Goal:\*\* Playable classic behavior.

Deliverables:

\- Entity system.  
\- QuakeC VM.  
\- Physics and collision.  
\- Input handling.  
\- HUD/menu basics.  
\- Sound basics.  
\- Save/load basics.  
\- Map transitions.

Exit Criteria:

\- A full episode can be played in a basic but stable manner.  
\- Monsters, doors, triggers, and items work.  
\- Original movement feel is close to reference behavior.  
\- Console commands function.

\---

\#\#\# Milestone 3 — Modern GPU Renderer

\*\*Goal:\*\* Use Rust GPU technologies meaningfully.

Deliverables:

\- GPU mesh conversion.  
\- Indirect draw support where available.  
\- Compute culling.  
\- GPU alias model interpolation.  
\- Dynamic light path.  
\- Graphics settings UI.  
\- GPU debug overlay.  
\- WebGPU experimental path.

Exit Criteria:

\- Enhanced mode is visually stable.  
\- GPU culling reduces CPU draw overhead.  
\- Renderer scales across integrated and dedicated GPUs.  
\- WebGPU path renders simplified scenes.

\---

\#\#\# Milestone 4 — Multiplayer, Demos, and Compatibility Hardening

\*\*Goal:\*\* Full community usability.

Deliverables:

\- UDP client/server.  
\- QuakeWorld-style prediction best-effort.  
\- Demo record/playback.  
\- Compatibility profiles.  
\- Mod test suite.  
\- Dedicated server build.

Exit Criteria:

\- Basic multiplayer works over LAN and internet.  
\- Demo recording/playback works for supported scenarios.  
\- Popular mods/maps pass compatibility tests.  
\- Dedicated server runs headless.

\---

\#\#\# Milestone 5 — Release Candidate

\*\*Goal:\*\* Stabilization and polish.

Deliverables:

\- Performance optimization.  
\- Security review.  
\- Legal review.  
\- Documentation.  
\- Installer/package artifacts.  
\- Crash reporting optionally enabled.  
\- Release notes.

Exit Criteria:

\- All P0 requirements satisfied.  
\- Critical bugs resolved.  
\- No known memory-safety issues.  
\- Benchmark targets met.  
\- Legal asset policy enforced.

\---

\#\# 18\. Risks and Mitigations

\| Risk \| Impact \| Likelihood \| Mitigation \|  
\|---\|---\|---\|---\|  
\| Original Quake behavior is difficult to reproduce perfectly \| High \| High \| Provide compatibility toggles, reference test suites, community feedback \|  
\| QuakeC mod compatibility is broad and messy \| High \| High \| Prioritize original progs, maintain mod test list, isolate VM bugs \|  
\| \`wgpu\` backend differences cause visual bugs \| Medium \| Medium \| Backend smoke tests, feature detection, fallback paths \|  
\| Advanced GPU features are unstable \| Medium \| Medium \| Keep experimental features optional and disabled by default \|  
\| Legal ambiguity around assets/source reference \| High \| Medium \| Clean-room policy, no asset redistribution, legal review \|  
\| Demo compatibility is hard \| Medium \| High \| Define supported demo scope, use best-effort labeling \|  
\| Network compatibility with old protocols is brittle \| Medium \| High \| Implement compatibility mode separately from modern protocol \|  
\| Performance regressions from GPU-driven architecture \| Medium \| Medium \| Maintain benchmarks, profiling, fallback renderer paths \|  
\| Parser vulnerabilities in legacy formats \| High \| Medium \| Fuzzing, validation, safe Rust parsers \|  
\| Scope creep into remake features \| High \| High \| Strict PRD prioritization and non-goals \|

\---

\#\# 19\. Open Questions

1\. Should the project target full original demo bit-compatibility, or only best-effort demo support?  
2\. Should QuakeWorld compatibility be a primary requirement or secondary to a modern protocol?  
3\. Is GPL licensing acceptable if GPL Quake source is used as reference?  
4\. Should the project include a bundled open-content fallback experience?  
5\. Which mods should define the official compatibility matrix?  
6\. Should \`rust-gpu\` be used for any shipping shader pass in v1, or only tooling/experiments?  
7\. Should WebGPU support target only demo playback or also limited single-player?  
8\. Is a server browser required for v1 or acceptable for post-release?  
9\. Should save files attempt compatibility with original Quake saves or use a new stable format only?  
10\. How should the project handle trademark-safe naming in public distribution?

\---

\#\# 20\. Dependencies and Technology Notes

\#\#\# 20.1 Expected Rust Dependencies

\| Category \| Candidate Crates \|  
\|---\|---\|  
\| GPU abstraction \| \`wgpu\` \|  
\| Shader translation \| \`naga\` \|  
\| Vulkan extensions \| \`ash\` \|  
\| Windowing \| \`winit\` \|  
\| UI \| \`egui\`, \`egui-wgpu\` \|  
\| Audio output \| \`cpal\` or equivalent \|  
\| Audio decoding \| \`symphonia\`, \`ogg\`, \`lewton\`, depending on formats \|  
\| Serialization \| \`serde\`, \`bincode\` or equivalent \|  
\| Logging/tracing \| \`tracing\`, \`tracing-subscriber\` \|  
\| Error handling \| \`thiserror\`, \`anyhow\` \|  
\| Math \| \`glam\`, \`bytemuck\` \|  
\| Image decoding \| \`image\` \|  
\| CLI \| \`clap\` \|  
\| Testing/fuzzing \| \`proptest\`, \`cargo-fuzz\` \|  
\| Profiling \| \`tracing\`, Tracy integration, backend GPU tools \|

\#\#\# 20.2 External GPU Tools

\- RenderDoc for Vulkan and general GPU frame capture.  
\- PIX for DirectX debugging where applicable.  
\- Xcode GPU Frame Capture for Metal.  
\- Vendor profiling tools for NVIDIA/AMD/Intel/Apple GPUs.

\---

\#\# 21\. Documentation Requirements

The project must provide:

1\. \*\*User Guide\*\*  
   \- Installation.  
   \- Pointing to legal content.  
   \- Controls.  
   \- Graphics settings.  
   \- Multiplayer instructions.  
   \- Demo instructions.

2\. \*\*Developer Guide\*\*  
   \- Build instructions.  
   \- Architecture overview.  
   \- Renderer design.  
   \- Shader workflow.  
   \- Adding new GPU passes.  
   \- Testing instructions.

3\. \*\*Compatibility Guide\*\*  
   \- Supported content.  
   \- Known incompatible mods.  
   \- Demo support status.  
   \- QuakeC extension support.

4\. \*\*Legal Notice\*\*  
   \- Unofficial status.  
   \- No asset redistribution.  
   \- Licensing explanation.  
   \- Trademark disclaimer.

\---

\#\# 22\. Definition of Done for v1.0

\`quake-rs\` v1.0 may be released when:

\- All P0 requirements are implemented and verified.  
\- Most P1 requirements are implemented or explicitly deferred.  
\- The base game is playable from beginning to end.  
\- Original PAK content loads correctly.  
\- QuakeC VM runs original \`progs.dat\`.  
\- GPU renderer is stable on at least two major desktop platforms.  
\- WebGPU experimental mode launches and renders a basic scene if enabled.  
\- No known security vulnerabilities in asset/network parsing are unresolved.  
\- Performance targets are met on reference hardware.  
\- Legal review confirms no proprietary assets are redistributed.  
\- Documentation is complete.  
\- Release artifacts are reproducible and signed where possible.

\---

\#\# 23\. Appendix: Example Command-Line Interface

The engine should support commands like:

\`\`\`bash  
quake-rs \--base-dir /path/to/quake \--game id1 \--map e1m1  
\`\`\`

\`\`\`bash  
quake-rs \--width 2560 \--height 1440 \--fullscreen \--vsync off  
\`\`\`

\`\`\`bash  
quake-rs \+connect 192.168.1.10:26000  
\`\`\`

\`\`\`bash  
quake-rs \--timedemo demo1.dem  
\`\`\`

\`\`\`bash  
quake-rs \--dedicated \--port 26000 \--maxplayers 16  
\`\`\`

Console examples:

\`\`\`text  
map e1m1  
bind mouse1 \+attack  
sensitivity 3.2  
volume 0.8  
record demo1  
playdemo demo1  
\`\`\`

\---

\#\# 24\. Appendix: GPU Feature Detection Matrix

The engine should detect and expose:

\| Feature \| Usage \| Fallback \|  
\|---\|---\|---\|  
\| Compute shaders \| Culling, particles, animation \| CPU paths \|  
\| Indirect drawing \| GPU-driven rendering \| Direct draws \|  
\| Timestamp queries \| Profiling \| CPU timing only \|  
\| Descriptor indexing \| Bindless-style resources \| Bind groups \|  
\| Ray tracing \| Experimental lighting/shadows \| Rasterized lighting \|  
\| Mesh shaders \| Optional geometry path \| Standard vertex/index buffers \|  
\| WebGPU limits \| Browser compatibility \| Reduced feature tier \|

\---

\#\# 25\. Appendix: Graphics Settings

\#\#\# Required Settings

\- Resolution  
\- Fullscreen mode  
\- VSync  
\- Frame limiter  
\- Render scale  
\- Texture filtering  
\- Field of view  
\- Gamma  
\- Graphics preset  
\- GPU backend selection or auto-detect  
\- Dynamic lights toggle  
\- Enhanced particles toggle  
\- Anti-aliasing toggle  
\- Debug overlay toggle

\#\#\# Optional Advanced Settings

\- Hi-Z occlusion culling  
\- GPU-driven culling  
\- Bindless resources  
\- Mesh shaders  
\- Ray tracing mode  
\- Upscaling mode  
\- Shader precompilation  
\- GPU device selection  
\- Frame latency mode

\---

\#\# 26\. Appendix: Compatibility Test Categories

The compatibility suite should include:

1\. \*\*Base Game\*\*  
   \- Start map  
   \- Episode 1  
   \- Later episodes  
   \- Boss sequences  
   \- Save/load transitions

2\. \*\*Mission Packs\*\*  
   \- Official mission pack maps where supported

3\. \*\*Mods\*\*  
   \- Standard QuakeC mods  
   \- Gameplay mods  
   \- Map packs  
   \- Total conversions where feasible

4\. \*\*Demos\*\*  
   \- Playback of selected classic demos  
   \- Recording and playback of new demos  
   \- Timedemo stability

5\. \*\*Multiplayer\*\*  
   \- Loopback client/server  
   \- LAN play  
   \- Internet play  
   \- Dedicated server stability

\---

\#\# 27\. Final Recommendation

The recommended direction is to build \`quake-rs\` as a \*\*compatibility-first, GPU-modernized Rust engine\*\*:

\- Use \`wgpu\` and WGSL as the foundation.  
\- Use compute shaders and GPU-driven rendering as the main modernization path.  
\- Keep advanced features such as ray tracing, mesh shaders, and bindless resources optional.  
\- Maintain strict separation between simulation and rendering.  
\- Prioritize safety, mod compatibility, and deterministic behavior.  
\- Treat WebGPU as an important long-term platform but not the primary feature ceiling.

This approach allows the project to benefit from the latest Rust GPU technologies without compromising the core goal: a faithful, high-performance, and maintainable way to experience classic Quake content.  
