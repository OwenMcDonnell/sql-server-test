$ErrorActionPreference = "Stop"
Install-Module sqlserver -Force -AllowClobber -AcceptLicense
$SQL_INSTANCE_NAME = $env:SQL_INSTANCE_NAME

Write-Host "Starting SQL Server instance: $SQL_INSTANCE_NAME" -ForegroundColor Cyan
Start-Service "MSSQL`$$SQL_INSTANCE_NAME"
Write-Host 'Service started...'
Write-Host "$env:computername\$SQL_INSTANCE_NAME"
Get-InstalledModule -Name "sqlserver"
Get-SqlInstance -ServerInstance "APPVEYOR-VM\SQL2022" | Set-SqlNetworkConfiguration -Protocol TCP -Port 1433 -ForceServiceRestart -AcceptSelfSignedCertificate

#Get-Service | Where {$_.status -eq 'running' -and $_.DisplayName -match "sql server*"}
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
