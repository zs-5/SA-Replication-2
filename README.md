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
reproduces five individual breaking updates using the provided Docker images. 
We additionally extend the original mining methodology to ten Java/Maven 
projects — five from the original dataset and five new ones — targeting pull 
requests submitted after the original collection cut-off date.

---

## 2. Repository Structure
```
README.md                   # This file
datasets/                   # Data used in the replication
    metadata/               # JSON metadata files for all 571 breaking updates
                            # downloaded from the original BUMP repository
    selected_updates/       # JSON files for the 5 manually reproduced updates
    extended_mining/        # Data for the 10 projects used in the extended 
                            # mining task (5 original + 5 new)
replication_scripts/        # Scripts used in the replication
    classify_failures.py    # Script to parse build logs and classify failures
                            # into the 5 categories from Table II
    run_reproductions.sh    # Shell script to pull and run the 5 selected
                            # Docker image pairs for manual reproduction
    run_miner.sh            # Shell script to run the BUMP miner against
                            # the 10 selected projects
outputs/                    # Generated results
    table2_replication.csv  # Our failure category counts vs. paper's Table II
    reproduction_results.md # Results of the 5 manual reproductions
    mining_results.csv      # Output of the extended mining task for all
                            # 10 projects
logs/                       # Console output and build logs
    docker_logs/            # Build logs from Docker image executions
    miner_logs/             # Console output from running the BUMP miner
notes/                      # Notes taken during replication
    discrepancies.md        # Notes on any discrepancies observed vs. 
                            # the original paper
    setup_issues.md         # Notes on setup and configuration issues 
                            # encountered
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
- **Python**: 3.9 or higher (for log parsing scripts)
  - Required packages: `pip install -r requirements.txt`
- **GitHub Personal Access Token**: required to run the BUMP miner
  - Generate one at https://github.com/settings/tokens with `repo` and 
    `read:packages` scopes

### Installation Steps

1. **Clone this repository**
```bash
   git clone https://github.com/zs-5/SA-Replication-2.git
   cd YOUR_REPO_HERE
```

2. **Clone the original BUMP repository**
```bash
   git clone https://github.com/chains-project/bump
```

3. **Download the BUMP metadata files**
```bash
   cp -r bump/data/breaking-updates/ datasets/metadata/
```

4. **Set up your GitHub token for the miner**
```bash
   export GITHUB_TOKEN=your_token_here
```

5. **Install Python dependencies**
```bash
   pip install -r requirements.txt
```

6. **Authenticate with the GitHub Docker registry to pull BUMP images**
```bash
   echo $GITHUB_TOKEN | docker login ghcr.io -u YOUR_GITHUB_USERNAME --password-stdin
```

### Reproducing Table II

Run the failure classification script against the full metadata set:
```bash
python replication_scripts/classify_failures.py \
    --metadata datasets/metadata/ \
    --output outputs/table2_replication.csv
```
Results will be written to `outputs/table2_replication.csv` and printed 
to the console for direct comparison with Table II of the paper.

### Reproducing the 5 Manual Breaking Updates
```bash
bash replication_scripts/run_reproductions.sh
```
This script pulls and runs both Docker images for each of the 5 selected 
breaking updates. Logs are saved to `logs/docker_logs/`. Results are 
summarized in `outputs/reproduction_results.md`.

### Running the Extended Miner
```bash
bash replication_scripts/run_miner.sh
```
This script runs the BUMP miner against all 10 projects. Ensure your 
`GITHUB_TOKEN` environment variable is set before running. Output is 
saved to `outputs/mining_results.csv` and logs to `logs/miner_logs/`.

---

## 4. GenAI Usage

Claude (Anthropic) was used during this replication for two purposes: 
improving the readability and clarity of this README, and providing 
guidance on Java and Maven usage conventions encountered during the 
reproduction process. All technical decisions, experimental results, 
and analysis are the work of the replication team.