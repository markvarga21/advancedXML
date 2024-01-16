xquery version "3.1";

(: 4. Azon nem színes hajú (fekete vagy fehér de nem hajnélküli)
      Marvel karakterek nevei, melyeknek neve több mint 3 szóból áll.
:)

import schema default element namespace "" at "./ex4.xsd";

let $heroes := fn:doc("../heroes.xml")/heroes/*
return
    validate {
        document {
            element names {
                for $hero in $heroes
                    where $hero/biography/publisher/string() = "Marvel Comics" and
                    fn:count(fn:tokenize($hero/name)) gt 2 and
                    (
                    $hero/appearance/hairColor/string() = "black" or
                    $hero/appearance/hairColor/string() = "white" or
                    $hero/appearance/hairColor/string() = "no hair" or
                    $hero/appearance/hairColor/string() = "-"
                    )
                return
                    element name {$hero/name/string()}
            }
        }
    }