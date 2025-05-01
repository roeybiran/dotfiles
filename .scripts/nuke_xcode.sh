#!/bin/bash

function nuke_xcode() {
	if [ -z "$(find . -name "*.xcodeproj")" ]; then
		echo "not an Xcode project"
		return
	fi
	find "$PWD" -path "*project.xcworkspace/xcshareddata/swiftpm/Package.resolved" -delete
	rm -rf ~/Library/Developer/Xcode/DerivedData ~/Library/org.swift.swiftpm ~/Library/Caches/org.swift.swiftpm
}