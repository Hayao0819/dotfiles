# Arch Linux Package List

Complete list of packages installed on the Arch Linux system at `/mnt/archlinux`.

**Total packages**: 2,178

## Package Categories

### System Base

- base
- base-devel
- filesystem
- linux-lts
- linux-lts-headers
- linux-firmware (amdgpu, atheros, broadcom, cirrus, intel, mediatek, nvidia, other, radeon, realtek, whence)
- systemd, systemd-libs, systemd-sysvcompat
- glibc
- coreutils
- util-linux, util-linux-libs

### Desktop Environment (GNOME)

- gdm
- gnome-shell
- gnome-session
- gnome-control-center
- gnome-settings-daemon
- gnome-tweaks
- gnome-terminal
- gnome-text-editor
- gnome-system-monitor
- gnome-disk-utility
- gnome-keyring
- gnome-menus
- gnome-font-viewer
- gnome-firmware
- gnome-color-manager
- gnome-bluetooth
- gnome-browser-connector
- gnome-online-accounts
- gnome-remote-desktop
- gnome-video-effects
- gnome-autoar
- gnome-desktop, gnome-desktop-common
- gnome-keybindings
- mutter
- nautilus

### GNOME Shell Extensions

- gnome-shell-extensions
- gnome-shell-extension-arc-menu
- gnome-shell-extension-dash-to-dock
- gnome-shell-extension-dash-to-panel
- gnome-shell-extension-desktop-icons-ng
- gnome-shell-extension-pano-git

### COSMIC Desktop (Experimental)

- cosmic-comp
- cosmic-icon-theme
- cosmic-launcher
- cosmic-randr
- cosmic-settings
- cosmic-workspaces

### Themes & Icons

- papirus-icon-theme
- pop-icon-theme
- adw-gtk-theme
- adwaita-cursors
- adwaita-fonts
- adwaita-icon-theme
- adwaita-icon-theme-legacy
- breeze-icons
- kvantum-qt4-git
- gradience
- default-cursors
- hicolor-icon-theme

### Input Method (Japanese)

- fcitx5
- fcitx5-configtool
- fcitx5-gtk
- fcitx5-mozc-ut
- fcitx5-qt
- mozc-ut
- ibus

### Browsers

- brave-bin
- google-chrome
- firefox-developer-edition
- firefox-developer-edition-i18n-ja
- ungoogled-chromium-bin

### Development - Editors & IDEs

- vim, vim-runtime
- visual-studio-code-bin
- visual-studio-code-insiders-bin
- cursor-bin
- zed
- ghidra

### Development - Version Control

- git
- github-cli
- github-copilot-cli
- gitkraken
- mercurial
- breezy
- subversion

### Development - Languages & Runtimes

#### Go

- go

#### Rust

- rust

#### Haskell

- ghc
- ghc-libs
- cabal-fmt
- hlint
- stack
- stylish-haskell
- haskell-language-server
- (200+ haskell-* library packages)

#### JavaScript/Node.js

- nodejs-lts-jod
- npm
- node-gyp
- nodejs-nopt
- deno
- volta
- asar

#### Python

- python
- python-pip (implicit)
- pyenv
- python-poetry
- python-pipx
- python-virtualenv
- uv
- (100+ python-* packages)

#### Java

- jdk8-openjdk
- jdk17-openjdk
- jdk21-openjdk
- jdk22-graalvm-bin
- jre8-openjdk
- jre8-openjdk-headless
- java-environment-common
- java-runtime-common
- gradle

#### Scala

- scala

#### Ruby

- ruby
- ruby-bundler
- ruby-erb
- rubygems

#### Lua

- lua

#### C/C++

- gcc
- gcc-libs
- gcc9-bin
- clang
- compiler-rt
- lld
- gdb
- gdb-common
- cppcheck
- autoconf
- automake
- make
- cmake (implicit via dkp-cmake-common-utils)

### Development - Containers & Virtualization

#### Docker

- docker
- docker-buildx
- docker-compose
- containerd
- runc

#### QEMU/KVM

- qemu-full (and all qemu-* subpackages)
- libvirt
- libvirt-glib
- libvirt-python
- virt-manager
- virt-install
- virtiofsd

#### VirtualBox

- virtualbox
- virtualbox-host-dkms

#### LXC

- lxc

#### Other

- waydroid
- genymotion

### Development - 3DS/Embedded

- devkitARM-r67
- devkitarm-binutils
- devkitarm-cmake
- devkitarm-crtls
- devkitarm-gcc
- devkitarm-newlib
- devkitarm-rules
- devkitpro-keyring
- dkp-cmake-common-utils
- 3ds-cmake
- 3ds-examples
- 3ds-pkg-config
- 3dstools
- tex3ds
- libctru
- citro2d
- citro3d
- general-tools

### Development - Android

- android-apktool
- android-tools

### Development - Database

- postgresql
- postgresql-libs
- sqlite
- lmdb
- litestream

### Development - Tools

- act
- mise
- hadolint-bin
- mermaid-cli
- goreleaser-bin
- migrate
- supabase

### Security & CTF Tools

- aircrack-ng
- binwalk
- ffuf
- ghidra
- hping
- jadx
- john
- nmap
- pwndbg
- ropgadget
- sleuthkit
- steghide
- testdisk
- unicorn
- wireshark-cli
- wireshark-qt
- wpscan
- wordlists
- libewf

### Networking Tools

- bind
- cloudflared
- curl
- dnsmasq
- filezilla
- globalprotect-openconnect
- iperf
- iproute2
- iptables
- net-snmp
- net-tools
- networkmanager
- networkmanager-openconnect
- networkmanager-openvpn
- nm-connection-editor
- nftables
- openssh
- openconnect
- openvpn
- speedtest-cli
- tigervnc
- traceroute
- vpnc
- wget
- wpa_supplicant
- x11vnc

### Office & Productivity

- libreoffice-fresh
- libreoffice-fresh-ja
- onlyoffice-bin
- drawio-desktop
- evince

### Communication

- mattermost-desktop
- slack-electron
- thunderbird
- thunderbird-i18n-ja
- vesktop
- zoom

### Media - Audio

- audacity
- easyeffects
- pavucontrol
- pipewire (alsa, audio, jack, pulse, session-manager)
- pulseaudio-qt
- qsynth
- qtractor
- sonic-visualiser
- sox
- vlc (and all vlc-plugin-* packages)
- lsp-plugins (clap, gst, ladspa, lv2, standalone, vst, vst3)

