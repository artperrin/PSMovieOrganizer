### Imports ###

Import-Module '.\lib\mainSort.psm1' -Force
Import-Module '.\lib\tools.psm1' -Force

### Constants ###

$confPath = '.\organizer.conf'
$dataPath = $args[0]

### Script ###

$sortingOrder = @( -split ([string] (Get-Content $confPath)))

$save = Invoke-Sort $dataPath $sortingOrder[0]

$export = @{
    'root' = $dataPath
    'tree' = $save
}

$sortingOrder = $sortingOrder[1..$sortingOrder.Length]

$data = $dataPath

while ($sortingOrder.Length -gt 0) {
    $data = $data | foreach-object { get-listdirs $_ }
    $data | ForEach-Object { Invoke-Sort $_ $sortingOrder[0] }
    $sortingOrder = $sortingOrder[1..$sortingOrder.Length]
}

$export | Export-Clixml "last_tree_save.xml"