#!/usr/bin/env bash
#{{{ Bash settings
set -o errexit
set -o errtrace
set -o nounset
set -o pipefail
set -o xtrace
#}}}
#################################################################
#                                                               #
# Waterfox Download and Installation and Uninstallation Script  #
#                         Version: 1.0.0                        #
#                       Copyright (C) 2019                      #
#           Marcelo dos Santos Mafra <msmafra@gmail.com>        #
#       Licensed under the GNU General Public License v3.0      #
#                                                               #
#           https://github.com/msmafra/waterfox-install         #
#                                                               #
#################################################################
#
#{{{ Primary Variables
readonly script_title="Waterfox Download and Installation and Uninstallation Script"
readonly script_ver="1.0.0"
readonly script_file=$(basename "${0}")
readonly script_dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
#IFS=$'\t\n' # Split on newlines and tabs (but not on spaces)
IFS="$(printf '\n\t')"
#}}}
#{{{ Primary Functions
function exit_stage_left() {
    # ? gets the exit code
    printf "\n%s" "So exit, Stage Left! ${?}"
}

function err_msg() {
    local the_message
    local the_time_stamp
    # Prints error messages
    the_message="${1}"; shift
    the_time_stamp="$(date +'%Y-%m-%dT%H:%M:%S%z')"
    # printf "%s [$(date +'%Y-%m-%dT%H:%M:%S%z')]: ${@}" >&2
    printf "%s [${the_time_stamp}]:" "${@}"
}

function check_sudo() {
    # wfxuser check which user is running the script
    local wfxuser
    wfxuser=$(\id --user --name)
    if [[ "${EUID}" != 0 ]];then
        printf "%s, run me as sudo, pleeeese.\n" "${wfxuser}"
        exit "${?}"
    fi
}

function wfx_check_existence() {
    # First checks if some needed programs are on the system
    local places
    local is_waterfox
    local is_wget
    local is_curl
    local is_notifysend

    places="/usr/bin/ /usr/local/bin/"

    is_waterfox=$(
        \whereis -B "${places:-}" -b "${wfxexecpath:-NULL}" -f 2>&1 |
        \whereis -B "${places:-}" -b waterfox -f 2>&1 |
        \awk --sandbox --field-separator=": " '{print $2}'
    )

    is_wget=$(
        \whereis -B "${places:-}" -b wget -f 2>&1 |
        \awk --sandbox --field-separator=": " '{print $2}'
    )

    is_curl=$(
        \whereis -B "${places:-}" -b curl -f 2>&1 |
        \awk --sandbox --field-separator=": " '{print $2}'
    )

    is_notifysend=$(
        \whereis -B "${places:-}" -b notify-send -f 2>&1 |
        \awk --sandbox --field-separator=": " '{print $2}'
    )
    printf "%s" "${is_waterfox:-0}"
    printf "%s" "${is_wget:-0}"
    printf "%s" "${is_curl:-0}"
    printf "%s" "${is_notifysend:-0}"

    [[ "${is_waterfox:-0}" && "${is_wget:-0}" && "${is_curl:-0}" && "${is_notifysend:-0}" ]]
}
#}}}
#{{{ Variables
# The new url with the releases
readonly wfxrelpage="https://www.waterfox.net/releases/"
readonly wfxrelcache="waterfox-releases.html"
readonly wfxdest="/opt/"
readonly wfxlogfile="waterfox-install.log"
readonly wfxexecpath="/usr/bin/waterfox"
readonly wfxdevexecpath="/usr/bin/waterfox-dev"
readonly wfxbinpath="/opt/waterfox/waterfox"
readonly wfxdevbinpath="/opt/waterfox-dev/waterfox"
readonly wfxusrbinpath="/usr/bin/waterfox"
readonly wfxdevusrbinpath="/usr/bin/waterfox-dev"
readonly wfxbranch="releases"
# Downloads everything here to be deleted automatically after a reboot or shutdown
readonly tmpdir="/tmp/"
# Implement creating /tmp/waterfox-install/ folder
# Use mktemp instead ?
readonly wfxtmpdir="$(\mktemp --directory --suffix=-waterfox-install)/"
#}}}
#{{{ Functions
function wfx_cache_page() {
    local url
    #local tool="${1}"; shift
    local wait
    local tries
    local timeout
    local maxtime
    # \mkdir --parent --verbose "${wfxtmpdir}"
    # \touch "${wfxtmpdir}${wfxrelcache}"
    #local url="${1}"; shift
    url="${wfxrelpage}"
    #local tool="${1}"; shift
    wait=3
    tries=3
    timeout=5
    maxtime=10
    #\wget --spider --no-verbose --show-progress --progress=dot --tries="${tries}" --connect-timeout="${timeout}" --waitretry="${wait}" --output-file="${wfxrelcache}" --continue "${wfxrelpage}"
    #\curl --continue-at - --output "${wfxrelcache}" --show-error --silent --head --request GET "${wfxrelpage}" --retry-connrefused --retry "${tries}" --connect-timeout "${timeout}" --retry-delay "${wait}"
    #\wget --output-document="${wfxtmpdir}${wfxrelcache}" --show-progress --tries="${tries}" --connect-timeout="${timeout}" --waitretry="${wait}" --output-file="${wfxrelcache}" --continue "${wfxrelpage}"
    # Downloading the download page to the temporary dir
    \curl --compressed --continue-at - --output "${wfxtmpdir}${wfxrelcache}" --show-error --silent --request GET "${wfxrelpage}" --retry-connrefused --retry "${tries}" --connect-timeout "${timeout}" --retry-delay "${wait}" --max-time "${maxtime}"
    # unset ${1}
}

function wfx_change_directory() {
    # Change to /tmp so the downloaded file will be automatically deleted after restart or shutdown
    printf "\n%s %s..." "Entering" "${tmpdir}"
    cd "${tmpdir}" && \pwd
}

