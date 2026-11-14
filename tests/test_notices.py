# Copyright 2026-present Contributors to the 3rdparty project.
# SPDX-License-Identifier: BSD-3-Clause
# https://github.com/mikaelsundell/3rdparty

"""Check project headers and the integrity of copied upstream notices offline."""
import hashlib
import json
from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[1]


class NoticeTests(unittest.TestCase):
    def test_cmake_headers(self):
        files = [ROOT / 'CMakeLists.txt', *sorted((ROOT / 'src').rglob('CMakeLists.txt')),
                 *sorted((ROOT / 'src').rglob('*.cmake'))]
        for path in files:
            with self.subTest(path=path.relative_to(ROOT)):
                text = path.read_text()
                header = text.splitlines()[:3]
                self.assertRegex(header[0], r'^# Copyright \d{4}-present ')
                self.assertEqual(header[1], '# SPDX-License-Identifier: BSD-3-Clause')
                self.assertEqual(text.count('SPDX-License-Identifier:'), 1)

    def test_notice_manifest(self):
        manifest = json.loads((ROOT / 'licenses/manifest.json').read_text())
        packages = manifest['packages']
        expected = {p.parent.name for p in (ROOT / 'src').glob('*/CMakeLists.txt')} | {'qt'}
        self.assertEqual({p['package'] for p in packages}, expected)
        self.assertEqual(len(packages), len(expected))
        copied = set()
        for package in packages:
            for notice in package['notices']:
                with self.subTest(package=package['package'], notice=notice['path']):
                    path = ROOT / notice['path']
                    copied.add(path)
                    self.assertEqual(hashlib.sha256(path.read_bytes()).hexdigest(),
                                     notice['sha256'])
                    source = ROOT / notice['source']
                    if source.is_file():
                        self.assertEqual(path.read_bytes(), source.read_bytes())
        self.assertEqual(copied, {p for p in (ROOT / 'licenses/third-party').rglob('*')
                                 if p.is_file()})

    def test_notice_index_links(self):
        text = (ROOT / 'THIRD_PARTY_NOTICES.md').read_text()
        for target in re.findall(r'\]\(([^)]+)\)', text):
            if '://' not in target:
                with self.subTest(target=target):
                    self.assertTrue((ROOT / target).exists())


if __name__ == '__main__':
    unittest.main()
