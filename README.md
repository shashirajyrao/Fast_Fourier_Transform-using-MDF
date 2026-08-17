# Fast Fourier Transform using MDF (Multi-path Delay Feedback)

A hardware implementation of a **1024-point Fast Fourier Transform (FFT)** in Verilog, built on a **Multi-path Delay Feedback (MDF)** architecture. Four samples are ingested per clock cycle and pushed through four parallel **Single-path Delay Feedback (SDF)** FFT pipelines before being recombined through twiddle multiplication and two final radix stages. Arithmetic throughout the datapath uses the **Posit** number format instead of standard IEEE-754 floating point.

> This README was generated from the repository's file structure and source code, since no description was provided in the original repo. Feel free to edit it to better reflect the project's intent.

## Overview

- **Transform size:** 1024 points
- **Architecture:** Multi-path Delay Feedback (MDF) — 4 parallel SDF lanes feeding a shared back-end
- **Throughput:** 4 input samples per clock cycle
- **Number format:** 32-bit Posit (custom encoder/decoder + arithmetic units), used instead of IEEE-754 floats
- **Control:** FSM-based sequencing (`FSM_controller.v`)
- **Verification:** Self-contained testbench (`MDF_tb.v`) driven by `.mem` input files, with output captured in `mdf_output.txt`

## Architecture

```
din0..din3 (32-bit Posit, 4 samples/cycle)
        │
        ▼
 ┌───────────────┐
 │  4× SDF FFT    │   fft0..fft3  (Single-path Delay Feedback lanes)
 │  (sdf.v)       │
 └───────────────┘
        │
        ▼
 ┌───────────────────────┐
 │  4× SDF_reorder_256    │   per-lane bit/data reordering
 │  (reorder_buff.v)      │
 └───────────────────────┘
        │
        ▼
 ┌───────────────────────┐
 │  MDF_twiddle_stage     │   cross-lane twiddle-factor multiplication
 │  (MDF_twiddle_stage.v, │
 │   twiddle_rom.v)       │
 └───────────────────────┘
        │
        ▼
 ┌───────────────────────┐
 │  MDF_stage8            │   penultimate radix stage
 │  (stage8.v)            │
 └───────────────────────┘
        │
        ▼
 ┌───────────────────────┐
 │  MDF_stage9            │   final radix stage
 │  (MDF_stage9.v)        │
 └───────────────────────┘
        │
        ▼
 ┌───────────────────────┐
 │  MDF_Output_Transpose  │   output reordering / transpose
 └───────────────────────┘
        │
        ▼
dout1..dout4 (32-bit Posit, 4 outputs/cycle)
```

The top-level module `MDF_top.v` instantiates and wires together all of the above stages, registering the four input samples and their valid flags on `valid_in`, and producing a `valid_out` strobe alongside the four output words once a result is ready.

### Top-level ports (`MDF_top`)

| Port | Direction | Width | Description |
|---|---|---|---|
| `clk` | input | 1 | System clock |
| `rst_n` | input | 1 | Active-low asynchronous reset |
| `din0_in` – `din3_in` | input | 32 | Four parallel Posit-encoded input samples |
| `valid_in` | input | 1 | Input sample valid strobe |
| `dout1` – `dout4` | output | 32 | Four parallel Posit-encoded output samples |
| `valid_out` | output | 1 | Output sample valid strobe |

## Repository structure

### Datapath / FFT core

| File | Description |
|---|---|
| `MDF_top.v` | Top-level module wiring the full MDF pipeline together |
| `sdf.v` | Single-path Delay Feedback FFT lane |
| `sdf_stage.v` | One radix stage within an SDF lane |
| `butterfly.v` | Radix butterfly (add/subtract) computation unit |
| `reorder_buff.v` | Data reordering / bit-reversal buffer between SDF stages |
| `MDF_twiddle_stage.v` | Applies twiddle-factor rotation across the four SDF lanes |
| `twiddle_rom.v`, `twiddle32.v` | Twiddle-factor ROM(s) supplying rotation coefficients |
| `stage8.v` | Radix stage 8 of the combined MDF pipeline |
| `MDF_stage9.v` | Final radix stage of the pipeline |
| `Delay_Buffer.v`, `buffer.v`, `SHIFT.v` | Pipeline delay/shift-register elements used for data alignment |
| `FSM_controller.v` | Finite state machine controlling stage sequencing and timing |

