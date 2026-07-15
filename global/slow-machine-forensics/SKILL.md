---
name: slow-machine-forensics
description: |
  Find what is actually burning a Windows machine's resources, and audit what starts at boot.
  Use when: (1) "my computer is slow / sluggish / fan is always on", (2) "what's using my CPU/RAM",
  (3) "what should I stop from booting up", "streamline my machine", "is <vendor> bloat safe to
  remove", (4) a process shows a big number in Task Manager and you're asked what it is (vmmem,
  vmmemWSL, svchost, Memory Compression), (5) an app "won't start at boot" though its Run key
  looks fine, (6) any app is suspected of looping, thrashing, or spinning. Host/OS-level
  forensics on the machine itself. NOT for debugging code in a repo (use /investigate) and NOT
  for web page perf (use /benchmark).
author: Claude Code
version: 1.0.0
date: 2026-07-15
---

# Slow Machine Forensics

## Problem

"Why is my machine slow?" gets answered with the wrong tool. People (and agents) open Task
Manager, sort by **Memory**, and start killing vendor bloat. That finds nothing, because the
processes that wreck a machine are usually **CPU or I/O bound, not memory bound** — and they can
hold trivially little RAM while eating a whole core.

Proven on 2026-07-14/15: a machine where the user suspected Adobe/HP/OMEN. Those totalled ~400 MB
and near-zero CPU. The real culprit was `iCloudDrive` holding **42 MB of RAM** while burning
**85.8% of a CPU core continuously for a month**, generating a **9.17 GB log file** and reading
**251 GB out of a 7.66 GB folder**. No amount of memory-sorting would ever have surfaced it.

## Context / Trigger Conditions

- "my machine is slow", "the fan never stops", "everything is sluggish"
- "what's using all my CPU/RAM", "what is <process> and why is it using so much"
- "what should I stop from booting", "streamline my computer", "remove the bloat"
- An app doesn't start at boot even though its startup entry looks correct
- You suspect something is looping but Task Manager looks unremarkable

## Solution

### Phase 0 — Establish whether there is a problem at all

Do this before touching anything. Half the time the answer is "nothing is wrong."

```powershell
$os=Get-CimInstance Win32_OperatingSystem
$t=[math]::Round($os.TotalVisibleMemorySize/1MB,2); $f=[math]::Round($os.FreePhysicalMemory/1MB,2)
"RAM in use : $([math]::Round($t-$f,2)) / $t GB ($([math]::Round(($t-$f)/$t*100,0))%)"
(Get-CimInstance Win32_Processor) | Select-Object Name, NumberOfCores, NumberOfLogicalProcessors, LoadPercentage
```

**Check the CPU model.** A U-series / low-power chip (15-28W, e.g. Core Ultra 7 255U) is a real
ceiling. If the workload is 30 agent processes + Docker + WSL, the honest answer may be "you are
CPU-bound by physics, not by bloat." Say that rather than overselling a cleanup.

If RAM is <70% with GBs free, **stop blaming RAM** and go to Phase 1.

### Phase 1 — Sort by CUMULATIVE CPU, not RAM (this is the whole trick)

```powershell
Get-Process | Sort-Object CPU -Descending | Select-Object -First 10 `
  @{N='Name';E={$_.ProcessName}}, @{N='CPUsec';E={[math]::Round($_.CPU,0)}}, `
  @{N='MB';E={[math]::Round($_.WorkingSet64/1MB,0)}}
```

Anything with high CPU seconds and low MB is your suspect. Compare `CPUsec` against uptime:
if a process has burned CPU-seconds approaching (or exceeding) wall-clock seconds since boot,
it is pegging a core.

### Phase 2 — Measure the SUSTAINED rate

Cumulative CPU lies on multi-threaded processes and after any spike you caused yourself
(a backup, a scan). Measure the rate:

```powershell
$c1=(Get-Process NAME).CPU; $t1=Get-Date
$sw=[Diagnostics.Stopwatch]::StartNew(); while($sw.Elapsed.TotalSeconds -lt 20){$null=1}
$c2=(Get-Process NAME).CPU; $t2=Get-Date
"Core util: {0}%" -f [math]::Round(($c2-$c1)/(($t2-$t1).TotalSeconds)*100,1)
```

Do NOT use `Start-Sleep` if the harness blocks it; busy-wait. Note this measurement *competes*
for CPU, so the result is a **floor**, not a ceiling.

