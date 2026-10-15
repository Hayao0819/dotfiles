import json
import os
import stat
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

import tomlkit

from merge_settings import merge_file


class SettingsMergeTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)
        self.source = self.root / "declared.json"
        self.destination = self.root / "settings"

    def declare(self, settings):
        self.source.write_text(json.dumps(settings))

    def test_json_keeps_hooks_and_permission_rules(self):
        hooks = {"SessionStart": [{"hooks": [{"command": "herdr-hook"}]}]}
        self.destination.write_text(
            json.dumps(
                {
                    "hooks": hooks,
                    "permissions": {"defaultMode": "default", "allow": ["Read"]},
                    "enabledPlugins": {"local": True},
                }
            )
        )
        self.declare({"permissions": {"defaultMode": "auto"}})
        merge_file("json", self.source, self.destination)
        result = json.loads(self.destination.read_text())
        self.assertEqual(result["hooks"], hooks)
        self.assertEqual(
            result["permissions"], {"defaultMode": "auto", "allow": ["Read"]}
        )
        self.assertEqual(result["enabledPlugins"], {"local": True})
        self.assertEqual(stat.S_IMODE(self.destination.stat().st_mode), 0o600)

    def test_toml_keeps_projects_hooks_comments_and_dates(self):
        self.destination.write_text(
            '# model preference\nmodel = "gpt-5"\n'
            "last_seen = 2026-10-14T00:00:00Z\n"
            '[projects."/home/test/project"]\ntrust_level = "trusted"\n'
            '[features]\nhooks = true\n[hooks]\nstate = "existing-hook"\n'
            "[sandbox_workspace_write]\nnetwork_access = false\n"
            'writable_roots = ["/old"]\n'
        )
        self.declare(
            {
                "approval_policy": "never",
                "sandbox_mode": "workspace-write",
                "sandbox_workspace_write": {
                    "network_access": True,
                    "writable_roots": ["/home/test"],
                },
            }
        )
        merge_file("toml", self.source, self.destination)
        text = self.destination.read_text()
        result = tomlkit.parse(text)
        self.assertIn("# model preference", text)
        self.assertEqual(result["model"], "gpt-5")
        self.assertEqual(
            result["projects"]["/home/test/project"]["trust_level"], "trusted"
        )
        self.assertTrue(result["features"]["hooks"])
        self.assertEqual(result["hooks"]["state"], "existing-hook")
        self.assertEqual(
            result["sandbox_workspace_write"]["writable_roots"], ["/home/test"]
        )
        self.assertTrue(result["sandbox_workspace_write"]["network_access"])
        self.assertIn("last_seen", result)

    def test_repeated_activation_applies_changes_without_unnecessary_rewrite(self):
        self.declare({"value": 1})
        merge_file("json", self.source, self.destination)
        original = self.destination.stat()
        merge_file("json", self.source, self.destination)
        self.assertEqual(self.destination.stat().st_ino, original.st_ino)
        self.declare({"value": 2})
        merge_file("json", self.source, self.destination)
        self.assertEqual(json.loads(self.destination.read_text()), {"value": 2})

    def test_symlink_becomes_regular_file_without_changing_referent(self):
        referent = self.root / "store-settings"
        referent.write_text('{"runtime": true}')
        referent.chmod(0o444)
        self.destination.symlink_to(referent)
        self.declare({"declared": True})
        merge_file("json", self.source, self.destination)
        self.assertFalse(self.destination.is_symlink())
        self.assertEqual(referent.read_text(), '{"runtime": true}')
        self.assertEqual(
            json.loads(self.destination.read_text()),
            {"runtime": True, "declared": True},
        )

    def test_invalid_settings_are_untouched(self):
        self.declare({"value": 1})
        for format_name, contents in (
            ("json", "["),
            ("json", "[]"),
            ("toml", "value = ["),
        ):
            with self.subTest(format=format_name, contents=contents):
                self.destination.write_text(contents)
                with self.assertRaises(Exception):
                    merge_file(format_name, self.source, self.destination)
                self.assertEqual(self.destination.read_text(), contents)
                self.assertEqual(list(self.root.glob(".settings.*")), [])

    def test_broken_symlink_is_untouched(self):
        self.destination.symlink_to(self.root / "missing")
        self.declare({"value": 1})
        with self.assertRaises(FileNotFoundError):
            merge_file("json", self.source, self.destination)
        self.assertTrue(self.destination.is_symlink())

    def test_concurrent_edit_is_kept_and_merge_fails(self):
        self.destination.write_text('{"value": 1}')
        self.declare({"value": 2})
        real_fsync = os.fsync

        def concurrent_edit(descriptor):
            real_fsync(descriptor)
            self.destination.write_text('{"value": 3}')

        with patch("merge_settings.os.fsync", side_effect=concurrent_edit):
            with self.assertRaisesRegex(ValueError, "changed during merge"):
                merge_file("json", self.source, self.destination)
        self.assertEqual(self.destination.read_text(), '{"value": 3}')
        self.assertEqual(list(self.root.glob(".settings.*")), [])

    def test_dry_run_does_not_create_or_modify_files(self):
        self.declare({"value": 2})
        self.destination = self.root / "absent" / "settings"
        merge_file("json", self.source, self.destination, dry_run=True)
        self.assertFalse(self.destination.parent.exists())
        self.destination = self.root / "settings"
        self.destination.write_text('{"value": 1}')
        merge_file("json", self.source, self.destination, dry_run=True)
        self.assertEqual(self.destination.read_text(), '{"value": 1}')


if __name__ == "__main__":
    unittest.main()
