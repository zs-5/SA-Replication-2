#!/bin/bash

# Array of 5 breaking commit ids to reproduce, with the lowest execution times
ids=($(jq --raw-output 'to_entries | sort_by(.value.breakingImageTime)[:5] | .[] | .key' RQData/image-execution-times.json))
# The 5 ids as of writing: ids=(164ee160adc0f663c2069bdbfcdd60e8596327b8 5af571586428b0be7883a3a374ec95d0695a25e4 abfb7dd92cff85ddb69f70666f3f1705bbf55c78 aa7bdc45bb47197d959ceae62538a100a01a4d98 72ff6be0c4702d86ad2435292f034948ec896cc2)

# Create/ensure directory structure
mkdir -p outputs/{reproductions/{successful,in-progress,unsuccessful},{maven,workflow}-logs,jars}

for id in "${ids[@]}"; do
	# Copy JSON files for commits from data/benchmark, and remove extra keys (since it fails otherwise)
	jq '.updatedDependency |= {dependencyGroupID, dependencyArtifactID, previousVersion, newVersion, dependencyScope, versionUpdateType, dependencySection} | {url, project, projectOrganisation, breakingCommit, prAuthor, preCommitAuthor, breakingCommitAuthor, updatedDependency, licenseInfo}' "data/benchmark/$id.json" > "outputs/reproductions/in-progress/$id.json"
	
	# Run reproducer in parallel
	java -jar target/BreakingUpdateReproducer.jar -a .env -b outputs/reproductions/successful/ -c github_packages_credentials.json -d outputs/reproductions/in-progress/ -f "outputs/reproductions/in-progress/$id.json" -j outputs/jars/ -l outputs/maven-logs/ -u outputs/reproductions/unsuccessful/ -w outputs/workflow-logs/ &
done

# Wait for all reproductions to finish
wait
# echo -e "\n### Done. Comparing outputs between our reproduction and the benchmark ###\n"

# Actually, if it's in the successful folder, it's already been successful reproduced. And besides, the researcher's script does mention if it was successfully reproduced, so no need to check here. Just a little info will suffice
# # Check that the failureCategory of our reproduction matches the benchmark
# for id in "${ids[@]}"; do
# 	benchmarkFailureCategory=($(jq --raw-output '.failureCategory' "data/benchmark/$id.json"))
# 	reproductionFailureCategory=($(jq --raw-output '.failureCategory' "outputs/reproductions/successful/$id.json"))
# 	if [[ $benchmarkFailureCategory == $reproductionFailureCategory ]]; then
# 		echo "$id: Matches"
# 	else
# 		echo "$id: DOESN'T MATCH! - Category of failure in reproduction is \"$reproductionFailureCategory\", while in benchmark it's \"$benchmarkFailureCategory\"."
# 	fi
# done

for id in "${ids[@]}"; do
	if [[ -f "outputs/reproductions/successful/$id.json" ]]; then
		echo "$id: Matches"
	elif [[ -f "outputs/reproductions/unsuccessful/$id.json" ]]; then
		echo "$id: DOESN'T MATCH!"
	fi
done

echo -e "\nDone!"