xquery version "3.1";

(: 6. Azon alteregó nélküli férfi karakterek,
      akiknek az alternevében szerepel a `master` szó.
:)

import schema default element namespace "" at "./ex6.xsd";

let $heroes := fn:doc("../heroes.xml")/heroes/*
return
    validate {
        document {
            element heroes {
                for $hero in $heroes
                    where
                    (
                    $hero/biography/alterEgos/string() eq "No alter egos found." or
                    $hero/biography/alterEgos/string() eq "-"
                    ) and
                    $hero/appearance/gender/string() eq "male" and
                    fn:contains(fn:lower-case($hero/biography/aliases/alias/string()), "master")
                return
                    element hero {
                        element id {$hero/@id/string()},
                        element name {$hero/name/string()},
                        $hero/biography/aliases
                    }
            }
        }
    }