function apici
    set -l workflow $argv[1]
    test -z "$workflow"; and set workflow api
    set -l branch $argv[2]
    test -z "$branch"; and set branch main
    set -l run_id (gh run list --workflow $workflow --branch $branch -L1 \
  --json databaseId -q '.[0].databaseId')
    if test -z "$run_id"
        echo "No runs found for workflow '$workflow' on branch '$branch'" >&2
        return 1
    end
    set -l jq_tmpl '
  def icon: if .status != "completed" then "\u001b[33m●\u001b[0m"
    elif .conclusion == "success" then "\u001b[32m✔\u001b[0m"
    elif .conclusion == "skipped" then "\u001b[90m–\u001b[0m"
    else "\u001b[31m✘\u001b[0m" end;
  "\u001b[1m" + (.headSha[0:8]) + "\u001b[0m  " + .displayTitle
  + "  [" + (.status) + (if (.conclusion // "") != "" then " / " + .conclusion else "" end) + "]",
  (.jobs[] | "  " + (. | icon) + " " + .name
    + "  \u001b[90m" + (.status) + (if (.conclusion // "") != "" then "/" + .conclusion else "" end) + "\u001b[0m")'
    while true
        set -l snapshot (gh run view $run_id \
    --json headSha,displayTitle,status,conclusion,jobs -q $jq_tmpl)
        clear
        echo "$workflow @ $branch  ·  run $run_id  ·  "(date +%H:%M:%S)
        printf '%s\n' $snapshot
        set -l overall (gh run view $run_id --json status -q .status)
        test "$overall" = completed; and break
        sleep 5
    end
end
