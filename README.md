TinyVers Heterogeneous SoC consists of a reconfigurable FlexML accelerator, a RISC-V processor, an eMRAM and a power management system. It is designed for flexible and energy-efficient deployment of ML workloads on battery and resource-constrained extreme edge devices. Extreme edge ML processing, brings several new challenges: 1.) As these nodes are battery-operated, the system is typically severely power or energy constrained requiring ultra-low power operation, with the ability to idle. 2.) most MCU, moreover, has limited compute power and memory space, resulting in a critical trade-off between model size, execution performance and hardware complexity; 3.) despite the need for efficiency, the system should also be flexible enough to support different classes of NN models across different applications, and 4.) it should have a small footprint. The salient FlexML features to address these challenges and further improve energy efficiency are as follows:

    Hardware-supported, zero-latency runtime dataflow reconfiguration.
    Precision-scalable MAC units inside each PE to support INT 2/4/8 data types.
    Zero-skipping support for blockwise structured sparsity and deconvolution operator.
    Support Vector Machines support with hardware extension in PEs to support subtraction, squaring and rounding.
    Support for multiple workloads including Convolutional Neural Networks, Fully Connected, Temporal Convolutional Networks, Autoencoders, Generative Adversial Networks, Recurrent Neural Networks, and Support Vector Machines.

These features of FlexML achieve state-of-the-art throughput and energy efficiency over other ML accelerators and SoCs for ML on one of the most diverse workloads. When combined with the TinyVers SoC, the flexibility is extended with the RISC-V and power management providing extensive support for non-ML as well as ML workloads at the extreme edge.

Index Terms: ML accelerator, flexible, open source, end-to-end flow, multi-modal AI, heterogeneous multi-core, extreme edge ML, OpenLANE, OpenRAM

Citations:

Jain, V., Giraldo, S., De Roose, J., Boons, B., Mei, L., Verhelst, M. (2022). TinyVers: A 0.8-17 TOPS/W, 1.7 μW-20 mW, Tiny Versatile System-on-chip with State-Retentive eMRAM for Machine Learning Inference at the Extreme Edge. In: 2022 IEEE Symposium on VLSI Technology and Circuits (VLSI Technology and Circuits). Presented at the 2022 IEEE Symposium on VLSI Technology and Circuits (VLSI Technology and Circuits), Honolulu, HI, USA. ISBN: 78-1-6654-9772-5. doi:10.1109/VLSITechnologyandCir46769.2022.9830409

Jain, V., Giraldo, S., Roose, J.D., Mei, L., Boons, B., Verhelst, M. (2023). "TinyVers: A Tiny Versatile System-on-Chip With State-Retentive eMRAM for ML Inference at the Extreme Edge." Ieee Journal Of Solid-State Circuits, 1-12. doi: 10.1109/JSSC.2023.3236566
