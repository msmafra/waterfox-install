#!/usr/bin/env bash
#
# =============================================================================
#  ------------------------------------------------------------------
# Waterfox Installation Script for the Production version
#  ------------------------------------------------------------------
#
# Author: Marcelo dos Santos Mafra
# License: GNU v3
# Version 0.9.7
# Created: 2019
#
# <https://forum.level1techs.com/u/msmafra>
# <https://stackoverflow.com/users/473433/msmafra>
# <https://www.reddit.com/user/msmafra/>
# <https://github.com/msmafra>
#
# Just installation here. SORRY! Uninstallation is a separated file.
# =============================================================================
#
set -o errexit
set -o errtrace
set -o nounset
set -o pipefail
#set -o xtrace
## Variables ##
# The url of the download page
readonly wfxpage="https://www.waterfox.net/releases/"
# Gets the URL from the download page
readonly wfxurl=$(\wget --quiet --output-document=- "${wfxpage}" | \grep --extended-regexp --only-matching "(http|https)://[a-zA-Z0-9./?=_-]*" | \sort --unique | \grep --max-count=1 ".bz2")
# Gets the file name from the URL
readonly wfxfile=$(printf "%s" "${wfxurl}" | \awk --field-separator "/" '{print $8}' | \tr --delete "\n")
# Install destination
readonly wfxdest="/usr/lib64/"
# Symbolic link to main executable
readonly wfxexec="/usr/bin/waterfox"
# Desktop entry file
readonly wfxdesktop="/usr/share/applications/waterfox.desktop"
# Main executable
readonly wfxbinpath="/usr/lib64/waterfox/waterfox"
# Executable with a flag to enable high resolution screens
readonly wfx_desktop_exec="env MOZ_ENABLE_WAYLAND=1 waterfox"
# Desktop entry default icon. Available: default16.png  default22.png  default24.png  default256.png  default32.png  default48.png
readonly wfxiconpath="/usr/lib64/waterfox/browser/chrome/icons/default/default256.png"
# Change to /tmp/ to automatically remove file or folders
readonly tmpdir="/tmp/"
## Functions ##
function wfx_available_versions() {

    # Gets the available versions
    local wfxver
    # Gets the production version of Waterfox from waterfox.net
    wfxver="$(\wget --quiet --output-document=- "${wfxpage}" | \grep --extended-regexp --only-matching "(http|https)://[a-zA-Z0-9./?=_-]*" |
    \grep --max-count=1 ".bz2" | \sort --unique | \awk --field-separator "/" '{print $8}' | \awk --field-separator "-" '{printf "%s %s\n", $2, $3}' |
    \awk '{print substr($0,1,15)}')"
    printf "%s" "${wfxver}"
    unset wfxver

}

function wfx_check_local_version() {
    local wfxwhere
    local message
    local wfxlver
    message="No installed version found in %s ${wfxdest}\n"
    # Obtains the local installed version if there is one
    wfxwhere=$( [[ -f "${wfxexec}" ]] && printf true || printf "" )
    if [[ "${wfxwhere}" ]];then
        wfxlver=$( "${wfxbinpath}" --version | \grep -F "WaterfoxLimited " | \awk '{printf "%s", $3}' )
        printf "The version %s of Waterfox is installed at %s" "${wfxlver}" "${wfxdest}"
    else
        printf "Waterfox is not installed on your system."
    fi

}

function wfx_get_the_drowned_fox() {

    local wfxfcheck
    # Downloads the .tar.bz2 file. Firstly, checks if file exists remotely. If file is not there or yet available to download (happened on version 56.2.10 release) exits
    wfxfcheck=$( \wget --spider --show-progress --quiet --server-response "${wfxurl}" 2>&1 | \head --lines=1 | \awk 'NR==1{print $2}' )
    if [[ ! "${wfxfcheck}" = "200" ]];then
        printf "\nNo file is available for downloading! Or some other error. Leaving...\n"
        exit 1
    else
        # If the file is there, it starts the download
        printf "\nStarting the download...\n"
        \wget --show-progress --continue "${wfxurl}"
    fi

}

function wfx_extract_it() {

    # Extracts the .tar.bz2 file to /tmp/ creating the subfolder named waterfox.
    # Next copies the resulting folder to /usr/lib64/
    if [[ -d "${tmpdir}waterfox/" ]];then
        printf "\nDeleting: %s" "${tmpdir}waterfox/"
        \rm --recursive --force "${tmpdir}waterfox/"
    fi
    printf "\nExtracting: %s to %s" "${wfxfile}" "${tmpdir}"
    \mkdir -p "${tmpdir}waterfox"
    \tar --extract --verbose --file "${wfxfile}" --directory="${tmpdir}waterfox/"
    
    printf "\nCopying %s to %s" "${wfxfile}" "${wfxdest}"
    \cp --recursive --force --update --verbose "${tmpdir}waterfox/" "${wfxdest}"

}

function wfx_create_desktop_file() {

    # Creates the waterfox.desktop file to be accessed system wide. If there is nothing already there, create one
    if [[ ! -f "${wfxdesktop}" ]];then
        printf "\nCreating the waterfox.desktop file...\n"
        \tee --ignore-interrupts "${wfxdesktop}" <<WFOX
[Desktop Entry]
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
Exec=${wfx_desktop_exec} %u
TryExec=${wfxbinpath}
Terminal=false
Type=Application
Icon=${wfxiconpath}
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;application/vnd.mozilla.xul+xml;text/mml;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;
StartupNotify=true
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
Exec=${wfx_desktop_exec} -new-tab about:newtab

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
Exec=${wfx_desktop_exec} -new-window

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
Exec=${wfx_desktop_exec} -private-window
WFOX
    else
        printf "\n The waterfox.desktop file already exists!\n"
    fi

}

function wfx_create_symbolic_link() {

    # Creates the symbolic for the main executable on /usr/bin
    if [[ ! -f "${wfxexec}" ]];then
        printf "\nCreating the symbolic link...\n"
        \ln --symbolic --verbose --force "${wfxbinpath}" "${wfxexec}"
    else
        printf "\nExecutable file is already there!\n"
    fi

}

function wfx_change_directory() {

    # Change to /tmp so the downloaded file will be automatically deleted after restart or shutdown
    printf "\nEntering %s...\n" "${tmpdir}"
    cd "${tmpdir}" && \pwd

}
## Calls ##
printf "%s\n" "This will download and install only the classic branch."
printf "%s\n" "Waterfox $(wfx_available_versions)"
wfx_change_directory
wfx_check_local_version
wfx_get_the_drowned_fox
wfx_extract_it
wfx_create_desktop_file
wfx_create_symbolic_link
printf "%s\n" "Installation process finished. Waterfox $(wfx_available_versions) is installed"
