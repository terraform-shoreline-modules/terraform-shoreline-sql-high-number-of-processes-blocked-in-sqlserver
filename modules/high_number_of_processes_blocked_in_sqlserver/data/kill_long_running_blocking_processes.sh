
# Define variables
 USERNAME="PLACEHOLDER"
 PASSWORD="PLACEHOLDER"
 SERVERINSTANCE="PLACEHOLDER"


# Define the query to find long-running or blocking processes

$Query = "SELECT session_id, status, blocking_session_id, wait_type, wait_time, wait_resource, command, last_wait_type, cpu_time, total_elapsed_time FROM sys.dm_exec_sessions WHERE is_user_process = 1 AND (status = 'running' OR blocking_session_id <> 0)"



# Get the list of processes to kill

$Processes = Invoke-Sqlcmd -Query $Query -ServerInstance ${SERVERINSTANCE} -Database ${DATABASE}



# Loop through the processes and kill them

ForEach ($Process in $Processes) {

    Write-Host "Killing process ID $($Process.session_id)..."

    Invoke-Sqlcmd -Query "KILL $($Process.session_id)" -ServerInstance ${SERVERINSTANCE} -Database ${DATABASE}

}



# Print a message to indicate completion

Write-Host "All long-running or blocking processes have been killed."