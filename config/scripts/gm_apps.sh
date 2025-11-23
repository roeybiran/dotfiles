#!/bin/bash

function gm_apps() {
	for app in \
		Calendar \
		ChatGPT \
		Dash \
		Mail \
		Notes \
		Safari \
		WhatsApp; do
		open -gja "$app"
	done
}
