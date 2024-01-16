xquery version "3.1";

(:
  9. A _Alignment_-enkénti karakterek maximum magasságával
  rendelkező karakterek neve, magassága és súlya.
:)

(:~
 : Finds the tallest hero for a specific alignment group.
 :
 : @param $heroes All heroes.
 : @param $alignment The name of the alignment.
 : @return The tallest hero for the given alignment.
 :)
declare function local:getHeroOfMaxHeightHeroForAlignment($heroes as item()+, $alignment as xs:string) as item()? {
    let $alignedHeroes := $heroes[biography/alignment = $alignment]
    let $maxHeight := fn:max($alignedHeroes/appearance/height/unit[@measurement = "cm"])
    for $h in $alignedHeroes
        where $h/appearance/height/unit[@measurement = "cm"] = $maxHeight
    return
        $h
};

let $heroes := fn:doc("../heroes.xml")/heroes/*
let $alignments := fn:distinct-values($heroes/biography/alignment/string())
let $output := map:merge(
for $a in $alignments
let $hero := local:getHeroOfMaxHeightHeroForAlignment($heroes, $a)
return
    map {
        $a: map {
            "name": $hero/name/string(),
            "height": map {
                "us": fn:concat(
                $hero/appearance/height/unit[@measurement = "feet-inches"]/feet/string(),
                "'",
                $hero/appearance/height/unit[@measurement = "feet-inches"]/inches/string()
                ),
                "eu": fn:concat($hero/appearance/height/unit[@measurement = "cm"]/string(), " cm")
            },
            "weight": map {
                "us": fn:concat($hero/appearance/weight/unit[@measurement = "lb"]/string(), " lb"),
                "eu": fn:concat($hero/appearance/weight/unit[@measurement = "kg"]/string(), " kg")
            }
        }
    }
)

return
    serialize($output, map {"method": "json"})