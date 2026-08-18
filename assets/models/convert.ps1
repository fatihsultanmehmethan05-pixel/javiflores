param($stlPath, $objPath)

$bytes = [System.IO.File]::ReadAllBytes($stlPath)
$numTriangles = [System.BitConverter]::ToUInt32($bytes, 80)
$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine("# Converted from STL to OBJ")

$offset = 84
$vIndex = 1

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

    [void]$sb.AppendLine(('v {0:0.######} {1:0.######} {2:0.######}' -f $x1, $y1, $z1))
    [void]$sb.AppendLine(('v {0:0.######} {1:0.######} {2:0.######}' -f $x2, $y2, $z2))
    [void]$sb.AppendLine(('v {0:0.######} {1:0.######} {2:0.######}' -f $x3, $y3, $z3))
    [void]$sb.AppendLine(('f {0} {1} {2}' -f $vIndex, ($vIndex+1), ($vIndex+2)))

    $vIndex += 3
    $offset += 50
}

[System.IO.File]::WriteAllText($objPath, $sb.ToString())
Write-Host "Successfully converted $stlPath to $objPath ($numTriangles triangles)"
