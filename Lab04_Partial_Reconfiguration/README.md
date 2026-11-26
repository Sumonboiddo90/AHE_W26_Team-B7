# Lab 04: MicroBlaze Partial Reconfiguration

This repository contains my Vivado partial-reconfiguration lab project
and the Vitis application source.

## Tools
- Vivado 2025.2
- Vitis Unified IDE 2026.1

## Reconfigurable modules
- rm_a: pass-through
- rm_b: invert
- rm_c: swap bytes

## Bitstreams
| File | Type | Size |
|---|---|---:|
| `top.bit` | Full bitstream | 3,825,904 bytes |
| `u_rm_rm_a_partial.bit` | Partial bitstream, rm_a | 1,149,685 bytes |
| `u_rm_rm_b_partial.bit` | Partial bitstream, rm_b | 1,149,685 bytes |
| `u_rm_rm_c_partial.bit` | Partial bitstream, rm_c | 1,149,685 bytes |

## Status
Vivado implementation and Vitis application build completed.
Board testing and the live reconfiguration demonstration are pending.

