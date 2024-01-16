xquery version "3.1";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "html";
declare option output:html-version "5.0";
declare option output:indent "yes";

(:
    10. Egy HTML dokumentum, mely a hősök nevét, 'slug'-ját,
        erejét, nemét, magasságát, súlyát, foglalkozásainak számát,
        hozzátartozóinak számát és képét tartalmazza egy táblázat
        formájában.
:)

let $heroes := fn:doc("../heroes.xml")/heroes/*

return
    document {
        <html
            lang="en">
            <head>
                <meta
                    charset="UTF-8"/>
                <meta
                    name="viewport"
                    content="width=device-width, initial-scale=1.0"/>
                <link
                    rel="stylesheet"
                    href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css"
                />
                <title>Heroes</title>
            </head>
            <body>
                <table
                    class="table table-dark table-striped table-hover table-bordered">
                    <thead>
                        <tr>
                            <th
                                scope="col">Id</th>
                            <th
                                scope="col">Name</th>
                            <th
                                scope="col">Slug</th>
                            <th
                                scope="col">Power</th>
                            <th
                                scope="col">Gender</th>
                            <th
                                scope="col">Height</th>
                            <th
                                scope="col">Weight</th>
                            <th
                                scope="col">No. occupations</th>
                            <th
                                scope="col">No. of relatives</th>
                            <th
                                scope="col">Image</th>
                        </tr>
                    </thead>
                    <tbody>
                        {
                            for $h in $heroes
                            return
                                <tr>
                                    <td>{$h/@id/string()}</td>
                                    <td>{$h/name/string()}</td>
                                    <td>{$h/slug/string()}</td>
                                    <td>{$h/powerstats/power/string()}</td>
                                    <td>{$h/appearance/gender/string()}</td>
                                    <td>{$h/appearance/height/euHeight/string()} cm</td>
                                    <td>{$h/appearance/weight/euWeight/string()} kg</td>
                                    <td>{fn:count($h/work/occupations/*)}</td>
                                    <td>{fn:count($h/connections/relatives/*)}</td>
                                    <td>
                                        <img
                                            src="{$h/images/xs/string()}"
                                            alt="Not found!"/>
                                    </td>
                                </tr>
                        }
                    </tbody>
                </table>
            </body>
        </html>
    
    }