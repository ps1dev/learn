# Outline

Machine first: each chapter starts with what the hardware does, then builds a psyqo example on top of it. Every chapter ships an example that CI builds and Redux boots. Hardware facts cite a [psx-spx dev](https://psx-spx.consoledev.net/dev/) page or a measurement on real hardware. The reader knows modern C++ and basic linear algebra and is new to the PS1.

Where [ps1-bare-metal](https://github.com/spicyjpeg/ps1-bare-metal) already teaches the same hardware without an SDK, the chapter links to that chapter. Toolchain setup is psyqo's [GETTING_STARTED.md](https://github.com/pcsx-redux/nugget/blob/main/psyqo/GETTING_STARTED.md) and the API tour is its [CONCEPTS.md](https://github.com/pcsx-redux/nugget/blob/main/psyqo/CONCEPTS.md); neither is repeated here.

## 1. The machine

- One CPU, one thread, no operating system to speak of: everything else on the board is a peripheral the program drives.
- The main bus: CPU, main RAM, the GPU and the MDEC, fed by DMA. The slower side: SPU, CD-ROM, BIOS ROM and expansion, each with its own access delay.
- What that split costs: why work goes out in DMA batches, and why a read from the CD or SPU RAM is far from free.
- End state: a block diagram of the console the reader can redraw from memory, with every later chapter placed on it.
- psx-spx: `system/memorymap.md`, `system/memorycontrol.md`, `system/dmachannels.md`.

## 2. The CPU

- MIPS R3000A in brief: what the code you write compiles to, and the toolchains that target it (GCC, Clang), with setup left to psyqo's GETTING_STARTED.md.
- Quirks that bite C++ code: the load delay slot, alignment (a word or halfword access through a pointer cast onto a misaligned buffer raises an address error), and no FPU.
- Caches and the 1 KB scratchpad: what is cached, what is not, and when the scratchpad pays.
- End state: the reader reads a disassembly of their own hot loop and explains each stall.
- Builds on: `hello`.
- psx-spx: `cpu/cpuspecifications.md` (Load Delay, Load/Store Alignment, Unaligned Load/Store), `system/memorymap.md` (Scratchpad).

## 3. Boot and the frame

- What happens between power-on and `main`: the BIOS, SYSTEM.CNF, the PS-EXE header, where in RAM the program is loaded.
- The vblank interrupt as the clock a game runs on, and what a psyqo `Application` and `Scene` do on each frame.
- End state: a program that counts frames and prints them, and knows why the count is 50 or 60.
- Builds on: `hello`, `hello-nokernel`, `timers`.
- psx-spx: `kernelbios/overview.md`, `cdr/cdromfileformats/executables.md`, `system/memorymap.md`, `system/interrupts.md`, `system/timers.md`.
- Without an SDK: [`00_helloWorld`](https://github.com/spicyjpeg/ps1-bare-metal/tree/main/src/00_helloWorld), [`01_basicGraphics`](https://github.com/spicyjpeg/ps1-bare-metal/tree/main/src/01_basicGraphics).

## 4. VRAM and framebuffers

- VRAM as one 1024x512 16-bit surface with no fixed layout: you decide where framebuffers, textures and palettes go.
- The display area (GP1 05h start, GP1 06h/07h ranges) versus the drawing area (GP0 E3h/E4h clip, E5h offset); GP1 08h picks the video mode.
- Double buffering: two regions of VRAM, drawing into one while GP1 05h shows the other, then trading places each frame.
- End state: the reader draws a VRAM map for their own program and picks a resolution and buffer placement on purpose.
- Builds on: `hello` (`GPU::Configuration`).
- psx-spx: `gpu/video-memory-vram.md`, `gpu/display-control-commands-gp1.md`, `gpu/rendering-attributes.md`.
- Without an SDK: [`02_doubleBuffer`](https://github.com/spicyjpeg/ps1-bare-metal/tree/main/src/02_doubleBuffer).

## 5. Primitives, ordering tables and DMA

- GP0 packets: polygons, lines, rectangles, and what each word means.
- The ordering table as a linked list in RAM, and the DMA2 linked-list mode that walks it; why there is no z-buffer.
- psyqo Fragments and `OrderingTable<N>` mapped back onto those packets and links.
- End state: a scene of overlapping primitives sorted by an OT the reader built.
- Builds on: `hello-chained`, `lines`, `cube`.
- psx-spx: `gpu/render-polygon-commands.md`, `gpu/render-line-commands.md`, `gpu/render-rectangle-commands.md`, `gpu/depth-ordering.md`, `system/dmachannels.md`.
- Without an SDK: [`03_dmaChain`](https://github.com/spicyjpeg/ps1-bare-metal/tree/main/src/03_dmaChain), [`07_orderingTable`](https://github.com/spicyjpeg/ps1-bare-metal/tree/main/src/07_orderingTable).

## 6. Texture pages and CLUTs

- How a primitive addresses a texture: the 256x256-texel texture page, how its VRAM footprint depends on 4/8/15-bit color, and the CLUT as a strip of VRAM.
- Uploading a TIM to VRAM, and why the UV window is 256x256.
- The texture cache and what makes it miss.
- End state: textured sprites from 4-bit art sharing palettes, with the VRAM map from chapter 2 extended.
- Builds on: `proctex`, `torus`, `backgrounds` (`png2tim.py`).
- psx-spx: `gpu/rendering-attributes.md`, `gpu/video-memory-vram.md`, `gpu/memory-transfer-commands.md`, `gpu/texture-caching.md`.
- Without an SDK: [`04_textures`](https://github.com/spicyjpeg/ps1-bare-metal/tree/main/src/04_textures), [`05_palettes`](https://github.com/spicyjpeg/ps1-bare-metal/tree/main/src/05_palettes), [`06_fonts`](https://github.com/spicyjpeg/ps1-bare-metal/tree/main/src/06_fonts).

## 7. The GTE and its FIFO

- The GTE as coprocessor 2: registers, how the CPU loads and reads them, and the load delay.
- RTPS/RTPT, the 3-deep SXY and 4-deep SZ FIFOs, and why NCLIP reads SXY0-2 while AVSZ3 reads SZ1-3 (diagram in `diagrams/gte-fifo.svg`).
- Lighting with NCCS, and what saturation and FLAG tell you.
- End state: a lit, back-face-culled spinning cube whose every GTE call the reader can explain.
- Builds on: `gte`, `cube`, `teapot`, `life3d`.
- psx-spx: `cpu/gte/geometrytransformationenginegte.md`, `cpu/gte/gtepipelinetimings.md`.
- Without an SDK: [`08_spinningCube`](https://github.com/spicyjpeg/ps1-bare-metal/tree/main/src/08_spinningCube), [`09_faceLighting`](https://github.com/spicyjpeg/ps1-bare-metal/tree/main/src/09_faceLighting).

## 8. Fixed point

- No FPU: the fixed-point formats each GTE register expects, and psyqo's `FixedPoint`.
- Range, precision and overflow, and where the GTE divider rounds.
- Lookup-table trig versus computing it.
- End state: the reader picks a format for a quantity and can say where it overflows.
- Builds on: `math`, `cube`.
- psx-spx: the GTE page sections on saturation, FLAG and division inaccuracy. No other course covers this; the chapter is new ground.

## 9. CD-ROM

- The drive as a slow, command-driven peripheral: sectors, modes, seeking, and why reads are asynchronous.
- ISO9660 on top of raw sectors, and CD audio from the same drive.
- psyqo's async callbacks and coroutines as the way to keep frames running during a read.
- End state: load a file from disc while animating, then loop a CD audio track.
- Builds on: `cdrom-demo`, `cdrom-dir`, `cdda`, `coroutine-demo`.
- psx-spx: `cdr/cdromdrive.md`, `cdr/cdromformat.md`.
- Without an SDK: [`13_cdromInit`](https://github.com/spicyjpeg/ps1-bare-metal/tree/main/src/13_cdromInit), [`14_cdAudio`](https://github.com/spicyjpeg/ps1-bare-metal/tree/main/src/14_cdAudio), [`15_cdromData`](https://github.com/spicyjpeg/ps1-bare-metal/tree/main/src/15_cdromData), [`16_iso9660`](https://github.com/spicyjpeg/ps1-bare-metal/tree/main/src/16_iso9660), [`17_fileLoading`](https://github.com/spicyjpeg/ps1-bare-metal/tree/main/src/17_fileLoading).

## 10. SPU

- 24 voices, 512 KB of sound RAM, ADPCM samples and their loop flags.
- ADSR envelopes, pitch, and reverb as a region of sound RAM.
- End state: upload samples and play them with envelopes and pitch from a key press.
- Builds on: `psyqo/spu.hh` and the sound code in `tetris`; no standalone psyqo SPU example exists, so this chapter writes one.
- psx-spx: `spu/soundprocessingunitspu.md`.
- Without an SDK: [`12_basicAudio`](https://github.com/spicyjpeg/ps1-bare-metal/tree/main/src/12_basicAudio).

## 11. Pads

- The serial protocol under a controller: the polling sequence, digital versus analog replies.
- The multitap, and what psyqo's `SimplePad` and `AdvancedPad` hide.
- End state: read every connected pad, including through a multitap, and show raw and decoded state.
- Builds on: `padtest`, `multitap`.
- psx-spx: `sio/controllersandmemorycards/` (communication sequence, standard controllers, multitap), `sio/serialinterfacessio.md`.
- Without an SDK: [`11_controllers`](https://github.com/spicyjpeg/ps1-bare-metal/tree/main/src/11_controllers).

## 12. Memory cards

- Same port, different device: the 128 KB card, its 8 KB blocks and directory frame.
- Save file format: header, icon, title, and what the BIOS shell expects.
- End state: save and load game state with an icon that shows up in the BIOS memory card manager.
- Builds on: `memorycard` (which formats the card in port 1 first; the chapter's example will not).
- psx-spx: `sio/controllersandmemorycards/memory-card-read-write-commands.md`, `memory-card-data-format.md`. ps1-bare-metal has no chapter on this.
