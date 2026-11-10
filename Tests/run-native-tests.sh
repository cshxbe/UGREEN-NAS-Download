#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
test_dir=$(mktemp -d /private/tmp/ugreen-native-tests.XXXXXX)
server_pid=""
cleanup() { if [ -n "$server_pid" ]; then kill "$server_pid" 2>/dev/null || true; fi; rm -rf "$test_dir"; }
trap cleanup EXIT INT TERM
openssl req -x509 -newkey rsa:2048 -nodes -keyout "$test_dir/key.pem" -out "$test_dir/cert.pem" -days 1 -subj /CN=localhost >/dev/null 2>&1
python3 Tests/tls-server.py "$test_dir/cert.pem" "$test_dir/key.pem" &
server_pid=$!
cat "Xcode/UGREEN NAS Download/UGREEN NAS Download Extension/SafariWebExtensionHandler.swift" Tests/native-test-tail.swift > "$test_dir/tests.swift"
xcrun swiftc -parse-as-library Shared/Localization.swift -module-cache-path "$test_dir/cache" "$test_dir/tests.swift" -o "$test_dir/tests"
"$test_dir/tests"