function wfx_draw_url() {
    # Gets the url with the right branch: produtction=releases, development=aurora
    # local wfxbranch="${1}"; shift
    # Sets the url based on the branch selected
    # The regular expression here has been expanded to get colons, ampersands, spaces: "\s", "%20" or " " (meaning three forms of space characters: escaped,
    # HTML enconding or the literal space). I guess by mistake, the MacOS X and Windows url/file names have spaces on their names. To avoid future problems
    # with the Linux files theses changes were made to the regular expression.
    # As Waterfox is available for various OSes it is here filtered to get the .bz2 file(s) ignoring the .dmg and the .exe files
    # To avoid getting both stable and developing version the wfxbranch is used
    local wfxurl
    wfxurl=$(
        \cat --squeeze-blank "${wfxtmpdir}${wfxrelcache}" |
        # \grep --extended-regexp --only-matching "(http|https)://[a-zA-Z0-9./?=_-]*" |
        # \grep --extended-regexp --only-matching "(http|https)://[a-zA-Z0-9:\.\ /?=_-]*" |
        # \grep --extended-regexp --only-matching "(http|https)://[a-zA-Z0-9:\.\s/\?=+_& -]*" |
        # \grep --extended-regexp --only-matching "(http|https)://([a-zA-Z0-9-\/])([a-zA-Z0-9:\.\s/\?=+_& %20-]).+" |
        \grep --extended-regexp --only-matching "(http|https)://[a-zA-Z0-9:\.\s/\?=+_& %20-]*" |
        \grep "/${wfxbranch}" |
        \grep --max-count=1 ".bz2"
    )
    printf "%s" "${wfxurl}"
    #unset ${wfxurl} ${1}
}

function wfx_draw_appimage() {

    local wfxappimgpage
    local wfxappimgcache
    local wfxappimgfile
    wfxappimgpage="https://download.opensuse.org/repositories/home:/hawkeye116477:/waterfox/AppImage/"
    wfxappimgcache="waterfox-appimage.html"
    wfxappimgfile=$(
        \cat --squeeze-blank "${tmpdir}${wfxappimgcache}" |
        \grep --perl-regex --only-matching '(?<=href=")[^"]*' |
        \grep --extended-regexp "^waterfox" |
        \grep --extended-regexp ".AppImage$" |
        \sort --unique
    )
    \wget --continue "${wfxappimgpage}" --output-document="${wfxappimgcache}"
    printf "%s%s" "${wfxappimgpage}" "${wfxappimgfile}"
}

function wfx_version_remote() {
    # Gets the remote version
    local wfxurl
    local wfxrver
    wfxurl="$(wfx_draw_url)"
    wfxrver=$(
        printf "%s" "${wfxurl}" |
        \awk --sandbox --assign FS="/" '{print $7}' |
        \awk --sandbox --field-separator="-" '{print $2}' |
        \awk --sandbox --field-separator="." '{printf "%s.%s.%s", $1,$2,$3}'
    ) # Available Waterfox version
    printf "%s" "${wfxrver}"
}

function wfx_version_local() {
    # Gets the remote version
    local wfxlver
    wfxlver=$(
        "${wfxexecpath:-NULL}" --version |
        \awk --sandbox --field-separator='[^0-9]*' '{printf("%s.%s.%s", $2,$3,$4)}' |
        \awk --sandbox --field-separator="." '{printf "%s.%s.%s", $1,$2,$3}'
    ) # Installed Waterfox version
    printf "%s" "${wfxlver}"
}

function wfx_version_check() {
    # Check if the local and remote versions are the same
    local remote
    local local
    remote="$(wfx_version_remote)"
    local="$(wfx_version_local)"
    if [[ "${remote}" != "${local}" ]];then
        printf "%s" "false"
    else
        printf "%s" "true"
        # If they are the same exits
        exit 3
    fi
}

function wfx_file() {
    local wfxurl
    local wfxfile
    wfxurl="$(wfx_draw_url)"
    wfxfile="$(
        printf "%s" "${wfxurl}" |
        \awk --sandbox --field-separator="/" '{print $7}' |
        \tr --delete "\n"
    )"
    printf "%s" "${wfxfile}"
}

function wfx_do_not_kill_the_messenger() {
    local chknotifysnd
    local wfxsummary
    local wfxbody
    local wfxwhat
    chknotifysnd=$(\whereis notify-send 2>&1 | \awk --sandbox --field-separator=": " '{print $2}')
    wfxsummary="${1}"; shift
    wfxbody="${1}"; shift
    wfxwhat="${1}"; shift
    # [[ -n "${chknotifysnd}" ]] &&
    # \notify-send --expire-time=10 --urgency=normal "${wfxsummary}" "${wfxwhat} ${wfxbody}" --icon=system-software-install ||
    # printf "%s %s" "${title}" "${message}"

    if [[ -n "$(command -v zenity)" ]]; then
        \zenity --error --title="${wfxsummary}" --text="${wfxwhat} ${wfxbody}"
    elif [[ -n "$(command -v kdialog)" ]]; then
        \kdialog --error "${wfxwhat} ${wfxbody}" --title "${wfxsummary}"
    elif [[ -n "$(command -v xmessage)" ]]; then
        \xmessage -print -center "${wfxsummary}" "${wfxwhat} ${wfxbody}"
    elif [[ -n "$(command -v notify-send)" ]]; then
        \notify-send  --urgency=normal "${wfxsummary}" "${wfxwhat} ${wfxbody}" --icon=system-software-install
    else
        printf "%s %s" "${wfxsummary}" "${wfxwhat} ${wfxbody}"
    fi
}

