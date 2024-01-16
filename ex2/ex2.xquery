xquery version "3.1";

(: 2. A leggyengébb dolgozó, de bázis nélküli
   férfi (ember) szuperhős ereje.
:)

let $heroes := fn:doc("../heroes.xml")/heroes/*
let $men := fn:filter($heroes, function ($temp) {
    let $race := fn:lower-case($temp/appearance/race/string())
    let $gender := fn:lower-case($temp/appearance/gender/string())
    return
        $gender = "male"
})
let $notWorkingMen := fn:filter($men, function ($temp) {
    let $work := $temp/work
    let $race := fn:lower-case($temp/appearance/race/string())
    return
        fn:not(fn:empty($work/occupations)) and
        $work/@base/string() = "-" and
        fn:contains($race, "human")
})
return
    fn:min($notWorkingMen/powerstats/strength)