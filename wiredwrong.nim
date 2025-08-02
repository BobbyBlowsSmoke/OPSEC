import os, strutils, osproc, terminal

proc checkIfRoot(): bool =
  return getEnv("USER") == "root"

proc warn(msg: string) =
  styledEcho(fgRed, "[!!] WARNING: ", fgWhite, msg)

proc info(msg: string) =
  styledEcho(fgGreen, "[*] ", fgWhite, msg)

proc enforceCompartmentalization() =
  info("Checking identity separation folders...")
  let realDir = "/home/user/real_identity"
  let deepDir = "/home/user/deep_identity"
  if dirExists(realDir) and dirExists(deepDir):
    info("Compartment folders exist.")
  else:
    warn("Missing compartmentalized identity folders.")
    createDir(realDir)
    createDir(deepDir)
    info("Created default folders.")

proc assumeWatched() =
  info("Reinforcing zero-trust posture...")
  warn("Assume screen is being recorded.")
  warn("Assume microphone is on.")
  warn("Assume network traffic is monitored.")

proc noPhonesCamerasBiometrics() =
  info("Checking USB and webcam devices...")
  let (usbOut, _) = execCmdEx("lsusb")
  if usbOut.contains("Camera") or usbOut.contains("iPhone"):
    warn("Remove phones or webcams before proceeding.")
  else:
    info("No phones or webcams detected.")
  # Optional: disable USB mounts (requires appropriate permissions)
  discard execShellCmd("echo 0 > /sys/bus/usb/drivers/usb/bind")

proc stripMetadata(files: seq[string]) =
  info("Stripping metadata...")
  for file in files:
    if file.endsWith(".jpg") or file.endsWith(".png") or file.endsWith(".pdf"):
      discard execShellCmd("mat2 " & file)
      discard execShellCmd("exiftool -all= -overwrite_original " & file)
      info("Sanitized " & file)

proc runAudit() =
  assumeWatched()
  enforceCompartmentalization()
  noPhonesCamerasBiometrics()

  var unsafeFiles: seq[string] = @[]
  for kind in @["jpg", "png", "pdf"]:
    for path in walkFiles("*." & kind):
      unsafeFiles.add(path)

  if unsafeFiles.len > 0:
    stripMetadata(unsafeFiles)
  else:
    info("No metadata-bearing files found.")

when isMainModule:
  if not checkIfRoot():
    warn("Run this script with sudo/root for full effectiveness.")
  runAudit()

