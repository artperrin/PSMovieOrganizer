### Imports ###

Import-Module '.\lib\mainSort.psm1' -Force
Import-Module '.\lib\tools.psm1' -Force

### Constants ###

$confPath = '.\organizer.conf'
$dataPath = '.\data'
# $dataPath = $args[0]

### Script ###

$sortingOrder = @(-split ([string] (Get-Content $confPath)))

Invoke-Sort $dataPath $sortingOrder[0]
$sortingOrder = $sortingOrder[1..$sortingOrder.Length]

$data = $dataPath

while ($sortingOrder.Length -gt 0) {
    $data = $data | foreach-object {get-listdirs $_}
    $data | ForEach-Object { Invoke-Sort $_ $sortingOrder[0] }
    $sortingOrder = $sortingOrder[1..$sortingOrder.Length]
}