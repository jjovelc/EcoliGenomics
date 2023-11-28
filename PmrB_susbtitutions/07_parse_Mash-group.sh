#!/usr/bin/bash



for FILE in *html; do
    echo -n "${FILE/_clermont.html/}: "
    sed -n 450p "$FILE" | grep -oP '(?<=<td align="left">).*?(?=<\/td>)'
done
