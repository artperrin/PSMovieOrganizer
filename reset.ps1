Import-Module '.\lib\sort.psm1'

try {
    $import = Import-Clixml "last_tree_save.xml"
    Invoke-ResetSort -root $import.root -tree $import.tree
}
catch {
    Write-Host "Save not found!"
}