### Phase 3 — Separate CPU-spinning from I/O-storming

```powershell
$p=Get-Process NAME; $ci1=Get-CimInstance Win32_Process -Filter "ProcessId=$($p.Id)"
$r1=$ci1.ReadOperationCount; $w1=$ci1.WriteOperationCount
$sw=[Diagnostics.Stopwatch]::StartNew(); while($sw.Elapsed.TotalSeconds -lt 10){$null=1}
$ci2=Get-CimInstance Win32_Process -Filter "ProcessId=$($p.Id)"
"ReadOps/s : $([math]::Round(($ci2.ReadOperationCount-$r1)/10,0))"
"WriteOps/s: $([math]::Round(($ci2.WriteOperationCount-$w1)/10,0))"
"Total read MB: $([math]::Round($ci2.ReadTransferCount/1MB,0))"
```

**The ratio test that proves a loop:** compare total bytes read against the size of the data set
it operates on. 251 GB read from a 7.66 GB folder = re-read the whole tree ~33x = **loop, not
work**. Legitimate work reads its data roughly once. Heavy *writes* with low *reads* usually
means a download/install, which is real work — don't call that a bug.

### Phase 4 — Check the app's LOG DIRECTORY SIZE (fastest root cause in the whole procedure)

```powershell
# AppX/Store apps:
Get-ChildItem "$env:LOCALAPPDATA\Packages\<PKG>\LocalCache\Local\Logs" |
  Sort-Object Length -Descending | Select-Object -First 5 Name, @{N='MB';E={[math]::Round($_.Length/1MB,1)}}
# Also check: %LOCALAPPDATA%\<Vendor>, %APPDATA%\<Vendor>, %PROGRAMDATA%\<Vendor>
```

**A multi-GB log file IS an error loop.** The app is writing an error per iteration. Read the
tail and it names the root cause outright:

```powershell
$log = Get-ChildItem $logDir -Filter '*.log' | Sort-Object LastWriteTime -Descending | Select-Object -First 1
Get-Content $log.FullName -Tail 25
# Frequency-count the error types:
Get-Content $log.FullName -Tail 4000 | ForEach-Object { if ($_ -match 'ERROR\s+(\S+)') { $Matches[1] } } |
  Group-Object | Sort-Object Count -Descending | Select-Object -First 5 Count, Name
```

**Sort by `LastWriteTime`, NOT `Length`.** A giant stale log outranks the live one by size and
will hand you dead timestamps from a previous boot. This cost real time.

### Phase 5 — Fix at the right LAYER

The layer the symptom appears at is often not the layer the bug lives at. Escalate deliberately:

| Layer | Action | If it fails, the bug is deeper |
|---|---|---|
| Process | restart it | not process state |
| Filesystem | remove the triggering file/folder | not the data on disk |
| OS | reboot | not runtime state |
| **App database** | **sign out / reset / rebuild** | the corruption is persisted |

In the proven case, layers 1-3 ALL failed (restart, folder delete, full reboot) because the
corruption was a persisted DB holding orphaned records. Only the rebuild worked. **When a fix
"should" work and doesn't, go down a layer instead of repeating it.**

**Before rebuilding, verify the old state is actually GONE**, or you re-import the bug:
```powershell
foreach ($f in "$lc\...\app.db","$lc\...\app.db-wal") { if (Test-Path $f) {"PRESENT"} else {"GONE"} }
```
Back up first (`robocopy` to external), and expect unreadable/phantom files to fail the copy.

### Phase 6 — Startup audit: FOUR mechanisms, not three

Most sweeps check Run keys, services, and scheduled tasks, then declare victory. **The fourth
catches what the other three miss** — a 382 MB process survived a sweep that disabled all 8 of
its scheduled tasks.

1. Run keys — `HKLM`/`HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run` (+ `WOW6432Node`),
   plus enable-flag at `...\Explorer\StartupApproved\Run` (`02`/`06` = user-disabled)
2. Startup folders — `%APPDATA%\...\Start Menu\Programs\Startup`, and the ProgramData one
3. `Get-CimInstance Win32_Service | Where StartMode -eq 'Auto'` + `Get-ScheduledTask`
4. **AppX / Store startup tasks** — the forgotten one:

