#!/usr/bin/bash

cut -f 1 curl_commands.txt  | sed 's/$/_genome/' > a
cut -f 2 curl_commands.txt | grep -o 'GCA_[0-9]*\.[0-9].zip\|GCF_[0-9]*\.[0-9].zip' > b
paste a b > zipFiles_and_ids.txt
rm a b

