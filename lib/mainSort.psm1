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

    switch ($sortBy) {
        'DATE' { Invoke-SortByDate $pathToData }
        'TITLE' { Invoke-SortByTitle $pathToData }
        'DIRECTOR' { Invoke-SortByDirector $pathToData }
        'NATIONALITY' { Invoke-SortByNationality $pathToData }
        'GENRE' { Invoke-SortByGenre $pathToData }
        'COLLECTION' { Invoke-SortByCollection $pathToData }
        'ROOT' {  }
        Default { Invoke-ResetSort $pathToData $treeSave }
    }
    return $treeSave
}