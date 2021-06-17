

# settings

url="http://localhost:9200"
index="hotel"
hits_size=10000
loop_count=5



# pid stands for pagination id.
pid=$(http -b POST "$url/$index/_pit?keep_alive=10m" | jq .id)

base_request_body='{
  "size": %s,
  "pit": {
	    "id":  %s, 
	    "keep_alive": "10m"
  },
    "sort": [
    {
      "hotel_name.keyword": {
        "order": "desc"
      }
    }
  ]
}
'

printf "$base_request_body" "$hits_size" "$pid" | http -b GET "$url/_search" > 1_10000.json


for i in $(seq 1 $loop_count) ; do 

  # making sure how many hits there is

  hits=$(cat "$i"_10000.json | jq '.hits.hits | length')

  last_hit=$(echo "$hits - 1" | bc)
  search_after=$(cat "$i"_10000.json | jq .hits.hits[$last_hit].sort)

  request_body_with_search_after='{
    "size": %s,
    "pit": {
      "id": %s,
      "keep_alive": "10m"
    },
    "sort": [
      {
        "hotel_name.keyword": {
          "order": "desc"
        }
      }
    ],
    "search_after": %s
  }' 

  file_name=$(echo "$i + 1" | bc)
  printf "$request_body_with_search_after" "$hits_size" "$pid" "$search_after" | http -b GET  "$url/_search" > "$file_name"_10000.json


 done


