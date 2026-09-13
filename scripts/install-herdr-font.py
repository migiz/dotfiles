#!/usr/bin/env python3
"""Install JetBrains Nerd Font 3.5.1 for the local terminal host, if needed."""
import argparse
import ctypes
import hashlib
import os
from pathlib import Path
import platform
import re
import shutil
import subprocess
import sys
import tempfile
import urllib.request
import venv

VERSION = '3.5.1'
FAMILY = 'JetBrains NF Heavy Icons'
STYLES = {
    'Regular': '1c680e8cde9fcf8b88a5605ce8d1fb94dd3fb15841f7ca7bf4c55664855e5611',
    'Bold': 'e490660ad75e0b152c93b1604c2ea1a4ea675f1b8a3fe0d005b1998568f99f1f',
    'Italic': '71d5466cc3ab31bee38b4e2c5cc99c2b41a749c4973ed4579b814ec992b0738e',
    'BoldItalic': '19a2e3af8ccf99954941ea07e0a29df27574500f12016d86d6c4c059b825ffe1',
}
BRAND_GLYPHS = {0xEC82, 0xEC81, 0xEC5C, 0xEC1E}
ICON_GLYPHS = BRAND_GLYPHS | {
    0x2726, 0x3C0, 0x2325, 0x22C2, 0x25A3, 0x1D687,
    0xF02A0, 0xF06A9, 0xF0241, 0x2624, 0xF0F67,
}


def font_location():
    """WSL must install on Windows, where the terminal renders its fonts."""
    system = platform.system()
    if system == 'Darwin':
        return Path.home() / 'Library/Fonts', False
    if system != 'Linux':
        raise RuntimeError('Run this installer on Linux, WSL, or macOS.')
    if 'microsoft' in platform.release().lower():
        if not shutil.which('powershell.exe'):
            raise RuntimeError('WSL font installation needs Windows PowerShell interoperability.')
        local_app_data = subprocess.check_output(
            ['powershell.exe', '-NoProfile', '-Command', '[Console]::Write($env:LOCALAPPDATA)'],
            text=True,
        ).strip()
        windows_dir = local_app_data + r'\Microsoft\Windows\Fonts'
        return Path(subprocess.check_output(['wslpath', '-u', windows_dir], text=True).strip()), True
    return Path(os.environ.get('XDG_DATA_HOME') or Path.home() / '.local/share') / 'fonts', False


def ensure_tools():
    try:
        import fontTools  # noqa: F401
        import freetype  # noqa: F401
    except ImportError:
        tools_dir = Path(os.environ.get('XDG_CACHE_HOME') or Path.home() / '.cache') / 'herdr-font-tools'
        python = tools_dir / 'bin/python'
        if not python.exists():
            venv.EnvBuilder(with_pip=True).create(tools_dir)
        subprocess.run([str(python), '-m', 'pip', 'install', '--disable-pip-version-check',
                        'fonttools==4.65.0', 'freetype-py==2.5.1'], check=True)
        os.execv(str(python), [str(python), str(Path(__file__).resolve()), *sys.argv[1:]])


def suitable_font(path):
    from fontTools.ttLib import TTFont, TTLibError
    try:
        with TTFont(path) as font:
            version = re.search(r'Nerd Fonts (\d+)\.(\d+)\.(\d+)', font['name'].getDebugName(5) or '')
            return (font['name'].getDebugName(1) == FAMILY and version is not None
                    and tuple(map(int, version.groups())) >= (3, 5, 0)
                    and BRAND_GLYPHS <= (font.getBestCmap() or {}).keys())
    except (OSError, KeyError, TTLibError):
        return False


