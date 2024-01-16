xquery version "3.1";

(:
  Az 5 legnagyobb hőscsapat, össz-statisztikái összege (intelligence, strength,
  speed, durability, power, combat) alapján vett leggyengébb hőse
  a statisztikáival, a nevével és a csapat együtt.
  Az eredmény legyen csapatméret alapján csökkenő sorrendben rendezve.
:)


(:~
 : Sums up all the stats of a hero.
 :
 : @param $heroe The hero itself.
 : @return The summed up statistics of the given hero.
 :)
declare function local:sumStatsForHero($hero as element()) as xs:integer {
    let $stats := $hero/powerstats/*
    return
        xs:integer(fn:sum($stats))
};

(:~
 : Fetches all the hero groups.
 :
 : @param $heroes All heroes.
 : @return The hero groups.
 :)
declare function local:getHeroGroups($heroes as item()+) as item()* {
    for $h in $heroes
    for $g in $h/connections/groupAffiliation/*
    return
        $g
};

(:~
 : Fetches all the heroes for the given group name.
 :
 : @param $heroes All heroes.
 : @param $groupName The name of the group.
 : @return The hero groups in the given group.
 :)
declare function local:getHeroesForGroup($heroes as item()+, $groupName as xs:string) as item()* {
    for $h in $heroes
    let $groups := $h/connections/groupAffiliation/*
        where $groupName = $groups
    return
        $h
};

(:~
 : Fetches the number of members in a specific group.
 :
 : @param $heroes All heroes.
 : @param $groupName The name of the group.
 : @return The number of heroes in the group.
 :)
declare function local:getHeroCountForGroup($heroes as item()+, $groupName as xs:string) as xs:integer {
    let $count := fn:count(local:getHeroesForGroup($heroes, $groupName))
    return
        $count
};

(:~
 : Finds the weakest hero in the given group.
 :
 : @param $heroes All heroes.
 : @param $groupName The name of the group.
 : @return The weakest hero in the given group.
 :)
declare function local:findWeakestHeroForGroup($heroes as item()+, $groupName as xs:string) as item()? {
    let $heroesForGroup := local:getHeroesForGroup($heroes, $groupName)
    let $topHeroes :=
    for $h in $heroesForGroup
    let $stat := local:sumStatsForHero($h)
        order by $stat
    return
        $h
    return
        $topHeroes[1]
};

let $heroes := fn:doc("../heroes.xml")/heroes/*
let $groups := fn:distinct-values(local:getHeroGroups($heroes))
let $output :=
for $g in $groups
let $count := local:getHeroCountForGroup($heroes, $g)
    order by $count descending
let $weakestHero := local:findWeakestHeroForGroup($heroes, $g)
let $heroStatSum := local:sumStatsForHero($weakestHero)
return
    map {
        "group": map {
            "name": $g,
            "memberCount": $count
        },
        "weakestHero": map {
            "id": $weakestHero/@id/string(),
            "name": $weakestHero/name/string(),
            "combinedPower": $heroStatSum,
            "stats": map {
                "intelligence": $weakestHero/powerstats/intelligence/string(),
                "strength": $weakestHero/powerstats/strength/string(),
                "speed": $weakestHero/powerstats/speed/string(),
                "durability": $weakestHero/powerstats/durability/string(),
                "power": $weakestHero/powerstats/power/string(),
                "combat": $weakestHero/powerstats/combat/string()
            }
        }
    }
let $array := array {fn:subsequence($output, 1, 5)}

return
    serialize($array, map {"method": "json"})