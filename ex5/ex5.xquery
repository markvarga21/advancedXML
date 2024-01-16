xquery version "3.1";

(: 5. Azon nem 'DC Comics' karakterek, akik Gotham City-ben dolgoznak,
      de nem ott születtek.
:)

import schema default element namespace "" at "../heroes.xsd";

let $heroes := fn:doc("../heroes.xml")/heroes/*
return
    validate {
        document {
            element heroes {
                for $hero in $heroes
                    where fn:not(fn:contains($hero/biography/publisher/string(), "DC Comics")) and
                    fn:contains(fn:lower-case($hero/work/@base), "gotham city") and
                    fn:not(fn:contains(fn:lower-case($hero/biography/placeOfBirth/string()), "gotham city"))
                return
                    element hero {$hero/*}
            }
        }
    }