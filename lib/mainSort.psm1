### Imports ###

Import-Module .\lib\sort.psm1 -Force

function Invoke-Sort {
    param (
        [string]
        # root dir of data to be sorted
        $pathToData,
        [string]
        # sorting type
        $sortBy
    )
    $treeSave = invoke-initialSort $pathToData

    if ($sortBy -eq 'DATE') {
        Invoke-SortByDate $pathToData
    }
    elseif ($sortBy -eq 'TITLE') {
        Invoke-SortByTitle $pathToData
    }
    elseif ($sortBy -eq 'DIR') {
        Invoke-SortByDirector $pathToData
    }
    elseif ($sortBy -eq 'NAT') {
        Invoke-SortByNationality $pathToData
    }
    elseif ($sortBy -eq 'GENRE') {
        Invoke-SortByGenre $pathToData
    }
    elseif ($sortBy -eq 'COL') {
        Invoke-SortByCollection $pathToData
    }
    elseif ($sortBy -eq 'ROOT') {
        
    }
    else {
        Invoke-ResetSort $pathToData $treeSave
    }

}