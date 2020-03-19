$ErrorActionPreference = "Stop"

function TestSqlServerInstance($SQL_INSTANCE_NAME) {
  Write-Host "Starting SQL Server instance: $SQL_INSTANCE_NAME"
  Start-Service "MSSQL`$$SQL_INSTANCE_NAME"
  cmd /c sqlcmd -S localhost -U SA -P Password12! -Q "select @@VERSION"
  Write-Host 'Testing connectivity with named instance over named pipes'
  $env:connection_string_with_instance = "Server=(local)\$SQL_INSTANCE_NAME;Database=master;User ID=sa;Password=Password12!"
  $conn = New-Object System.Data.SqlClient.SqlConnection
  $conn.ConnectionString = $env:connection_string_with_instance
  $conn.Open()
  $cmd = New-Object System.Data.SqlClient.SqlCommand("SELECT * FROM information_schema.tables", $conn)
  $reader = $cmd.ExecuteReader()
  while($reader.Read()){
    Write-Host "Table: $($reader["table_name"])"
  }
  $conn.Close()
  
  Write-Host 'Testing connectivity with localhost (TCP/IP 1433)'
  $env:connection_string_localhost = "Server=localhost;Database=master;User ID=sa;Password=Password12!"
  $conn = New-Object System.Data.SqlClient.SqlConnection
  $conn.ConnectionString = $env:connection_string_localhost
  $conn.Open()
  $cmd = New-Object System.Data.SqlClient.SqlCommand("SELECT * FROM information_schema.tables", $conn)
  $reader = $cmd.ExecuteReader()
  while($reader.Read()){
    Write-Host "Table: $($reader["table_name"])"
  }
  $conn.Close()
  Write-Host "Stopping SQL Server instance: $SQL_INSTANCE_NAME"
  Stop-Service "MSSQL`$$SQL_INSTANCE_NAME"
}

$SQL_INSTANCES = @('SQL2008R2SP2', 'SQL2012SP1', 'SQL2014', 'SQL2016', 'SQL2017')

if (test-path "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community") {
  $SQL_INSTANCES = @('SQL2014', 'SQL2016', 'SQL2017')
}

if ((test-path "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community") -or (test-path "C:\Program Files (x86)\Microsoft Visual Studio\2019\Preview")) {
  $SQL_INSTANCES = @('SQL2017', 'SQL2019')
}

foreach($SQL_INSTANCE_NAME in $SQL_INSTANCES) {
  TestSqlServerInstance $SQL_INSTANCE_NAME
}
