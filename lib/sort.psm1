Import-Module .\lib\tools.psm1 -Force

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
    $newPaths = $files | Split-Path -Leaf | ForEach-Object { add-rootPath $root $_ }
    $map = @{}
    $idx = 0
    foreach ($file in $files) {
        $newPath = $newPaths[$idx]
        $null = Move-Item -Path $file -Destination $newPath 
        $idx++
        $map.Add((Split-Path $newPath -Leaf), $file)
    }
    $null = Get-ChildItem $root -Directory | Remove-Item -Force -Recurse
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
    $files = Get-ListFiles $root
    foreach ($file in $files) {
        # for each file, get the date and move the file
        $date = Get-DataDate $file
        Move-ItemCreate $file ("$root\{0}\{1}" -f $date, (split-path $file -Leaf))
    }
}

function Invoke-SortByTitle {
    param (
        [string]
        # root directory of the files to sort by title
        $root
    )
    $files = Get-ListFiles $root
    foreach ($file in $files) {
        # for each file, get the first letter
        $baseName = split-path $file -Leaf
        if (([string]::join('', (split-path $baseName -Leaf)[0..3])).replace(' ', '_') -eq 'the_') {
            # if the file begins with 'the ' or 'the_'
            $letter = [string] $baseName[4] # take the first letter after 'the'
        }
        else {
            $letter = [string] $baseName[0]
        }
        Move-ItemCreate $file ("$root\{0}\{1}" -f $letter.ToUpper(), (split-path $file -Leaf))
    }
}

function Invoke-SortByDirector {
    param (
        [string]
        # root directory of the files to sort by title
        $root
    )
    <#
        .SYNOPSIS
        Sorts the files by directors by finding them with TMDB's API
    #>
    $files = Get-ListFiles $root
    foreach ($file in $files) {
        # get the director(s)
        $directors = Get-Director $file
        if (($directors | Measure-Object).count -gt 1) {
            # if there are more than one director, just take the family names
            $pathName = ''
            foreach ($director in $directors) {
                $name = (-Split $director)
                $pathName += ("{0}.{1} & " -f $name[0][0], $name[-1])
            }
            # erase the last ' &' symbol
            $pathName = $pathName.Substring(0, $pathName.Length - 3)
        }
        else {
            $pathName = $directors
        }
        Move-ItemCreate $file ("$root\{0}\{1}" -f $pathName, (split-path $file -Leaf))
    }
}