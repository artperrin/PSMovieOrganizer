# PowerShell Movie Organizer

This repository contains Windows PowerShell scripts aiming to organize one's movie database on a Windows file system. It uses the [TMDB](https://www.themoviedb.org/) API.

## What it does

The `main.ps1` script allows the user to input a root directory containing its movie files to be sorted. The script then uses the `organizer.conf` file to sort the root and subdirecties given a list of criteria.

The main script invokes a general function with two parameters: the directory to sort and the criterion. This function invokes the right algorithm which moves the movies into a created folder accordingly to the sorting criterion.

## How to use it

Firstly, open the `organizer.conf` file and write the sorting criteria. The first criterion will be the root's sorting criterion, the second will be each subfolder's, and so on until the last criteria is reached.

***Note that all the subdirectories are sorted accordingly to a criterion, even if there is only one file in it.***

Then, use the command line:

```powershell
main.ps1 \path\to\movies\directory
```

The root directory given as an argument will be sorted, and the previous tree is save as an `.xml` file. If the user is not satisfied (and has not erased the `.xml` file), he can retrieve the previous tree by running the command line:

```powershell
reset.ps1
```

## The criterion

Here is the list of possible criteria:
+ DATE: sort by date (not searched if given in the filename between parenthesis)
+ TITLE: sort by first letter of title (ignore `the` and `le`)
+ DIRECTOR: sort by director (list of last names if many)
+ NATIONALITY: sort by production country (list of countries if many)
+ GENRE: sort by genre (list of genres if many)
+ COLLECTION: sort by film collection ('Others' if in no collection)
+ ROOT: moves all the files to the root directory

For all these criteria (except the DATE if given in the filename and the TITLE), an internet connection is needed or TMDB's API to be accessed.

## Example

I got some movies in my `\Films` directory (these are `.txt` files actually to mimic my tree):

```
│   A Fantastic Fear of Everything (2012) [Vosten].txt
│   A Girl Walks Home Alone at Night (2014).txt
│   A Million Ways to Die in the West (2014) [Vosten].txt
│   Brigsby Bear [Mutli].txt
│   Brimstone (2016).en.txt
│   Brimstone (2016).txt
│   Buffaloed.txt
│   Bullets of Justice 2019 [Vosten].txt
│   Call For Dreams (2018).txt
│   The Salvation (2014).txt
│   The Void (2016) [Vosten].txt
│   Thoroughbreds (2017) [Vosten].txt
│   Timecrimes (2007).txt
│
├───Sam Raimi
│   │   The Quick and the Dead [Multi].txt
│   │
│   └───the Evil Dead trilogy
│           Evil Dead (1981) [Multi].txt
│           Evil Dead II [Multi].txt
│           Evil Dead III [Multi].txt
│
├───Sofia Coppola
│       Lost in Translation [Multi].txt
│       Marie Antoinette [Vosten].txt
│       On The Rocks (2020) [Vosten-fr].txt
│       The Beguiled [Multi].txt
│       The Bling Ring (2013).txt
│       Virgin Suicides [Multi].txt
│
├───Stanley Kubrick
│       Barry Lyndon [Multi].txt
│       Docteur Folamour [Multi].txt
│       Eyes Wide Shut [Vo].txt
│       Les Sentiers De La Gloire 1957 [Multi].txt
│
├───Taika Waititi
│       Hunt for the Wilderpeople [Vo].txt
│       Jojo Rabbit [Multi].txt
│
├───the Middle Earth saga
│       The Hobbit 2 The Desolation Of Smaug [Multi].txt
│       The Hobbit 3 The Battle Of The Five Armies [Multi].txt
│       The Hobbit An Unexpected Journey [Multi].txt
│       The Lord of the Rings 1 The Fellowship of the Ring.txt
│       The Lord of the Rings 2 The Two Towers.txt
│       The Lord of the Rings 3 The Return of the King.txt
│
├───Woody Allen
│       A Rainy Day in New York [Multi].txt
│       Annie Hall [Multi].txt
│       Blue Jasmine (2013).txt
│       Cassandra's Dream [Vosten].txt
│       Crimes And Misdemeanors [Vosten].txt
│       Magic in the Moonlight (2014).txt
│       Manhattan [Vosten-fr].txt
│       Match Point [Multi].txt
│       Play It Again Sam (1972) [Vosten].txt
│       Sleeper (1973).txt
│       Stardust Memories (1980).txt
│       The Purple Rose Of Cairo (1985).txt
│
└───Yorgos Lanthimos
        The Favourite [Multi].txt
        The Killing Of A Sacred Deer [Vostfr].txt
        The Lobster [Multi].txt
```

And after calling 

```powershell
main.ps1 \Films
```

with this `.conf` file:

```
NATIONALITY
GENRE
```

I obtain the following tree:
```
│   Call For Dreams (2018).txt
│
├───Belgium & France & Germany & Netherlands & Sweden & United Kingdom
│   └───Drama & Mystery & Thriller & Western
│           Brimstone (2016).en.txt
│           Brimstone (2016).txt
│
├───Denmark & South Africa & United Kingdom
│   └───Drama & Western
│           The Salvation (2014).txt
│
├───France & United States of America
│   ├───Comedy & Drama & Romance
│   │       Magic in the Moonlight (2014).txt
│   │
│   └───Crime & Drama
│           The Bling Ring (2013).txt
│
├───Iran & United States of America
│   └───Horror & Romance
│           A Girl Walks Home Alone at Night (2014).txt
│
├───New Zealand & United States of America
│   └───Action & Adventure & Fantasy
│           The Lord of the Rings 1 The Fellowship of the Ring.txt
│           The Lord of the Rings 2 The Two Towers.txt
│           The Lord of the Rings 3 The Return of the King.txt
│
├───Spain
│   └───Science Fiction & Thriller
│           Timecrimes (2007).txt
│
├───United States of America
│   ├───Comedy & Drama & Romance
│   │       Buffaloed.txt
│   │       Stardust Memories (1980).txt
│   │
│   ├───Comedy & Fantasy & Romance
│   │       The Purple Rose Of Cairo (1985).txt
│   │
│   ├───Comedy & Romance & Science Fiction
│   │       Sleeper (1973).txt
│   │
│   └───Drama
│           Blue Jasmine (2013).txt
│
└───Unkown
    └───Unknown
            A Fantastic Fear of Everything (2012) [Vosten].txt
            A Million Ways to Die in the West (2014) [Vosten].txt
            Brigsby Bear [Mutli].txt
            Bullets of Justice 2019 [Vosten].txt
            The Void (2016) [Vosten].txt
            Thoroughbreds (2017) [Vosten].txt
```
The `unknown`-sorted movies were not found on TMDB.