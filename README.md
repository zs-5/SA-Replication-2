# BUMP Replication Study

## 1. Project Title and Overview

- **Paper Title**: BUMP: A Benchmark of Reproducible Breaking Dependency Updates
- **Authors**: Frank Reyes, Yogya Gamage, Gabriel Skoglund, Benoit Baudry, 
  Martin Monperrus
- **Replication Team**: John Yun Moe & Zavier Shaikh
- **Course**: CS-UH 3260 Software Analytics, NYUAD

### Original Paper
BUMP is a benchmark of 571 reproducible breaking dependency updates collected 
from 153 real-world Java/Maven projects on GitHub. Each breaking update 
corresponds to a pull request that bumps a single dependency version and causes 
the project's CI build to fail. The benchmark packages each breaking update as 
a pair of Docker images, ensuring long-term reproducibility across platforms.

### This Replication
This replication study reproduces Table II of the original paper by 
re-classifying all 571 breaking updates by failure category, and manually 
reproduces five individual breaking updates using the provided Java program. 
We additionally extend the original mining methodology to ten Java/Maven 
projects (five from the original dataset and five new ones) targeting pull 
requests submitted after the original collection cut-off date.

---

## 2. Repository Structure
```
README.md                         # This file
benchmark-data                    # Will contain the JSON metadata files for all 571 breaking
                                  # updates downloaded from the original BUMP repository
scripts/                          # Scripts used in the replication
    calculate_failure_stats.sh    # Script to build table of failure categories
    reproduce_breaking_commits.sh # Script to reproduce 5 breaking updates
output/                           # Generated results
    parallel/                     # Output of reproducing 5 breaking updates,
                                  # as they were done with GNU parallel
    miner/                        # Contains the repos.json file used, and
                                  # the corresponding breaking updates found
notes/                            # Notes taken during replication
    discrepancies.md              # Notes on any discrepancies observed vs. 
                                  # the original paper
```

---

## 3. Setup Instructions

### Prerequisites

- **OS**: Linux (Ubuntu 22.04 LTS recommended) or Windows 11 with WSL2
- **Docker**: version 23.0.3 or higher
  - Installation: https://docs.docker.com/engine/install/
- **Java**: OpenJDK 11
  - `sudo apt install openjdk-11-jdk`
- **Apache Maven**: 3.9.2 or higher
  - `sudo apt install maven`
<!-- - **Python**: 3.9 or higher (for log parsing scripts)
  - Required packages: `pip install -r requirements.txt` -->
- **GitHub Personal Access Token**: required to run the BUMP miner
  - Generate one at https://github.com/settings/tokens with `repo` and 
    `read:packages` scopes

### Installation Steps

1. **Clone this repository**
```bash
git clone https://github.com/zs-5/SA-Replication-2.git
```
2. **Clone the original BUMP repository**
```bash
git clone https://github.com/chains-project/bump
```

3. **Download the required BUMP metadata files and java jars (after building)**
```bash
mkdir SA-Replication-2/{benchmark-data,target}
cp -r bump/data/benchmark/ SA-Replication-2/benchmark-data/
cp -r bump/target/*.jar SA-Replication-2/target/
```

4. **Set up your GitHub token for the miner**
   <!-- export GITHUB_TOKEN=<your_token_here> -->
```bash
  echo "your_token" > .env
```

<!-- 5. **Install Python dependencies**
```bash
   pip install -r requirements.txt
``` -->

<!-- 6. **Authenticate with the GitHub Docker registry to pull BUMP images**
```bash
   echo $GITHUB_TOKEN | docker login ghcr.io -u YOUR_GITHUB_USERNAME --password-stdin
``` -->

### Reproducing Table II

Run the failure classification script against the full metadata set:
```bash
./scripts/calculate_failure_stats.sh
```
Results will be printed to the console for direct comparison with Table II of the paper.

Also run the following to execute all breaking updates
```bash
parallel --use-cores-instead-of-threads -j 75% --delay 2 --bar -t -v -v --output-as-files --results out podman run --network none ghcr.io/chains-project/breaking-updates:{}-breaking ::: $(cat ./all_ids)
```

### Reproducing the 5 Manual Breaking Updates
```bash
bash replication_scripts/reproduce_breaking_commits.sh
```
This script runs the reproducer for each of the 5 selected 
breaking updates. Logs are saved `outputs/reproductions`.

### Running the Extended Miner
```bash
java -jar target/BreakingUpdateMiner.jar mine -a .env -o output/miner/ -r output/miner/repos.json
```
This script runs the BUMP miner against all 10 projects. Ensure your 
GitHub token is saved in `.env` before running. Output is 
saved to `output/miner`.

---

## 4. GenAI Usage

Claude (Anthropic) was used during this replication for two purposes: 
improving the readability and clarity of this README, and providing 
guidance on Java and Maven usage conventions encountered during the 
reproduction process. All technical decisions, experimental results, 
and analysis are the work of the replication team.