function wfx_is_it_running() {
    # See if there is a process for waterfoxproject
    if [[ $(\whereis pgrep 2>&1 | \awk --sandbox --field-separator=' ' '{print $2}') ]];then
        if [[ $(\pgrep waterfox) ]];then
            read -rp "Waterfox is running.  It's recommended to close it before proceding. [Enter] to continue..."
        fi
    else
        exit 1
    fi
}

function wfx_get_the_drowned_fox() {

    local url
    local tool
    local wait
    local tries
    local timeout
    local maxtime

    if [[ $# -lt 2 ]];then
        exit 1
    else

        url="${1}"; shift
        tool="${1}"; shift
        wait=3
        tries=3
        timeout=5
        maxtime=10

        printf "Downloading version %s\n" "${wfxrver}"
        # Choose which one to start the download
        case "${tool}" in
            ["w"])
                wfx_do_not_kill_the_messenger "Waterfox Install Script" "${wfxfile} has been downloaded successfuly"
                # \wget --spider --no-verbose --show-progress --progress=dot --tries="${tries}" --connect-timeout="${timeout}" --waitretry="${wait}" --output-file="${tmpdir}${wfxlogfile}" --continue "${url}"
                \wget --no-verbose --show-progress --progress=dot --tries="${tries}" --connect-timeout="${timeout}" --waitretry="${wait}" --output-file="${tmpdir}${wfxlogfile}" --continue "${url}"
                ;;
            ["c"])
                wfx_do_not_kill_the_messenger "Waterfox Install Script" "${wfxfile} has been downloaded successfuly"
                # \curl --head --continue-at - --output "${tmpdir}${wfxfile}" --show-error --silent --request GET "${url}" --retry-connrefused --retry "${tries}" --connect-timeout "${timeout}" --retry-delay "${wait}"
                \curl --continue-at - --output "${tmpdir}${wfxfile}" --show-error --silent --request GET "${url}" --retry-connrefused --retry "${tries}" --connect-timeout "${timeout}" --retry-delay "${wait}"
                ;;
            *)
                wfx_do_not_kill_the_messenger "Error" "$# Unknkown tool"
                exit 1
                ;;
        esac
    fi


    # There is also the AppImage option available at:
    # https://download.opensuse.org/repositories/home:/hawkeye116477:/waterfox/AppImage/
    # Get manually from:
    # https://appimage.github.io/Waterfox/
    #
}

function wfx_extract_it() {
    local file
    local dest
    file="${1}"; shift
    dest="${1}"; shift

    # Extracts the downloaded file to ${dest}
    printf "Extracting %s...\n" "${wfxrver}"
    \tar --extract --verbose --file="${file}" --directory="${dest}"
}

