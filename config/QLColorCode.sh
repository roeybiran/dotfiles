#!/usr/bin/env bash

utis=(
	# .ts
	public.mpeg-2-transport-stream
	# .tsx
	public.tsx
	# .swiftformat
	dyn.ah62d4rv4ge81g75mq34gq55wrzu1k
)

# https://gregbrown.co/code/typescript-quicklook
ql=~/Library/QuickLook/QLColorCode.qlgenerator
pl="$ql"/Contents/Info.plist

if test ! -d "$ql" || test ! -f "$pl"; then
	exit
fi

current="$(/usr/libexec/PlistBuddy -c "Print :CFBundleDocumentTypes:0:LSItemContentTypes" "$pl")"
for uti in "${utis[@]}"; do
	echo "$current" | grep -q "$uti" || /usr/libexec/PlistBuddy -c "Add :CFBundleDocumentTypes:0:LSItemContentTypes:0 string $uti" "$pl"
done
tmp="$(mktemp -d)"
mv "$ql" "$tmp"
sleep 0.5
mv "$tmp"/* "$ql"
