$inv = [System.Globalization.CultureInfo]::InvariantCulture

function Convert-And-Normalize($stlPath, $objPath, $targetSize) {
    $bytes = [System.IO.File]::ReadAllBytes($stlPath)
    $numTriangles = [System.BitConverter]::ToUInt32($bytes, 80)
    
    $offset = 84
    $vIndex = 1
    
    $verts = New-Object System.Collections.Generic.List[Object]
    $faces = New-Object System.Collections.Generic.List[String]

    $minX = 1e12; $minY = 1e12; $minZ = 1e12
    $maxX = -1e12; $maxY = -1e12; $maxZ = -1e12

    for ($i = 0; $i -lt $numTriangles; $i++) {
        if ($offset + 50 -gt $bytes.Length) { break }

        $x1 = [System.BitConverter]::ToSingle($bytes, $offset + 12)
        $y1 = [System.BitConverter]::ToSingle($bytes, $offset + 16)
        $z1 = [System.BitConverter]::ToSingle($bytes, $offset + 20)

        $x2 = [System.BitConverter]::ToSingle($bytes, $offset + 24)
        $y2 = [System.BitConverter]::ToSingle($bytes, $offset + 28)
        $z2 = [System.BitConverter]::ToSingle($bytes, $offset + 32)

        $x3 = [System.BitConverter]::ToSingle($bytes, $offset + 36)
        $y3 = [System.BitConverter]::ToSingle($bytes, $offset + 40)
        $z3 = [System.BitConverter]::ToSingle($bytes, $offset + 44)

        foreach ($v in @(@($x1,$y1,$z1), @($x2,$y2,$z2), @($x3,$y3,$z3))) {
            $verts.Add($v)
            if ($v[0] -lt $minX) { $minX = $v[0] }; if ($v[0] -gt $maxX) { $maxX = $v[0] }
            if ($v[1] -lt $minY) { $minY = $v[1] }; if ($v[1] -gt $maxY) { $maxY = $v[1] }
            if ($v[2] -lt $minZ) { $minZ = $v[2] }; if ($v[2] -gt $maxZ) { $maxZ = $v[2] }
        }

        $faces.Add(('f {0} {1} {2}' -f $vIndex, ($vIndex+1), ($vIndex+2)))
        $vIndex += 3
        $offset += 50
    }

    $centerX = ($minX + $maxX) / 2.0
    $centerY = ($minY + $maxY) / 2.0
    $centerZ = ($minZ + $maxZ) / 2.0

    $sizeX = $maxX - $minX
    $sizeY = $maxY - $minY
    $sizeZ = $maxZ - $minZ
    $maxDim = [Math]::Max($sizeX, [Math]::Max($sizeY, $sizeZ))
    $scale = $targetSize / $maxDim

    $sb = New-Object System.Text.StringBuilder
    [void]$sb.AppendLine('# Correct Invariant OBJ')

    foreach ($v in $verts) {
        $nx = ($v[0] - $centerX) * $scale
        $ny = ($v[1] - $centerY) * $scale
        $nz = ($v[2] - $centerZ) * $scale
        $strX = $nx.ToString('0.000000', $inv)
        $strY = $ny.ToString('0.000000', $inv)
        $strZ = $nz.ToString('0.000000', $inv)
        [void]$sb.AppendLine("v $strX $strY $strZ")
    }

    foreach ($f in $faces) {
        [void]$sb.AppendLine($f)
    }

    [System.IO.File]::WriteAllText($objPath, $sb.ToString())
    Write-Host "Re-generated $objPath with Invariant Culture Dot separators. Target Size: $targetSize m"
}

Convert-And-Normalize "E:\signal_array-main\assets\models\signal_array_anomaly_detector.stl" "E:\signal_array-main\assets\models\signal_array_anomaly_detector.obj" 0.22
Convert-And-Normalize "E:\signal_array-main\assets\models\sa_light.stl" "E:\signal_array-main\assets\models\sa_light.obj" 0.20
