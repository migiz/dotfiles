#!/usr/bin/env python3
"""Exercise font installation against verified upstream files in a temporary home.

Run with the installer tooling Python and pass a directory containing the four
original v3.5.1 JetBrainsMonoNerdFont-*.ttf files. No live fonts are modified.
"""
import hashlib
import importlib.util
import io
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location('font_installer', Path(__file__).with_name('install-herdr-font.py'))
installer = importlib.util.module_from_spec(spec)
spec.loader.exec_module(installer)
FIXTURES = Path(sys.argv.pop(1)) if len(sys.argv) > 1 else None


class FontTests(unittest.TestCase):
    def test_native_destinations(self):
        with patch.object(installer.platform, 'system', return_value='Darwin'):
            self.assertEqual(installer.font_location(), (Path.home() / 'Library/Fonts', False))
        with patch.object(installer.platform, 'system', return_value='Linux'), \
                patch.object(installer.platform, 'release', return_value='6.8.0'), \
                patch.dict(installer.os.environ, {'XDG_DATA_HOME': '/tmp/custom data'}):
            self.assertEqual(installer.font_location(), (Path('/tmp/custom data/fonts'), False))

    def test_wsl_targets_windows(self):
        with patch.object(installer.platform, 'system', return_value='Linux'), \
                patch.object(installer.platform, 'release', return_value='6.6-microsoft-standard-WSL2'), \
                patch.object(installer.shutil, 'which', return_value='/bin/powershell.exe'), \
                patch.object(installer.subprocess, 'check_output', side_effect=[
                    'C:\\Users\\Test User\\AppData\\Local', '/mnt/c/Users/Test User/AppData/Local/Microsoft/Windows/Fonts\n'
                ]) as command:
            path, windows = installer.font_location()
            self.assertTrue(windows)
            self.assertEqual(path, Path('/mnt/c/Users/Test User/AppData/Local/Microsoft/Windows/Fonts'))
            self.assertEqual(command.call_args.args[0][0:2], ['wslpath', '-u'])

    def test_clean_install_and_idempotence(self):
        self.assertIsNotNone(FIXTURES, 'Pass the upstream font fixture directory.')
        def download(url, timeout):
            if url.endswith('.ttf'):
                return io.BytesIO((FIXTURES / url.rsplit('/', 1)[-1]).read_bytes())
            return io.BytesIO(b'Test license response')
        with tempfile.TemporaryDirectory(prefix='herdr-font-test-') as temp, \
                patch.object(installer, 'font_location', return_value=(Path(temp), False)), \
                patch.object(installer, 'ensure_tools'), \
                patch.object(installer.urllib.request, 'urlopen', side_effect=download) as network, \
                patch.object(installer.shutil, 'which', return_value=None), \
                patch.object(sys, 'argv', ['install-herdr-font.py']):
            installer.main()
            fonts = list(Path(temp).glob('*.ttf'))
            self.assertEqual(len(fonts), 4)
            self.assertTrue(all(installer.suitable_font(p) for p in fonts))
            before = {p.name: hashlib.sha256(p.read_bytes()).digest() for p in fonts}
            network.reset_mock()
            installer.main()
            network.assert_not_called()
            self.assertEqual(before, {p.name: hashlib.sha256(p.read_bytes()).digest() for p in fonts})
            from fontTools.ttLib import TTFont
            regular = Path(temp) / 'JetBrainsNFHeavyIcons-Regular.ttf'
            with TTFont(regular) as font:
                for record in font['name'].names:
                    if record.nameID == 5:
                        record.string = 'Nerd Fonts 3.4.0'.encode(record.getEncoding())
                font.save(Path(temp) / 'old.ttf')
            self.assertFalse(installer.suitable_font(Path(temp) / 'old.ttf'))
            self.assertFalse(installer.suitable_font(Path(temp) / 'missing.ttf'))
            with TTFont(regular) as font:
                for table in font['cmap'].tables:
                    table.cmap.pop(0xEC81, None)
                font.save(Path(temp) / 'missing-glyph.ttf')
            self.assertFalse(installer.suitable_font(Path(temp) / 'missing-glyph.ttf'))

    def test_bad_download_never_installs(self):
        with tempfile.TemporaryDirectory(prefix='herdr-font-test-') as temp, \
                patch.object(installer, 'font_location', return_value=(Path(temp), False)), \
                patch.object(installer, 'ensure_tools'), \
                patch.object(installer.urllib.request, 'urlopen', return_value=io.BytesIO(b'wrong contents')), \
                patch.object(sys, 'argv', ['install-herdr-font.py']):
            with self.assertRaisesRegex(RuntimeError, 'Checksum mismatch'):
                installer.main()
            self.assertEqual(list(Path(temp).iterdir()), [])


if __name__ == '__main__':
    unittest.main()
