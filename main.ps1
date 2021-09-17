### Imports ###

Import-Module .\lib\tools.psm1 -Force

### Constants ###

$pathToData = ".\data"
$sortBy = 'DATE'

### Script ###

get-listFiles $pathToData

$treeSave = invoke-initialSort $pathToData

Invoke-ResetSort $pathToData $treeSave

# $files = get-listFiles $pathToData

# if ($sortBy -eq 'DATE') {

# }