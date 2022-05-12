# Artifacts for RunD

This repository contains the test scripts and raw data used in the RunD paper. The paper has been accepted by ATC 22'.

## Experiment Setup

The hardware we used for experiment is an `ecs.ebmg6.26xlarge` instance from Aliyun. The specification is as follow:

| Item    | Spec                                         |
| ------- | -------------------------------------------- |
| CPU     | Intel Xeon(Cascade Lake) Platinum 8269CY     |
| Cores   | 104                                          |
| Memory  | 384 GiB                                      |
| Storage | Two ESSDs: 100GB + 500GB                     |
| OS      | Aliyun Cloud OS 2, with Linux kernel 4.19.91 |

## RunD Experiment

The source code of RunD is submitted to the Kata community, and most of them are still under review. The related commits in Kata community are listed as follows:
xxxxxxxxxxx

Considering that some related binary packages and binaries are tightly integrated with our internal system, we provide a screencast of the tool along with the results in our artifact.

Refer to video: [ATC_RunD_AE.mp4](ATC_RunD_AE.mp4).

Test scripts used in the video are also provided in the `script` directory. Logs and analysis results are provided in the `ae_data` directory.

## Baseline Experiment

### Install

We are using containerd 1.5.2 and kata-containers 2.2.3 for the baseline experiments. Follow the instructions to install them:

1.  Download and unzip.

   ```bash
   wget https://github.com/containerd/containerd/releases/download/v1.5.2/cri-containerd-cni-1.5.2-linux-amd64.tar.gz
   wget https://github.com/kata-containers/kata-containers/releases/download/2.2.3/kata-static-2.2.3-x86_64.tar.xz
   tar xf cri-containerd-cni-1.5.2-linux-amd64.tar.gz -C /
   tar xf kata-static-2.2.3-x86_64.tar.xz -C /
   ```

2. Copy our config files.

   ```bash
   mkdir -p /etc/containerd /etc/kata-containers
   cp ./config/config.toml /etc/containerd/config.toml
   cp ./config/configuration-* /etc/kata-containers/
   ```

3. Setup volume pool for device mapper.

   ```bash
   ./script/dmsetup.sh
   ```

4. According to an issue of kata-containers ([here](https://github.com/kata-containers/kata-containers/issues/3121)), kernel and initrd image from kata-containers 2.0.4 are required in kata-template experiment.

   ```bash
   wget https://github.com/kata-containers/kata-containers/releases/download/2.0.4/kata-static-2.0.4-x86_64.tar.xz
   mkdir kata204
   tar xf kata-static-2.0.4-x86_64.tar.xz -C ./kata204
   cp ./kata204/opt/kata/share/kata-containers/vmlinux-5.4.71-84 /opt/kata/share/kata-containers/vmlinux204.container
   cp ./kata204/opt/kata/share/kata-containers/kata-containers-initrd_alpine_2.0.4_agent_8b9607a742.initrd /opt/kata/share/kata-containers/kata-containers-initrd204.img
   ```

5. Start containerd.

   ```bash
   systemctl start containerd
   ```

6. Install dependencies

   ```
   mkdir result
   pip3 install pandas
   yum install smem
   ```

### High-concurrency Experiment (Section 5.2)

Scripts `time_kata_test.sh`, `time_katafc_test.sh`, and `time_katatemplate_test.sh` can run the high-concurrency test for kata-qemu, kata-fc and kata-template. 

- Run high-concurrency tests.

  ```bash
  ./script/time_kata_test.sh
  ./script/time_katafc_test.sh
  ./script/time_katatemplate_test.sh
  ```

They may takes several hours to finish. To shorten the time, some concurrency tests can be removed by removing the corresponding concurrency setting in file `time_test.conf`. The scripts will create a directory named like `time_kata_05120948` to store the logs. 

We provide python scripts to analyze logs from the tests.

- Analyze results from high-concurrency tests.

  ```bash
  python3 data/time.py
  python3 data/cpu.py
  ```

The python script will create two csv files in the result directory: `time.csv` and `cpu.csv`. Each line in the csv file indicates the average cold-start latency and cpu time of a container runtime.

### High-density Experiment (Section 5.3)

Scripts `mem_kata_test.sh`, `mem_katafc_test.sh`, and `mem_katatemplate_test.sh` can run the high-density test for kata-qemu, kata-fc and kata-template. 

- Run high-density tests.

  ```bash
  ./script/mem_kata_test.sh
  ./script/mem_katafc_test.sh
  ./script/mem_katatemplate_test.sh
  ```

Density and memory capacity of containers in the tests can be changed in the file `mem_test.conf`. The scripts will create a directory named like `mem_kata_05120948` to store the logs.

We provide python scripts to analyze logs from the tests.

- Analyze results from high-density tests.

  ```bash
  python3 data/mem.py
  ```

The python script will create a csv file for each runtime, named like `mem_kata.csv`, containing the average memory consumption of containers with different memory capacity in different density.

### Density Impact on Concurrency Experiment (Section 5.4)

Scripts `density_kata_test.sh`, `density_katafc_test.sh`, and `density_katatemplate_test.sh` can run the high-density test for kata-qemu, kata-fc and kata-template. 

- Run high-density tests.

  ```bash
  ./script/density_kata_test.sh
  ./script/density_katafc_test.sh
  ./script/density_katatemplate_test.sh
  ```

The background density and the concurrency of the tests can be changed in the file `density_test.conf`. The scripts will create a directory named like `density_kata_05120948` to store the logs.

We provide python scripts to analyze logs from the tests.

- Analyze results from high-density tests.

  ```bash
  python3 data/density.py
  ```

The python script will create a csv file for each runtime, named like `density_kata.csv`, containing the average cold-start latency under different background densities and concurrencies.

## Directory Structure

`script`: test scripts.

`data`: python scripts for data analysis.

`config`: configuration file for containerd and kata-containers.

`ae_data`: raw logs and analysis results in the RunD AE video.

`paper_data`: raw logs and analysis results used in the paper.