function wfx_create_desktop_file() {
    local wfxiconpath
    local wfxdeviconpath
    local wfxdesktop
    local wfxdevdesktop
    # Set as default icon on waterfox.desktop
    wfxiconpath="/opt/waterfox/browser/chrome/icons/default/default256.png"
    wfxdeviconpath="/opt/waterfox-dev/browser/chrome/icons/default/default256.png"
    wfxdesktop="/usr/share/applications/waterfox.desktop"
    wfxdevdesktop="/usr/share/applications/waterfox-dev.desktop"
    # Creates the waterfox.desktop file to be accessed system wide.
    # If there is nothing already there, creates one
    # If there is one already replaces it
    if [[ ! -f "${wfxdesktop}" ]];then
        printf "%s" "\nCreating the waterfox.desktop file...\n"
        \tee --ignore-interrupts "${wfxdesktop}" <<'WFOXDESKTOP'
[Desktop Entry]
Version=1.2
Name=Waterfox
GenericName=Web Browser
GenericName[ar]=متصفح ويب
GenericName[ast]=Restolador Web
GenericName[bn]=ওয়েব ব্রাউজার
GenericName[ca]=Navegador web
GenericName[cs]=Webový prohlížeč
GenericName[da]=Webbrowser
GenericName[el]=Περιηγητής διαδικτύου
GenericName[es]=Navegador web
GenericName[et]=Veebibrauser
GenericName[fa]=مرورگر اینترنتی
GenericName[fi]=WWW-selain
GenericName[fr]=Navigateur Web
GenericName[gl]=Navegador Web
GenericName[he]=דפדפן אינטרנט
GenericName[hr]=Web preglednik
GenericName[hu]=Webböngésző
GenericName[it]=Browser web
GenericName[ja]=ウェブ・ブラウザ
GenericName[ko]=웹 브라우저
GenericName[ku]=Geroka torê
GenericName[lt]=Interneto naršyklė
GenericName[nb]=Nettleser
GenericName[nl]=Webbrowser
GenericName[nn]=Nettlesar
GenericName[no]=Nettleser
GenericName[pl]=Przeglądarka WWW
GenericName[pt]=Navegador Web
GenericName[pt_BR]=Navegador Web
GenericName[ro]=Navigator Internet
GenericName[ru]=Веб-браузер
GenericName[sk]=Internetový prehliadač
GenericName[sl]=Spletni brskalnik
GenericName[sv]=Webbläsare
GenericName[tr]=Web Tarayıcı
GenericName[ug]=توركۆرگۈ
GenericName[uk]=Веб-браузер
GenericName[vi]=Trình duyệt Web
GenericName[zh_CN]=网络浏览器
GenericName[zh_TW]=網路瀏覽器
Comment=Browse the World Wide Web
Comment[ar]=تصفح الشبكة العنكبوتية العالمية
Comment[ast]=Restola pela Rede
Comment[bn]=ইন্টারনেট ব্রাউজ করুন
Comment[ca]=Navegueu per la web
Comment[cs]=Prohlížení stránek World Wide Webu
Comment[da]=Surf på internettet
Comment[de]=Im Internet surfen
Comment[el]=Μπορείτε να περιηγηθείτε στο διαδίκτυο (Web)
Comment[es]=Navegue por la web
Comment[et]=Lehitse veebi
Comment[fa]=صفحات شبکه جهانی اینترنت را مرور نمایید
Comment[fi]=Selaa Internetin WWW-sivuja
Comment[fr]=Naviguer sur le Web
Comment[gl]=Navegar pola rede
Comment[he]=גלישה ברחבי האינטרנט
Comment[hr]=Pretražite web
Comment[hu]=A világháló böngészése
Comment[it]=Esplora il web
Comment[ja]=ウェブを閲覧します
Comment[ko]=웹을 돌아 다닙니다
Comment[ku]=Li torê bigere
Comment[lt]=Naršykite internete
Comment[nb]=Surf på nettet
Comment[nl]=Verken het internet
Comment[nn]=Surf på nettet
Comment[no]=Surf på nettet
Comment[pl]=Przeglądanie stron WWW
Comment[pt]=Navegue na Internet
Comment[pt_BR]=Navegue na Internet
Comment[ro]=Navigați pe Internet
Comment[ru]=Доступ в Интернет
Comment[sk]=Prehliadanie internetu
Comment[sl]=Brskajte po spletu
Comment[sv]=Surfa på webben
Comment[tr]=İnternet'te Gezinin
Comment[ug]=دۇنيادىكى توربەتلەرنى كۆرگىلى بولىدۇ
Comment[uk]=Перегляд сторінок Інтернету
Comment[vi]=Để duyệt các trang web
Comment[zh_CN]=浏览互联网
Comment[zh_TW]=瀏覽網際網路
Exec=waterfox %u
TryExec="${wfxbinpath}"
Terminal=false
Type=Application
Icon="${wfxiconpath}"
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;application/vnd.mozilla.xul+xml;text/mml;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;application/xml;application/rss+xml;application/rdf+xml;image/gif;image/jpeg;image/png;x-scheme-handler/chrome;video/webm;application/x-xpinstall;
StartupNotify=true
X-MuiltpleArgs=false
StartupWMClass=Waterfox
Actions=NewTab;NewWindow;NewPrivateWindow;

[Desktop Action NewTab]
Name=Open new tab
Name[ach]=Yab dirica matidi manyen
Name[af]=Open nuwe oortjie
Name[an]=Ubrir una pestanya nueva
Name[ar]=افتح لسانًا جديدًا
Name[as]=নতুন টেব খোলক
Name[ast]=Abrir llingüeta nueva
Name[az]=Yeni vərəq aç
Name[be]=Адкрыць новую ўстаўку
Name[bg]=Отваряне на нов подпрозорец
Name[bn_BD]=নতুন ট্যাব খুলুন
Name[bn_IN]=নতুন ট্যাব খুলুন
Name[br]=Digeriñ un ivinell nevez
Name[bs]=Otvori novi tab
Name[ca]=Obre una pestanya nova
Name[cs]=Otevřít nový panel
Name[cy]=Agor tab newydd
Name[da]=Åbn nyt faneblad
Name[de]=Neuen Tab öffnen
Name[dsb]=Nowy rejtark wócyniś
Name[el]=Άνοιγμα νέας καρτέλας
Name[eo]=Malfermi novan langeton
Name[es_AR]=Abrir nueva pestaña
Name[es_CL]=Abrir nueva pestaña
Name[es_ES]=Abrir pestaña nueva
Name[es_MX]=Abrir una pestaña nueva
Name[et]=Ava uus kaart
Name[eu]=Ireki fitxa berria
Name[ff]=Uddit tabbere hesere
Name[fi]=Avaa uusi välilehti
Name[fr]=Ouvrir un nouvel onglet
Name[fy_NL]=Iepenje nij ljepblêd
Name[ga_IE]=Oscail i gcluaisín nua
Name[gd]=Fosgail taba ùr
Name[gl]=Abrir unha nova lapela
Name[gu_IN]=નવી ટૅબને ખોલો
Name[he]=פתיחת לשונית חדשה
Name[hi_IN]=नया टैब खोलें
Name[hr]=Otvori novu karticu
Name[hsb]=Nowy rajtark wočinić
Name[hu]=Új lap megnyitása
Name[hy_AM]=Բացել նոր ներդիր
Name[id]=Buka tab baru
Name[is]=Opna nýjan flipa
Name[it]=Apri nuova scheda
Name[ja]=新しいタブ
Name[kk]=Жаңа бетті ашу
Name[kn]=ಹೊಸ ಹಾಳೆಯನ್ನು ತೆರೆ
Name[ko]=새 탭 열기
Name[lij]=Àrvi nêuvo féuggio
Name[lt]=Atverti naują kortelę
Name[mai]=नव टैब खोलू
Name[mk]=Отвори ново јазиче
Name[ml]=പുതിയ റ്റാബ് തുറക്കുക
Name[mr]=नवीन टॅब उघडा
Name[ms]=Buka tab baru
Name[nb_NO]=Åpne ny fane
Name[nl]=Nieuw tabblad openen
Name[nn_NO]=Opna ny fane
Name[or]=ନୂତନ ଟ୍ୟାବ ଖୋଲନ୍ତୁ
Name[pa_IN]=ਨਵੀਂ ਟੈਬ ਖੋਲ੍ਹੋ
Name[pl]=Otwórz nową kartę
Name[pt_BR]=Nova aba
Name[pt_PT]=Abrir novo separador
Name[rm]=Avrir in nov tab
Name[ro]=Deschide o filă nouă
Name[ru]=Открыть новую вкладку
Name[si]=නව ටැබය විවෘත කරන්න
Name[sk]=Otvoriť novú kartu
Name[sl]=Odpri nov zavihek
Name[son]=Nor loku taaga feeri
Name[sq]=Hap skedë të re
Name[sr]=Отвори нови језичак
Name[sv_SE]=Öppna ny flik
Name[ta]=புதிய கீற்றைத் திற
Name[te]=కొత్త టాబ్ తెరువుము
Name[th]=เปิดแท็บใหม่
Name[tr]=Yeni sekme aç
Name[uk]=Відкрити нову вкладку
Name[uz]=Yangi ichki oyna ochish
Name[vi]=Mở thẻ mới
Name[xh]=Vula ithebhu entsha
Name[zh_CN]=打开新标签页
Name[zh_TW]=開啟新分頁
Exec=waterfox -new-tab about:newtab

[Desktop Action NewWindow]
Name=Open new window
Name[ach]=Yab dirica manyen
Name[af]=Open nuwe venster
Name[an]=Ubrir una nueva finestra
Name[ar]=افتح نافذة جديدة
Name[as]=নতুন উইন্ডো খোলক
Name[ast]=Abrir ventana nueva
Name[az]=Yeni pəncərə aç
Name[be]=Адкрыць новае акно
Name[bg]=Отваряне на нов прозорец
Name[bn_BD]=নতুন উইন্ডো খুলুন
Name[bn_IN]=নতুন উইন্ডো খুলুন
Name[br]=Digeriñ ur prenestr nevez
Name[bs]=Otvori novi prozor
Name[ca]=Obre una finestra nova
Name[cs]=Otevřít nové okno
Name[cy]=Agor ffenestr newydd
Name[da]=Åbn nyt vindue
Name[de]=Neues Fenster öffnen
Name[dsb]=Nowe wokno wócyniś
Name[el]=Άνοιγμα νέου παραθύρου
Name[eo]=Malfermi novan fenestron
Name[es_AR]=Abrir nueva ventana
Name[es_CL]=Abrir nueva ventana
Name[es_ES]=Abrir nueva ventana
Name[es_MX]=Abrir nueva ventana
Name[et]=Ava uus aken
Name[eu]=Ireki leiho berria
Name[ff]=Uddit henorde hesere
Name[fi]=Avaa uusi ikkuna
Name[fr]=Ouvrir une nouvelle fenêtre
Name[fy_NL]=Iepenje nij finster
Name[ga_IE]=Oscail fuinneog nua
Name[gd]=Fosgail uinneag ùr
Name[gl]=Abrir unha nova xanela
Name[gu_IN]=નવી વિન્ડોને ખોલો
Name[he]=פתח חלון חדש
Name[hi_IN]=नई विंडो खोलें
Name[hr]=Otvori novi prozor
Name[hsb]=Nowe wokno wočinić
Name[hu]=Új ablak megnyitása
Name[hy_AM]=Բացել նոր պատուհան
Name[id]=Buka jendela baru
Name[is]=Opna nýjan glugga
Name[it]=Apri nuova finestra
Name[ja]=新しいウィンドウ
Name[kk]=Жаңа терезені ашу
Name[kn]=ಹೊಸ ವಿಂಡೊವನ್ನು ತೆರೆ
Name[ko]=새 창 열기
Name[lij]=Àrvi nêuvo barcón
Name[lt]=Atverti naują langą
Name[mai]=नई विंडो खोलू
Name[mk]=Отвори нов прозорец
Name[ml]=പുതിയ ജാലകം തുറക്കുക
Name[mr]=नवीन पटल उघडा
Name[ms]=Buka tetingkap baru
Name[nb_NO]=Åpne nytt vindu
Name[nl]=Een nieuw venster openen
Name[nn_NO]=Opna nytt vindauge
Name[or]=ନୂତନ ୱିଣ୍ଡୋ ଖୋଲନ୍ତୁ
Name[pa_IN]=ਨਵੀਂ ਵਿੰਡੋ ਖੋਲ੍ਹੋ
Name[pl]=Otwórz nowe okno
Name[pt_BR]=Nova janela
Name[pt_PT]=Abrir nova janela
Name[rm]=Avrir ina nova fanestra
Name[ro]=Deschide o nouă fereastră
Name[ru]=Открыть новое окно
Name[si]=නව කවුළුවක් විවෘත කරන්න
Name[sk]=Otvoriť nové okno
Name[sl]=Odpri novo okno
Name[son]=Zanfun taaga feeri
Name[sq]=Hap dritare të re
Name[sr]=Отвори нови прозор
Name[sv_SE]=Öppna nytt fönster
Name[ta]=புதிய சாளரத்தை திற
Name[te]=కొత్త విండో తెరువుము
Name[th]=เปิดหน้าต่างใหม่
Name[tr]=Yeni pencere aç
Name[uk]=Відкрити нове вікно
Name[uz]=Yangi oyna ochish
Name[vi]=Mở cửa sổ mới
Name[xh]=Vula iwindow entsha
Name[zh_CN]=打开新窗口
Name[zh_TW]=開啟新視窗
Exec=waterfox -new-window

[Desktop Action NewPrivateWindow]
Name=New private window
Name[ach]=Dirica manyen me mung
Name[af]=Nuwe privaatvenster
Name[an]=Nueva finestra de navegación privada
Name[ar]=نافذة خاصة جديدة
Name[as]=নতুন ব্যক্তিগত উইন্ডো
Name[ast]=Ventana privada nueva
Name[az]=Yeni məxfi pəncərə
Name[be]=Новае акно адасаблення
Name[bg]=Нов прозорец за поверително сърфиране
Name[bn_BD]=নতুন ব্যক্তিগত উইন্ডো
Name[bn_IN]=নতুন ব্যাক্তিগত উইন্ডো
Name[br]=Prenestr merdeiñ prevez nevez
Name[bs]=Novi privatni prozor
Name[ca]=Finestra privada nova
Name[cs]=Nové anonymní okno
Name[cy]=Ffenestr breifat newydd
Name[da]=Nyt privat vindue
Name[de]=Neues privates Fenster öffnen
Name[dsb]=Nowe priwatne wokno
Name[el]=Νέο παράθυρο ιδιωτικής περιήγησης
Name[eo]=Nova privata fenestro
Name[es_AR]=Nueva ventana privada
Name[es_CL]=Nueva ventana privada
Name[es_ES]=Nueva ventana privada
Name[es_MX]=Nueva ventana privada
Name[et]=Uus privaatne aken
Name[eu]=Leiho pribatu berria
Name[ff]=Henorde suturo hesere
Name[fi]=Uusi yksityinen ikkuna
Name[fr]=Nouvelle fenêtre de navigation privée
Name[fy_NL]=Nij priveefinster
Name[ga_IE]=Fuinneog nua phríobháideach
Name[gd]=Uinneag phrìobhaideach ùr
Name[gl]=Nova xanela privada
Name[gu_IN]=નવી ખાનગી વિન્ડો
Name[he]=חלון פרטי חדש
Name[hi_IN]=नया निजी विंडो
Name[hr]=Novi privatni prozor
Name[hsb]=Nowe priwatne wokno
Name[hu]=Új privát ablak
Name[hy_AM]=Գաղտնի դիտարկում
Name[id]=Jendela mode pribadi baru
Name[is]=Nýr einkagluggi
Name[it]=Nuova finestra anonima
Name[ja]=新しいプライベートウィンドウ
Name[kk]=Жаңа жекелік терезе
Name[kn]=ಹೊಸ ಖಾಸಗಿ ಕಿಟಕಿ
Name[ko]=새 사생활 보호 창
Name[lij]=Nêuvo barcón privòu
Name[lt]=Atverti privačiojo naršymo langą
Name[mai]=नव निज विंडो
Name[mk]=Нов прозорец за приватно сурфање
Name[ml]=പുതിയ സ്വകാര്യ ജാലകം
Name[mr]=नवीन वैयक्तिक पटल
Name[ms]=Tetingkap peribadi baharu
Name[nb_NO]=Nytt privat vindu
Name[nl]=Nieuw privévenster
Name[nn_NO]=Nytt privat vindauge
Name[or]=ନୂତନ ବ୍ୟକ୍ତିଗତ ୱିଣ୍ଡୋ
Name[pa_IN]=ਨਵੀਂ ਪ੍ਰਾਈਵੇਟ ਵਿੰਡੋ
Name[pl]=Nowe okno w trybie prywatnym
Name[pt_BR]=Nova janela privativa
Name[pt_PT]=Nova janela privada
Name[rm]=Nova fanestra privata
Name[ro]=Fereastră fără urme nouă
Name[ru]=Новое приватное окно
Name[si]=නව පුද්ගලික කවුළුව
Name[sk]=Nové okno v režime Súkromné prehliadanie
Name[sl]=Novo zasebno okno
Name[son]=Sutura zanfun taaga
Name[sq]=Dritare e re private
Name[sr]=Нови приватни прозор
Name[sv_SE]=Nytt privat fönster
Name[ta]=புதிய தனிப்பட்ட சாளரம்
Name[te]=కొత్త ఆంతరంగిక విండో
Name[th]=หน้าต่างท่องเว็บแบบส่วนตัวใหม่
Name[tr]=Yeni gizli pencere
Name[uk]=Нове приватне вікно
Name[uz]=Yangi shaxsiy oyna
Name[vi]=Cửa sổ riêng tư mới
Name[xh]=Ifestile yangasese entsha
Name[zh_CN]=新建隐私浏览窗口
Name[zh_TW]=新增隱私視窗
Exec=waterfox -private-window
WFOXDESKTOP
    else
        printf "\n The waterfox.desktop file already exists!\n"
    fi
}

