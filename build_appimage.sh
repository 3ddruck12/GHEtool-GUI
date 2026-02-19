#!/bin/bash
# Exit bei Fehler
set -e

# Konfiguration
APP_NAME="GHEtoolGUI"
VERSION="2.2.0"
ARCH="x86_64"
APPDIR="AppDir"

echo "Bereite AppDir vor..."
rm -rf "$APPDIR"
mkdir -p "$APPDIR/usr/bin"
mkdir -p "$APPDIR/usr/share/applications"
mkdir -p "$APPDIR/usr/share/icons/hicolor/256x256/apps"

# 1. Dateien aus dist kopieren
echo "Kopiere PyInstaller-Dateien..."
cp -r dist/GHEtoolGUI/* "$APPDIR/"

# 2. Icon bereitstellen (wir nehmen das png falls vorhanden)
if [ -f "GHEtoolGUI/icons/icon_squared.png" ]; then
    cp "GHEtoolGUI/icons/icon_squared.png" "$APPDIR/$APP_NAME.png"
    cp "GHEtoolGUI/icons/icon_squared.png" "$APPDIR/usr/share/icons/hicolor/256x256/apps/$APP_NAME.png"
fi

# 3. Desktop-Datei erstellen
echo "Erstelle .desktop Datei..."
cat <<EOF > "$APPDIR/$APP_NAME.desktop"
[Desktop Entry]
Name=GHEtool GUI
Exec=$APP_NAME
Icon=$APP_NAME
Type=Application
Categories=Science;Engineering;
EOF
cp "$APPDIR/$APP_NAME.desktop" "$APPDIR/usr/share/applications/"

# 4. AppRun Skript erstellen
echo "Erstelle AppRun..."
cat <<EOF > "$APPDIR/AppRun"
#!/bin/sh
HERE="\$(dirname "\$(readlink -f "\$0")")"
export PATH="\$HERE:\$PATH"
exec "\$HERE/GHEtoolGUI" "\$@"
EOF
chmod +x "$APPDIR/AppRun"

# 5. AppImage bauen
echo "Baue AppImage..."
# Wir nutzen das bereits heruntergeladene appimagetool
# Falls es nicht im PATH ist, nutzen wir den lokalen Pfad
./appimagetool "$APPDIR" "${APP_NAME}-${VERSION}-${ARCH}.AppImage"

echo "Fertig! AppImage liegt als ${APP_NAME}-${VERSION}-${ARCH}.AppImage vor."
