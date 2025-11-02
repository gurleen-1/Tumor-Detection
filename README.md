# Intelligent MRI Analysis for Automated Brain Tumor Detection

This project uses advanced image processing techniques to assist in detecting potential brain tumors from MRI scans.  
By analyzing pixel intensity patterns and abnormal regions, the system highlights possible tumor areas and estimates the affected percentage of the brain tissue.

The purpose of this work is to demonstrate how automated medical image analysis can support early detection and improve understanding of MRI data through clear visual interpretation.

---

## Project Overview

Medical imaging plays a crucial role in early and accurate disease detection.  
This project introduces an automated MRI analysis framework that identifies brain tumors using classical image processing and statistical methods.  
It produces a three-panel output showing the original scan, detected tumor regions, and estimated tumor percentage, allowing for easy comparison and visual assessment.

---

## Objectives

- Detect and highlight abnormal regions in MRI brain scans.  
- Quantify the percentage of affected and unaffected brain tissue.  
- Provide a clear visual output for medical image interpretation.  
- Demonstrate a systematic and reliable approach to MRI-based tumor detection.

---

## Technologies and Tools

- **Language:** MATLAB (Base version, no additional toolboxes required)  
- **Techniques:** Image normalization, Gaussian filtering, Z-score mapping, region segmentation, and quantitative visualization  
- **Supported Formats:** `.jpeg`, `.png`, `.tif`, `.dcm`  
- **Outputs:** Heatmap visualization, overlay image, and summary report with tumor percentage

---

## Methodology

The detection process is based on statistical analysis of MRI image intensities.  
Each image is first converted to grayscale, normalized, and smoothed to remove noise.  
A Z-score map is then generated to identify statistically unusual regions, which are expanded using a region-growing technique to form a coherent tumor mask.  
The resulting visualization highlights the detected region and displays the estimated affected percentage.

---

## Key Steps

1. Load and normalize the MRI image.  
2. Apply Gaussian smoothing to minimize noise.  
3. Generate a Z-score intensity map to identify anomalies.  
4. Locate and expand the strongest hotspot to define the tumor region.  
5. Compute the ratio of tumor-affected area to the total brain region.  
6. Display a three-panel visualization: **Original**, **Detecting Tumour**, and **Percentage of Tumour**.  
7. Print a concise detection report in the MATLAB Command Window.

---

## Conclusion

This project demonstrates an automated and interpretable approach to identifying tumor regions from MRI scans using classical image analysis methods.  
While it is not intended for medical diagnosis, it offers a valuable foundation for further research in computer-assisted medical imaging and provides a practical educational example of medical image interpretation through visualization.

---