function wfx_create_bin_file() {
    # Creates a executable file in /usr/bin/
    if [[ ! -f "${wfxusrbinpath}" ]];then
        printf "%s\n" "Creating the waterfox.desktop file..."
        \tee --ignore-interrupts "${wfxusrbinpath}" <<'WFOXUSRBIN'
  #!/usr/bin/bash
  #
  # This file is an quick adaptation of the Fedora's version of /usr/bin/firefox file created by DNF
  # package manager during the installation process
  #
  #
  # The contents of this file are subject to the Netscape Public
  # License Version 1.1 (the "License"); you may not use this file
  # except in compliance with the License. You may obtain a copy of
  # the License at http://www.mozilla.org/NPL/
  #
  # Software distributed under the License is distributed on an "AS
  # IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
  # implied. See the License for the specific language governing
  # rights and limitations under the License.
  #
  # The Original Code is mozilla.org code.
  #
  # The Initial Developer of the Original Code is Netscape
  # Communications Corporation.  Portions created by Netscape are
  # Copyright (C) 1998 Netscape Communications Corporation. All
  # Rights Reserved.
  #
  # Contributor(s):
  #
  ##
  ## Usage:
  ##
  ## $ waterfox
  ##
  ## This script is meant to run a mozilla program from the mozilla
  ## rpm installation.
  ##
  ## The script will setup all the environment voodoo needed to make
  ## mozilla work.

  cmdname=`basename $0`

  ##
  ## Variables
  ##
  WFX_ARCH=$(uname -m)
  case $WFX_ARCH in
    x86_64 | s390x | sparc64)
      WFX_LIB_DIR="/usr/lib64"
      SECONDARY_LIB_DIR="/usr/lib"
      ;;
    * )
      WFX_LIB_DIR="/usr/lib"
      SECONDARY_LIB_DIR="/usr/lib64"
      ;;
  esac

  WFX_WATERFOX_FILE="waterfox"

  if [ ! -r $WFX_LIB_DIR/waterfox/$WFX_WATERFOX_FILE ]; then
    if [ ! -r $SECONDARY_LIB_DIR/waterfox/$WFX_WATERFOX_FILE ]; then
      echo "Error: $WFX_LIB_DIR/waterfox/$WFX_WATERFOX_FILE not found"
      if [ -d $SECONDARY_LIB_DIR ]; then
        echo "       $SECONDARY_LIB_DIR/waterfox/$WFX_WATERFOX_FILE not found"
      fi
      exit 1
    fi
    WFX_LIB_DIR="$SECONDARY_LIB_DIR"
  fi
  WFX_DIST_BIN="$WFX_LIB_DIR/waterfox"
  WFX_LANGPACKS_DIR="$WFX_DIST_BIN/langpacks"
  WFX_EXTENSIONS_PROFILE_DIR="$HOME/.waterfox/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
  WFX_PROGRAM="$WFX_DIST_BIN/$WFX_WATERFOX_FILE"
  WFX_LAUNCHER="$WFX_DIST_BIN/run-mozilla.sh"

  ##
  ## Enable Wayland backend?
  ##
  if false && ! [ $WFX_DISABLE_WAYLAND ]; then
    if [ "$XDG_CURRENT_DESKTOP" == "GNOME" ]; then
      export WFX_ENABLE_WAYLAND=1
    fi
  fi

  ##
  ## Set WFX_GRE_CONF
  ##
  WFX_GRE_CONF=/etc/gre.d/gre.conf
  if [ "$WFX_LIB_DIR" == "/usr/lib64" ]; then
    WFX_GRE_CONF=/etc/gre.d/gre64.conf
  fi
  export WFX_GRE_CONF

  ##
  ## Set WFX_HOME
  ##
  WFX_HOME="$WFX_DIST_BIN"

  export WFX_HOME

  ##
  ## Make sure that we set the plugin path
  ##
  WFX_PLUGIN_DIR="plugins"

  if [ "$WFX_PLUGIN_PATH" ]
  then
    WFX_PLUGIN_PATH=$WFX_PLUGIN_PATH:$WFX_LIB_DIR/mozilla/$WFX_PLUGIN_DIR:$WFX_DIST_BIN/$WFX_PLUGIN_DIR
  else
    WFX_PLUGIN_PATH=$WFX_LIB_DIR/mozilla/$WFX_PLUGIN_DIR:$WFX_DIST_BIN/$WFX_PLUGIN_DIR
  fi
  export WFX_PLUGIN_PATH

  ##
  ## Set WFX_APP_LAUNCHER for gnome-session
  ##
  export WFX_APP_LAUNCHER="/usr/bin/waterfox"

  ##
  ## Set FONTCONFIG_PATH for Xft/fontconfig
  ##
  FONTCONFIG_PATH="/etc/fonts:${WFX_HOME}/res/Xft"
  export FONTCONFIG_PATH

  ##
  ## In order to better support certain scripts (such as Indic and some CJK
  ## scripts), Fedora builds its Firefox, with permission from the Mozilla
  ## Corporation, with the Pango system as its text renderer.  This change
  ## may negatively impact performance on some pages.  To disable the use of
  ## Pango, set WFX_DISABLE_PANGO=1 in your environment before launching
  ## Firefox.
  ##
  #
  # WFX_DISABLE_PANGO=1
  # export WFX_DISABLE_PANGO
  #

  ##
  ## Disable the GNOME crash dialog, Moz has it's own
  ##
  GNOME_DISABLE_CRASH_DIALOG=1
  export GNOME_DISABLE_CRASH_DIALOG

  ##
  ## Disable the SLICE allocator (rhbz#1014858)
  ##
  export G_SLICE=always-malloc

  ##
  ## Enable Xinput2 (mozbz#1207973)
  ##
  export WFX_USE_XINPUT2=1

  # OK, here's where all the real work gets done


  ##
  ## To disable the use of Waterox localization, set WFX_DISABLE_LANGPACKS=1
  ## in your environment before launching Waterfox.
  ##
  #
  # WFX_DISABLE_LANGPACKS=1
  # export WFX_DISABLE_LANGPACKS
  #

  ##
  ## Automatically installed langpacks are tracked by .fedora-langpack-install
  ## config file.
  ##
  FEDORA_LANGPACK_CONFIG="$WFX_EXTENSIONS_PROFILE_DIR/.fedora-langpack-install"

  # WFX_DISABLE_LANGPACKS disables language packs completely
  WATERFOX_DOWN=0
  if ! [ $WFX_DISABLE_LANGPACKS ] || [ $WFX_DISABLE_LANGPACKS -eq 0 ]; then
    if [ -x $WFX_DIST_BIN/$WFX_WATERFOX_FILE ]; then
      # Is waterfox running?
      /usr/bin/pidof waterfox > /dev/null 2>&1
      WATERFOX_DOWN=$?
    fi
  fi

  # Modify language pack configuration only when waterfox is not running
  # and language packs are not disabled
  if [ $WATERFOX_DOWN -ne 0 ]; then

    # Clear already installed langpacks
    mkdir -p $WFX_EXTENSIONS_PROFILE_DIR
    if [ -f $FEDORA_LANGPACK_CONFIG ]; then
      rm `cat $FEDORA_LANGPACK_CONFIG` > /dev/null 2>&1
      rm $FEDORA_LANGPACK_CONFIG > /dev/null 2>&1
      # remove all empty langpacks dirs while they block installation of langpacks
      rmdir $WFX_EXTENSIONS_PROFILE_DIR/langpack* > /dev/null 2>&1
    fi

    # Get locale from system
    CURRENT_LOCALE=$LC_ALL
    CURRENT_LOCALE=${CURRENT_LOCALE:-$LC_MESSAGES}
    CURRENT_LOCALE=${CURRENT_LOCALE:-$LANG}

    # Try with a local variant first, then without a local variant
    SHORTMOZLOCALE=`echo $CURRENT_LOCALE | sed "s|_\([^.]*\).*||g" | sed "s|\..*||g"`
    MOZLOCALE=`echo $CURRENT_LOCALE | sed "s|_\([^.]*\).*|-\1|g" | sed "s|\..*||g"`

    function create_langpack_link() {
      local language=$*
      local langpack=langpack-${language}@waterfox.waterfox.org.xpi
      if [ -f $WFX_LANGPACKS_DIR/$langpack ]; then
        rm -rf $WFX_EXTENSIONS_PROFILE_DIR/$langpack
        # If the target file is a symlink (the fallback langpack),
        # install the original file instead of the fallback one
        if [ -h $WFX_LANGPACKS_DIR/$langpack ]; then
          langpack=`readlink $WFX_LANGPACKS_DIR/$langpack`
        fi
        ln -s $WFX_LANGPACKS_DIR/$langpack \
          $WFX_EXTENSIONS_PROFILE_DIR/$langpack
        echo $WFX_EXTENSIONS_PROFILE_DIR/$langpack > $FEDORA_LANGPACK_CONFIG
        return 0
      fi
      return 1
    }

    create_langpack_link $MOZLOCALE || create_langpack_link $SHORTMOZLOCALE || true
  fi

  # BEAST fix (rhbz#1005611)
  NSS_SSL_CBC_RANDOM_IV=${NSS_SSL_CBC_RANDOM_IV-1}
  export NSS_SSL_CBC_RANDOM_IV

  # Prepare command line arguments
  script_args=""
  pass_arg_count=0
  while [ $# -gt $pass_arg_count ]
  do
    case "$1" in
      -g | --debug)
        script_args="$script_args -g"
        debugging=1
        shift
        ;;
      -d | --debugger)
        if [ $# -gt 1 ]; then
          script_args="$script_args -d $2"
          shift 2
        else
          shift
        fi
        ;;
      *)
        # Move the unrecognized argument to the end of the list.
        arg="$1"
        shift
        set -- "$@" "$arg"
        pass_arg_count=`expr $pass_arg_count + 1`
        ;;
    esac
  done

  # Run the browser
  debugging=0
  if [ $debugging = 1 ]
  then
    echo $WFX_LAUNCHER $script_args $WFX_PROGRAM "$@"
  fi

  exec $WFX_LAUNCHER $script_args $WFX_PROGRAM "$@"
