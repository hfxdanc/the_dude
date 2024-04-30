#!/bin/sh
rm -rf ./.flatpak-builder/ ./build-dir/

RELEASE_TXT=$(curl https://cdn.mikrotik.com/routeros/latest-stable.rss | tee latest-stable.rss | awk '
	function ltrim(s) { sub(/^[ \t\r\n]+/, "", s); return s }
	function rtrim(s) { sub(/[ \t\r\n]+$/, "", s); return s }
	function trim(s)  { return rtrim(ltrim(s)); }

	BEGIN {
		content = ""
		pubdate = ""
		reldate = ""
		release = ""
		title = ""
	}

	/<item>/, /<\/item>/ {
		if ($0 ~ /<title>.*<\/title>/) title = trim(gensub(/<title>(.*)<\/title>/, "\\1", "g"))
		if ($0 ~ /<content:encoded>.*<\/content:encoded>/) content = trim(gensub(/<content:encoded><!\[CDATA\[(.*);\]\]><\/content:encoded>/, "\\1", "g"))
		if ($0 ~ /<pubDate>.*<\/pubDate>/) pubdate = trim(gensub(/<pubDate>(.*)<\/pubDate>/, "\\1", "g"))
	}

	END {
		split(title , a)
		release = a[2]

		split(pubdate, a)
		switch (a[3]) {
		case /^[Jj][Aa][Nn]/:
			a[3] = 1
			break
		case /^[Ff][Ee][Bb]/:
			a[3] = 2
			break
		case /^[Mm][Aa][Rr]/:
			a[3] = 3
			break
		case /^[Aa][Pp][Rr]/:
			a[3] = 4
			break
		case /^[Mm][Aa][Yy]/:
			a[3] = 5
			break
		case /^[Jj][Uu][Nn]/:
			a[3] = 6
			break
		case /^[Jj][Uu][Ll]/:
			a[3] = 7
			break
		case /^[Aa][Uu][Gg]/:
			a[3] = 8
			break
		case /^[Ss][Ee][Pp]/:
			a[3] = 9
			break
		case /^[O][Cc][Tt]/:
			a[3] = 10
			break
		case /^[Nn][Oo][Vv]/:
			a[3] = 11
			break
		case /^[Dd][Ee][Cc]/:
			a[3] = 12
		}
		reldate = sprintf("%s-%02d-%s", a[4], a[3], a[2])

		print "<releases>"
		printf("<release version=\"%s\" date=\"%s\">\n", release, reldate)
		printf("<description>\n<p>%s</p>\n", gensub(/<br>/, "\\\n\\\n\\\t", "g", content))
		printf("</description>\n</release>\n</releases>\n")
	}'
)

RELEASE=$(cat latest-stable.rss | awk '
	function ltrim(s) { sub(/^[ \t\r\n]+/, "", s); return s }
	function rtrim(s) { sub(/[ \t\r\n]+$/, "", s); return s }
	function trim(s)  { return rtrim(ltrim(s)); }

	BEGIN {
		release = ""
		title = ""
	}

	/<item>/, /<\/item>/ {
		if ($0 ~ /<title>.*<\/title>/) title = trim(gensub(/<title>(.*)<\/title>/, "\\1", "g"))
	}

	END {
		split(title , a)
		print a[2]
	}'
)

cat << %E%O%T% >./TheDude.metainfo.xml
<?xml version="1.0" encoding="UTF-8"?>
<component type="desktop-application">
  <id>org.flatpak.TheDude</id>
  <metadata_license>CC0-1.0</metadata_license>
  <project_license>LicenseRef-proprietary</project_license>
  <name>TheDude</name>
  <summary>MikroTik The Dude client</summary>
  <developer_name>SIA Mikrotīkls</developer_name>
  <update_contact>hfxdanc_AT_gmail.com</update_contact>

  <description>
	<p>This is a build of The Dude client for Microsoft Windows, packaged for Linux as a Flatpak using Wine.</p>
	<p>NOTE: This wrapper is not verified by, affiliated with, sponsored or supported by MikroTīk in any way.</p>
	<p>
	The Dude network monitor is a new application by MikroTik which can dramatically
	improve the way you manage your network environment. It will automatically scan all
	devices within specified subnets, draw and layout a map of your networks, monitor
	services of your devices and alert you in case some service has problems.
	</p>
  </description>

  <launchable type="desktop-id">org.flatpak.TheDude.desktop</launchable>

  <url type="homepage">https://mikrotik.com</url>
  <url type="help">https://wiki.mikrotik.com/wiki/Manual:The_Dude</url>

  <screenshots>
	<screenshot type="default">
	  <caption>Network Layout</caption>
	  <image>https://i.mt.lv/img/mt/v2/dude/1f.png</image>
	</screenshot>
	<screenshot>
	  <caption>Device view</caption>
	  <image>https://i.mt.lv/img/mt/v2/dude/2f.png</image>
	</screenshot>
	<screenshot>
	  <caption>Network worksheet</caption>
	  <image>https://i.mt.lv/img/mt/v2/dude/3t.png</image>
	</screenshot>
  </screenshots>

  ${RELEASE_TXT}

  <content_rating type="oars-1.1"/>
