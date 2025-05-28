# PowerShell script to fix YAML formatting issues in Kubernetes configuration files

$kubernetesDir = Join-Path (Get-Location) "kubernetes"
$yamlFiles = Get-ChildItem -Path $kubernetesDir -Filter "*.yaml"

foreach ($file in $yamlFiles) {
    Write-Host "Processing $($file.Name)..." -ForegroundColor Green
    
    # Read the file content
    $content = Get-Content -Path $file.FullName -Raw
    
    # Fix the "spec:      containers:" issue (missing line break)
    if ($content -match "spec:\s+containers:") {
        $content = $content -replace "spec:\s+containers:", "spec:`n      containers:"
        Write-Host "  - Fixed 'spec: containers:' issue" -ForegroundColor Yellow
    }
    
    # Fix the "containerPort: XXXX        env:" issue (missing line break)
    if ($content -match "containerPort:\s+\d+\s+env:") {
        $content = $content -replace "(containerPort:\s+\d+)\s+env:", "$1`n        env:"
        Write-Host "  - Fixed 'containerPort: XXXX env:' issue" -ForegroundColor Yellow
    }
    
    # Write the fixed content back to the file
    $content | Set-Content -Path $file.FullName
    
    Write-Host ""
}

Write-Host "All files processed." -ForegroundColor Green