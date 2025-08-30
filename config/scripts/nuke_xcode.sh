#!/bin/bash

function nuke_xcode() {

	name="$(basename "$PWD")"

	found=false
	for f in "$PWD"/*.xcodeproj; do
		found=true
		break
	done

	if [ "$found" = false ]; then
		echo "not an Xcode project"
		return
	fi

	find "$PWD" -path "*project.xcworkspace/xcshareddata/swiftpm/Package.resolved" -delete

	for f in ~/Library/Developer/Xcode/DerivedData/"$name"*; do
		rm -rf "$f"
	done

	rm -rf ~/Library/org.swift.swiftpm ~/Library/Caches/org.swift.swiftpm ~/Library/Developer/Xcode/DerivedData/"$(basename "$PWD")"*
}