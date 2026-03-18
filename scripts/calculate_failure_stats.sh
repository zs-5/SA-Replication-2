#!/bin/bash
# This script will perform some rudimentary analysis of the number of breaking updates found
# and the status of reproduction.

# This script is just a slight modification of calculate_stats.sh provided by the original authors, to output a table instead

function get_fraction_as_percentage() {
  fraction=$(bc -l <<< "($1 * 100) / ($2 * 100) * 100")
  LC_NUMERIC=en_US.UTF-8 printf "%0.2f%%" "$fraction"
}

# Calculate numbers concerning the reproduction process.
num_compilation_failure=$(grep -ro "\"COMPILATION_FAILURE\"" data/benchmark | wc -l)
num_test_failure=$(grep -ro "\"TEST_FAILURE\"" data/benchmark | wc -l)
num_enforcer_failure=$(grep -ro "\"ENFORCER_FAILURE\"" data/benchmark | wc -l)
num_dependency_lock_failure=$(grep -ro "\"DEPENDENCY_LOCK_FAILURE\"" data/benchmark | wc -l)
num_dependency_resolution_failure=$(grep -ro "\"DEPENDENCY_RESOLUTION_FAILURE\"" data/benchmark | wc -l)
num_reproduced=$(find data/benchmark -iname "*.json" | wc -l)
num_unique_projects=$(jq -r '"\(.projectOrganisation)/\(.project)"' data/benchmark/*.json | sort -u | wc -l)

# Normal table
# echo "
# Failure category              | Number of breaking updates
# ------------------------------+----------------------------
# Compilation failure           | $num_compilation_failure ($(get_fraction_as_percentage "$num_compilation_failure" "$num_reproduced"))
# Test failure                  | $num_test_failure ($(get_fraction_as_percentage "$num_test_failure" "$num_reproduced"))
# Enforcer failure              | $num_enforcer_failure ($(get_fraction_as_percentage "$num_enforcer_failure" "$num_reproduced"))               
# Dependency lock failure       | $num_dependency_lock_failure ($(get_fraction_as_percentage "$num_dependency_lock_failure" "$num_reproduced")) 
# Dependency resolution failure | $num_dependency_resolution_failure ($(get_fraction_as_percentage "$num_dependency_resolution_failure" "$num_reproduced"))
# "

# Fancy table (made manually with characters from https://en.wikipedia.org/wiki/Box-drawing_characters)
printf "
╭────────────────────────────────────────────────────────────╮
│ Failure category              │ Number of breaking updates │
│╶──────────────────────────────┼───────────────────────────╴│
│ Compilation failure           │ %17s (%6s) │
│ Test failure                  │ %17s (%6s) │
│ Enforcer failure              │ %17s (%6s) │
│ Dependency lock failure       │ %17s (%6s) │
│ Dependency resolution failure │ %17s (%6s) │
╰────────────────────────────────────────────────────────────╯

Based on $num_reproduced reproducible breaking updates from $num_unique_projects unique projects.
" \
"$num_compilation_failure"           "$(get_fraction_as_percentage "$num_compilation_failure" "$num_reproduced")"     \
"$num_test_failure"                  "$(get_fraction_as_percentage "$num_test_failure" "$num_reproduced")"            \
"$num_enforcer_failure"              "$(get_fraction_as_percentage "$num_enforcer_failure" "$num_reproduced")"        \
"$num_dependency_lock_failure"       "$(get_fraction_as_percentage "$num_dependency_lock_failure" "$num_reproduced")" \
"$num_dependency_resolution_failure" "$(get_fraction_as_percentage "$num_dependency_resolution_failure" "$num_reproduced")"
