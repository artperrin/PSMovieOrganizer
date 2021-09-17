function add-rootPath {
    param (
        [string]
        # root to be added in the path
        $root, 
        [string]
        # path to be added a root
        $path
    )
    <#
        .SYNOPSIS
        adds a root to a given path
    #>
    return $root + '\' + $path
}

function get-listFiles {
    param (
        [string]
        # path to get the list of files from
        $path 
    )
    <#
        .SYNOPSIS
        returns the list of files contained in a given path recursively as a list of strings
    #>
    return Get-ChildItem -Path $path -Recurse -File -Name | ForEach-Object {add-rootPath $path $_}
}

function get-initialSort {
    param (
        # list of files to be sorted
        $files,
        [string]
        # directory to move the files to
        $dir
    )
    $newPaths = $files | Split-Path -Leaf | ForEach-Object {add-rootPath $dir $_}
    $idx = 0
    foreach ($file in $files) {
        Move-Item -Path $file -Destination $newPaths[$idx]
        $idx++
    }
    Get-ChildItem $dir -Directory | Remove-Item -Force -Recurse
}
