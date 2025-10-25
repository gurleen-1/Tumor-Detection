# 🧠 Brain MRI Tumour Flagger (MATLAB)

**Research demo — not for diagnosis.**  
This repository contains a **base MATLAB implementation** that automatically detects and highlights tumour-like regions in brain MRI scans using **z-score hotspot detection and region growing**.  
It produces a 3-panel visualization — **Original**, **Detecting Tumour**, and **Percentage of Tumour** — and reports the tumour-affected area percentage directly in the MATLAB console.

> ✅ Runs on base MATLAB (no toolboxes required)  
> 🎯 Supports `.jpg`, `.png`, `.tif`, and `.dcm` MRI slice images  

---

## 🚀 Overview

This script analyzes an MRI image and identifies potential tumour regions by detecting statistical intensity anomalies.  
It performs image preprocessing, z-score mapping, hotspot selection, and seed-based region growing to isolate and visualize the affected area.

The workflow includes:
1. Image loading and grayscale normalization  
2. Gaussian denoising  
3. Z-score anomaly mapping  
4. Candidate region detection  
5. Region growing and convex hull outlining  
6. Area percentage calculation  
7. Visual and textual reporting  

---

## 📄 File

**`project.m`** — main MATLAB script file.  
Run directly; no dependencies beyond base MATLAB.

---

## ⚙️ How to Run

1. Open `project.m` in **MATLAB** (R2018b or later).  
2. Place your MRI image (e.g., **`30 no.jpg`**) in the same folder.  
3. Edit the **user settings** at the top of the script if needed:
   ```matlab
   imgPath      = "30 no.jpg";   % MRI image file (JPG, PNG, TIF, or DICOM)
   sliceType    = "T1c";         % Choose: 'T1c' | 'T2' | 'FLAIR'
   zThrBase     = 2.0;           % Base z-threshold for hotspot detection
   sigma        = 1.2;           % Gaussian smoothing factor
   alphaMax     = 0.65;          % Overlay opacity
   gamma        = 0.7;           % Overlay gamma for brightness control
4. Click **Run** (or press **F5**).  
5. The program displays three panels:  
   - **Original (normalized)** — the base MRI slice  
   - **Detecting Tumour** — heatmap view highlighting hotspots  
   - **Percentage of Tumour** — overlay view showing tumour mask and affected/safe area percentages  

---

## 🖼️ Example Output

**Figure panels:**
| Panel | Description |
|--------|--------------|
| **Left** | Original MRI slice (normalized grayscale) |
| **Center** | Z-score heatmap showing detected anomalies |
| **Right** | Overlay showing tumour region and percentage text |

**Sample console report:**
--- Tumour Detection Report ---
File: 30 no.jpg | Mode: T1c | zThr=2.00
Brain area (approx): 178234 px (central mask)
Tumour area: 9324 px
Affected: 5.23% | Safe: 94.77%

---

## 🧩 Key Features

- Works entirely in **base MATLAB** — no external libraries needed  
- Supports color and grayscale MRI slices  
- Uses **z-score anomaly detection** to locate tumour-like regions  
- Dynamic threshold adjustment by MRI type (`T1c`, `T2`, or `FLAIR`)  
- **Region-growing algorithm** isolates contiguous tumour areas  
- Calculates **affected and safe area percentages**  
- Produces an intuitive **3-panel visualization**  

---

## ⚙️ Parameters Overview

| Parameter | Default | Description |
|------------|----------|-------------|
| `imgPath` | `"30 no.jpg"` | MRI image file path |
| `sliceType` | `"T1c"` | MRI type (adjusts threshold) |
| `zThrBase` | `2.0` | Base z-score threshold for anomaly detection |
| `sigma` | `1.2` | Gaussian smoothing factor |
| `alphaMax` | `0.65` | Overlay opacity (0–1) |
| `gamma` | `0.7` | Overlay gamma correction for brightness |

---

## 🧠 Method Summary

| Step | Description |
|------|-------------|
| **Preprocessing** | Converts MRI image to grayscale, normalizes, and denoises via Gaussian filter. |
| **Z-score Mapping** | Computes intensity deviations to find potential tumour hotspots. |
| **Candidate Masking** | Identifies regions with z-scores above threshold. |
| **Region Growing** | Expands from the strongest hotspot into a connected tumour mask. |
| **Visualization** | Displays 3 panels and overlays tumour coverage percentages. |

---

## 📈 Results

- Successfully detects tumour regions in **T1c**, **T2**, and **FLAIR** MRI images.  
- Achieved stable segmentation across different image contrasts.  
- Provides clear **visual feedback and quantitative metrics**.  

---

## ⚠️ Disclaimer

This MATLAB project is intended **for educational and research purposes only**.  
It should **not be used for medical diagnosis or clinical applications**.

---

## 👩‍💻 Author

**Gurleen Kaur**  
📧 [Gurleenk1424@gmail.com](mailto:Gurleenk1424@gmail.com)  
🔗 [LinkedIn](https://www.linkedin.com/in/gurleen-kaur-6074051b0) · [GitHub](https://github.com/gurleen-1)

---

### ⭐ If you found this project useful, please consider starring the repository!
