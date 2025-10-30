# run on login node

INTERVAL_HOURS=6

cd /home/scur1678/ir2-project-monitor

while true; do

	echo "[RUN - $(date)] Generating report..." 
	bash generate_sbu_report.sh
	echo "[RUN - $(date)] The report is degenerated." 

       	echo "[SLEEP] Waiting $INTERVAL_HOURS hour(s)..."
       	sleep $((INTERVAL_HOURS * 3600))
done
