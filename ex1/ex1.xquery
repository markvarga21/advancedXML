xquery version "3.1";

(: 1. Azon jó szuperhősőknek a nemenkénti átlagsúlya kg-ban mérve,
      akik magasabbak mint 180 cm.
:)

import schema default element namespace "" at "./ex1.xsd";

declare variable $MIN_HEIGHT_IN_CM := 180;

(:~
 : Maps the incoming gender to 'MALE' or 'FEMALE'
   or to 'OTHER' if neither/not known.
 :
 : @param $gender The gender itself.
 : @return The mapped gender.
 :)
declare function local:mapGender($gender as xs:string) as xs:string {
    let $lowerGender := fn:lower-case($gender)
    return
        if ($lowerGender = "male" or $lowerGender = "female")
        then
            fn:upper-case($lowerGender)
        else
            "OTHER"
};

let $heroes := fn:doc("../heroes.xml")/heroes/*
return
    validate {
        document {
            element RESULT {
                for $h in $heroes/appearance
                    where $h/height/euHeight > $MIN_HEIGHT_IN_CM
                    group by $gender := local:mapGender($h/gender)
                return
                    element {$gender} {
                        let $avg := fn:avg($h/weight/euWeight)
                        return
                            fn:round($avg, 2)
                    }
            }
        }
    }