def build_font(source, destination, style):
    """Thicken only available preview symbols, preserving text and cell advances."""
    import freetype
    from fontTools.ttLib import TTFont
    from fontTools.ttLib.tables._g_l_y_f import GlyphCoordinates
    with TTFont(source) as font:
        face = freetype.Face(str(source))
        cmap = font.getBestCmap()
        if not BRAND_GLYPHS <= cmap.keys():
            raise RuntimeError('Downloaded font lacks the required agent glyphs.')
        for code in ICON_GLYPHS & cmap.keys():
            glyph = font['glyf'][cmap[code]]
            face.load_char(code, freetype.FT_LOAD_NO_SCALE | freetype.FT_LOAD_NO_HINTING | freetype.FT_LOAD_NO_BITMAP)
            outline = face.glyph.outline
            if glyph.isComposite() or len(outline.points) != len(glyph.coordinates):
                raise RuntimeError(f'Unexpected glyph structure: U+{code:04X}')
            error = freetype.FT_Outline_Embolden(ctypes.byref(outline._FT_Outline),
                                              round(font['head'].unitsPerEm * 0.025))
            if error:
                raise RuntimeError(f'Could not embolden U+{code:04X}: FreeType error {error}')
            glyph.coordinates = GlyphCoordinates(outline.points)
            glyph.recalcBounds(font['glyf'])
        subfamily = 'Bold Italic' if style == 'BoldItalic' else style
        names = {1: FAMILY, 2: subfamily, 3: 'JetBrainsNFHeavyIcons-' + style,
                 4: FAMILY + ' ' + subfamily, 6: 'JetBrainsNFHeavyIcons-' + style,
                 16: FAMILY, 17: subfamily}
        for record in font['name'].names:
            if record.nameID in names:
                record.string = names[record.nameID].encode(record.getEncoding())
        font.save(destination)
    with TTFont(source) as original, TTFont(destination) as result:
        if original['hmtx'].metrics != result['hmtx'].metrics:
            raise RuntimeError('Font advances changed unexpectedly.')
        for code in range(32, 127):
            name = original.getBestCmap()[code]
            if original['glyf'][name].compile(original['glyf']) != result['glyf'][name].compile(result['glyf']):
                raise RuntimeError('Ordinary text outlines changed unexpectedly.')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check', action='store_true', help='Check font files without installing them.')
    args = parser.parse_args()
    ensure_tools()
    destination, windows = font_location()
    paths = [destination / f'JetBrainsNFHeavyIcons-{style}.ttf' for style in STYLES]
    if all(suitable_font(path) for path in paths):
        print(f'Font ready: {FAMILY} (Nerd Fonts 3.5+, all four styles and brand glyphs).')
        return
    if args.check:
        raise SystemExit(f'Missing or outdated font: {FAMILY}')
    # Build and verify every file before installing any of them.
    with tempfile.TemporaryDirectory(prefix='herdr-font-') as temp:
        staging = Path(temp)
        output = staging / 'built'
        output.mkdir()
        for style, checksum in STYLES.items():
            filename = f'JetBrainsMonoNerdFont-{style}.ttf'
            url = (f'https://raw.githubusercontent.com/ryanoasis/nerd-fonts/v{VERSION}/'
                   f'patched-fonts/JetBrainsMono/Ligatures/{filename}')
            data = urllib.request.urlopen(url, timeout=60).read()
            if hashlib.sha256(data).hexdigest() != checksum:
                raise RuntimeError(f'Checksum mismatch for {filename}')
            source = staging / filename
            source.write_bytes(data)
            build_font(source, output / f'JetBrainsNFHeavyIcons-{style}.ttf', style)
        # Preserve the upstream font license alongside our modified font files.
        license_urls = {
            'OFL': 'https://raw.githubusercontent.com/JetBrains/JetBrainsMono/v2.304/OFL.txt',
            'NerdFonts': f'https://raw.githubusercontent.com/ryanoasis/nerd-fonts/v{VERSION}/LICENSE',
        }
        licenses = {name: urllib.request.urlopen(url, timeout=60).read()
                    for name, url in license_urls.items()}
        destination.mkdir(parents=True, exist_ok=True)
        for path in paths:
            if path.exists():
                backup = path.with_suffix('.ttf.backup')
                if backup.exists():
                    raise RuntimeError(f'Existing backup would be overwritten: {backup}')
                shutil.copy2(path, backup)
        if windows:
            script = Path(__file__).with_name('install-windows-herdr-font.ps1')
            win_path = lambda p: subprocess.check_output(['wslpath', '-w', str(p)], text=True).strip()
            subprocess.run(['powershell.exe', '-NoProfile', '-ExecutionPolicy', 'Bypass',
                            '-File', win_path(script), '-SourceDirectory', win_path(output)], check=True)
        else:
            for path in paths:
                shutil.copy2(output / path.name, path)
            if shutil.which('fc-cache'):
                subprocess.run(['fc-cache', '-f', str(destination)], check=True)
        for name, data in licenses.items():
            (destination / f'JetBrainsNFHeavyIcons-{name}-LICENSE.txt').write_bytes(data)
    if not all(suitable_font(path) for path in paths):
        raise RuntimeError('Installed font verification failed.')
    print(f'Installed {FAMILY}. Select this family in your terminal; reopen it if necessary.')


if __name__ == '__main__':
    main()
