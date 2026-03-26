# Asahi Linux Workaround Services

These services/patches work around known Asahi Linux issues. When debugging
suspend, display, or boot problems, disable/rename these first to isolate
whether the issue is a regression or already handled here.

---

## 1. HDMI Resume (`hdmi-resume.service`)

**File:** `/etc/systemd/system/hdmi-resume.service`

**Problem:** The HDMI DCP (`289c00000.dcp`) fails to reinitialise after
resume from suspend, leaving external HDMI displays blank.

**Fix:** Unbinds and rebinds the `apple-dcp` kernel driver for the HDMI DCP
on resume from sleep.

**Enable/disable:**
```bash
sudo systemctl enable hdmi-resume.service
sudo systemctl disable hdmi-resume.service
```

---

## 2. Docker Sleep (`docker-sleep.service`)

**File:** `/etc/systemd/system/docker-sleep.service`

**Problem:** Docker container networking breaks after suspend/resume — bridge
interfaces and NAT rules get into a bad state when the system sleeps with
containers running.

**Fix:** Stops all running containers and Docker itself before sleep, restarts
Docker on wake.

**Enable/disable:**
```bash
sudo systemctl enable docker-sleep.service
sudo systemctl disable docker-sleep.service
```

---

## 3. SDDM Wait for DRM (`sddm.service.d/wait-for-drm.conf`)

**File:** `/etc/systemd/system/sddm.service.d/wait-for-drm.conf`

**Problem:** SDDM races udev during boot and starts before DRM devices are
available, resulting in a black screen instead of the login prompt.

**Fix:** Adds `systemd-udev-settle.service` as a dependency so SDDM waits for
udev to finish before starting. Adds a few seconds to boot time.

**Enable:** rename the directory so systemd picks it up:
```bash
sudo mv /etc/systemd/system/sddm.service.d.bak /etc/systemd/system/sddm.service.d
sudo systemctl daemon-reload
```

**Disable:**
```bash
sudo mv /etc/systemd/system/sddm.service.d /etc/systemd/system/sddm.service.d.bak
sudo systemctl daemon-reload
```
