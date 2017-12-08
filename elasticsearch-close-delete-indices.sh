#!/bin/bash
# Close and delete indices created 5 days ago
 
set -e
 
#elasticsearch host
es_host=ip-172-27-60-58
 
#temp files
indices=./indices
open_indices=./open_indices
closed_indices=./closed_indices
 
#close indices older than 5 days
close_older_than=$(date -d "5 days ago" "+%Y.%m.%d")
 
#delete indices older than 5 days.
#Change this if you want to keep closed indices for longer
delete_older_than=$close_older_than
 
#Get indices, exclude kibana index. These are the indices before we close some of them.
curl -s -XGET "$es_host:9200/_cat/indices?v&pretty" | grep -v kibana > $indices
 
#grep open indices
cat $indices | grep open | awk '{print$3}' > $open_indices
 
echo "Indices older than date - $close_older_than will be closed."
 
#Close indices
while read index ; do
  time_stamp=$(echo $index|awk -F '-' '{print $2}')
  if [[ $close_older_than > $time_stamp ]]; then
        echo "Closing index: $index"
        curl -XPOST "$es_host:9200/$index/_close?pretty"
        close_index=true
  fi
done < $open_indices
 
if [ ! $close_index ] ; then
  echo "No indices were closed."
fi
 
echo "Indices older than date - $delete_older_than will be deleted."
 
#Get indices, exclude kibana index, this will include the indices that we closed
curl -s -XGET "$es_host:9200/_cat/indices?v&pretty" | grep -v kibana > $indices
 
#grep close indices
cat $indices | grep close |awk '{print $2}'> $closed_indices
 
#Delete indices
while read index ; do
  time_stamp=$(echo $index|awk -F '-' '{print $2}')
  if [[ $delete_older_than > $time_stamp ]]; then
        echo "Deleting index: $index"
        curl -XDELETE "$es_host:9200/$index?pretty"
       delete_index=true
  fi
done < $closed_indices
 
if [ ! $delete_index ] ; then
  echo "No indices were deleted."
fi
 
#cleanup
rm -f $indices $open_indices $closed_indices