WFOXUSRBIN
    else
        printf "\n%s already exists!" "${wfxusrbinpath}"
    fi
}

function wfx_iconic_figures() {
    # Creates symbolic links to the icons based on hawkeye116477 https://github.com/hawkeye116477/install-waterfox-linux
    local wfxicons
    local wfxiconsize
    local wfxsysicons
    wfxicons="/opt/waterfox/browser/chrome/icons/default/"

    \ln --symbolic --force /opt/waterfox/browser/icons/mozicon128.png /usr/share/pixmaps/waterfox.png
    # for wfxiconsize in $(\ls -1 "${wfxicons}" | \awk --sandbox --field-separator='[^0-9]*' '{print $2}')
    for wfxiconsize in $(\find "${wfxicons}" -maxdepth 1 -printf "\n%f" | \awk --sandbox --field-separator='[^0-9]*' '{print $2}')
    do
        wfxsysicons="/usr/share/icons/hicolor/${wfxiconsize:-0}x${wfxiconsize:-0}/apps/waterfox.png"
        \ln --symbolic --force "${wfxicons:-0}"default"${wfxiconsize:-0}".png "${wfxsysicons:-0}"
    done
    \ln --symbolic --force /opt/waterfox/browser/icons/mozicon128.png /usr/share/icons/hicolor/128x128/apps/waterfox.png
}

