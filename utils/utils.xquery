module namespace utils = "http://www.markvarga21.com/utils";

(:~
 : Removes the parantheses from the start and the end.
 :
 : @param $str The string to remove from.
 : @return The parantheses-free string.
 :)
declare function utils:removeParantheses($str as xs:string) as xs:string {
    if (fn:not(fn:empty($str))) then
        (
        let $ret := fn:substring($str, 2, fn:string-length($str) - 2)
        return
            $ret
        )
    else
        ""
};

(:~
 : Normalizes a given string by replacing the ';' characters 
 : with ',', then replaces the commas inside the paraantheses
 : with '__', which then will be removed.
 : The final string will be normalized for custom usages.
 :
 : @param $str The string to normalize.
 : @return The normalized string.
 :)
declare function utils:tokenize($str as xs:string) as xs:string {
    let $normalized0 := fn:replace($str, ";", ",")
    
    let $regex := "\(([^,]+),\s?([^)]+)\)"
    let $regex2 := "\((\w+)\)"
    let $temp := fn:replace($normalized0, $regex2, "($1,__)")
    
    let $normalized1 := fn:replace($temp, $regex, "($1* $2)")
    let $normalized2 := fn:replace($normalized1, "\* __", "")
    let $normalized3 := fn:replace($normalized2, ",", ";")
    let $ret := fn:replace($normalized3, "\*", ",")
    return
        fn:replace($ret, ";__", "")
};

(:~
 : Replaces the '-' character with 0.
 :
 : @param $str The string to correct.
 : @return The corrected string.
 :)
declare function utils:removeNan($str as xs:string*) {
  if (fn:contains($str, "-")) then "0"
  else xs:string($str)
};

(:~
 : Converts a hero in JSON format to XML format.
 :
 : @param $hero The hero itself.
 : @return The hero in XML format.
 :)
declare function utils:getHeroAsXml($hero as item()+) as item()+ {
    <hero
        id="{$hero?id}">
        <name>{$hero?name}</name>
        <slug>{$hero?slug}</slug>
        <powerstats>
            <intelligence>{$hero?powerstats?intelligence}</intelligence>
            <strength>{$hero?powerstats?strength}</strength>
            <speed>{$hero?powerstats?speed}</speed>
            <durability>{$hero?powerstats?durability}</durability>
            <power>{$hero?powerstats?power}</power>
            <combat>{$hero?powerstats?combat}</combat>
        </powerstats>
        <appearance>
            <gender>{fn:lower-case($hero?appearance?gender)}</gender>
            <race>
                {
                  let $rawRace := $hero?appearance?race
                  return
                    if (fn:empty($rawRace)) then "-"
                    else $rawRace
                }
            </race>
            <height>
                <usHeight measurement="feet-inches">
                   <feet>
                       {
                         let $rawFeet := $hero?appearance?height?*[1]
                         return 
                             if (fn:contains($rawFeet, "-")) then 0
                             else if (fn:not(fn:contains($rawFeet, "'"))) then $hero?appearance?height?*[1]
                             else utils:removeNan(fn:tokenize($hero?appearance?height?*[1], "'")[1])
                       }
                   </feet>
                   <inches>
                       {
                         let $rawInches := $hero?appearance?height?*[1]
                         return
                             if (fn:contains($rawInches, "-")) then 0
                             else if (fn:not(fn:contains($rawInches, "'"))) then 0
                             else (
                               let $temp := utils:removeNan(fn:tokenize($hero?appearance?height?*[1], "'")[2])
                               return
                                   if ($temp = "") then 0
                                   else $temp
                             )
                       }
                   </inches>
                </usHeight>
                <euHeight measurement="cm">
                    {
                      let $rawCm := fn:tokenize($hero?appearance?height?*[2])
                      let $unit := $rawCm[2]
                      return
                          if ($unit = "meters" or $unit = "m") then utils:removeNan(xs:string(xs:integer(xs:float($rawCm[1])*100)))
                          else utils:removeNan($rawCm[1])
                    }
                </euHeight>
            </height>
            <weight>
                <usWeight measurement="lb">
                    {
                      let $rawLb := fn:tokenize($hero?appearance?weight?*[1])[1]
                      return utils:removeNan($rawLb)
                    }
                </usWeight>
                <euWeight measurement="kg">
                    {
                      let $rawKg := fn:tokenize($hero?appearance?weight?*[2])[1]
                      return
                          if (fn:contains($rawKg, ",")) then (utils:removeNan(fn:replace($rawKg, ",", "")))
                          else utils:removeNan($rawKg)
                    }
                </euWeight>
            </weight>
            <eyeColor>{fn:lower-case($hero?appearance?eyeColor)}</eyeColor>
            <hairColor>{fn:lower-case($hero?appearance?hairColor)}</hairColor>
        </appearance>
        <biography>
            <fullName>{$hero?biography?fullName}</fullName>
            <alterEgos>{$hero?biography?alterEgos}</alterEgos>
            <aliases>
                {
                    let $aliases := $hero?biography?aliases
                    for $alias in $aliases
                    return
                        <alias>{$alias}</alias>
                }
            </aliases>
            <placeOfBirth>{$hero?biography?placeOfBirth}</placeOfBirth>
            <firstAppearance>{$hero?biography?firstAppearance}</firstAppearance>
            <publisher>{$hero?biography?publisher}</publisher>
            <alignment>{$hero?biography?alignment}</alignment>
        </biography>
        <work
            base="{$hero?work?base}">
            <occupations>
                {
                    let $normalizedOccupation := utils:tokenize($hero?work?occupation)
                    let $occupations := fn:tokenize($normalizedOccupation, "; ")
                    for $occ in $occupations
                    return
                        if ($occ = "-") then
                            ()
                        else
                            <occupation>{fn:lower-case($occ)}</occupation>
                }
            </occupations>
        </work>
        <connections>
            <groupAffiliation>
                {
                    let $groupAffiliationsRaw := utils:tokenize($hero?connections?groupAffiliation)
                    let $groupAffiliationsNormalized :=
                    if (fn:not(fn:empty($groupAffiliationsRaw)) and fn:not($groupAffiliationsRaw = "-")) then
                        fn:tokenize($groupAffiliationsRaw, "; ")
                    else
                        ()
                    for $group in $groupAffiliationsNormalized
                    return
                        if (fn:contains($group, "(")) then
                            (
                            let $relation := fn:tokenize($group, " \(")
                            return
                                <group
                                    relation="{fn:replace($relation[2], "\)", "")}">{$relation[1]}</group>
                            )
                        else
                            <group>{$group}</group>
                }
            </groupAffiliation>
            <relatives>
                {
                    let $relativesRaw := utils:tokenize($hero?connections?relatives)
                    let $relativesNormalized :=
                    if (fn:not(fn:empty($relativesRaw)) and fn:not($relativesRaw = "-")) then
                        fn:tokenize($relativesRaw, "; ")
                    else
                        ()
                    for $relative in $relativesNormalized
                    let $relation := fn:tokenize($relative, " \(")
                    return
                        <relative
                            relation="{fn:replace($relation[2], "\)", "")}">{$relation[1]}</relative>
                }
            </relatives>
        </connections>
        <images>
            <xs>{$hero?images?xs}</xs>
            <sm>{$hero?images?sm}</sm>
            <md>{$hero?images?md}</md>
            <lg>{$hero?images?lg}</lg>
        </images>
    </hero>
};
