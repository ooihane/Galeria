"""Exercise packaging gates without claiming to compile an iOS application."""
from pathlib import Path
import plistlib
import shutil
import subprocess
import tempfile
import unittest
import zipfile

SOURCE = Path(__file__).resolve().parents[1] / 'scripts/package_ipa.py'

class PackagingTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        (self.root / 'scripts').mkdir()
        shutil.copyfile(SOURCE, self.root / 'scripts/package_ipa.py')
        self.app = self.root / 'build/device/Build/Products/Release-iphoneos/Galeria.app'
        self.app.mkdir(parents=True)
        executable = self.app / 'Galeria'
        executable.write_bytes(b'fixture, not a real executable')
        executable.chmod(0o755)

    def run_package(self, platform='iPhoneOS', permission=True):
        info = {'CFBundleSupportedPlatforms': [platform], 'CFBundleExecutable': 'Galeria'}
        if permission:
            info['NSPhotoLibraryUsageDescription'] = 'Prueba'
        (self.app / 'Info.plist').write_bytes(plistlib.dumps(info))
        return subprocess.run(['python3', str(self.root / 'scripts/package_ipa.py')], capture_output=True, text=True)

    def test_payload_and_executable_permissions_preserved(self):
        result = self.run_package()
        self.assertEqual(result.returncode, 0, result.stderr)
        with zipfile.ZipFile(self.root / 'build/Galeria-unsigned.ipa') as archive:
            executable = archive.getinfo('Payload/Galeria.app/Galeria')
            self.assertTrue((executable.external_attr >> 16) & 0o111)
            self.assertIn('Payload/Galeria.app/Info.plist', archive.namelist())

    def test_rejects_simulator_product(self):
        result = self.run_package(platform='iPhoneSimulator')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('dispositivo iOS', result.stderr)

    def test_rejects_missing_privacy_description(self):
        result = self.run_package(permission=False)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('explicación', result.stderr)

if __name__ == '__main__':
    unittest.main()