```powershell
$base = "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\SystemAppData"
Get-ChildItem $base | ForEach-Object { $fam=$_.PSChildName
  Get-ChildItem $_.PSPath -EA SilentlyContinue | ForEach-Object {
    $st=(Get-ItemProperty $_.PSPath -EA SilentlyContinue).State
    if ($st -in 0,2) { "$fam :: $($_.PSChildName) = $st" } } }
```
`2`=enabled, `1`=DisabledByUser (what Settings writes — write this to disable),
**`0` does NOT mean off** (observed on a process that was actively running).

5. **Rarer:** SystemApps spawned by `sihost.exe` with no startup task, gated by a feature flag
   (e.g. `HKCU:\...\CrossDeviceResume\Configuration\IsResumeAllowed` DWord → 0).

**Semantics:** `State=1` blocks BOOT autostart only. The app still launches on demand. That is
the desired outcome, not a failure — say so rather than reporting it as a leftover.

### Phase 7 — Report honestly

- Prefer **Manual** over **Disabled** for services, so things still work on demand.
- Back up registry/service/task state before changing it (`reg export`, `Export-Csv`).
- **Do not oversell.** If the vendor bloat is 400 MB and no CPU, say cutting it is hygiene, not
  a fix. Name the real constraint even when it's unwelcome (a U-series CPU, or the user's own
  workload).
- Never claim a fix from an exit code. Re-measure the same number you baselined.

## Verification

Re-run the Phase 2 sustained-rate probe and compare to the baseline you captured. Confirm the
log directory has stopped growing and the error signature is gone:

```powershell
Select-String -Path $newLog -Pattern '\tERROR\t' | Measure-Object | Select-Object Count   # want 0
```

Proven outcome: core util **85.8% → 9%** (measured *during* a 6.93 GB re-download, so it settles
lower), read ops **21,174/s → 17/s**, errors **~2,100 per 4k lines → 0**, app local state
**10,707 MB → 37.8 MB**.

## Example

Ask: *"what is vmmemWSL and why does it take so much RAM?"*

- Phase 0: 55% RAM, 14 GB free → not RAM-constrained. `vmmemWSL` is an accounting placeholder
  for the WSL2 VM; most of its number is Linux page cache and it self-reclaims. **No action.**
- Phase 1: sort by CPU → `iCloudDrive`, 42 MB RAM, more CPU-seconds than Defender. Suspect found.
- Phase 2: 85.8% of a core, sustained.
- Phase 3: 21,174 reads/sec; 251 GB read from a 7.66 GB folder → loop.
- Phase 4: log dir = 10.5 GB, one file 9.17 GB. Tail names it: `Can't find dir for item`,
  `Apply failed for item, rank 21023467` → orphaned DB records, 21M-entry queue.
- Phase 5: restart ✗ → delete trigger folder ✗ (reads −94%, CPU unchanged) → reboot ✗ →
  **sign out/in (DB rebuild) ✓**.

## Notes

- **Windows cloud placeholders:** detect by **attributes**, not extension. Looking for a
  `.icloud` extension reports 0. The real marker is bit `0x400000`
  (`RECALL_ON_DATA_ACCESS`); e.g. attributes `4199968` = OFFLINE + RECALL + ARCHIVE, and reads
  fail *"The cloud operation was not completed before the time-out period expired."*
- **Deleting from a synced folder propagates** to the user's other devices. Always confirm
  explicitly before removing anything under iCloud/OneDrive/Dropbox/GDrive, even if you found it
  yourself and it looks like junk. A permission classifier correctly blocked exactly this.
- **Antivirus exclusions:** excluding WSL/Docker `.vhdx` and `.git/objects` is cheap CPU win at
  low risk (opaque/content-addressed blobs). **Do not blanket-exclude `node_modules`** — that is
  precisely the npm postinstall supply-chain vector. Keep real-time protection on.
- Check for *multiple* sync clients (OneDrive + Dropbox + GDrive + iCloud) with overlapping
  roots — that causes genuine infinite churn. Verify dev dirs sit outside every sync root.
- Machine-specific facts live in memory, not here:
  `feedback_icloud_windows_runaway_rescan_loop.md`,
  `feedback_windows_startup_audit_four_mechanisms.md`,
  `feedback_docker_desktop_autostart_setting_not_run_key.md`,
  `feedback_wsl_vmmem_self_reclaims_no_config_needed.md`.
- See also: `/investigate` for code/repo debugging (repo-scoped, freeze hooks — does NOT cover
  host/OS forensics); `/benchmark` for web page performance; `/preflight` for env checks.
