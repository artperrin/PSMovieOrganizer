$APIkey = get-content '.\apikey.txt'
$GenreTableFilePath = '.\lib\genres_table.csv'

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
    $null = Move-Item -LiteralPath $pathFrom -Destination $pathTo
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

function Get-ListDirs {
    param (
        [string]
        # path to get the list of dirs from
        $path 
    )
    <#
        .SYNOPSIS
        returns the list of directories contained in a given path recursively as a list of strings
    #>
    return Get-ChildItem -Path $path -Directory -Name | ForEach-Object { add-rootPath $path $_ }
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
    if ($movie -match '\(([0-9]{4})\)') {
        $sliceIdx = $movie.IndexOf($Matches[0])
        $movie = [string]::join('', $movie[0..($sliceIdx-2)])
    }
    $uri = "https://api.themoviedb.org/3/search/movie?api_key=$APIkey&query=$movie"
    try {$res = Invoke-RestMethod $uri}
    catch {return 0}
    if ($res.total_results -eq 0) {
        return 0
    }
    return $res.results
}

function Invoke-tmdbAPIsearchById {
    param (
        [int]
        # movie Id to search the nationality of
        $movieId,
        [switch]
        # whether to seek the credits
        $credits,
        [switch]
        # whether to seek the nationality
        $nationality,
        [switch]
        # whether to seek the collection
        $collection
    )
    $uri = ("https://api.themoviedb.org/3/movie/{0}?api_key=$APIkey&append_to_response=credits" -f $movieId)
    try {$res = Invoke-RestMethod $uri}
    catch {return 0}
    if ($credits) {
        $res = $res.credits
    }
    elseif ($nationality) {
        $res = $res.production_countries.name
    }
    elseif ($collection) {
        $res = $res.belongs_to_collection
    }
    return $res
}

function Get-ResParsed {
    param (
        # results of TMDB API to be parsed
        $res,
        [string]
        # basename of the file
        $baseName
    )
    if (($res | Measure-Object).count -gt 1) {
        $others = $res | Select-Object -Property original_title, release_date
        $res = $res[0]
        Write-Host ("Multiple movies for '$baseName' found... Chose '{0}' released the {1}!`nTotal movies found:" -f $res.original_title, $res.release_date)
        Write-Host ($others | Format-Table | Out-String)
    }
    return $res
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

    if ($baseName -match "([0-9]{4})") {
        $date = $Matches[0]
    }
    else {
        # if the date is not found in the file's name, invoke TMDB's API
        $res = Invoke-tmdbAPIsearchmovie $baseName
        if ($res -eq 0) {
            return 'Unknown'
        }
        $res = Get-ResParsed $res $baseName
        $date = $res.release_date
        # format correctly
        $date = [string]::join('', $date[0..3])
        $date = [int] $date
    }
    return $date
}

function Get-Director {
    param (
        [string]
        # file to find the director from
        $file
    )
    <#
        .SYNOPSIS
        Gets the list of directors for the given file
    #>
    $baseName = (Get-Item $file).BaseName
    $res = Invoke-tmdbAPIsearchmovie $baseName
    if ($res -eq 0) {
        return 'Unknown'
    }
    $res = Get-ResParsed $res $baseName
    $movieId = $res.Id
    $credits = Invoke-tmdbAPIsearchById $movieId -credits
    $directors = @()
    foreach ($person in $credits.crew) {
        if ($person.job -eq 'Director') {
            $directors += $person.original_name
        }
    }
    return $directors
}

function Get-Nationality {
    param (
        [string]
        # file to find the director from
        $file
    )
    <#
        .SYNOPSIS
        Gets the nationality of the given file
    #>
    $baseName = (Get-Item $file).BaseName
    $res = Invoke-tmdbAPIsearchmovie $baseName
    if ($res -eq 0) {
        return 'Unkown'
    }
    $res = Get-ResParsed $res $baseName
    $movieId = $res.Id
    $nat = Invoke-tmdbAPIsearchById $movieId -nationality
    return $nat
}

function Get-Genre {
    param (
        [string]
        # file to find the director from
        $file
    )
    <#
        .SYNOPSIS
        Gets the genre of the given file
    #>
    $baseName = (Get-Item $file).BaseName
    $res = Invoke-tmdbAPIsearchmovie $baseName
    if ($res -eq 0) {
        return 'Unknown'
    }
    $res = Get-ResParsed $res $baseName
    $genre_table = Import-Csv -Path $GenreTableFilePath
    $genres = ($genre_table | where-object {$_.id -in $res.genre_ids} | select-object -property name).name
    return $genres
}

function Get-Collection {
    param (
        [string]
        # file to find the director from
        $file
    )
    <#
        .SYNOPSIS
        Gets the genre of the given file
    #>
    $baseName = (Get-Item $file).BaseName
    $res = Invoke-tmdbAPIsearchmovie $baseName
    if ($res -eq 0) {
        return 'Others'
    }
    $res = Get-ResParsed $res $baseName $null
    $movieId = $res.Id
    $col = Invoke-tmdbAPIsearchById $movieId -collection
    if ($null -ne $col) {
        $col = $col.name
    }
    return $col
}