# run on login node

INTERVAL_HOURS=12

cd /home/scur1678/ir2-project-monitor

while true; do

	echo "[RUN] [$(date)] Generating report..." 
	bash generate_sbu_report.sh
	REPORT_PID=$!
	echo "[RUN] The PID for the report monitor is: $REPORT_PID"
	echo "[RUN] [$(date)] The report is degenerated and updated..." 

       	echo "[SLEEP] Waiting $INTERVAL_HOURS hour(s)..."
       	sleep $((INTERVAL_HOURS * 3600))
done
