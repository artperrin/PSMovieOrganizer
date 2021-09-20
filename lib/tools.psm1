$APIkey = ''

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
    if (-not (Test-Path $pathTo)) {
        $null = split-path $pathTo | New-Item -Path { $_ } -ItemType Directory -Force
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
    return Get-ChildItem -Path $path -Recurse -File -Name | ForEach-Object { add-rootPath $path $_ }
}

function Invoke-tmdbAPIsearchmovie {
    param (
        [string]
        # name of the movie to be searched
        $movie
    )
    <#
        Invokes the TMDB API to search for a given movie by its name
    #>
    $movie = ($movie.Replace(' ', '+')).Replace('_', '+')
    $uri = "https://api.themoviedb.org/3/search/movie?api_key=$APIkey&query=$movie"
    $res = Invoke-RestMethod $uri
    return $res.results
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
    # do as the date was written in the end of the file
    $baseName = (get-item $file).BaseName
    $date = [string]::join('', $baseName[-5..-2])

    try { $date = [int] $date }
    catch {
        # if the date is not found in the file's name, invoke TMDB's API
        $res = Invoke-tmdbAPIsearchmovie $baseName
        $date = $res.release_date
        if (-not ($date.GetType().name -eq [string])) {
            # if mutliple results are returned, choose the first one
            $date = $date[0]
            Write-Output ("Multiple movies for $baseName found... Chosen {0} released the $date!" -f $res.original_title)
        }
        # format correctly
        $date = [string]::join('', $date[0..3])
        $date = [int] $date
    }
    return $date
}