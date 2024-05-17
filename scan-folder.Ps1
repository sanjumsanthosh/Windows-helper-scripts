$folderPath = Read-Host "Enter the folder path"
$depth = Read-Host "Enter the depth level"

# loop though the files and folders and based on the depth level
# display the count of files and folders within the folder
# also at each level display the folder name with files and folders count
# also display the size of the files /folders at each level in human readable format

function Get-SizeInAppropriateUnit {
    param([double]$sizeInBytes)

    if ($sizeInBytes -ge 1GB) {
        return "{0:N2} GB" -f ($sizeInBytes / 1GB)
    } elseif ($sizeInBytes -ge 1MB) {
        return "{0:N2} MB" -f ($sizeInBytes / 1MB)
    } else {
        return "{0:N2} KB" -f ($sizeInBytes / 1KB)
    }
}

function Get-TimeInAppropriateUnit {
    param([double]$timeInSeconds)

    if ($timeInSeconds -ge 3600) {
        return "{0:N2} hours" -f ($timeInSeconds / 3600)
    } elseif ($timeInSeconds -ge 60) {
        return "{0:N2} minutes" -f ($timeInSeconds / 60)
    } else {
        return "{0:N2} seconds" -f $timeInSeconds
    }
}

$items = Get-ChildItem -Path $folderPath -Recurse -Depth $depth
$totalItems = $items.Count
$currentItem = 0

# Start the timer
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

$items | ForEach-Object {
    $currentItem++

    # Calculate elapsed and remaining time
    $elapsedTime = $stopwatch.Elapsed.TotalSeconds
    $estimatedTotalTime = $elapsedTime / $currentItem * $totalItems
    $estimatedTimeRemaining = $estimatedTotalTime - $elapsedTime
    $estimatedTimeRemaining = Get-TimeInAppropriateUnit -timeInSeconds $estimatedTimeRemaining

    # Write-Progress -Activity "Scanning files and folders" -Status "$currentItem of $totalItems processed, estimated time remaining: $estimatedTimeRemaining" -PercentComplete (($currentItem / $totalItems) * 100)
    Write-Progress -Activity "Scanning $($_.FullName)" -Status "$currentItem of $totalItems processed, estimated time remaining: $estimatedTimeRemaining" -PercentComplete (($currentItem / $totalItems) * 100)

    # check if the item is a folder
    if ($_.PSIsContainer) {
        # get the files and folders count
        $filesCount = (Get-ChildItem -Path $_.FullName -File).Count
        $foldersCount = (Get-ChildItem -Path $_.FullName -Directory).Count
        # get the size of the folder
        $size = (Get-ChildItem -Path $_.FullName -Recurse -File | Measure-Object -Property Length -Sum).Sum
        $size = Get-SizeInAppropriateUnit -sizeInBytes $size
        # display the folder name with files and folders count
        "Folder: $($_.FullName) Files: $filesCount Folders: $foldersCount Size: $size" | Out-File -FilePath "output.txt" -Append
    } else {
        # get the size of the file
        $size = $_.Length
        # display the file name with size
        "File: $($_.FullName) Size: $size" | Out-File -FilePath "output.txt" -Append
    }
}

# Stop the timer
$stopwatch.Stop()