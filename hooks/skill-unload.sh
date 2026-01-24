#!/usr/bin/env bash
# skill-unload.sh - Stop hook to remind Claude to re-evaluate skills
#
# Stop hooks must output valid JSON. This hook outputs a continue decision
# with a system message to remind Claude about skill re-evaluation.

# Output valid JSON for Stop hook
jq -n '{
  "systemMessage": "<skill-unload>Skills from this task are now unloaded. Re-evaluate skill needs for the next task.</skill-unload>"
}'
