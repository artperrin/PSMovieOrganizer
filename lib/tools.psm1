function Move-ItemCreate {
    param (
        [string]
        # from
        $pathFrom,
        [string]
        # to
        $pathTo
    )
    <#
        .SYNOPSIS
        moves an item from a directory to another and create subdirectories if needed
    #>
    if(-not (Test-Path $pathTo)) {
        $null = split-path $pathTo | New-Item -Path {$_} -ItemType Directory -Force
    }
    $null = Move-Item -Path $pathFrom -Destination $pathTo
}

function Add-RootPath {
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

function Get-ListFiles {
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

function Invoke-InitialSort {
    param (
        [string]
        # root path of the files to be sorted
        $root
    )
    <#
        .SYNOPSIS
        moves all the given files into the root directory and removes the existing tree, returns the initial tree and mapping data
    #>
    $files = get-listFiles $root
    $newPaths = $files | Split-Path -Leaf | ForEach-Object {add-rootPath $root $_}
    $map = @{}
    $idx = 0
    foreach ($file in $files) {
        $newPath = $newPaths[$idx]
        $null = Move-Item -Path $file -Destination $newPath 
        $idx++
        $map.Add((Split-Path $newPath -Leaf), $file)
    }
    Get-ChildItem $root -Directory | Remove-Item -Force -Recurse
    return $map
}

function Invoke-ResetSort {
    param (
        [string]
        # root dir of the data to be re-sorted
        $root,
        # tree to be re-created
        $tree
    )
    Invoke-InitialSort $root
    $files = Get-ListFiles $root
    foreach ($file in $files) {
        $baseName = Split-Path $file -Leaf
        Move-ItemCreate $file $tree[$baseName]
    }
}