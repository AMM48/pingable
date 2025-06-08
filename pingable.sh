#!/bin/bash

if [[ "$#" != 1 ]]; then
  echo "Usage: $0 <cidr_list_file>"
  exit 1
fi

cyan=$(tput setaf 6)
yellow=$(tput setaf 3)
green=$(tput setaf 2)
magenta=$(tput setaf 5)
white=$(tput setaf 7)
bold=$(tput bold)
reset=$(tput sgr0)

IPS_FILE="$1"
OUTPUT_FILE="pingable_ips.csv"
total=0
#normalize_cidr() {
#  local cidr="$1"
#  local network=$(echo "$cidr" | cut -d'/' -f1)
#  local prefix=$(echo "$cidr" | cut -d'/' -f2)

#  if [[ "$prefix" > 24 ]]; then
#    prefix="24"
#    echo "$network/$prefix"
#  else
#    echo "$cidr"
#  fi
#}

scan_cidr() {
  local counter=1
  while read -r cidr || [[ -n $cidr ]]; do
    #local normalized_cidr=$(normalize_cidr $cidr)
    local prefix=$(echo $cidr | cut -d'/' -f2)
    local host_bits=$((32 - prefix))
    local num_ips=$((2**host_bits))
    local formatted_hosts=$(printf "%'d" $num_ips)
    local normalized_cidr=$cidr
    cat <<EOF
${cyan}┌───────────────────────────────────────────────────────${reset}
${cyan}│${reset} ${bold}${white}                      SCAN RESULTS${reset}
${cyan}├───────────────────────────────────────────────────────${reset}
${cyan}│${reset} ${yellow}• Scan Number:${reset}     ${green}#$counter${reset}
${cyan}│${reset} ${yellow}• Total IPs:${reset}       ${magenta}$formatted_hosts${reset}
${cyan}│${reset} ${yellow}• Subnet:${reset}          ${magenta}$cidr${reset}
${cyan}└───────────────────────────────────────────────────────${reset}
EOF
    SECONDS=0
    masscan --ping "$normalized_cidr" --rate 100 2>/dev/null | awk '/Discovered/{print $6}' | head -n 3 > temp_ips.txt
    ips_list=$(paste -sd, temp_ips.txt 2>/dev/null)
    if [[ -z "$ips_list" ]]; then
      ips_list="None,None,None"
    fi
    num_of_ips=$(wc -l < temp_ips.txt)
    echo "• Pingable IPs Found: $num_of_ips"
    echo "• Execution Time: $SECONDS Seconds"
    echo $ips_list >> $OUTPUT_FILE
    ((counter++))
    ((total += num_of_ips))
  done < $IPS_FILE
}
scan_cidr
echo "Total Number of Pingable IPs: $total"
