$CSVFiles = Read-Host "enter the full path to the CSV files"
$MergedCSV = Read-Host "enter the output location for the merged CSV"
$getFirstLine = $true 
get-childItem "$CSVFiles\*.csv" | foreach {
    $filePath = $_

    $lines = $lines = Get-Content $filePath  
    $linesToWrite = switch($getFirstLine) {
           $true {$lines}
           $false {$lines | Select -Skip 1}

    }

    $getFirstLine = $false
    Add-Content "$MergedCSV\Merged-Hashes.csv" $linesToWrite
    }