# Red Pitaya FPGA Moving Average Verification

This repository documents a hardware verification experiment for a moving average filter on the Red Pitaya FPGA platform.

The project is based on the official Red Pitaya FPGA moving average example. The main modified file is `src/moving_average.vhd`.

## Project Goal

The goal of this experiment is to verify the ADC-to-FPGA-to-DAC signal path on real hardware:

```text
External Signal Generator
        ↓
Red Pitaya IN2
        ↓
ADC
        ↓
FPGA Moving Average Filter
        ↓
DAC
        ↓
Red Pitaya OUT1
        ↓
External Oscilloscope
```

## Main Modification

The original moving average example uses a tag-controlled 1/2/3-tap structure.

This version modifies `moving_average.vhd` into a fixed 512-tap moving average filter.

Main changes:

1. Extended the original 3-tap structure to a fixed 512-tap filter.
2. Increased the accumulator width from 14-bit to 26-bit to prevent overflow.
3. Replaced direct summation with a rolling-sum implementation.
4. Used a circular buffer to store the latest 512 ADC samples.
5. Divided the accumulated sum by 512 using a 9-bit right shift.

## Why 512 Taps?

The Red Pitaya ADC sampling rate is 125 MHz, so the sampling period is:

```text
Ts = 1 / 125 MHz = 8 ns
```

For a 512-tap moving average filter:

```text
512 × 8 ns = 4.096 µs
```

For a 50 kHz square wave:

```text
Period = 1 / 50 kHz = 20 µs
Half period = 10 µs
```

Therefore, the 512-tap averaging window is:

```text
4.096 µs / 20 µs = 20.48% of the full period
4.096 µs / 10 µs = 40.96% of the half period
```

This makes the smoothing effect visible on an oscilloscope.

## Hardware Verification

The most important part of this experiment was not only modifying the HDL code, but also verifying the result using external measurement equipment.

Using only the Red Pitaya Web Scope caused confusion during testing because the Web Scope service could interfere with the custom FPGA bitstream. The experiment was successfully verified by using:

- An external signal generator as the input source
- An external oscilloscope to observe the DAC output
- A direct hardware measurement path instead of relying only on the Red Pitaya Web Scope

## Attribution

This project is based on the official Red Pitaya FPGA project:

https://github.com/RedPitaya/RedPitaya-FPGA

The original Red Pitaya FPGA source code is released under the BSD license.

This repository is not officially endorsed by Red Pitaya.

## License

The original Red Pitaya source code is distributed under the BSD license. The original copyright notice and license terms are included in this repository.
