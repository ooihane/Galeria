#!/usr/bin/env python3
"""Package an unsigned app; this is not an Apple distribution export."""
from pathlib import Path
import plistlib
import stat
import zipfile

root = Path(__file__).resolve().parents[1]
app = root / 'build/device/Build/Products/Release-iphoneos/Galeria.app'
if not app.is_dir():
    raise SystemExit('No existe la app compilada para dispositivo.')
with (app / 'Info.plist').open('rb') as file:
    info = plistlib.load(file)
if info.get('CFBundleSupportedPlatforms') != ['iPhoneOS']:
    raise SystemExit('El producto no es una app para dispositivo iOS.')
executable = app / info['CFBundleExecutable']
if not executable.is_file() or not (executable.stat().st_mode & stat.S_IXUSR):
    raise SystemExit('Falta el ejecutable de la aplicación.')
if not info.get('NSPhotoLibraryUsageDescription'):
    raise SystemExit('Falta la explicación de acceso a Fotos.')
output = root / 'build/Galeria-unsigned.ipa'
with zipfile.ZipFile(output, 'w', zipfile.ZIP_DEFLATED) as archive:
    for path in sorted(app.rglob('*')):
        if path.is_file():
            archive.write(path, 'Payload/' + path.relative_to(app.parent).as_posix())
with zipfile.ZipFile(output) as archive:
    if archive.testzip() is not None:
        raise SystemExit('El archivo IPA está dañado.')
print(f'Paquete sin firmar: {output}. Requiere firma personal antes de instalar.')
