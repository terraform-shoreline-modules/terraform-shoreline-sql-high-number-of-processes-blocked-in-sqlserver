resource "shoreline_notebook" "high_number_of_processes_blocked_in_sqlserver" {
  name       = "high_number_of_processes_blocked_in_sqlserver"
  data       = file("${path.module}/data/high_number_of_processes_blocked_in_sqlserver.json")
  depends_on = [shoreline_action.invoke_cpu_usage_sqlserver,shoreline_action.invoke_rename_script,shoreline_action.invoke_inefficient_queries_check,shoreline_action.invoke_kill_long_running_blocking_processes,shoreline_action.invoke_optimize_indexes_queries]
}

resource "shoreline_file" "cpu_usage_sqlserver" {
  name             = "cpu_usage_sqlserver"
  input_file       = "${path.module}/data/cpu_usage_sqlserver.sh"
  md5              = filemd5("${path.module}/data/cpu_usage_sqlserver.sh")
  description      = "Next Step"
  destination_path = "/agent/scripts/cpu_usage_sqlserver.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "rename_script" {
  name             = "rename_script"
  input_file       = "${path.module}/data/rename_script.sh"
  md5              = filemd5("${path.module}/data/rename_script.sh")
  description      = "Define input parameters"
  destination_path = "/agent/scripts/rename_script.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "inefficient_queries_check" {
  name             = "inefficient_queries_check"
  input_file       = "${path.module}/data/inefficient_queries_check.sh"
  md5              = filemd5("${path.module}/data/inefficient_queries_check.sh")
  description      = "Check for inefficient queries"
  destination_path = "/agent/scripts/inefficient_queries_check.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "kill_long_running_blocking_processes" {
  name             = "kill_long_running_blocking_processes"
  input_file       = "${path.module}/data/kill_long_running_blocking_processes.sh"
  md5              = filemd5("${path.module}/data/kill_long_running_blocking_processes.sh")
  description      = "Kill any long-running or blocking processes manually or automatically using a script."
  destination_path = "/agent/scripts/kill_long_running_blocking_processes.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "optimize_indexes_queries" {
  name             = "optimize_indexes_queries"
  input_file       = "${path.module}/data/optimize_indexes_queries.sh"
  md5              = filemd5("${path.module}/data/optimize_indexes_queries.sh")
  description      = "Check the database for inefficiencies in queries or indexes that could potentially cause blocking. Optimize the queries or add indexes to improve performance."
  destination_path = "/agent/scripts/optimize_indexes_queries.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_cpu_usage_sqlserver" {
  name        = "invoke_cpu_usage_sqlserver"
  description = "Next Step"
  command     = "`chmod +x /agent/scripts/cpu_usage_sqlserver.sh && /agent/scripts/cpu_usage_sqlserver.sh`"
  params      = ["SQLSERVER"]
  file_deps   = ["cpu_usage_sqlserver"]
  enabled     = true
  depends_on  = [shoreline_file.cpu_usage_sqlserver]
}

resource "shoreline_action" "invoke_rename_script" {
  name        = "invoke_rename_script"
  description = "Define input parameters"
  command     = "`chmod +x /agent/scripts/rename_script.sh && /agent/scripts/rename_script.sh`"
  params      = ["DATABASE_NAME","TABLE_NAME"]
  file_deps   = ["rename_script"]
  enabled     = true
  depends_on  = [shoreline_file.rename_script]
}

resource "shoreline_action" "invoke_inefficient_queries_check" {
  name        = "invoke_inefficient_queries_check"
  description = "Check for inefficient queries"
  command     = "`chmod +x /agent/scripts/inefficient_queries_check.sh && /agent/scripts/inefficient_queries_check.sh`"
  params      = ["TABLE_NAME","SERVER_NAME"]
  file_deps   = ["inefficient_queries_check"]
  enabled     = true
  depends_on  = [shoreline_file.inefficient_queries_check]
}

resource "shoreline_action" "invoke_kill_long_running_blocking_processes" {
  name        = "invoke_kill_long_running_blocking_processes"
  description = "Kill any long-running or blocking processes manually or automatically using a script."
  command     = "`chmod +x /agent/scripts/kill_long_running_blocking_processes.sh && /agent/scripts/kill_long_running_blocking_processes.sh`"
  params      = []
  file_deps   = ["kill_long_running_blocking_processes"]
  enabled     = true
  depends_on  = [shoreline_file.kill_long_running_blocking_processes]
}

resource "shoreline_action" "invoke_optimize_indexes_queries" {
  name        = "invoke_optimize_indexes_queries"
  description = "Check the database for inefficiencies in queries or indexes that could potentially cause blocking. Optimize the queries or add indexes to improve performance."
  command     = "`chmod +x /agent/scripts/optimize_indexes_queries.sh && /agent/scripts/optimize_indexes_queries.sh`"
  params      = ["DATABASE_NAME","TABLE_NAME"]
  file_deps   = ["optimize_indexes_queries"]
  enabled     = true
  depends_on  = [shoreline_file.optimize_indexes_queries]
}

