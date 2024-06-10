# small-pSquare
Public implementations of the *small-pSquare* tweakable block cipher.

## Publication
This repository contains source code related to a EUROCRYPT 2024 publication titled "Generalized Feistel Ciphers for Efficient Prime Field Masking" authored by Lorenzo Grassi, Loïc Masure, Pierrick Méaux, Thorben Moos and François-Xavier Standaert.

Links:
- [ePrint (full version)](https://eprint.iacr.org/2024/431)
- [DOI](https://doi.org/10.1007/978-3-031-58734-4_7)

## FPM and small-pSquare
The EC'24 paper introduces the FPM (Feistel for Prime Masking) family of tweakable block ciphers and its concrete instance *small-pSquare*. Both, the family and the instance, are based on a Type-II generalized Feistel network and have been designed for the efficient application of additive prime-field masking. *small-pSquare* specifically leverages the benefits of a small Mersenne prime (hence, "small-p") and the efficient masked implementation of the squaring operation (hence, "Square").

## Content of the Repository
We provide reference implementations of *small-pSquare* in software (C language) and hardware (VHDL language) for both encryption and decryption, together with one set of generated test vectors (further test vectors can be generated using the provided code). We also share unprotected hardware implementations of *small-pSquare* with tweak lengths 0 (tau=0), n (tau=1) and 2n (tau=2) optimized for different design goals (low latency (standard), medium latency/frequency, maximum frequency). For tau=1 in particular, a large set of optimized masked hardware implementations is provided, including round-based, half-round-based, non-pipelined, data-pipelined, data-tweak-pipelined and data-tweak-key-pipelined circuits for 2, 3 and 4 shares each, leading to provable first-, second- and third-order glitch-robust probing security. All folders that contain hardware implementations also include a Makefile to simulate the provided testbenches using [ghdl](https://github.com/ghdl/ghdl).

## Cost and Performance Evaluation
The cost and performance evaluation presented in the paper is based on ASIC synthesis results obtained using Synopsys Design Compiler Version O-2018.06-SP4 as a synthesis/EDA tool and the TSMC 65nm Low Power (LP) standard cell library (including low, standard and high threshold voltage cells) characterized for typical operating conditions.

## SCA Security Evaluation
The experimental SCA security evaluation described in the paper has been performed on a [SAKURA-G FPGA board](https://ieeexplore.ieee.org/document/7031104). We analyzed the power consumption of our implementations configured and executed on the target FPGA (45-nm Xilinx Spartan-6) using Xilinx ISE version 14.7 as a synthesis/EDA tool with parameter "-keep hierarchy" set to "yes". All implementations have been driven by a 6 MHz clock and the power consumption has been measured using a [PicoScope 5244D](https://www.picotech.com/oscilloscope/5000/picoscope-5000-specifications) digital sampling oscilloscope  at 250 MS/s sampling rate with 12-bit vertical resolution through a [Tektronix CT-1 current probe](https://www.tek.com/en/current-probe-manual/ct-1-and-ct-2) placed in the power supply path of the target FPGA. The [SCALib library](https://github.com/simple-crypto/SCALib) has been used for the analytical evaluation of the recorded leakages, including the metrics Test Vector Leakage Assessment (TVLA), Signal-to-Noise Ratio (SNR) and Soft-Analytical Side-Channel Attack (SASCA).

## Contact and Support
Please contact Thorben Moos (thorben.moos@uclouvain.be) if you have any questions, comments or if you found a bug that should be fixed.

## Licensing
Please see `LICENSE.txt` for licensing instructions.