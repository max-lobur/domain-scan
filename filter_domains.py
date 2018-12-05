#!/usr/bin/env python3
import os

print("Filtering out domains set in SKIP_DOMAINS.")
with open("hosts.txt", "r+") as f:
    known_domains = [d.strip() for d in os.environ['SKIP_DOMAINS'].split(',')]
    discovered_domains = [d.strip() for d in f.readlines()]

    domains = []
    for d in discovered_domains:
        if d in known_domains:
            print("Removed '{}' based on SKIP_DOMAINS.".format(d))
            continue
        domains.append(d)

    f.seek(0)
    f.write(os.linesep.join(domains))
    f.truncate()
