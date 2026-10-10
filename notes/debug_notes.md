# Debug Notes

The simulation result was correct, but the real hardware test initially failed.

At first, the experiment was tested together with the Red Pitaya Web Scope environment. However, the Web Scope service could interfere with the custom FPGA bitstream, causing the ADC input path to behave unexpectedly.

The issue was resolved by using an external signal generator as the input source and an external oscilloscope to observe the DAC output directly.

Final verification setup:

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

Key lessons:

1. The HDL simulation result alone was not enough.
2. The hardware measurement setup affected the experiment result.
3. External measurement equipment helped avoid interference from the Red Pitaya Web Scope.
4. The final working experiment verified the complete ADC-to-FPGA-to-DAC path.
