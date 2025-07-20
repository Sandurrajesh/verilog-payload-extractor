# Verilog Payload Extractor

A Verilog design to extract variable-length message payloads from a stream of packets using an FSM-based control path, pipelined data path, and FIFO with error detection.

## Features

- FSM reads headers and payloads from FIFO
- Pipeline outputs 1 byte per clock
- Byte-enable signal to mark valid payload
- Error flag when packet ends prematurely

## File Structure

- `packet_extractor.v`: Main FSM + pipeline + error logic
- `simple_fifo_1k.v`: 1000-byte buffer FIFO
- `packet_extractor_tb.v`: Testbench
- `Makefile`: For simulation using Icarus Verilog

## How to Simulate

```bash
make sim
