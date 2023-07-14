# Stop the console application
$processName = "AWSCOnsole.dll"
$runningProcesses = Get-Process -Name $processName -ErrorAction SilentlyContinue
if ($runningProcesses) {
    $runningProcesses | Stop-Process -Force
}

#  path for console application DLL
$consoleAppPath = "C:\MyApp\AWSCOnsole.dll"

#  path for the output file
$outputFilePath = "C:\outputfile\output.txt"

# Run the console application 
$output = & dotnet $consoleAppPath


$outputContent = "Console application output:`n"
$outputContent += $output
$outputContent += "`n"

# Write the output to the output file
$outputContent | Out-File -FilePath $outputFilePath -Encoding UTF8

# Read the output file and display its contents
$outputContent = Get-Content -Path $outputFilePath -Raw
Write-Host "Console application output:"
Write-Host $outputContent