</component>
%E%O%T%

cat << %E%O%T% >./dude-installer.sh
#!/bin/sh
CHOICE=\$(zenity --list \\
	--hide-header \\
	--hide-column=3 \\
	--modal \\
	--ok-label="Next >" \\
	--print-column=3 \\
	--radiolist \\
	--text="By downloading any files from mikrotik.com, you agree to the following:\n\t<a href=\"https://mikrotik.com/downloadterms.html\">Export Eligibility Requirements and END USER LICENSE</a>" \\
	--title="The Dude client" \\
	--width=480 \\
	--column="Select" \\
	--column="Text" \\
	--column="VAR" \\
	FALSE "I agree with the above terms and conditions" "TRUE" \\
	TRUE "I do not accept the agreement" "FALSE")

# If dialog is cancelled insure default of FALSE is enforced
# shellcheck disable=SC2181
[ \$? -ne 0 ] && CHOICE="FALSE"
if [ "\${CHOICE}" != "TRUE" ]; then
	exit 1
fi

(PERCENT=5
echo "# Downloading latest-stable (${RELEASE}) The Dude client"
echo "\${PERCENT}"; sleep 1
mkdir -p "\${WINEPREFIX}/drive_c/Program Files/Dude"
curl --location \\
	--output "\${WINEPREFIX}/drive_c/Program Files/Dude/dude-install.exe" \\
	https://cdn.mikrotik.com/routeros/${RELEASE}/dude-install-${RELEASE}.exe
PERCENT=30

echo "# Downloading Export Eligibility Requirements and END USER LICENSE"
echo "\${PERCENT}"; sleep 1
curl --location \\
	--output "\${WINEPREFIX}/drive_c/Program Files/Dude/LICENSE" \\
	https://mikrotik.com/downloadterms.html
PERCENT=40

echo "# Running installer"
echo "\${PERCENT}"; sleep 1
wine "\${WINEPREFIX}/drive_c/Program Files/Dude/dude-install.exe" "/S"
PERCENT=70

echo "# Extracting Icons"
echo "\${PERCENT}"; sleep 1
(cd /tmp && 7z e "\${WINEPREFIX}/drive_c/Program Files/Dude/dude.exe" .rsrc/ICON/*)

file /tmp/* | awk '
BEGIN {
	cmd = ""
	file = ""
	size = ""
}

/PNG image data/ {
	split(\$0, a, /:/)
	file = a[1]

	split(\$0, a, /, /)
	size = gensub(/ /, "", "g", a[2])
	switch (size) {
	case /256x256/:
		paths[size] = sprintf("~/.local/share/icons/hicolor/%s/apps", size)
		files[size] = file
		break
	}
}

END {
	if (length(paths) > 0) {
		# remove default icon
		cmd = sprintf("rm -f ~/.local/share/icons/hicolor/256x256/apps/%s.png", ENVIRON["FLATPAK_ID"])
		system(cmd)

		for (size in paths) {
			cmd = sprintf("install -d %s", paths[size])
			system(cmd)
			cmd = sprintf("cp %s %s/%s.png", files[size], paths[size], ENVIRON["FLATPAK_ID"])
			system(cmd)
		}
	}
}'
PERCENT=90

echo "# Set Windows Version to win10"
echo "\${PERCENT}"; sleep 1
wine REG ADD 'HKCU\\Software\\Wine' /v 'Version' /d 'win10' /f

echo "# Installer finished" ) | zenity --progress --title="Installing Application" --width=480
%E%O%T%

flatpak-builder --default-branch=stable \
	--verbose \
	--force-clean \
	--install-deps-from=flathub \
	--install \
	--user \
	./build-dir ./org.flatpak.TheDude.yml

# vi: set noexpandtab:wrap:
