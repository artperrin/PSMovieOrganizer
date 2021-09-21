### Imports ###

$pathToData = 'E:\Films'
$pathToClone = '.'

Import-Module .\lib\tools.psm1 -Force

$files = Get-ListFiles $pathToData

foreach ($file in $files) {
    $temp = $file.Substring(3, $file.Length - 7)
    $pathTo = ("$pathToClone\{0}.txt" -f $temp)
    if (-not (Test-Path $pathTo)) {
        $null = split-path $pathTo | New-Item -Path { $_ } -ItemType Directory -Force
    }
    $null = New-Item -Path $pathTo -ItemType 'file'
}