### Media - Video

- ffmpeg
- obs-studio
- vlc
- yt-dlp
- yt-dlp-ejs
- mjpegtools
- v4l-utils
- v4l2-relayd
- v4l2loopback-dkms
- guvcview

### Media - Graphics

- gimp (implicit via dependencies)
- imagemagick
- graphicsmagick
- inkscape
- krita
- viewnior

### Media - 3D Printing

- creality-print-appimage
- orca-slicer
- openscad

### Gaming

- retroarch
- steam
- wine
- wine-mono
- winetricks

### System Tools

- baobab
- btop
- dconf-editor
- fastfetch
- gparted
- htop
- lsd
- lsof
- mission-center
- nvtop
- parallel
- progress
- rsync
- snapper
- snapper-gui-git
- tlp
- tlpui
- tree

### Disk & Filesystem

- btrfs-progs
- cryptsetup
- dosfstools
- e2fsprogs
- exfatprogs
- gpart
- mdadm
- ntfs (ntfs-3g)
- parted
- squashfs-tools
- udisks2

### Archive Tools

- cabextract
- cpio
- gzip
- lhasa
- lz4
- lzo
- p7zip (implicit)
- tar
- unzip
- upx
- xz
- zstd

### Fonts

- noto-fonts
- noto-fonts-cjk
- noto-fonts-emoji
- otf-ipaexfont
- otf-ipafont
- otf-ipamjfont
- otf-source-han-code-jp
- ttf-carlito
- ttf-dejavu
- ttf-liberation
- ttf-opensans
- ttf-sourcecodepro-nerd

### Printing

- cups
- cups-filters
- cups-pk-helper
- brother-mfc-l9570cdw
- xerox-docucentre-driver
- simple-scan
- system-config-printer

### Hardware Support

- bluez, bluez-libs, bluez-obex, bluez-utils
- bolt
- fwupd, fwupd-efi
- hdparm
- hwdata
- hwinfo
- iio-sensor-proxy
- intel-ipu7-camera-bin-r31.09ccd02
- intel-ipu7-camera-hal-git-r48.feed915
- intel-ipu7-dkms-git-r42.62a3704
- intel-ivsc-firmware-r13.3377801
- intel-sgx-sdk-bin
- intel-vision-drivers-dkms-git-r48.92a717e
- libcamera, libcamera-ipa
- libinput
- libinput-config-git-r86.185c6cb
- libwacom
- linux-sgx-driver-hayao-dkms-git
- lm_sensors
- msr-tools
- pciutils
- tpm2-tss
- usbutils
- v4l-utils

### Arch Linux Specific

- pacman
- pacman-contrib
- pacman-mirrorlist
- yay
- arch-install-scripts
- archiso
- archlinux-keyring
- archlinuxcn-keyring
- archlinuxcn-mirrorlist-git
- arch4edu-keyring
- blackarch-keyring
- blackarch-mirrorlist
- cachyos-keyring
- cachyos-mirrorlist
- cachyos-v3-mirrorlist
- cachyos-v4-mirrorlist
- devtools
- devtools-alterlinux
- expac
- reflector
- dkms
- mkinitcpio
- mkinitcpio-busybox

### Display Server & Compositor

- xorg-server (and all xorg-* packages)
- wayland
- xorg-xwayland
- egl-wayland
- seatd

### Boot

- grub
- grub2-theme-arch-leap
- efibootmgr
- efivar
- os-prober
- plymouth
- plymouth-theme-arch-darwin

### PS Vita Tools

- libvitamtp-git
- qcma-git

### Miscellaneous

- aws-cli
- aws-session-manager-plugin
- flatpak
- flashrom
- glow
- gum
- hyperfine
- rpi-imager
- etcher-bin
- sl
- tamarin-prover
- transmission-gtk
- ventoy-bin
- virtscreen
- zellij
- zenity

## Full Alphabetical List

