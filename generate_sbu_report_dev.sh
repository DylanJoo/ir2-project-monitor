#!/bin/bash
ACCOUNT="gpuuva065"
OUT_RAW="raw.txt"
OUT_MD="README.md"
BACKUP_DIR="sbu_reports"

DATE=$(date +"%Y-%m-%d %H:%M")
DATE_FILE=$(date +"%Y-%m-%d_%H-%M")

# Collect usage data
accuse --account "$ACCOUNT" --sbu -d > "$OUT_RAW"

# Build Markdown report
awk -v DATE="$DATE" -v TOTAL=2000000 '
BEGIN {
  print "# Snellius SBU Usage Report"
  print ""
  print "**Latest update:** " DATE
  print ""

  # Read group mapping (TSV)
  FS="\t"
  while ((getline < "mapping.tsv") > 0) {
    if ($1 == "Snellius account") continue;  # skip header
    user = $1
    grp  = $2
    if (grp == "" || grp == "-") grp = "UNGROUPED"
    group[user] = grp
    groups[grp] = 1
  }
  FS=" "  # restore default field splitting for accuse output
}

/^[0-9]{4}-[0-9]{2}-[0-9]{2}/ {
  date=$1; user=$3; sbu=$4;
  usage[user,date]+=sbu;
  users[user]=1; dates[date]=1;

  g = group[user]; group_usage[g] += sbu;
}
END {
  n=0;
  for (d in dates) { date_list[n++]=d }
  asort(date_list);

  print ""
  printf "| %-12s |", "User";
  for (i=1;i<=n;i++) printf " %s |", date_list[i];
	  printf " Sum | Usage (%) |\n";

  printf "|--------------|";
  for (i=1;i<=n+2;i++) printf "------------|";
  printf "\n";

  for (u in users) {
    sum=0;
    printf "| %-12s |", u;
    for (i=1;i<=n;i++) {
      val = usage[u,date_list[i]];
      if (val=="") val=0;
      printf " %8.1f |", val;
      sum+=val;
    }
    ratio = (sum / TOTAL) * 100;
    printf " %8.1f | %3.1f |\n", sum, ratio;
  }

  print ""
  print "## Group-level Usage Summary"
  print ""
  printf "| Group | Total SBU | Ratio |\n";
  printf "|-------|-----------|-------|\n";

  all_groups_total = 0
  for (g in groups) {
    total = group_usage[g] + 0
    ratio = (total / TOTAL) * 100
    all_groups_total += total
    printf "| %-8s | %9.1f | %5.1f%% |\n", g, total, ratio
  }
  all_groups_ratio = (all_groups_total / TOTAL) * 100
  printf "| %-8s | %9.1f | %5.1f%% |\n", "TOTAL", all_groups_total, all_groups_ratio

}' "$OUT_RAW" > "$OUT_MD"

# Create timestamped backup
cp "$OUT_MD" "$BACKUP_DIR/report_$DATE_FILE.md"

#  Commit and push
git add . 
git commit -m "auto update: $DATE"
git push

echo "The report is updated."
# echo "The report is updated." | mail -s "Snellius SBU usage report is updated ($DATE)" -a "$BACKUP_DIR/report_$DATE_FILE.md" j.ju@uva.nl
