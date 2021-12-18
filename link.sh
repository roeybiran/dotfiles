#!/usr/bin/env bash

links_dir="${1:?ERR! No links_dir argument supplied}"
symlink_prefix="_LINK_"
cd "$links_dir" || exit

trash() {
	swift - "$@" <<-EOF
		import Foundation
		CommandLine.arguments.dropFirst().forEach { path in
			try? FileManager.default.trashItem(at: URL(fileURLWithPath: path), resultingItemURL: nil)
		}
	EOF
}

tmp="$(mktemp -d)"
while IFS=$'\n' read -r line; do
	dst_dir="$(dirname "${line//$links_dir/$HOME}")"
	dst_name="$(basename "${line//$symlink_prefix/}")"
	dst_path="$dst_dir/$dst_name"
	test -e "$dst_path" && mv "$dst_path" "$tmp"
	mkdir -p "$dst_dir" 2>/dev/null
	ln -sFh "$line" "$dst_path"
done < <(find "$(pwd)" -name "$symlink_prefix*")
trash "$tmp"
