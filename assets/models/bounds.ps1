$paths = @("E:\signal_array-main\assets\models\signal_array_anomaly_detector.obj", "E:\signal_array-main\assets\models\sa_light.obj")
foreach ($path in $paths) {
    $lines = Get-Content $path
    $minX = 1e9; $minY = 1e9; $minZ = 1e9
    $maxX = -1e9; $maxY = -1e9; $maxZ = -1e9
    foreach ($line in $lines) {
        if ($line.StartsWith("v ")) {
            $parts = $line.Split(" ", [System.StringSplitOptions]::RemoveEmptyEntries)
            $x = [double]$parts[1]
            $y = [double]$parts[2]
            $z = [double]$parts[3]
            if ($x -lt $minX) { $minX = $x }; if ($x -gt $maxX) { $maxX = $x }
            if ($y -lt $minY) { $minY = $y }; if ($y -gt $maxY) { $maxY = $y }
            if ($z -lt $minZ) { $minZ = $z }; if ($z -gt $maxZ) { $maxZ = $z }
        }
    }
    Write-Host "File: $path"
    Write-Host "  Min: $minX, $minY, $minZ"
    Write-Host "  Max: $maxX, $maxY, $maxZ"
    Write-Host "  Size: $($maxX - $minX), $($maxY - $minY), $($maxZ - $minZ)"
    Write-Host "  Center: $(($minX+$maxX)/2), $(($minY+$maxY)/2), $(($minZ+$maxZ)/2)"
}
