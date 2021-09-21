$pathToData = 'real_data'
$pathToClone = 'clone'

Import-Module .\lib\tools.psm1 -Force

$files = Get-ListFiles $pathToData

foreach ($file in $files) {
    $pathTo = ("$pathToClone\{0}.txt" -f $file.Substring(0, $file.Length - 4))
    if (-not (Test-Path $pathTo)) {
        $null = split-path $pathTo | New-Item -Path { $_ } -ItemType Directory -Force
    }
    $null = New-Item -Path $pathTo -ItemType 'file'
}