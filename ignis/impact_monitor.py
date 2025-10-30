#!/usr/bin/env python3
import psutil
import time
import math
import argparse
from datetime import datetime

def estimate_microload(pid, sample_ms=50, report_interval=5):
    """Stima un 'micro load average' simile a quello del sistema."""
    alpha = math.exp(-report_interval / 60.0)  # costante per smoothing 1min
    load = 0.0
    proc = psutil.Process(pid)
    samples = 0
    runnable_sum = 0
    next_report = time.time() + report_interval

    while True:
        try:
            if not proc.is_running():
                print(f"[{datetime.now().strftime('%H:%M:%S')}] Ignis terminato.")
                break

            # Controlla stato
            state = proc.status()
            runnable_sum += 1 if state in ("running", "disk-sleep") else 0
            samples += 1

            # Ogni report_interval secondi, aggiorna media
            if time.time() >= next_report:
                runnable_avg = runnable_sum / samples
                load = load * alpha + runnable_avg * (1 - alpha)

                with open("/proc/loadavg") as f:
                    sysload = f.read().split()[:3]

                cpu = proc.cpu_percent(None) / psutil.cpu_count()
                mem = proc.memory_info().rss / (1024 * 1024)

                print(f"[{datetime.now().strftime('%H:%M:%S')}] "
                      f"microload={load:.2f}  sysload={sysload[0]}  "
                      f"cpu={cpu:.1f}%  mem={mem:.1f}MB")

                yield {
                    "timestamp": datetime.now().isoformat(timespec="seconds"),
                    "microload": load,
                    "sysload": float(sysload[0]),
                    "cpu": cpu,
                    "mem": mem
                }

                runnable_sum = samples = 0
                next_report += report_interval

            time.sleep(sample_ms / 1000.0)

        except (psutil.NoSuchProcess, KeyboardInterrupt):
            print("\nMonitoraggio interrotto.")
            break


def main():
    parser = argparse.ArgumentParser(description="Monitora Ignis e stima micro-load isolato.")
    parser.add_argument("pid", type=int, help="PID del processo Ignis")
    parser.add_argument("--sample-ms", type=int, default=50, help="Intervallo di campionamento in millisecondi")
    parser.add_argument("--report", type=int, default=5, help="Intervallo di report in secondi")
    parser.add_argument("--out", default="ignis_load.csv", help="File di output CSV")
    args = parser.parse_args()

    print(f"Inizio monitoraggio PID {args.pid} "
          f"(sample={args.sample_ms}ms, report={args.report}s)...\n")

    with open(args.out, "w") as f:
        f.write("timestamp,microload,sysload,cpu,mem\n")
        for data in estimate_microload(args.pid, args.sample_ms, args.report):
            f.write(
                f"{data['timestamp']},{data['microload']:.2f},"
                f"{data['sysload']:.2f},{data['cpu']:.1f},{data['mem']:.1f}\n"
            )
            f.flush()

    print(f"\nDati salvati in {args.out}")

if __name__ == "__main__":
    main()
