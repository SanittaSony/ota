#!/system/bin/sh
if ! applypatch -c MTD:recovery:5797888:c7b9e8cc7ff49258549e46d34874667319d62945; then
  applypatch  MTD:boot:5797888:c7b9e8cc7ff49258549e46d34874667319d62945 MTD:recovery c7b9e8cc7ff49258549e46d34874667319d62945 5797888 c7b9e8cc7ff49258549e46d34874667319d62945:/system/recovery-from-boot.p && log -t recovery "Installing new recovery image: succeeded" || log -t recovery "Installing new recovery image: failed"
else
  log -t recovery "Recovery image already installed"
fi
