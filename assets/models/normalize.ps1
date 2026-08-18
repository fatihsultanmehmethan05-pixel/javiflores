function Normalize-Obj($path, $targetSize = 0.25) {
    $lines = Get-Content $path
    $minX = 1e12; $minY = 1e12; $minZ = 1e12
    $maxX = -1e12; $maxY = -1e12; $maxZ = -1e12
    
    foreach ($line in $lines) {
        if ($line.StartsWith("v ")) {
            $parts = $line.Split(" ", [System.StringSplitOptions]::RemoveEmptyEntries)
            $x = [double]$parts[1]; $y = [double]$parts[2]; $z = [double]$parts[3]
            if ($x -lt $minX) { $minX = $x }; if ($x -gt $maxX) { $maxX = $x }
            if ($y -lt $minY) { $minY = $y }; if ($y -gt $maxY) { $maxY = $y }
            if ($z -lt $minZ) { $minZ = $z }; if ($z -gt $maxZ) { $maxZ = $z }
        }
    }

    $centerX = ($minX + $maxX) / 2.0
    $centerY = ($minY + $maxY) / 2.0
    $centerZ = ($minZ + $maxZ) / 2.0

    $sizeX = $maxX - $minX
    $sizeY = $maxY - $minY
    $sizeZ = $maxZ - $minZ
    $maxDim = [Math]::Max($sizeX, [Math]::Max($sizeY, $sizeZ))
    
    if ($maxDim -le 0) { return }
    $scale = $targetSize / $maxDim

    $sb = New-Object System.Text.StringBuilder
    [void]$sb.AppendLine("# Normalized OBJ centered at (0,0,0) size $targetSize")

    foreach ($line in $lines) {
        if ($line.StartsWith("v ")) {
            $parts = $line.Split(" ", [System.StringSplitOptions]::RemoveEmptyEntries)
            $x = ([double]$parts[1] - $centerX) * $scale
            $y = ([double]$parts[2] - $centerY) * $scale
            $z = ([double]$parts[3] - $centerZ) * $scale
            [void]$sb.AppendLine(('v {0:0.######} {1:0.######} {2:0.######}' -f $x, $y, $z))
        } else {
            [void]$sb.AppendLine($line)
        }
    }

    [System.IO.File]::WriteAllText($path, $sb.ToString())
    Write-Host "Normalized $path -> Target Size: $targetSize meters (Scale: $scale)"
}

Normalize-Obj "E:\signal_array-main\assets\models\signal_array_anomaly_detector.obj" 0.22
Normalize-Obj "E:\signal_array-main\assets\models\sa_light.obj" 0.20
