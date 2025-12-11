#!/bin/bash

conn_name=$(nmcli -t -f NAME connection show --active | head -n1)

nmcli connection modify "$conn_name" ipv4.ignore-auto-dns yes
nmcli connection modify "$conn_name" ipv4.dns "8.8.8.8 8.8.4.4"
nmcli connection down "$conn_name"
nmcli connection up "$conn_name"
