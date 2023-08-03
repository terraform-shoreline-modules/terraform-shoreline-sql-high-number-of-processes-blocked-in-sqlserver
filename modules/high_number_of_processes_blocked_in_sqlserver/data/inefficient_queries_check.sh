echo "Checking for inefficient queries in ${DB_NAME}..."

inefficient_queries=$(sqlcmd -S ${SERVER_NAME} -U ${USERNAME} -P ${PASSWORD} -d ${DB_NAME} -Q "SELECT query FROM sys.dm_exec_query_stats CROSS APPLY sys.dm_exec_sql_text(plan_handle) WHERE text LIKE '%${TABLE_NAME}%' ORDER BY total_worker_time DESC")

if [[ -z "${inefficient_queries}" ]]; then

    echo "No inefficient queries found."

else

    echo "Inefficient queries found:"

    echo "${inefficient_queries}"

fi