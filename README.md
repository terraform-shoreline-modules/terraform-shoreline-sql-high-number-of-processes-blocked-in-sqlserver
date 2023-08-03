
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# High number of processes blocked in SQLServer
---

This incident type involves a high number of processes being blocked in SQLServer. It may cause delays or errors in database operations and can impact the performance of the system.

### Parameters
```shell
# Environment Variables

export SQLSERVER="PLACEHOLDER"

export SERVER_NAME="PLACEHOLDER"

export DATABASE_NAME="PLACEHOLDER"

export TABLE_NAME="PLACEHOLDER"

export PATH_TO_ERROR_LOG_FILE="PLACEHOLDER"



```

## Debug

### Next Step
```shell
powershell

# 1. Check the CPU usage of the SQLServer process.

Get-Process -Name ${SQLSERVER} | Select-Object -Property CPU
```

### 2. Check the memory usage of the SQLServer process.
```shell
Get-Process -Name ${SQLSERVER} | Select-Object -Property WorkingSet
```

### 3. Check the blocked processes in SQLServer.
```shell
Invoke-Sqlcmd -ServerInstance ${SERVER_NAME} -Database ${DATABASE_NAME} -Query "SELECT * FROM sys.dm_exec_requests WHERE blocking_session_id <> 0"
```

### 4. Check the top queries that are causing the blocking.
```shell
Invoke-Sqlcmd -ServerInstance ${SERVER_NAME} -Database ${DATABASE_NAME} -Query "SELECT TOP 10 * FROM sys.dm_exec_query_stats CROSS APPLY sys.dm_exec_sql_text(plan_handle) WHERE execution_count > 0 AND last_execution_time > DATEADD(minute, -5, GETDATE()) ORDER BY total_worker_time DESC"
```

### 5. Check the current state of the SQLServer.
```shell
Get-Service -Name ${SQLSERVER}
```

### 6. Check the SQLServer error logs for any relevant messages.
```shell
Get-Content "${PATH_TO_ERROR_LOG_FILE}" | Select-String -Pattern "blocked", "error", "warning"
```

## Repair

### Define input parameters
```shell
DB_NAME=${DATABASE_NAME}

TABLE_NAME=${TABLE_NAME}
```

### Check for inefficient queries
```shell
echo "Checking for inefficient queries in ${DB_NAME}..."

inefficient_queries=$(sqlcmd -S ${SERVER_NAME} -U ${USERNAME} -P ${PASSWORD} -d ${DB_NAME} -Q "SELECT query FROM sys.dm_exec_query_stats CROSS APPLY sys.dm_exec_sql_text(plan_handle) WHERE text LIKE '%${TABLE_NAME}%' ORDER BY total_worker_time DESC")

if [[ -z "${inefficient_queries}" ]]; then

    echo "No inefficient queries found."

else

    echo "Inefficient queries found:"

    echo "${inefficient_queries}"

fi
```

### Kill any long-running or blocking processes manually or automatically using a script.
```shell

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


```

### Check the database for inefficiencies in queries or indexes that could potentially cause blocking. Optimize the queries or add indexes to improve performance.
```shell


# Define variables
 USERNAME="PLACEHOLDER"
 PASSWORD="PLACEHOLDER"
 SERVERINSTANCE="PLACEHOLDER"
 COLUMN_NAME="PLACEHOLDER"
 INDEX_NAME="PLACEHOLDER"



# Check for inefficiencies in queries or indexes

sqlcmd -S $SERVERINSTANCE -d ${DATABASE_NAME} -U $USERNAME -P $PASSWORD -Q "SET NOCOUNT ON; SELECT TOP 10 * FROM sys.dm_exec_requests"

sqlcmd -S $SERVERINSTANCE -d ${DATABASE_NAME} -U $USERNAME -P $PASSWORD -Q "SET NOCOUNT ON; SELECT TOP 10 * FROM sys.dm_exec_sessions"

sqlcmd -S $SERVERINSTANCE -d ${DATABASE_NAME} -U $USERNAME -P $PASSWORD -Q "SET NOCOUNT ON; SELECT TOP 10 * FROM sys.dm_exec_query_stats"



# Optimize queries or add indexes

sqlcmd -S $SERVERINSTANCE -d $database_name -U $USERNAME -P $databasePASSWORD_password -Q "SET NOCOUNT ON; EXEC sp_helpindex '${TABLE_NAME}'"

sqlcmd -S $SERVERINSTANCE -d $database_name -U $USERNAME -P $PASSWORD -Q "SET NOCOUNT ON; CREATE INDEX ${INDEX_NAME} ON ${TABLE_NAME} (${COLUMN_NAME})"



# Exit script

exit 0


```