function wfx_keep_it() {
    # Copies the downloaded file from /tmp/ to ~/Downloads/
    local wfxkeepfolder
    wfxkeepfolder="$HOME/Downloads/Waterfox/"
    mkdir --parents --verbose "${wfxkeepfolder}"
    cp --archive --verbose --one-file-system "${tmpdir}" "${wfxkeepfolder}"
}

function wfx_menu() {
    select yn in "Install" "AppImage" "Update" "Uninstall" "Quit"; do
        case "${yn}" in
            Install )
                break ;;
            AppImage )
                break ;;
            Update )
                break ;;
            Uninstall )
                break ;;
            "Quit" )
                printf "%s" "If I’m not back in five minutes, just wait longer."
                exit 0; break ;;
        esac
    done
}

function main() {
    # trap exit_stage_left EXIT ERR # Elegant exit
    check_sudo
    #wfx_version_check
    #if [[ "$(wfx_version_check)" ]];then
    #        printf "Latest version already installed. %s" "$(wfx_version_local)"
    #        exit 1
    #    else
    # Put the funcnions here
    # Calling functions
    wfx_menu
    wfx_change_directory
    wfx_is_it_running
    #wfx_do_not_kill_the_messenger "Waterfox Download and Installation Script" "$(wfx_file)" "has been downloaded successfuly"
    #wfx_get_the_drowned_fox "${wfxurl}" c
    #wfx_extract_it
    #create_desktop_file
    #wfx_create_bin_file
    #wfx_iconic_figures
    #wfx_symbolic_lnk
    printf "Page cache\n"
    wfx_cache_page
    wfx_draw_appimage
    wfx_draw_url "releases"
    # wfx_check_existence
    # wfx_cache_page "$(wfx_draw_url releases)"
    # wfx_stable_or_development s
    # err_msg "sdf"
    #    fi
}
#}}} End Functions
#{{{ Ignition
main "${@}"
#}}} End Ignition
