# Android Emulator Hypervisor Driver - Fix Guide

**Error:** `StartService FAILED with error 4294967201`  
**Issue:** Hypervisor driver service won't start

![Error Screenshot](C:/Users/ELITEX21012G2/.gemini/antigravity/brain/2400cc73-ffee-4ecb-8a42-7a7f4b50de42/uploaded_image_1764077087860.jpg)

---

## 🔴 Root Causes

This error typically occurs due to:
1. **Hyper-V conflict** - Windows Hyper-V is blocking the emulator driver
2. **Virtualization disabled** - CPU virtualization not enabled in BIOS
3. **Conflicting software** - VirtualBox, VMware, or other hypervisors
4. **Windows security** - Core Isolation/Memory Integrity blocking driver

---

## ✅ Fix Methods (Try in Order)

### Fix 1: Disable Hyper-V (Most Common Solution)

**Why:** Windows Hyper-V conflicts with Android Emulator's hypervisor

**Steps:**
```powershell
# Run PowerShell as Administrator
# Disable Hyper-V
bcdedit /set hypervisorlaunchtype off

# Restart computer
shutdown /r /t 0
```

**After restart:**
- Try installing the hypervisor driver again in Android Studio
- Launch emulator

**To re-enable Hyper-V later (if needed):**
```powershell
bcdedit /set hypervisorlaunchtype auto
```

---

### Fix 2: Disable Windows Memory Integrity

**Why:** Windows Core Isolation can block unsigned drivers

**Steps:**
1. Open **Windows Security**
2. Go to **Device Security**
3. Click **Core isolation details**
4. Turn **OFF** "Memory integrity"
5. **Restart** computer
6. Try installing hypervisor driver again

---

### Fix 3: Enable CPU Virtualization in BIOS

**Why:** Emulator needs hardware virtualization (VT-x/AMD-V)

**Steps:**
1. **Restart** computer
2. Press **F2** or **Del** during boot (varies by manufacturer)
3. Find **Virtualization Technology** (usually in Advanced/CPU settings)
4. **Enable** it (may be called VT-x, AMD-V, SVM, or Virtualization)
5. **Save** and exit BIOS
6. Boot Windows
7. Try installing hypervisor driver again

**Check if enabled:**
```powershell
# Run in PowerShell
systeminfo | findstr /C:"Virtualization"
```

Should show: `Virtualization Enabled In Firmware: Yes`

---

### Fix 4: Uninstall Conflicting Software

**Why:** VirtualBox, VMware, etc. conflict with Android Emulator

**Check for:**
- VirtualBox
- VMware Workstation
- Docker Desktop (if using Hyper-V backend)
- Windows Sandbox

**Action:**
- Temporarily uninstall or disable these
- Install hypervisor driver
- Launch emulator

---

### Fix 5: Manual Driver Installation

**Why:** Android Studio installer may have issues

**Steps:**
1. Download manually: https://github.com/intel/haxm/releases
2. Get latest `haxm-windows_vX.X.X.zip`
3. Extract and run `intelhaxm-android.exe` **as Administrator**
4. Follow installer
5. Restart computer

---

### Fix 6: Use Windows Hypervisor Platform (WHPX)

**Why:** Alternative to HAXM, works with Hyper-V enabled

**Steps:**
1. Open **Control Panel**
2. **Programs** → **Turn Windows features on or off**
3. Enable:
   - ✅ **Windows Hypervisor Platform**
   - ✅ **Virtual Machine Platform**
4. Click **OK**
5. **Restart** computer
6. Open Android Studio → AVD Manager
7. Edit your emulator
8. Under **Emulated Performance**, select **Automatic** or **Hardware - WHPX**

---

## 🎯 Recommended Solution Path

### Quick Test (5 minutes):
```powershell
# 1. Disable Hyper-V (Run as Admin)
bcdedit /set hypervisorlaunchtype off

# 2. Restart
shutdown /r /t 0

# 3. After restart, try emulator
flutter emulators --launch Medium_Phone_API_36.1
```

### If that doesn't work (10 minutes):
1. Disable Memory Integrity (Windows Security)
2. Restart
3. Try emulator

### If still failing (15 minutes):
1. Check BIOS virtualization
2. Enable if disabled
3. Try emulator

---

## 🚀 Alternative: Skip Emulator Entirely

**Best Option:** Use physical device + scrcpy

```powershell
# 1. Connect Android phone via USB
# 2. Enable USB Debugging
# 3. Run app
flutter run

# 4. Mirror screen with scrcpy
scrcpy
```

**Or use Web:**
```powershell
flutter run -d chrome
```

---

## 📊 Diagnostic Commands

**Check virtualization status:**
```powershell
systeminfo | findstr /C:"Virtualization"
```

**Check Hyper-V status:**
```powershell
bcdedit /enum | findstr hypervisorlaunchtype
```

**Check running hypervisors:**
```powershell
sc query type= driver | findstr /i "hyper vmware virtual"
```

---

## ⚠️ Important Notes

### If you need Hyper-V for other work:
- Use **Windows Hypervisor Platform (WHPX)** instead of HAXM
- This allows Hyper-V and Android Emulator to coexist
- Slightly slower but works

### If you use Docker Desktop:
- Docker may use Hyper-V
- Switch Docker to WSL 2 backend (doesn't conflict)
- Or use physical device for Flutter testing

---

## ✅ Success Verification

After applying fixes, verify:

```powershell
# 1. Check emulator list
flutter emulators

# 2. Launch emulator
flutter emulators --launch Medium_Phone_API_36.1

# 3. Wait 30-60 seconds for emulator to boot

# 4. Check if running
flutter devices
```

Should show emulator in device list!

---

## 🎯 My Recommendation

**For your situation:**

1. **Try Fix 1 first** (Disable Hyper-V) - 90% success rate
2. **If that fails**, try Fix 2 (Memory Integrity)
3. **If still failing**, use physical device instead

**Physical device is actually better for testing:**
- ✅ Faster than emulator
- ✅ Real hardware performance
- ✅ No driver issues
- ✅ Use scrcpy for screen mirroring

---

## 📝 Next Steps

**Choose one:**

**Option A:** Fix emulator (15-30 min)
1. Disable Hyper-V
2. Restart
3. Try emulator

**Option B:** Use physical device (5 min) ⭐ Recommended
1. Connect phone
2. Enable USB debugging
3. Run `flutter run`
4. Use `scrcpy` for mirroring

**Option C:** Test on web (0 min)
1. Run `flutter run -d chrome`
2. Test all features

Which would you like to try?
