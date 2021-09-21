Import-Module '.\lib\sort.psm1'

$import = Import-Clixml "last_tree_save.xml"

Invoke-ResetSort -root $import.root -tree $import.tree