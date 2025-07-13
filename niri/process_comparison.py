#!/usr/bin/env python3

import psutil
import time
import subprocess
import argparse
from statistics import mean

def get_all_children(proc):
    try:
        return proc.children(recursive=True)
    except (psutil.NoSuchProcess, psutil.AccessDenied):
        return []

def get_usage(proc):
    try:
        procs = [proc] + get_all_children(proc)
        cpu = sum(p.cpu_percent(interval=None) for p in procs if p.is_running())
        mem = sum(p.memory_info().rss for p in procs if p.is_running())
        return cpu, mem
    except psutil.NoSuchProcess:
        return 0.0, 0

def monitor_process(pid, duration, interval):
    proc = psutil.Process(pid)
    cpu_data, mem_data = [], []

    for _ in range(int(duration / interval)):
        cpu, mem = get_usage(proc)
        cpu_data.append(cpu)
        mem_data.append(mem)
        time.sleep(interval)

    return {
        "cpu_avg": mean(cpu_data),
        "cpu_max": max(cpu_data),
        "mem_avg": mean(mem_data),
        "mem_max": max(mem_data),
    }

def spawn_process(cmd):
    return subprocess.Popen(cmd, shell=True)

def print_results(label, stats):
    print(f"\n=== {label} ===")
    print(f"CPU avg: {stats['cpu_avg']:.2f} %")
    print(f"CPU max: {stats['cpu_max']:.2f} %")
    print(f"MEM avg: {stats['mem_avg'] / (1024**2):.2f} MB")
    print(f"MEM max: {stats['mem_max'] / (1024**2):.2f} MB")

def main():
    print("Starting")
    parser = argparse.ArgumentParser()
    parser.add_argument("--cmd1", help="Comando del primo processo (es: 'eww open bar')", required=False)
    parser.add_argument("--cmd2", help="Comando del secondo processo", required=False)
    parser.add_argument("--pid1", type=int, help="PID del primo processo (alternativo a cmd1)")
    parser.add_argument("--pid2", type=int, help="PID del secondo processo")
    parser.add_argument("--duration", type=int, default=10, help="Durata del monitoraggio in secondi")
    parser.add_argument("--interval", type=float, default=0.5, help="Intervallo di polling in secondi")
    args = parser.parse_args()

    print("Parameters parsed")

    procs = []

    if args.cmd1:
        p1 = spawn_process(args.cmd1)
        time.sleep(1)  # tempo per avviarsi
        pid1 = p1.pid
        procs.append(p1)
    else:
        pid1 = args.pid1

    if args.cmd2:
        p2 = spawn_process(args.cmd2)
        time.sleep(1)
        pid2 = p2.pid
        procs.append(p2)
    else:
        pid2 = args.pid2

    print(f"Monitoraggio per {args.duration} secondi...\n")
    stats1 = monitor_process(pid1, args.duration, args.interval)
    stats2 = monitor_process(pid2, args.duration, args.interval)

    print_results("Processo 1", stats1)
    print_results("Processo 2", stats2)

    for p in procs:
        try:
            p.terminate()
        except Exception:
            pass

    print("\n👉 Processo più esoso (media RAM):", "1" if stats1['mem_avg'] > stats2['mem_avg'] else "2")

if __name__ == "__main__":
    main()
