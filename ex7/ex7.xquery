xquery version "3.1";

(:
  7. Azon hozzátartozói keresztnevek és a hozzájuk tartozó hősök,
     akik legalább 3 hőshöz tartoznak.
     Az eredemény legyen a hozzátartozók
     keresztnevei alapján rendezve növekvő sorrendben.
:)

import schema default element namespace "" at "./ex7.xsd";

(:~
 : Retrieves the first name of a hero's relative.
 :
 : @param $heroes All heroes.
 : @return The hero's relative's first name.
 :)
declare function local:getRelativeFirstNames($heroes as item()+) as item()* {
    for $h in $heroes
    for $rel in $h/connections/relatives/string()
    let $name := fn:tokenize($rel)[1]
    return
        if ($name ne "Unidentified" and $name ne "Mr." and $name ne "Mrs." and $name ne "Dr.") then
            $name
        else
            ()
};

(:~
 : Retrieves all the heroes which have the same relative with
 : the same first name as the one passed by parameter.
 :
 : @param $hero All heroes.
 : @param $name The relative's first name.
 : @return The hero who has a relative with that first name.
 :)
declare function local:heroesWithRelativeName($heroes as item()+, $name as xs:string) as item()* {
    for $h in $heroes
    for $rel in $h/connections/relatives/string()
    let $n := fn:tokenize($rel)[1]
    return
        if ($n eq $name) then
            <heroName
                id="{$h/@id/string()}">{$h/name/string()}</heroName>
        else
            ()
};

let $heroes := fn:doc("../heroes.xml")/heroes/*
let $relativeFirstNames := fn:distinct-values(local:getRelativeFirstNames($heroes))
return
    validate {
        document {
            element relatives {
                for $firstName in $relativeFirstNames
                    order by $firstName
                let $relatives := local:heroesWithRelativeName($heroes, $firstName)
                return
                    if (fn:count($relatives) ge 3) then
                        (
                        element relative {
                            attribute firstName {$firstName},
                            element heroName {$relatives}
                        }
                        )
                    else
                        ()
            }
        }
    }