
for i in $(ls -1 *.json ); do

    cat $i | jq .hits.hits[]._source > 1.json
    jq -s < 1.json > 2.json
    cat 2.json | jq '.[] + {"tags" : "_grokparsefailure_sysloginput"}' > 3.json
    jq -s < 3.json > 4.json
    cat 4.json | jq -r '(map(keys) | add | unique) as $cols | map(. as $row | $cols | map($row[.])) as $rows | $cols, $rows[] | @csv' > $i.csv

    rm [1234].json

done
