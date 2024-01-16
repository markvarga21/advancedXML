xquery version "3.1";

(: 
  3. A legtöbb csapattaggal (groupAffiliation) rendelkező
     szuperhős(ök) neve ábécé sorrendben rendezve 
:)

import schema default element namespace "" at "./ex3.xsd";

(:~
 : Returns the number of team/group members of a hero.
 :
 : @param $hero the hero itself.
 : @return the hero's team member count.
 :)
declare function local:getGroupMemberCount($hero as item()+) as xs:integer {
    let $groupAffiliation := $hero/connections/groupAffiliation/*
    let $groupMemberCount := fn:count($groupAffiliation)
    return
        $groupMemberCount
};

let $heroes := fn:doc("../heroes.xml")/heroes/*
let $maxGroupMembers := fn:max(
for $h in $heroes
    order by $h/name
return
    local:getGroupMemberCount($h)
)
return
    validate {
        document {
            element names {
                attribute maxMembers {$maxGroupMembers},
                for $h in $heroes
                    where local:getGroupMemberCount($h) = $maxGroupMembers
                return
                    <name>{$h/name/string()}</name>
            }
        }
    }
