# PowerShell Script to Find, Move, and Zip .hush Files
# This script recursively finds all .hush files, moves them to a collection folder, and creates a zip archive

param(
    [string]$SearchPath = ".",
    [string]$CollectionFolder = "hush_files_collection",
    [string]$ZipFileName = "hush_files_$(Get-Date -Format 'yyyyMMdd_HHmmss').zip",
    [string]$LogFile = "hush_collection_log.txt"
)

# Initialize variables
$collectionPath = Join-Path (Get-Location) $CollectionFolder
$zipPath = Join-Path (Get-Location) $ZipFileName
$logPath = Join-Path (Get-Location) $LogFile
$foundFiles = @()
$movedFiles = 0
$errors = 0

# Initialize log file
"Hush Files Collection Log - $(Get-Date)" | Out-File -FilePath $logPath -Encoding UTF8
"=" * 60 | Out-File -FilePath $logPath -Append -Encoding UTF8
"Search Path: $SearchPath" | Out-File -FilePath $logPath -Append -Encoding UTF8
"Collection Folder: $collectionPath" | Out-File -FilePath $logPath -Append -Encoding UTF8
"Zip File: $zipPath" | Out-File -FilePath $logPath -Append -Encoding UTF8
"=" * 60 | Out-File -FilePath $logPath -Append -Encoding UTF8

Write-Host "Starting .hush files collection..." -ForegroundColor Cyan
Write-Host "Searching in: $SearchPath" -ForegroundColor Yellow

# Step 1: Find all .hush files recursively
try {
    Write-Host "Searching for .hush files..." -ForegroundColor Green
    $foundFiles = Get-ChildItem -Path $SearchPath -Filter "*.hush" -File -Recurse -ErrorAction SilentlyContinue
    
    Write-Host "Found $($foundFiles.Count) .hush files" -ForegroundColor Green
    "Found Files: $($foundFiles.Count)" | Out-File -FilePath $logPath -Append -Encoding UTF8
    "" | Out-File -FilePath $logPath -Append -Encoding UTF8
    
} catch {
    $errorMsg = "ERROR during search: $($_.Exception.Message)"
    Write-Host $errorMsg -ForegroundColor Red
    $errorMsg | Out-File -FilePath $logPath -Append -Encoding UTF8
    exit 1
}

# Exit if no files found
if ($foundFiles.Count -eq 0) {
    Write-Host "No .hush files found. Exiting." -ForegroundColor Yellow
    "No .hush files found. Script completed." | Out-File -FilePath $logPath -Append -Encoding UTF8
    exit 0
}

# Step 2: Create collection folder
try {
    if (Test-Path $collectionPath) {
        Write-Host "Collection folder already exists, clearing contents..." -ForegroundColor Yellow
        Remove-Item -Path "$collectionPath\*" -Recurse -Force -ErrorAction SilentlyContinue
    } else {
        Write-Host "Creating collection folder..." -ForegroundColor Green
        New-Item -ItemType Directory -Path $collectionPath -Force | Out-Null
    }
} catch {
    $errorMsg = "ERROR creating collection folder: $($_.Exception.Message)"
    Write-Host $errorMsg -ForegroundColor Red
    $errorMsg | Out-File -FilePath $logPath -Append -Encoding UTF8
    exit 1
}

# Step 3: Move files to collection folder
Write-Host "Moving files to collection folder..." -ForegroundColor Green
"Moving Files:" | Out-File -FilePath $logPath -Append -Encoding UTF8

foreach ($file in $foundFiles) {
    try {
        # Create unique filename if duplicates exist
        $destinationName = $file.Name
        $destinationPath = Join-Path $collectionPath $destinationName
        $counter = 1
        
        while (Test-Path $destinationPath) {
            $nameWithoutExt = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
            $extension = $file.Extension
            $destinationName = "$nameWithoutExt($counter)$extension"
            $destinationPath = Join-Path $collectionPath $destinationName
            $counter++
        }
        
        # Move the file
        Move-Item -Path $file.FullName -Destination $destinationPath -Force
        
        # Log the move
        $logEntry = "MOVED: $($file.FullName) -> $destinationName"
        Write-Host "  $($file.Name) -> $destinationName" -ForegroundColor Gray
        $logEntry | Out-File -FilePath $logPath -Append -Encoding UTF8
        
        $movedFiles++
        
    } catch {
        $errorMsg = "ERROR moving $($file.FullName): $($_.Exception.Message)"
        Write-Host $errorMsg -ForegroundColor Red
        $errorMsg | Out-File -FilePath $logPath -Append -Encoding UTF8
        $errors++
    }
}

Write-Host "Successfully moved $movedFiles files" -ForegroundColor Green
if ($errors -gt 0) {
    Write-Host "Encountered $errors errors during file moving" -ForegroundColor Red
}

# Step 4: Create zip archive
Write-Host "Creating zip archive..." -ForegroundColor Green
try {
    # Remove existing zip if it exists
    if (Test-Path $zipPath) {
        Remove-Item $zipPath -Force
    }
    
    # Create zip archive using .NET compression
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::CreateFromDirectory($collectionPath, $zipPath)
    
    Write-Host "Zip archive created: $zipPath" -ForegroundColor Green
    
    # Get zip file size
    $zipSize = (Get-Item $zipPath).Length
    $zipSizeMB = [math]::Round($zipSize / 1MB, 2)
    
    Write-Host "Zip file size: $zipSizeMB MB" -ForegroundColor Cyan
    
} catch {
    $errorMsg = "ERROR creating zip archive: $($_.Exception.Message)"
    Write-Host $errorMsg -ForegroundColor Red
    $errorMsg | Out-File -FilePath $logPath -Append -Encoding UTF8
    $errors++
}

# Step 5: Clean up collection folder (optional)
Write-Host "Cleaning up temporary collection folder..." -ForegroundColor Yellow
try {
    Remove-Item -Path $collectionPath -Recurse -Force
    Write-Host "Collection folder cleaned up" -ForegroundColor Green
} catch {
    Write-Host "Warning: Could not clean up collection folder: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Final summary
"" | Out-File -FilePath $logPath -Append -Encoding UTF8
"=" * 60 | Out-File -FilePath $logPath -Append -Encoding UTF8
"SUMMARY:" | Out-File -FilePath $logPath -Append -Encoding UTF8
"Files found: $($foundFiles.Count)" | Out-File -FilePath $logPath -Append -Encoding UTF8
"Files moved: $movedFiles" | Out-File -FilePath $logPath -Append -Encoding UTF8
"Errors: $errors" | Out-File -FilePath $logPath -Append -Encoding UTF8
"Zip created: $zipPath" | Out-File -FilePath $logPath -Append -Encoding UTF8
"Completed: $(Get-Date)" | Out-File -FilePath $logPath -Append -Encoding UTF8

Write-Host "`nScript completed!" -ForegroundColor Cyan
Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "  Files found: $($foundFiles.Count)" -ForegroundColor White
Write-Host "  Files moved: $movedFiles" -ForegroundColor White
Write-Host "  Errors: $errors" -ForegroundColor White
Write-Host "  Zip file: $zipPath" -ForegroundColor White
Write-Host "  Log file: $logPath" -ForegroundColor White

if ($errors -eq 0) {
    Write-Host "`nAll operations completed successfully!" -ForegroundColor Green
} else {
    Write-Host "`nCompleted with $errors errors. Check log file for details." -ForegroundColor Yellow
}
