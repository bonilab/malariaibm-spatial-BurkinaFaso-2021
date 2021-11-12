# malariaibm-spatial-BurkinaFaso-2021

Repository to accompany Zupko et al. (2021) "Long-term effects of increased adoption of artemisinin combination therapies in Burkina Faso"

[Penn State](https://www.psu.edu/) - [Center for Infectious Disease Dynamics (CIDD)](https://www.huck.psu.edu/institutes-and-centers/center-for-infectious-disease-dynamics) - [Boni Lab](http://mol.ax/)

---

# Overview

This repository contains a frozen snapshot of the code and intermediate data used to prepare the manuscript. Due to the size of the intermediate data (349 MB) this repository uses [Git Large File Storage](https://git-lfs.github.com/) and may be limited in terms of bandwidth as a result.  All studies run by the simulation use YAML files (in Studies) to provide the configuration and ASC files (in Data/GIS) for spatial data. 

## Organization

Contents of the Study directory are organized in the following fashion:

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
| Mutation Rate | Baseline, 10x faster mutation rate | bfa-0.01983.yml |
| Mutation Rate | Baseline, 5x faster mutation rate | bfa-0.009915.yml |
| Mutation Rate | Baseline, 5x slower mutation rate | bfa-0.0003966.yml |
| Mutation Rate | Baseline, 10x slower mutation rate | bfa-0.0001983.yml |
| Mutation Rate | Rapid AL/DHA-PPQ MF, 10x faster mutation rate | bfa-aldp-0.01983.yml |
| Mutation Rate | Rapid AL/DHA-PPQ MF, 5x faster mutation rate | bfa-aldp-0.009915.yml |
| Mutation Rate | Rapid AL/DHA-PPQ MF, 5x slower mutation rate | bfa-aldp-0.0003966.yml |
| Mutation Rate | Rapid AL/DHA-PPQ MF, 10x slower mutation rate | bfa-aldp-0.0001983.yml |
| Mutation Rate | Rapid Private Market Elimination, 10x faster mutation rate | bfa-rapid-0.01983.yml |
| Mutation Rate | Rapid Private Market Elimination, 5x faster mutation rate | bfa-rapid-0.009915.yml |
| Mutation Rate | Rapid Private Market Elimination, 5x slower mutation rate | bfa-rapid-0.0003966.yml |
| Mutation Rate | Rapid Private Market Elimination, 10x slower mutation rate | bfa-rapid-0.0001983.yml |


## Binary Files

The compiled version of the simulation used for the studies is provided in the `Binaries` directory, which was  compiled and ran on in the following environment:

```
LSB Version:    :core-4.1-amd64:core-4.1-noarch:cxx-4.1-amd64:cxx-4.1-noarch:desktop-4.1-amd64:desktop-4.1-noarch:languages-4.1-amd64:languages-4.1-noarch:printing-4.1-amd64:printing-4.1-noarch
Distributor ID: RedHatEnterpriseServer
Description:    Red Hat Enterprise Linux Server release 7.9 (Maipo)
Release:        7.9
Codename:       Maipo
```

---

### Original Repositories
- Malaria Simulation, version 4.0: https://github.com/rjzupkoii/PSU-CIDD-Malaria-Simulation
- Burkina Faso analysis and plots: https://github.com/rjzupkoii/PSU-CIDD-Burkina-Faso
- Support scripts and infrastructure: https://github.com/bonilab/PSU-CIDD-MaSim-Support

# Sources

Adam Auton (2021). Red Blue Colormap (https://www.mathworks.com/matlabcentral/fileexchange/25536-red-blue-colormap), MATLAB Central File Exchange. Retrieved August 9, 2021.
