#!/bin/bash

if [[ "$#" != 1 ]]; then
  echo "Usage: $0 <cidr_list_file>"
  exit 1
fi

IPS_FILE="$1"
OUTPUT_FILE="pingable_ips.csv"

normalize_cidr() {
  local cidr="$1"
  local network=$(echo "$cidr" | cut -d'/' -f1)
  local prefix=$(echo "$cidr" | cut -d'/' -f2)

  if [[ "$prefix" > 24 ]]; then
    prefix="24"
    echo "$network/$prefix"
  else
    echo "$cidr"
  fi
}

scan_cidr() {
  local counter=1
  while read -r cidr; do
    local normalized_cidr=$(normalize_cidr $cidr)
    cat <<EOF
┌───────────────────────────────────────────────────────
│                         SCAN RESULTS
├───────────────────────────────────────────────────────
│ Scan:            #$counter
│ Normalized CIDR: $normalized_cidr
│ Original CIDR:   $cidr
└───────────────────────────────────────────────────────
EOF
    masscan --ping "$normalized_cidr" --rate 100 2>/dev/null | awk '/Discovered/{print $6}' | head -n 3 > temp_ips.txt
    ips_list=$(paste -sd, temp_ips.txt 2>/dev/null)
    if [[ -z "$ips_list" ]]; then
      ips_list="None,None,None"
    fi
    num_of_ips=$(wc -l < temp_ips.txt)
    echo "$num_of_ips Pingable IPs Found"

    echo $ips_list >> $OUTPUT_FILE
    ((counter++))
  done < $IPS_FILE
}
scan_cidr