### Posit arithmetic

| File | Description |
|---|---|
| `posit_encoder.v` | Encodes a value into the 32-bit Posit format |
| `posit_decoder.v` | Decodes a 32-bit Posit value back to its numeric fields |
| `posit_adder.v` | Posit addition unit |
| `posit_subtractor.v` | Posit subtraction unit |
| `posit_multiplier.v` | Posit multiplication unit |
| `posit_complex.v` | Complex (real + imaginary) arithmetic built on the Posit primitives above |

### Verification & data

| File | Description |
|---|---|
| `MDF_tb.v` | Testbench that drives `MDF_top` with input vectors and checks/logs output |
| `input_1_to_1024.mem` | Sample input stimulus (sequential values 1–1024) |
| `sine.mem` | Sine-wave input stimulus, useful for validating frequency-domain output |
| `random_posit.mem` | Randomized Posit-encoded input stimulus |
| `twiddles.mem` | Precomputed twiddle-factor table loaded into the twiddle ROM |
| `mdf_output.txt` | Captured simulation output from the MDF pipeline |
| `sdf_stage_log.txt` | Captured simulation log from an individual SDF stage |
| `MDF` | Compiled simulation binary (e.g. Icarus Verilog output) — regenerate locally rather than relying on this artifact |

## Getting started

### Prerequisites

- [Icarus Verilog](http://iverilog.icarus.com/) (`iverilog` / `vvp`) or another Verilog-2001 compatible simulator
- (Optional) A waveform viewer such as [GTKWave](http://gtkwave.sourceforge.net/) if you add `$dumpfile`/`$dumpvars` to the testbench

### Cloning

```bash
git clone https://github.com/shashirajyrao/Fast_Fourier_Transform-using-MDF.git
cd Fast_Fourier_Transform-using-MDF
```

### Running the simulation

Compile all sources with the testbench as the top module and run it with `vvp`:

```bash
iverilog -o mdf_sim MDF_tb.v MDF_top.v MDF_stage9.v MDF_twiddle_stage.v \
  FSM_controller.v Delay_Buffer.v buffer.v SHIFT.v sdf.v sdf_stage.v \
  butterfly.v reorder_buff.v stage8.v twiddle_rom.v twiddle32.v \
  posit_encoder.v posit_decoder.v posit_adder.v posit_subtractor.v \
  posit_multiplier.v posit_complex.v

vvp mdf_sim
```

Make sure `input_1_to_1024.mem`, `sine.mem`, `random_posit.mem`, and `twiddles.mem` remain in the working directory, since the testbench loads them via `$readmemh`/`$readmemb`. Simulation output is written to the console and/or `mdf_output.txt`, matching the format already present in the repo.

> Adjust the file list above if `MDF_tb.v` references additional or differently named modules — check the `` `include `` directives or module instantiations inside the testbench for the exact set.

## Design notes

- **Why MDF over a plain SDF/SDC pipeline?** Multi-path Delay Feedback processes multiple samples per cycle by running several delay-feedback pipelines in parallel and merging them, trading extra hardware (four SDF lanes plus a twiddle/merge stage) for significantly higher throughput than a single-path design.
- **Why Posit arithmetic?** Posits aim to offer better dynamic range and precision per bit than IEEE-754 floats at the same bit width, which is attractive for area/power-constrained FFT hardware. All datapath values (twiddle factors, samples, and intermediate butterfly results) are represented as 32-bit Posits and manipulated using the custom `posit_*` units rather than a standard floating-point library.

## Contributing

Issues and pull requests are welcome — in particular, documentation of the exact stage-by-stage data flow, timing diagrams, and resource-utilization figures would be valuable additions.

## License

No license file is currently included in this repository. Add a `LICENSE` file to clarify how others may use, modify, or distribute this code.
