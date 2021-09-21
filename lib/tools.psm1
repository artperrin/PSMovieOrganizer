$APIkey = get-content '.\apikey.txt'

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
    if ($res.total_results -eq 0) {
        return 0
    }
    return $res.results
}

function Invoke-tmdbAPIsearchcredits {
    param (
        [int]
        # movie Id to search the credits for
        $movieId
    )
    $uri = ("https://api.themoviedb.org/3/movie/{0}?api_key=$APIkey&append_to_response=credits" -f $movieId)
    $res = Invoke-RestMethod $uri
    return $res.credits
}

function Invoke-tmdbAPIsearchnationality {
    param (
        [int]
        # movie Id to search the nationality of
        $movieId
    )
    $uri = ("https://api.themoviedb.org/3/movie/{0}?api_key=$APIkey" -f $movieId)
    $res = Invoke-RestMethod $uri
    return $res.production_countries.name
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
        if ($res -eq 0) {
            return 'Unknown'
        }
        $date = $res.release_date
        if (-not ($date.GetType().name -eq [string])) {
            # if mutliple results are returned, choose the first one
            $date = $date[0]
            $others = ''
            foreach ($movie in $res) {
                $others += ("    '{0}' from {1}`n" -f $movie.original_title, $movie.release_date)
            }
            Write-Host ("Multiple movies for '$baseName' found... Chosen '{0}' released the $date! Movies found:" -f $res.original_title)
            Write-Host $others
        }
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
    if (($res | Measure-Object).count -gt 1) {
        $others = ''
        foreach ($movie in $res) {
            $others += ("    '{0}' from {1}`n" -f $movie.original_title, $movie.release_date)
        }
        $res = $res[0]
        Write-Host ("Multiple movies for '$baseName' found... Chosen '{0}' released the {1}! Movies found:" -f $res.original_title, $res.release_date)
        Write-Host $others
    }
    $movieId = $res.Id
    $credits = Invoke-tmdbAPIsearchcredits $movieId
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
        return 'Unknown'
    }
    if (($res | Measure-Object).count -gt 1) {
        $others = ''
        foreach ($movie in $res) {
            $others += ("    '{0}' from {1}`n" -f $movie.original_title, $movie.release_date)
        }
        $res = $res[0]
        Write-Host ("Multiple movies for '$baseName' found... Chosen '{0}' released the {1}! Movies found:" -f $res.original_title, $res.release_date)
        Write-Host $others
    }
    $movieId = $res.Id
    $nat = Invoke-tmdbAPIsearchnationality $movieId
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
    if (($res | Measure-Object).count -gt 1) {
        $others = ''
        foreach ($movie in $res) {
            $others += ("    '{0}' from {1}`n" -f $movie.original_title, $movie.release_date)
        }
        $res = $res[0]
        Write-Host ("Multiple movies for '$baseName' found... Chosen '{0}' released the {1}! Movies found:" -f $res.original_title, $res.release_date)
        Write-Host $others
    }
    $genre_table = Import-Csv -Path ".\lib\genres_table.csv"
    $genres = ($genre_table | where-object {$_.id -in $res.genre_ids} | select-object -property name).name
    return $genres
}