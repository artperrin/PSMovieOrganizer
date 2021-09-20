### Imports ###

Import-Module .\lib\tools.psm1 -Force
Import-Module .\lib\sort.psm1 -Force

### Constants ###

$pathToData = ".\data"
$sortBy = 'DATE'

### Script ###

get-listFiles $pathToData

$treeSave = invoke-initialSort $pathToData

if ($sortBy -eq 'DATE') {
    Invoke-SortByDate $pathToData
}
elseif ($sortBy -eq 'TITLE') {
    Invoke-SortByTitle $pathToData
}