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

function Get-DataDate {
    param (
        # file name to get the date from
        $file
    )
    <#
        .SYNOPSIS
        gets the date with the file's name (search in TMDB if not found at the end of the title), return an hashtable [date -> filename]
    #>
    $baseName = (get-item $file).BaseName
    $date = [string]::join('', $baseName[-5..-2])
    return $date
}