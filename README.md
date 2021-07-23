# malariaibm-spatial-BurkinaFaso-2021

Repository to accompany Zupko et al. (2021) "Long-term effects of increased adoption of artemisinin combination therapies in Burkina Faso"

[Penn State](https://www.psu.edu/) - [Center for Infectious Disease Dynamics (CIDD)](https://www.huck.psu.edu/institutes-and-centers/center-for-infectious-disease-dynamics) - [Boni Lab](http://mol.ax/)

---

# Overview

This repository contains a frozen snapshot of the code and intermediate data used to prepare the manuscript. Due to the size of the intermediate data (349 MB) this repository uses [Git Large File Storage](https://git-lfs.github.com/) and may be limited in terms of bandwidth as a result.  All studies run by the simuation use YAML files (in Studies) to provide the configuration and ASC files (in Data/GIS) for spatial data. 

# Organization

Contents of the Study directory are organized in the following fasion:

| Type | Study Name | Filename |
| --- | --- | --- |
| Baseline | Baseline, normal mutation rate | Baseline/bfa-fast-no-asaq.yml |
| Baseline, sensitivity | Baseline, slow mutation rate | Baseline/bfa-slow-no-asaq.yml |
| Drug Policy | Rapid Private Market Elimination | Drug Policies/bfa-rapid.yml |
| Drug Policy | Rapid Private Market Elimination, Rapid AL/DHA-PPQ MFT | Drug Policies/bfa-aldp-rapid.yml |
| Drug Policy | Rapid Private Market Elimination, Ten Year AL/DHA-PPQ MFT Phase-in | Drug Policies/bfa-aldp10-rapid.yml |
| Drug Policy | Ten Year Private Market Elimination | Drug Policies/bfa-tenyear.yml |
| Drug Policy | Ten Year Private Market Elimination, Rapid AL/DHA-PPQ MFT | Drug Policies/bfa-aldp-tenyear.yml |
| Drug Policy | Ten Year Private Market Elimination, Ten Year AL/DHA-PPQ MFT Phase-in | Drug Policies/bfa-aldp10-tenyear.yml |
| Drug Policy | Rapid AL/DHA-PPQ MFT | Drug Policies/bfa-aldp.yml | 
| Drug Policy | Ten Year AL/DHA-PPQ MFT Phase-in | Drug Policies/bfa-aldp10.yml |
| Drug Policy | Rapid Private Market Elimination, Rapid 60% AL/40% DHA-PPQ MFT | Drug Policies/bfa-60-al-40-dp.yml |
| Drug Policy | Rapid Private Market Elimination, Rapid 60% AL/40% DHA-PPQ MFT | Drug Policies/bfa-70-al-30-dp.yml |
| Drug Policy | Rapid Private Market Elimination, Rapid 60% AL/40% DHA-PPQ MFT | Drug Policies/bfa-80-al-20-dp.yml |
| Drug Policy | Rapid Private Market Elimination, Rapid 60% AL/40% DHA-PPQ MFT | Drug Policies/bfa-90-al-10-dp.yml |
| Drug Policy | Rapid Private Market Elimination, AL Only First-line Therapy | Drug Policies/bfa-90-al-10-dp.yml |

---

### Original Repositories
- Malaria Simulation, version 4.0: https://github.com/rjzupkoii/PSU-CIDD-Malaria-Simulation
- Burkina Faso analysis and plots: https://github.com/rjzupkoii/PSU-CIDD-Burkina-Faso
- Support scripts and infrastructure: https://github.com/bonilab/PSU-CIDD-MaSim-Support
