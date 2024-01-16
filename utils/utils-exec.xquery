xquery version "3.1";

import module namespace utils = "http://www.markvarga21.com/utils" at "utils.xquery";

(: 
  10. Az összes karaktert XML-ként reprezentálva, attribútumokat használva.
:)


let $heroes := fn:json-doc("../heroes.json")?*
return
    document {
        element heroes {
            for $h in $heroes
            let $hero := utils:getHeroAsXml($h)
            return
                $hero
        }
    }