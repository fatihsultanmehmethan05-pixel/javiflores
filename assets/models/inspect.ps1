function Inspect-Stl($path) {
    $bytes = [System.IO.File]::ReadAllBytes($path)
    $numTriangles = [System.BitConverter]::ToUInt32($bytes, 80)
    $minX = $minY = $minZ = 1e12
    $maxX = $maxY = $maxZ = -1e12
    $offset = 84
    for ($i = 0; $i -lt $numTriangles; $i++) {
        if ($offset + 50 -gt $bytes.Length) { break }
        for ($j = 0; $j -lt 3; $j++) {
            $x = [System.BitConverter]::ToSingle($bytes, $offset + 12 + ($j * 12))
            $y = [System.BitConverter]::ToSingle($bytes, $offset + 16 + ($j * 12))
            $z = [System.BitConverter]::ToSingle($bytes, $offset + 20 + ($j * 12))
            if ($x -lt $minX) { $minX = $x }; if ($x -gt $maxX) { $maxX = $x }
            if ($y -lt $minY) { $minY = $y }; if ($y -gt $maxY) { $maxY = $y }
            if ($z -lt $minZ) { $minZ = $z }; if ($z -gt $maxZ) { $maxZ = $z }
        }
        $offset += 50
    }
    Write-Host "File: $path"
    Write-Host "  X bounds: $minX to $maxX (extent: $($maxX - $minX))"
    Write-Host "  Y bounds: $minY to $maxY (extent: $($maxY - $minY))"
    Write-Host "  Z bounds: $minZ to $maxZ (extent: $($maxZ - $minZ))"
}

Inspect-Stl "E:\signal_array-main\assets\models\signal_array_anomaly_detector.stl"
Inspect-Stl "E:\signal_array-main\assets\models\sa_light.stl"
