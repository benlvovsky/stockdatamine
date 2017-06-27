#!/bin/bash
#echo '<link rel="stylesheet" href="https://unpkg.com/purecss@1.0.0/build/pure-min.css" integrity="sha384-nn4HPE8lTHyVtfCBi5yW9d20FjT8BJwUXyWZT9InLYax14RDjBj46LmSztkmNP9w" crossorigin="anonymous">'
echo "<!DOCTYPE html>"
echo "<html>
<head>
<style>
th {
    background-color: #4CAF50;
    color: white;
}
tr:nth-child(even) {background-color: #f2f2f2}
tr:hover {background-color: #f5f5f5}
th, td {
    border-bottom: 1px solid #ddd;
}
</style>
</head>"

echo '<table class="pure-table pure-table-horizontal pure-table-striped">' ;
print_header=true
while read INPUT ; do
  if $print_header;then
    echo "<thead><tr><th>${INPUT//,/</th><th>}</th></tr></thead>" ;
    print_header=false
    echo "<tbody>"
  else
    echo "<tr><td>${INPUT//,/</td><td>}</td></tr>" ;
  fi
done < "${1:-/dev/stdin}"
echo "</tbody>"
echo "</table></html>"
