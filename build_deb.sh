#!/bin/bash
# Exit bei Fehler
set -e

# Konfiguration
APP_NAME="GHEtoolGUI"
VERSION="2.2.0"
ARCH="amd64"
DEB_NAME="${APP_NAME}_${VERSION}_${ARCH}"
VENV_DIR="venv"

# 1. Umgebung vorbereiten und aktivieren
if [ ! -d "$VENV_DIR" ]; then
    echo "Umgebung nicht gefunden. Bitte erst 'pip install -r requirements.txt' ausführen."
    exit 1
fi
source "$VENV_DIR/bin/activate"

# Sicherstellen, dass PyInstaller installiert ist
pip install --upgrade PyInstaller

# 2. PyInstaller Build
echo "Erstelle Executable mit PyInstaller..."
# Aufräumen
rm -rf build dist

# Build starten (nutzt die .spec Datei)
pyinstaller GHEtoolGUI.spec --clean --noconfirm

# 3. Debian-Paketstruktur vorbereiten
PKG_DIR="pkg_build"
rm -rf "$PKG_DIR"
mkdir -p "$PKG_DIR/DEBIAN"
mkdir -p "$PKG_DIR/opt/$APP_NAME"
mkdir -p "$PKG_DIR/usr/share/applications"
mkdir -p "$PKG_DIR/usr/share/icons/hicolor/256x256/apps"
mkdir -p "$PKG_DIR/usr/share/icons/hicolor/48x48/apps"
mkdir -p "$PKG_DIR/usr/share/icons/hicolor/32x32/apps"
mkdir -p "$PKG_DIR/usr/bin"

# 4. Dateien kopieren
echo "Kopiere Dateien..."
# Das generierte Executable und alle Abhängigkeiten (Verzeichnis)
cp -r "dist/$APP_NAME"/* "$PKG_DIR/opt/$APP_NAME/"

# Symlink erstellen
ln -s "/opt/$APP_NAME/$APP_NAME" "$PKG_DIR/usr/bin/$APP_NAME"

# 4b. Icons installieren (für Startmenü und Taskleiste)
if [ -f "GHEtoolGUI/icons/icon_squared.png" ]; then
    echo "Kopiere Icons..."
    cp "GHEtoolGUI/icons/icon_squared.png" "$PKG_DIR/usr/share/icons/hicolor/256x256/apps/$APP_NAME.png"
    cp "GHEtoolGUI/icons/icon_squared.png" "$PKG_DIR/usr/share/icons/hicolor/48x48/apps/$APP_NAME.png"
    cp "GHEtoolGUI/icons/icon_squared.png" "$PKG_DIR/usr/share/icons/hicolor/32x32/apps/$APP_NAME.png"
fi

# 5. Control-Datei erstellen
echo "Erstelle DEBIAN/control..."
cat <<EOF > "$PKG_DIR/DEBIAN/control"
Package: ghetoolgui
Version: $VERSION
Section: science
Priority: optional
Architecture: $ARCH
Maintainer: GHEtool Team <info@ghetool.eu>
Description: GUI for GHEtool
 GHEtool is a open-source python package for borefield sizing.
 This package provides the GUI application.
EOF

# 6. Desktop-Datei erstellen
echo "Erstelle .desktop Datei..."
cat <<EOF > "$PKG_DIR/usr/share/applications/$APP_NAME.desktop"
[Desktop Entry]
Name=GHEtool GUI
Comment=GUI for GHEtool
Exec=/usr/bin/$APP_NAME
Icon=$APP_NAME
Terminal=false
Type=Application
Categories=Science;Engineering;
EOF

# 7. Bauen des Pakets
echo "Baue .deb Paket..."
dpkg-deb --build "$PKG_DIR" "${DEB_NAME}.deb"

echo "Fertig! Paket liegt als ${DEB_NAME}.deb vor."
