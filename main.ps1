### Imports ###

Import-Module .\lib\tools.psm1 -Force

### Constants ###

$pathToData = ".\data"
$sortBy = 'NONE'

### Script ###

$files = get-listFiles $pathToData

if ($sortBy -eq 'NONE') {
    get-initialSort $files $pathToData
}