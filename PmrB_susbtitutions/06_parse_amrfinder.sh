#!/usr/bin/bash

for FILE in *amrfinder
do
        echo -n "${FILE/_amrfinder/}: "
        if grep -q "Y358N" "$FILE" && grep -q "E123D" "$FILE"; then
                echo "Y358N/E123D"
        elif grep -q "Y358N" "$FILE"; then
                echo "Y358N"
        elif grep -q "E123D" "$FILE"; then
                echo "E123D"
        else
                echo "WT"
        fi
done
