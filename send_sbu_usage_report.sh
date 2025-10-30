#!/bin/bash
ACCOUNT="gpuuva065"
WORKDIR="$HOME/sbu_reports"
mkdir -p "$WORKDIR"

OUT_RAW="$WORKDIR/raw.txt"
OUT_CSV="$WORKDIR/report.csv"
DATE=$(date +"%Y-%m-%d_%H-%M")

# Collect usage
accuse --account "$ACCOUNT" --sbu -d > "$OUT_RAW"

# Convert to CSV summary
awk -v OFS=',' '
/^[0-9]{4}-[0-9]{2}-[0-9]{2}/ {
  date=$1; user=$3; sbu=$4;
  usage[user,date]+=sbu;
  users[user]=1; dates[date]=1;
}
END {
  n=0;

  for (d in dates) { date_list[n++]=d }
  asort(date_list);

  printf "User";
  for (i=1;i<=n;i++) printf ",%s", date_list[i];
  printf ",Sum\n";

  for (u in users) {
    sum=0;
    printf "%s", u;
    for (i=1;i<=n;i++) {
      val = usage[u,date_list[i]];
      if (val=="") val=0;
      printf ",%.1f", val;
      sum+=val;
    }
    printf ",%.1f\n", sum;
  }
}' "$OUT_RAW" > "$OUT_CSV"

# Timestamped backup
cp "$OUT_CSV" "$WORKDIR/report_$DATE.csv"

# Email the CSV as attachment
echo "Attached is the SBU usage report $ACCOUNT until $DATE." | mail -s "Snellius SBU usage report of IR2 students ($DATE)" -a "$WORKDIR/report_$DATE.csv" j.ju@uva.nl

