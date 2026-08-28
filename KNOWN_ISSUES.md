## Known Issues

### Crash on launch on GrapheneOS ("mprotect failed: 13, Permission denied")

**Symptom:** the app crashes immediately on launch on GrapheneOS with a SIGABRT
and an abort message like:

```
../../../flutter/third_party/dart/runtime/vm/virtual_memory_posix.cc: ###:
error: mprotect failed: 13 (Permission denied)
```
**Cause:** this is not an Openshelf-specific bug. GrapheneOS's per-app "Exploit
protection" includes a toggle called **"Dynamic code loading from memory"**. The
Dart VM, even in AOT release builds, needs to allocate writable memory pages at
startup, write certain internal routines into them (e.g. `dart:core`'s regex JIT
compiler, which is still JIT-compiled even in release mode), and then call `mprotect`
to mark them executable. GrapheneOS flags this exact pattern as dynamic code
loading and blocks it when the toggle is enabled, which makes the `mprotect` call
fail and the Dart VM abort. The same crash, with the same message and in the same
library (`libflutter.so`), has been reported in other, unrelated Flutter apps on
GrapheneOS (e.g. Ente Photos, Ente Locker, BlueBubbles), it's a Flutter/Dart engine
limitation, not something fixable from application code.

**Workaround:** go to Settings --> Apps --> Openshelf --> "Exploit protection", and disable
**"Dynamic code loading from memory"** for Openshelf specifically. The other two toggles
(storage, WebView JIT) are unrelated and can stay enabled.

### Error when importing library from v1.1.1 to v1.2.2 (untested for other versions)

**Symptom:** an error appears that prevents the importation, such as:

```
Error: PathNotFoundException: Cannot copy file to '/data/user/0/org.ftena.openshelf/
app_flutter/imprints/imprint_image_cropper_1786282222584.jpg', path ='/data/user/0/
org.ftena.openshelf/cache/import_imprints/imprint_image_cropper_1786282222584.jpg'
(OS Error: No such file or directory, errno = 2)
```
**Cause:** This is likely caused by a bad migration process in the database from the
v1.1.1 to the v1.2.2. This is likely a version specific issue that is actively worked
upon.

**Workaround:** Creating a new book and then importing the save file seems to solve the
issue. For more information see issue https://github.com/Swappppy/Openshelf/issues/21.
