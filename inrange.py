import ipaddress, csv

def ip_in_subnet(ip, subnet):
    subnetArr = subnet.split('/')
    if int(subnetArr[1]) > 24:
        subnetArr[1] = "24"
        network = subnetArr[0].split('.')
        network[3] = "0"
        subnet = ".".join(network) + f"/{subnetArr[1]}"
    return ipaddress.ip_address(ip) in ipaddress.ip_network(subnet)

with open("ips.csv", "r") as csv_file:
    csv_reader = csv.reader(csv_file)
    with open("ipsnew.csv", "w", newline='') as new_file:
        csv_writer = csv.writer(new_file, delimiter=',')
        csv_writer.writerow(["Subnet", "IP1", "IP2", "IP3", "IP1 In Range", "IP2 In Range", "IP3 In Range"])
        next(csv_reader, None)
        for line in csv_reader:
            selected_columns = line[2:6]
            for i in range(2, 5):
                if line[i+1] != "None":
                    selected_columns.append(ip_in_subnet(line[i+1], line[2]))
                else:
                    selected_columns.append("None")
            csv_writer.writerow(selected_columns)
