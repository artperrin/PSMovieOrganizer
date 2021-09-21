### Imports ###

Import-Module .\lib\tools.psm1 -Force
Import-Module .\lib\sort.psm1 -Force

### Constants ###

$pathToData = ".\data"
$sortBy = 'DIR'

### Script ###

$treeSave = invoke-initialSort $pathToData

if ($sortBy -eq 'DATE') {
    Invoke-SortByDate $pathToData
}
elseif ($sortBy -eq 'TITLE') {
    Invoke-SortByTitle $pathToData
}
elseif ($sortBy -eq 'DIR') {
    Invoke-SortByDirector $pathToData
}