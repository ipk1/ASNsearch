#!/bin/bash

org_name="${1%.*}"
cidr_dir="$1cid"

echo "Collecting ASN numbers from Org name '$org_name' using amass and bgpview API"
mkdir -p "$cidr_dir"
amass intel -org "$org_name" | cut -d ',' -f 1 > "$cidr_dir/${org_name}_amassasn.txt"
curl "https://api.bgpview.io/search?query_term=${org_name}" | jq '. | .data | .asns[] | .asn' >> "$cidr_dir/${org_name}_amassasn.txt"

echo "Gathering CIDR"
echo "CIDR from metabigor"
echo "$1" | metabigor net --org > "$cidr_dir/cidr_${org_name}_metabigor.txt"

echo "CIDR from bgp-search"
python3 ~/bgp_search/bgp_search.py -s "$org_name" | cut -d ' ' -f 3 > "$cidr_dir/cidr_${org_name}_bgp-search.txt"

echo "CIDR from asnlookup to CIDRs"
python3 ~/Asnlookup/asnlookup.py -o "$org_name"
mv ~/Asnlookup/output/${org_name}_ipv4.txt "$cidr_dir/cidr_${org_name}_asncidr.txt"

curl "http://asnlookup.com/api/lookup?org='${org_name}'" | jq -r '.[]' > "$cidr_dir/cidr_${org_name}_asnlookup.txt"

curl "https://api.bgpview.io/search?query_term=${org_name}" | jq . | grep "prefix" | cut -d '"' -f 4 | grep "." | grep -v ":" >> "$cidr_dir/cidr_${org_name}_cidr.txt"

echo "ASN number to CIDR's"
for i in $(cat "$cidr_dir/${org_name}_amassasn.txt"); do
  xpasn $i >> "$cidr_dir/cidr_${org_name}_cidr.txt"
  curl "https://api.bgpview.io/asn/$i/prefixes" | jq . | grep "prefix" | cut -d '"' -f 4 >> "$cidr_dir/cidr_${org_name}_cidr.txt"
done

cat $cidr_dir/${org_name}_amassasn.txt | metabigor net --asn -o $cidr_dir/cidrmetabig.txt

echo "Combining all CIDRs"
cat $cidr_dir/cidr* >> $cidr_dir/allcidrs.txt
sort $cidr_dir/allcidrs.txt | uniq | grep -v ':' > $cidr_dir/CIDRS.txt

echo "Domains from ASN's"
while read m; do
  amass intel -cidr $m >> $cidr_dir/amassdomains.txt
done < $cidr_dir/CIDRS.txt

while read k ; do
  amass intel --asn $k >> $cidr_dir/${org_name}_amassasndoms.txt
done < $cidr_dir/${org_name}_amassasn.txt