```
3ds-cmake
3ds-examples
3ds-pkg-config
3dstools
a52dec
aalib
abseil-cpp
accountsservice
acl
acpi
act
adw-gtk-theme
adwaita-cursors
adwaita-fonts
adwaita-icon-theme
adwaita-icon-theme-legacy
aircrack-ng
alsa-card-profiles
alsa-lib
alsa-plugins
alsa-topology-conf
alsa-ucm-conf
alsa-utils
android-apktool
android-tools
aom
appstream
apr
apr-util
arch-install-scripts
arch4edu-keyring
archiso
archlinux-appstream-data
archlinux-keyring
archlinuxcn-keyring
archlinuxcn-mirrorlist-git
argon2
asar
at-spi2-core
atkmm
attr
audacity
audit
autoconf
automake
avahi
aws-cli
aws-session-manager-plugin
ayatana-ido
baobab
base
base-devel
bash
bat
bcg729
binaryninja-free
bind
binutils
binwalk
bison
blackarch-keyring
blackarch-mirrorlist
blas
bless
bluez
bluez-libs
bluez-obex
bluez-utils
bolt
boost-libs
botan
brave-bin
breeze-icons
breezy
brltty
brother-mfc-l9570cdw
brotli
btop
btrfs-progs
bubblewrap
buddy
bzip2
c-ares
ca-certificates
ca-certificates-mozilla
ca-certificates-utils
cabal-fmt
cabextract
cachyos-keyring
cachyos-mirrorlist
cachyos-v3-mirrorlist
cachyos-v4-mirrorlist
cairo
cairomm
capnproto
capstone
catnip
cblas
cdparanoia
cdrtools
cheese
chromaprint
cifs-utils
citro2d
citro3d
clang
cln
cloudflared
clucene
clutter
clutter-gst
clutter-gtk
cogl
colord
colord-gtk-common
colord-gtk4
colord-sane
compiler-rt
composefs
confuse
containerd
coreutils
cosmic-comp
cosmic-icon-theme
cosmic-launcher
cosmic-randr
cosmic-settings
cosmic-workspaces
cpio
cppcheck
cracklib
creality-print-appimage
cryptsetup
cudd
cups
cups-filters
cups-pk-helper
curl
cursor-bin
cvc4
dav1d
db5.3
dbus
dbus-broker
dbus-broker-units
dbus-glib
dbus-units
dconf
dconf-editor
debugedit
debuginfod
default-cursors
deno
desktop-file-utils
device-mapper
devkitARM-r67
devkitarm-binutils
devkitarm-cmake
devkitarm-crtls
devkitarm-gcc
devkitarm-newlib
devkitarm-rules
devkitpro-keyring
devtools
devtools-alterlinux
diffstat
diffutils
djvulibre
dkms
dkp-cmake-common-utils
dmidecode
dnsmasq
dnssec-anchors
docker
docker-buildx
docker-compose
dosfstools
double-conversion
drawio-desktop
dtc
duktape
dvisvgm
e2fsprogs
easyeffects
editorconfig-core-c
edk2-aarch64
edk2-arm
edk2-ovmf
efibootmgr
efivar
egl-wayland
eglexternalplatform
electron
electron37
electron38
electron39
enchant
erofs-utils
etcher-bin
ethtool
evince
exempi
exfatprogs
exiv2
expac
expat
eyedropper
faac
faad2
fakeroot
fastfetch
fcitx5
fcitx5-configtool
fcitx5-gtk
fcitx5-mozc-ut
fcitx5-qt
fd
ffcall
ffmpeg
fftw
ffuf
file
filesystem
filezilla
findutils
firefox-developer-edition
firefox-developer-edition-i18n-ja
fish
flac
flashrom
flatpak
flex
fltk1.3
fluidsynth
fmt
fontconfig
freeglut
freerdp
freetype2
frei0r-plugins
fribidi
fuse-common
fuse2
fuse3
fwupd
fwupd-efi
gawk
gc
gcc
gcc-libs
gcc9-bin
gcr
gd
gdb
gdb-common
gdbm
gdk-pixbuf2
gdm
general-tools
genymotion
geoclue
geocode-glib
geocode-glib-common
gettext
gexiv2
gfortran9-bin
gfxstream
ghc
ghc-libs
ghidra
ghostscript
giflib
git
github-cli
github-copilot-cli
gitkraken
gjs
glew
glib-networking
glib2
glibc
glibmm
glm
globalprotect-openconnect
glow
glslang
glu
glusterfs
glycin
gmp
gnome-autoar
gnome-bluetooth
gnome-browser-connector
gnome-color-manager
gnome-control-center
gnome-desktop
gnome-desktop-common
gnome-disk-utility
gnome-firmware
gnome-font-viewer
gnome-keybindings
gnome-keyring
gnome-menus
gnome-online-accounts
gnome-remote-desktop
gnome-session
gnome-settings-daemon
gnome-shell
gnome-shell-extension-arc-menu
gnome-shell-extension-dash-to-dock
gnome-shell-extension-dash-to-panel
gnome-shell-extension-desktop-icons-ng
gnome-shell-extension-pano-git
gnome-shell-extensions
gnome-system-monitor
gnome-terminal
gnome-text-editor
gnome-tweaks
gnome-video-effects
gnu-netcat
gnulib-l10n
gnupg
gnutls
go
gobject-introspection
gobject-introspection-runtime
google-chrome
goreleaser-bin
gpart
gparted
gperftools
gpgme
gpgmepp
gpm
gradience
gradle
graphene
graphicsmagick
graphite
graphviz
grep
groff
grub
grub2-theme-arch-leap
gsettings-desktop-schemas
gsettings-system-schemas
gsfonts
gsl
gsm
gsound
gspell
gssdp
gst-plugin-libcamera
gst-plugins-bad
gst-plugins-bad-libs
gst-plugins-base
gst-plugins-base-libs
gst-plugins-good
gst-plugins-ugly
gstreamer
gtest
gtk-sharp
gtk-update-icon-cache
gtk-vnc
gtk2
gtk3
gtk4
gtkmm
gtkmm3
gtksourceview3
gtksourceview4
gtksourceview5
gts
guile
gum
gupnp
gupnp-dlna
gupnp-igd
guvcview
guvcview-common
gvfs
gvfs-mtp
gvfs-smb
gzip
hadolint-bin
harfbuzz
harfbuzz-icu
haskell-adjunctions
haskell-aeson
haskell-aeson-pretty
haskell-algebraic-graphs
haskell-annotated-wl-pprint
haskell-ansi-terminal
haskell-ansi-terminal-types
haskell-ansi-wl-pprint
haskell-appar
haskell-apply-refact
haskell-asn1-encoding
haskell-asn1-parse
haskell-asn1-types
haskell-assoc
haskell-async
haskell-attoparsec
haskell-attoparsec-aeson
haskell-auto-update
haskell-base-compat
haskell-base-orphans
haskell-base16-bytestring
haskell-base64-bytestring
haskell-basement
haskell-bifunctors
haskell-binary-instances
haskell-binary-orphans
haskell-bitvec
haskell-blaze-builder
haskell-blaze-html
haskell-blaze-markup
haskell-blaze-textual
haskell-boring
haskell-bsb-http-chunked
haskell-byteorder
haskell-call-stack
haskell-casa-client
haskell-casa-types
haskell-case-insensitive
haskell-cborg
haskell-cereal
haskell-clientsession
haskell-clock
haskell-cmdargs
haskell-co-log-core
haskell-colour
haskell-commutative-semigroups
haskell-comonad
haskell-conduit
haskell-conduit-extra
haskell-constraints
haskell-constraints-extras
haskell-contravariant
haskell-cookie
haskell-cpphs
haskell-crypto-api
haskell-cryptohash-md5
haskell-cryptohash-sha1
haskell-cryptohash-sha256
haskell-crypton
haskell-crypton-conduit
haskell-crypton-connection
haskell-crypton-socks
haskell-crypton-x509
haskell-crypton-x509-store
haskell-crypton-x509-system
haskell-crypton-x509-validation
haskell-cryptonite
haskell-cryptonite-conduit
haskell-css-text
haskell-data-default
haskell-data-default-class
haskell-data-default-instances-containers
haskell-data-default-instances-dlist
haskell-data-default-instances-old-locale
haskell-data-fix
haskell-deferred-folds
haskell-dependent-map
haskell-dependent-sum
haskell-deriving-aeson
haskell-diff
haskell-digest
haskell-direct-sqlite
haskell-distributive
haskell-dlist
haskell-easy-file
haskell-echo
haskell-ed25519
haskell-entropy
haskell-enummapset
haskell-erf
haskell-extra
haskell-fast-logger
haskell-fclabels
haskell-fgl
haskell-file-embed
haskell-filelock
haskell-filemanip
haskell-filepattern
haskell-filtrable
haskell-fingertree
haskell-floskell
haskell-fmlist
haskell-focus
haskell-foldable1-classes-compat
haskell-foldl
haskell-fourmolu
haskell-free
haskell-fsnotify
haskell-fuzzy
haskell-generic-deriving
haskell-generic-lens
haskell-generic-lens-core
haskell-generically
haskell-ghc-check
haskell-ghc-exactprint
haskell-ghc-lib-parser
haskell-ghc-lib-parser-ex
haskell-ghc-paths
haskell-ghc-trace-events
haskell-ghcide
haskell-githash
haskell-gitrev
haskell-glob
haskell-graphviz
haskell-hackage-security
haskell-haddock-library
haskell-half
haskell-hashable
haskell-hi-file-parser
haskell-hie-bios
haskell-hie-compat
haskell-hiedb
haskell-hinotify
haskell-hjsmin
haskell-hls-alternate-number-format-plugin
haskell-hls-cabal-fmt-plugin
haskell-hls-cabal-plugin
haskell-hls-call-hierarchy-plugin
haskell-hls-change-type-signature-plugin
haskell-hls-class-plugin
haskell-hls-code-range-plugin
haskell-hls-eval-plugin
haskell-hls-explicit-fixity-plugin
haskell-hls-explicit-imports-plugin
haskell-hls-explicit-record-fields-plugin
haskell-hls-floskell-plugin
haskell-hls-fourmolu-plugin
haskell-hls-gadt-plugin
haskell-hls-graph
haskell-hls-hlint-plugin
haskell-hls-module-name-plugin
haskell-hls-ormolu-plugin
haskell-hls-overloaded-record-dot-plugin
haskell-hls-plugin-api
haskell-hls-pragmas-plugin
haskell-hls-qualify-imported-names-plugin
haskell-hls-refactor-plugin
haskell-hls-rename-plugin
haskell-hls-retrie-plugin
haskell-hls-splice-plugin
haskell-hls-stylish-haskell-plugin
haskell-hourglass
haskell-hpack
haskell-hscolour
haskell-hslogger
haskell-hsyaml
haskell-hsyaml-aeson
haskell-http-api-data
haskell-http-client
haskell-http-client-tls
haskell-http-conduit
haskell-http-date
haskell-http-download
haskell-http-types
haskell-http2
haskell-hunit
haskell-hw-fingertree
haskell-hw-prim
haskell-implicit-hie
haskell-implicit-hie-cradle
haskell-indexed-profunctors
haskell-indexed-traversable
haskell-indexed-traversable-instances
haskell-infer-license
haskell-integer-conversion
haskell-integer-logarithms
haskell-invariant
haskell-iproute
haskell-js-dgtable
haskell-js-flot
haskell-js-jquery
haskell-kan-extensions
haskell-language-javascript
haskell-language-server
haskell-lens
haskell-lens-aeson
haskell-libyaml
haskell-lift-type
haskell-lifted-base
haskell-list-t
haskell-listlike
haskell-logict
haskell-lsp
haskell-lsp-types
haskell-lucid
haskell-megaparsec
haskell-memory
haskell-memotrie
haskell-microlens
haskell-microlens-mtl
haskell-microlens-th
haskell-mime-types
haskell-mintty
haskell-mmap
haskell-mmorph
haskell-mod
haskell-monad-control
haskell-monad-dijkstra
haskell-monad-logger
haskell-monad-loops
haskell-monadrandom
haskell-mono-traversable
haskell-monoid-subclasses
haskell-mustache
haskell-neat-interpolation
haskell-network
haskell-network-bsd
haskell-network-byte-order
haskell-network-control
haskell-network-info
haskell-network-uri
haskell-newtype-generics
haskell-old-locale
haskell-old-time
haskell-onetuple
haskell-only
haskell-open-browser
haskell-opentelemetry
haskell-optparse-applicative
haskell-optparse-simple
haskell-ordered-containers
haskell-ormolu
haskell-os-string
haskell-pantry
haskell-parallel
haskell-parser-combinators
haskell-path
haskell-path-io
haskell-path-pieces
haskell-pem
haskell-persistent
haskell-persistent-sqlite
haskell-polyparse
haskell-pretty-simple
haskell-prettyprinter
haskell-prettyprinter-ansi-terminal
haskell-prettyprinter-compat-ansi-wl-pprint
haskell-primes
haskell-primitive
haskell-primitive-extras
haskell-primitive-unlifted
haskell-process-extras
haskell-profunctors
haskell-project-template
haskell-psqueues
haskell-quickcheck
haskell-random
haskell-random-shuffle
haskell-raw-strings-qq
haskell-recv
haskell-refact
haskell-reflection
haskell-regex
haskell-regex-applicative
haskell-regex-base
haskell-regex-pcre
haskell-regex-posix
haskell-regex-tdfa
haskell-resource-pool
haskell-resourcet
haskell-retrie
haskell-retry
haskell-rio
haskell-rio-orphans
haskell-rio-prettyprint
haskell-row-types
haskell-safe
haskell-safe-exceptions
haskell-scientific
haskell-semialign
haskell-semigroupoids
haskell-semirings
haskell-serialise
haskell-setenv
haskell-sha
haskell-shakespeare
haskell-silently
haskell-simple-sendfile
haskell-skein
haskell-some
haskell-sorted-list
haskell-split
haskell-splitmix
haskell-sqlite-simple
haskell-src-exts
haskell-src-meta
haskell-statevar
haskell-stm-chans
haskell-stm-containers
haskell-stm-hamt
haskell-streaming-commons
haskell-strict
haskell-string-interpolate
haskell-syb
haskell-tagged
haskell-tamarin-prover-accountability
haskell-tamarin-prover-export
haskell-tamarin-prover-sapic
haskell-tamarin-prover-term
haskell-tamarin-prover-theory
haskell-tamarin-prover-utils
haskell-tar
haskell-tar-conduit
haskell-tasty
haskell-temporary
haskell-terminal-size
haskell-text-binary
haskell-text-conversions
haskell-text-iso8601
haskell-text-metrics
haskell-text-rope
haskell-text-short
haskell-th-abstraction
haskell-th-compat
haskell-th-env
haskell-th-expand-syns
haskell-th-lift
haskell-th-lift-instances
haskell-th-orphans
haskell-th-reify-many
haskell-these
haskell-threads
haskell-time-compat
haskell-time-locale-compat
haskell-time-manager
haskell-tls
haskell-transformers-base
haskell-transformers-compat
haskell-typed-process
haskell-unicode-data
haskell-unicode-transforms
haskell-uniplate
haskell-unix-compat
haskell-unix-time
haskell-unliftio
haskell-unliftio-core
haskell-unordered-containers
haskell-utf8-string
haskell-uuid
haskell-uuid-types
haskell-vault
haskell-vector
haskell-vector-algorithms
haskell-vector-binary-instances
haskell-vector-stream
haskell-void
haskell-wai
haskell-wai-app-static
haskell-wai-extra
haskell-wai-logger
haskell-warp
haskell-witherable
haskell-wl-pprint-text
haskell-word8
haskell-yaml
haskell-yesod-core
haskell-yesod-static
haskell-zip-archive
haskell-zlib
hdparm
hicolor-icon-theme
hidapi
highway
hlint
hping
htop
hunspell
hwdata
hwinfo
hwloc
hyperfine
hyphen
iana-etc
ibus
icu
iio-sensor-proxy
ijs
imagemagick
imath
imlib2
inetutils
iniparser
inkscape
inotify-tools
intel-ipu7-camera-bin-r31.09ccd02
intel-ipu7-camera-hal-git-r48.feed915
intel-ipu7-dkms-git-r42.62a3704
intel-ivsc-firmware-r13.3377801
intel-sgx-sdk-bin
intel-vision-drivers-dkms-git-r48.92a717e
iperf
iproute2
iptables
iputils
iso-codes
iw
jadx
jansson
java-environment-common
java-runtime-common
jbig2dec
jbigkit
jdk17-openjdk
jdk21-openjdk
jdk22-graalvm-bin
jdk8-openjdk
jemalloc
john
jq
jre8-openjdk
jre8-openjdk-headless
js140
json-c
json-glib
jsoncpp
karchive
kbd
kbookmarks
kcodecs
kcolorscheme
kcompletion
kcompletion5
kconfig
kconfig5
kconfigwidgets
kcontacts
kcoreaddons
kcoreaddons5
kcrash
kcrash5
kdbusaddons
kdeclarative
kdeconnect
keyutils
kglobalaccel
kguiaddons
kguiaddons5
ki18n
ki18n5
kiconthemes
kio
kirigami
kirigami-addons
kitemmodels
kitemviews
kitemviews5
kjobwidgets
kmod
knotifications
kpeople
krb5
krita
kservice
kstatusnotifieritem
ksvg
kvantum-qt4-git
kwallet
kwidgetsaddons
kwidgetsaddons5
kwindowsystem
kwindowsystem5
l-smash
lame
lapack
lcms2
ldb
leancrypto
leptonica
less
lhasa
lib2geom
lib32-alsa-lib
lib32-alsa-plugins
lib32-audit
lib32-brotli
lib32-bzip2
lib32-curl
lib32-dbus
lib32-e2fsprogs
lib32-expat
lib32-fontconfig
lib32-freetype2
lib32-gcc-libs
lib32-glib2
lib32-glibc
lib32-gmp
lib32-gnutls
lib32-icu
lib32-json-c
lib32-keyutils
lib32-krb5
lib32-libcap
lib32-libdisplay-info
lib32-libdrm
lib32-libelf
lib32-libffi
lib32-libgcrypt
lib32-libglvnd
lib32-libgpg-error
lib32-libidn2
lib32-libldap
lib32-libnghttp2
lib32-libnghttp3
lib32-libngtcp2
lib32-libnm
lib32-libnsl
lib32-libpciaccess
lib32-libpipewire
lib32-libpng
lib32-libpsl
lib32-libssh2
lib32-libtasn1
lib32-libtirpc
lib32-libunistring
lib32-libva
lib32-libx11
lib32-libxau
lib32-libxcb
lib32-libxcrypt
lib32-libxcrypt-compat
lib32-libxdmcp
lib32-libxext
lib32-libxfixes
lib32-libxinerama
lib32-libxml2
lib32-libxshmfence
lib32-libxss
lib32-libxxf86vm
lib32-llvm-libs
lib32-lm_sensors
lib32-mesa
lib32-ncurses
lib32-nettle
lib32-nspr
lib32-nss
lib32-openssl
lib32-p11-kit
lib32-pam
lib32-pcre2
lib32-pipewire
lib32-spirv-tools
lib32-sqlite
lib32-systemd
lib32-util-linux
lib32-vulkan-icd-loader
lib32-vulkan-intel
lib32-vulkan-mesa-implicit-layers
lib32-wayland
lib32-xcb-util-keysyms
lib32-xz
lib32-zlib-ng
lib32-zlib-ng-compat
lib32-zstd
lib3mf
libabw
libadwaita
libaemu
libaio
libantlr3c
libao
libarchive
libass
libassuan
libasyncns
libatasmart
libatomic_ops
libavc1394
libavif
libavtp
libayatana-appindicator
libayatana-indicator
libb2
libb64
libblockdev
libblockdev-crypto
libblockdev-fs
libblockdev-loop
libblockdev-mdraid
libblockdev-nvme
libblockdev-part
libblockdev-smart
libblockdev-swap
libbluray
libbpf
libbs2b
libbsd
libburn
libbytesize
libcaca
libcacard
libcamera
libcamera-ipa
libcanberra
libcap
libcap-ng
libcbor
libcdio
libcdio-paranoia
libcdr
libcheese
libcloudproviders
libcmis
libcoap
libcolord
libctru
libcue
libcups
libcupsfilters
libcurl-gnutls
libdaemon
libdatachannel
libdatrie
libdbusmenu-glib
libdbusmenu-gtk3
libdc1394
libdca
libde265
libdecor
libdeflate
libdisplay-info
libdovi
libdrm
libdv
libdvdnav
libdvdread
libe-book
libebur128
libedit
libei
libelf
libepoxy
libepubgen
libetonyek
libevdev
libevent
libewf
libexif
libexttextcat
libfabric
libfakekey
libfdk-aac
libffi
libfilezilla
libfishsound
libfontenc
libfreeaptx
libfreehand
libftdi
libfyaml
libgbinder
libgcrypt
libgda6
libgdiplus
libgdm
libgexiv2
libgirepository
libgit2
libglibutil
libglvnd
libgme
libgnomekbd
libgoa
libgpg-error
libgphoto2
libgsf
libgtop
libgudev
libgusb
libgweather
libgxps
libhandy
libheif
libibus
libical
libice
libid3tag
libidn
libidn2
libiec61883
libieee1284
libimagequant
libimobiledevice
libimobiledevice-glue
libinih
libinput
libinput-config-git-r86.185c6cb
libiptcdata
libiscsi
libisl
libisoburn
libisofs
libixion
libjcat
libjpeg-turbo
libjuice
libjxl
libkdcraw5
libksba
liblangtag
liblc3
libldac
libldap
liblo
liblouis
liblqr
liblrdf
libltc
liblzf
libmad
libmakepkg-dropins
libmalcontent
libmanette
libmaxminddb
libmbim
libmcrypt
libmd
libmicrodns
libmicrohttpd
libmm-glib
libmng
libmnl
libmodplug
libmpc
libmpcdec
libmpeg2
libmspack
libmspub
libmtp
libmwaw
libmysofa
libnatpmp
libnautilus-extension
libnbd
libndp
libnet
libnetfilter_conntrack
libnewt
libnfnetlink
libnfs
libnftnl
libnghttp2
libnghttp3
libngtcp2
libnice
libnl
libnm
libnma
libnma-common
libnma-gtk4
libnotify
libnsl
libnumbertext
libnvme
libodfgen
libogg
liboggz
libopenmpt
liborcus
libosinfo
libp11-kit
libpagemaker
libpaper
libpcap
libpciaccess
libpgm
libpipeline
libpipewire
libplacebo
libplist
libpng
libpoly
libportal
libportal-gtk4
libppd
libproxy
libpsl
libpulse
libpwquality
libqalculate
libqmi
libqrtr-glib
libqxp
libraqm
libraw
libraw1394
libreoffice-fresh
libreoffice-fresh-ja
librest
librevenge
librsvg
libsamplerate
libsasl
libsbsms
libseccomp
libsecret
libshout
libsigc++
libsigsegv
libslirp
libsm
libsndfile
libsodium
libsoup3
libsoxr
libspectre
libspeechd
libspelling
libspnav
libsrtp
libssh
libssh2
libstaroffice
libstemmer
libsynctex
libsysprof-capture
libtasn1
libtatsu
libteam
libtecla
libthai
libtheora
libtiff
libtirpc
libtommath
libtool
libtpms
libtraceevent
libtracefs
libunibreak
libunistring
libunwind
liburcu
liburing
libusb
libusbmuxd
libutf8proc
libuv
libva
libvdpau
libverto
libvirt
libvirt-glib
libvirt-python
libvisio
libvitamtp-git
libvlc
libvncserver
libvorbis
libvpl
libvpx
libwacom
libwbclient
libwebp
libwireplumber
libwpd
libwpg
libwps
libx11
libx86emu
libxau
libxaw
libxcb
libxcomposite
libxcrypt
libxcrypt-compat
libxcursor
libxcvt
libxdamage
libxdmcp
libxdp
libxext
libxfixes
libxfont2
libxft
libxi
libxinerama
libxkbcommon
libxkbcommon-x11
libxkbfile
libxklavier
libxml2
libxml2-legacy
libxmlb
libxmu
libxpm
libxrandr
libxrender
libxshmfence
libxslt
libxss
libxt
libxtst
libxv
libxxf86vm
libyaml
libyuv-r2426+464c51a03
libzip
libzmf
licenses
lightdm
lightdm-settings
lightdm-slick-greeter
lilv
linux-api-headers
linux-firmware
linux-firmware-amdgpu
linux-firmware-atheros
linux-firmware-broadcom
linux-firmware-cirrus
linux-firmware-intel
linux-firmware-mediatek
linux-firmware-nvidia
linux-firmware-other
linux-firmware-radeon
linux-firmware-realtek
linux-firmware-whence
linux-lts
linux-lts-headers
linux-sgx-driver-hayao-dkms-git
litestream
lld
llhttp
llvm-libs
lm_sensors
lmdb
localsearch
lpsolve
lsb-release
lsd
lsof
lsp-plugins
lsp-plugins-clap
lsp-plugins-gst
lsp-plugins-ladspa
lsp-plugins-lv2
lsp-plugins-standalone
lsp-plugins-vst
lsp-plugins-vst3
lua
lv2
lxc
lz4
lzo
m4
mailcap
make
man-db
mattermost-desktop
maude
mbedtls
md4c
mdadm
media-player-info
mercurial
mermaid-cli
mesa
mesa-utils
mhash
migrate
miniupnpc
minizip
minizip-ng
miraktest
mise
mission-center
mjpegtools
mkinitcpio
mkinitcpio-busybox
mlt
mobile-broadband-provider-info
modemmanager
modemmanager-qt
mono
mozc-ut
mpdecimal
mpfr
mpg123
msr-tools
mtdev
mtools
multipath-tools
mutter
nano
nasm
nautilus
ncurses
ndctl
neon
net-snmp
net-tools
netpbm
nettle
networkmanager
networkmanager-openconnect
networkmanager-openvpn
networkmanager-vpn-plugin-openconnect
networkmanager-vpn-plugin-openvpn
nftables
nixfmt
nlohmann-json
nm-connection-editor
nmap
node-gyp
nodejs-lts-jod
nodejs-nopt
nody-greeter
noto-fonts
noto-fonts-cjk
noto-fonts-emoji
npm
npth
nspr
nss
ntfs
numactl
nvtop
oath-toolkit
obs-studio
ocl-icd
onetbb
oniguruma
onlyoffice-bin
openal
openblas
opencolorio
openconnect
opencore-amr
opencsg
openexr
openh264
openjpeg2
openmpi
openpmix
openscad
openssh
openssl
openucx
openvpn
openxr
opus
opusfile
orc
orca-slicer
os-prober
osc
osinfo-db
ostree
otf-ipaexfont
otf-ipafont
otf-ipamjfont
otf-source-han-code-jp
p11-kit
pacman
pacman-contrib
pacman-mirrorlist
pahole
pam
pambase
pango
pangomm
papirus-icon-theme
parallel
parted
passim
patch
pavucontrol
payload-dumper-go
pciutils
pcre
pcre2
pcsclite
perl
perl-clone
perl-encode-locale
perl-error
perl-file-listing
perl-html-parser
perl-html-tagset
perl-http-cookiejar
perl-http-cookies
perl-http-daemon
perl-http-date
perl-http-message
perl-http-negotiate
perl-image-exiftool
perl-io-html
perl-libwww
perl-lwp-mediatypes
perl-mailtools
perl-net-http
perl-timedate
perl-try-tiny
perl-uri
perl-www-robotrules
perl-xml-parser
perl-xml-writer
phodav
picasso
pinentry
pipewire
pipewire-alsa
pipewire-audio
pipewire-jack
pipewire-pulse
pipewire-session-manager
pixman
pkcs11-helper
pkgconf
plymouth
plymouth-theme-arch-darwin
polkit
pop-icon-theme
pop-launcher
poppler
poppler-data
poppler-glib
popt
portaudio
portmidi
portsmf
postgresql
postgresql-libs
potrace
ppp
procps-ng
progress
protobuf
protobuf-c
prrte
psmisc
pulse-native-provider
pulseaudio-qt
pwndbg
pyenv
pystring
python
python-anyascii
python-appdirs
python-argcomplete
python-attrs
python-autocommand
python-automat
python-bcrypt
python-beautifulsoup4
python-binaryornot
python-boolean.py
python-botocore
python-build
python-cachecontrol
python-cachy
python-cairo
python-capstone
python-certifi
python-cffi
python-chardet
python-charset-normalizer
python-cleo
python-click
python-colorama
python-colored-traceback
python-configobj
python-constantly
python-crashtest
python-cryptography
python-cssselect
python-cssselect2
python-dateutil
python-dbus
python-debian
python-distlib
python-distro
python-docutils
python-dulwich
python-fastbencode
python-fastjsonschema
python-filelock
python-findpython
python-fluidity
python-gbinder
python-gobject
python-html5lib
python-hyperlink
python-idna
python-incremental
python-installer
python-intervaltree
python-invoke
python-jaraco.classes
python-jaraco.collections
python-jaraco.context
python-jaraco.functools
python-jaraco.text
python-jeepney
python-jinja
python-jmespath
python-jsonschema
python-jsonschema-specifications
python-keyring
python-lark-parser
python-lexicon
python-license-expression
python-lockfile
python-lxml
python-mako
python-markdown
python-markupsafe
python-material-color-utilities
python-merge3
python-more-itertools
python-msgpack
python-netifaces
python-numpy
python-packaging
python-paramiko
python-patiencediff
python-pbs-installer
python-pexpect
python-pillow
python-pipx
python-pkginfo
python-platformdirs
python-pluggy
python-plumbum
python-ply
python-poetry
python-poetry-core
python-poetry-plugin-export
python-psutil
python-psycopg2
python-pt-r20240401.114.50227bd
python-ptrace
python-ptyprocess
python-pwntools
python-pyasn1
python-pycparser
python-pycryptodome
python-pycryptodomex
python-pycups
python-pyelftools
python-pygments
python-pynacl
python-pyproject-hooks
python-pyqt5
python-pyqt5-sip
python-pyqt6
python-pyqt6-sip
python-pyserial
python-pysocks
python-qasync
python-rapidfuzz
python-referencing
python-regex
python-reportlab
python-requests
python-requests-toolbelt
python-rpds-py
python-rpyc
python-rsa
python-ruamel-yaml
python-ruamel.yaml.clib
python-s3transfer
python-secretstorage
python-setproctitle
python-setuptools
python-shellingham
python-six
python-sortedcontainers
python-soupsieve
python-svglib
python-tabulate
python-tinycss2
python-tomlkit
python-trove-classifiers
python-twisted
python-typing_extensions
python-unicorn
python-urllib3
python-userpath
python-virtualenv
python-webencodings
python-wheel
python-xapp
python-yaml
python-yapsy-git-release_Yapsy.1.12.2.r17.g6b487b0
python-zope-interface
python-zstandard
qca-qt6
qcma-git
qemu-audio-alsa
qemu-audio-dbus
qemu-audio-jack
qemu-audio-oss
qemu-audio-pa
qemu-audio-pipewire
qemu-audio-sdl
qemu-audio-spice
qemu-base
qemu-block-curl
qemu-block-dmg
qemu-block-gluster
qemu-block-iscsi
qemu-block-nfs
qemu-block-ssh
qemu-chardev-baum
qemu-chardev-spice
qemu-common
qemu-desktop
qemu-docs
qemu-emulators-full
qemu-full
qemu-hw-display-qxl
qemu-hw-display-virtio-gpu
qemu-hw-display-virtio-gpu-gl
qemu-hw-display-virtio-gpu-pci
qemu-hw-display-virtio-gpu-pci-gl
qemu-hw-display-virtio-gpu-pci-rutabaga
qemu-hw-display-virtio-gpu-rutabaga
qemu-hw-display-virtio-vga
qemu-hw-display-virtio-vga-gl
qemu-hw-display-virtio-vga-rutabaga
qemu-hw-s390x-virtio-gpu-ccw
qemu-hw-uefi-vars
qemu-hw-usb-host
qemu-hw-usb-redirect
qemu-hw-usb-smartcard
qemu-img
qemu-pr-helper
qemu-system-aarch64
qemu-system-alpha
qemu-system-alpha-firmware
qemu-system-arm
qemu-system-arm-firmware
qemu-system-avr
qemu-system-hppa
qemu-system-hppa-firmware
qemu-system-loongarch64
qemu-system-m68k
qemu-system-microblaze
qemu-system-microblaze-firmware
qemu-system-mips
qemu-system-or1k
qemu-system-ppc
qemu-system-ppc-firmware
qemu-system-riscv
qemu-system-riscv-firmware
qemu-system-rx
qemu-system-s390x
qemu-system-s390x-firmware
qemu-system-sh4
qemu-system-sparc
qemu-system-sparc-firmware
qemu-system-tricore
qemu-system-x86
qemu-system-x86-firmware
qemu-system-xtensa
qemu-tests
qemu-tools
qemu-ui-curses
qemu-ui-dbus
qemu-ui-egl-headless
qemu-ui-gtk
qemu-ui-opengl
qemu-ui-sdl
qemu-ui-spice-app
qemu-ui-spice-core
qemu-user
qemu-vhost-user-gpu
qemu-vmsr-helper
qopenvpn
qpdf
qqc2-desktop-style
qrcodegencpp-cmake
qrencode
qscintilla-qt5
qsynth
qt4
qt5-base
qt5-declarative
qt5-location
qt5-multimedia
qt5-quickcontrols
qt5-styleplugins
qt5-svg
qt5-translations
qt5-wayland
qt5-webchannel
qt5-webengine
qt5-websockets
qt5-x11extras
qt5ct
qt6
qt6-base
qt6-connectivity
qt6-declarative
qt6-graphs
qt6-multimedia
qt6-multimedia-ffmpeg
qt6-quick3d
qt6-quicktimeline
qt6-scxml
qt6-shadertools
qt6-svg
qt6-tools
qt6-translations
qt6-wayland
qt6ct
qtkeychain-qt5
qtractor
qtspim
quazip-qt5
ragel
raptor
rasqal
rav1e
rdma-core
readline
redland
reflector
retroarch
reuse
ripgrep
rnnoise
ropgadget
rpcbind
rpi-imager
rsync
rtkit
rtmpdump
rubberband
ruby
ruby-bundler
ruby-erb
rubygems
runc
rust
rutabaga-ffi
s3fs-fuse
sane
sane-airscan
sbc
scala
scour
sdl12-compat
sdl2-compat
sdl2_image
sdl3
sdl3_ttf
seabios
seahorse
seatd
sed
semver
sequoia-sqv
serd
serf
shaderc
shadow
shared-mime-info
shellcheck
shfmt
simde
simple-scan
sipp
sl
slack-electron
slang
sleuthkit
smbclient
snapper
snapper-gui-git
snappy
sof-firmware
solid
sonic-visualiser
sonnet
sord
sound-theme-freedesktop
soundtouch
source-highlight
sox
spandsp
speedtest-cli
speex
speexdsp
spice
spice-gtk
spice-protocol
spirv-tools
spotify-launcher
sqlite
squashfs-tools
sratom
srt
stack
startup-notification
steam
steghide
stoken
stylish-haskell
subversion
sudo
suil
supabase
svt-av1
svt-hevc
system-config-printer
systemd
systemd-libs
systemd-sysvcompat
taglib
talloc
tamarin-prover
tar
tdb
tecla
tesseract
tesseract-data-eng
tesseract-data-osd
testdisk
tevent
tex3ds
texinfo
texlive-basic
texlive-bibtexextra
texlive-bin
texlive-binextra
texlive-context
texlive-fontsextra
texlive-fontsrecommended
texlive-fontutils
texlive-formatsextra
texlive-games
texlive-humanities
texlive-latex
texlive-latexextra
texlive-latexrecommended
texlive-luatex
texlive-mathscience
texlive-metapost
texlive-music
texlive-pictures
texlive-plaingeneric
texlive-pstricks
texlive-publishers
texlive-xetex
thunderbird
thunderbird-i18n-ja
tigervnc
tinysparql
tinyxml2
tlp
tlpui
totem-pl-parser
tpm2-tss
traceroute
transmission-gtk
tree
tslib
ttf-carlito
ttf-dejavu
ttf-liberation
ttf-opensans
ttf-sourcecodepro-nerd
twolame
tzdata
uchardet
udisks2
ungoogled-chromium-bin
unicorn
unzip
upower
upx
usbredir
usbutils
uthash
util-linux
util-linux-libs
uv
v4l-utils
v4l2-relayd
v4l2loopback-dkms
vamp-plugin-sdk
vapoursynth
vde2
ventoy-bin
vesktop
vid.stab
viewnior
vim
vim-runtime
virglrenderer
virt-install
virt-manager
virtiofsd
virtscreen
virtualbox
virtualbox-host-dkms
visual-studio-code-bin
visual-studio-code-insiders-bin
vlc
vlc-cli
vlc-gui-qt
vlc-plugin-a52dec
vlc-plugin-alsa
vlc-plugin-archive
vlc-plugin-dav1d
vlc-plugin-dbus
vlc-plugin-dbus-screensaver
vlc-plugin-faad2
vlc-plugin-flac
vlc-plugin-gnutls
vlc-plugin-inflate
vlc-plugin-journal
vlc-plugin-jpeg
vlc-plugin-lua
vlc-plugin-mpg123
vlc-plugin-ogg
vlc-plugin-opus
vlc-plugin-png
vlc-plugin-pulse
vlc-plugin-shout
vlc-plugin-speex
vlc-plugin-tag
vlc-plugin-theora
vlc-plugin-twolame
vlc-plugin-vorbis
vlc-plugin-vpx
vlc-plugin-xml
vlc-plugins-base
vlc-plugins-video-output
vmaf
volta
volume_key
vpnc
vte-common
vte3
vulkan-icd-loader
vulkan-intel
vulkan-mesa-implicit-layers
vulkan-tools
wavpack
waydroid
wayland
webkit2gtk
webkitgtk
webrtc-audio-processing
wget
which
wildmidi
wine
wine-mono
winetricks
wireless_tools
wireplumber
wireshark-cli
wireshark-qt
woff2
wolfssl
wordlists
wpa_supplicant
wpscan
wxwidgets-common
wxwidgets-gtk3
x11vnc
x264
x265
xapp
xapp-symbolic-icons
xcb-imdkit
xcb-proto
xcb-util
xcb-util-cursor
xcb-util-image
xcb-util-keysyms
xcb-util-renderutil
xcb-util-wm
xdg-dbus-proxy
xdg-desktop-portal
xdg-desktop-portal-gnome
xdg-desktop-portal-gtk
xdg-user-dirs
xdg-user-dirs-gtk
xdg-utils
xerox-docucentre-driver
xf86-input-libinput
xf86-video-vesa
xkeyboard-config
xmlsec
xorg-bdftopcf
xorg-docs
xorg-font-util
xorg-fonts
xorg-fonts-alias
xorg-fonts-encodings
xorg-iceauth
xorg-mkfontscale
xorg-server
xorg-server-common
xorg-server-devel
xorg-server-xephyr
xorg-server-xnest
xorg-server-xvfb
xorg-sessreg
xorg-setxkbmap
xorg-smproxy
xorg-util-macros
xorg-x11perf
xorg-xauth
xorg-xbacklight
xorg-xcmsdb
xorg-xcursorgen
xorg-xdpyinfo
xorg-xdriinfo
xorg-xev
xorg-xgamma
xorg-xhost
xorg-xinit
xorg-xinput
xorg-xkbcomp
xorg-xkbevd
xorg-xkbutils
xorg-xkill
xorg-xlsatoms
xorg-xlsclients
xorg-xmodmap
xorg-xpr
xorg-xprop
xorg-xrandr
xorg-xrdb
xorg-xrefresh
xorg-xset
xorg-xsetroot
xorg-xvinfo
xorg-xwayland
xorg-xwd
xorg-xwininfo
xorg-xwud
xorgproto
xvidcore
xxhash
xz
yaml-cpp
yay
yices
yt-dlp
yt-dlp-ejs
yyjson
zbar
zed
zellij
zenity
zeromq
zimg
zita-convolver
zix
zlib-ng
zlib-ng-compat
zoom
zstd
zvbi
zxing-cpp
zziplib
```
