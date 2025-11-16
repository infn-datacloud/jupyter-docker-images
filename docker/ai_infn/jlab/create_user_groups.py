#!/bin/env python3
"""
Simple script creating groups for the NB_USER based on NB_GROUPS env var.
The script is intended for Jupyter docker images inherinting from docker-stacks-foundation 
and should be installed in /usr/local/bin/before-notebook.d/

The format of the NB_GROUPS env var is:
  NB_GROUPS=gid:group[,gid2:group2[, ...]]

For example,
  NB_GROUPS=4001:lhcb,4002:cms,4003:atlas

"""

import os
import subprocess

groups = os.environ.get("NB_GROUPS", "").split(", ")
username = os.environ.get("NB_USER", os.environ.get("JUPYTERHUB_USER", "jovyan"))

for group in groups:
    gid, groupname = group.split(":")
    subprocess.run(["addgroup", "--gid", gid, groupname])
    subprocess.run(["adduser", username, groupname])

