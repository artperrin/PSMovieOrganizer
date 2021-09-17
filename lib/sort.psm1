Import-Module .\lib\tools.psm1

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

function Invoke-SortByDate {
    param (
        [string]
        # root directory of the files to sort by date
        $root
    )
    <#
        .SYNOPSIS
        sorts the given root directory by date
    #>
    $file = Get-ListFiles $root
    $datedFiles = @{}
    foreach ($file in $files) {
        $datedFiles.Add($file, (Get-DataDate $file))
    }
    ### TO BE CONTINUED
}