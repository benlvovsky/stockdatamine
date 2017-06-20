#!/bin/bash
echo "<table>" ;
print_header=true
while read INPUT ; do
  if $print_header;then
    echo "<tr><th>$INPUT" | sed -e 's/:[^,]*\(,\|$\)/<\/th><th>/g'
    print_header=false
  fi
  echo "<tr><td>${INPUT//,/</td><td>}</td></tr>" ;
done < "${1:-/dev/stdin}"
echo "</table>"
