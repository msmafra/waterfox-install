#!/bin/bash
# Waterfox Installation Script (just install. Sorry!)
# Version 0.7.5
# Downloads it to /tmp, extracts it to /usr/lib64/, creates waterfox.desktop file in /usr/share/applications/ a symbolic link in /usr/bin pointing to /usr/lib64/waterfox/waterfox
#
# The url from the download page
WFXPAGE="https://www.waterfox.net/releases/" # Most recent download links page
WFXURL=$(wget -qO- $WFXPAGE | grep -Eo "(http|https)://[a-zA-Z0-9./?=_-]*" | sort | uniq | grep -m 1 ".bz2") # Get the URL from the releases page
WFXFILE="$(echo "$WFXURL" | awk  -F "/" '{print $7}' | tr -d "\n")" # Get the file name from the URL
WFXDEST="/usr/lib64/" # Install destination
WFXEXEC="/usr/bin/waterfox" # Symbolic link to main executable
WFXDESKTOP="/usr/share/applications/waterfox.desktop"
WFXBINPATH="/usr/lib64/waterfox/waterfox" # Main executable
TMPDIR="/tmp" # Change to tmp to automatically remove file or folders

# Obtains the most recent downloadable version
function getAvailableWFXVersion() {

  # Gets the production version of Waterfox from waterfox.net. Comment this to be able to download the testing verions
  WFXVER="$(\wget -qO- $WFXPAGE | grep -Eo "(http|https)://[a-zA-Z0-9./?=_-]*" | sort | uniq | grep -m 1 ".bz2" | awk -v FS="/" '{print $7}' | awk -F"-" '{print $2}' | awk -F"." '{printf "Available Waterfox version %s.%s.%s\n", $1,$2,$3}')"
  echo $WFXVER

}

# Obtains the local installed version if there is one
function getLocalWFXVersion() {

  WFXWHERE=$( \whereis -b waterfox | awk '$2 != "" {print true}' | tr -d "\n" )

  if [[ -n $WFXWHERE  ]];then
    WFXLVER=$(\waterfox --version | awk -F'[^0-9]*' '{printf("%s.%s.%s", $2,$3,$4)}' | awk -F"." '{printf "%s.%s.%s", $1,$2,$3}' | tr " " "\n" )
    echo $WFXLVER
    sleep 2s
  else
    echo -e "\nNo installed version found\n"
    sleep 2s
  fi

}

# Downloads the .tar.bz2 file
function getTheDrownedFox() {

  # Check if file exists
  WFXFCHECK=$(\wget --spider --show-progress -qS $WFXURL 2>&1 | head -n 1 | awk 'NR==1{print $2}')
  # If file is not there exits\
    # If the file is not yet available to download (happened on version 56.2.10)
  if [[ ! "${WFXFCHECK}" = "200" ]];then
    echo -e "\nNo file found! or another error Leaving...\n"
    exit 1
  else
    # If the file is there starts the download
    echo -e "\nStarting the download...\n"
    \wget --show-progress -t 5 -T 10 -w 5 --waitretry=15 -c $WFXURL

  fi

}

# Extract the .tar.bz2 file to /usr/lib64/ creating the subfolder named waterfox
function extractIt() {

  echo -e "\nExtracting ...\n"
  echo $WFXFILE
  tar -xvf $WFXFILE -C $WFXDEST

}

# Creates the waterfox.desktop file to be accessed system wide
function createDesktopFile() {

  # If there is not already a file there, create one
  if [ ! -f "$WFXDESKTOP" ]; then
    echo -e "\nCreating the waterfox.desktop file...\n"
    # waterfox.desktop is taken from AUR : waterfox-bin.git https://aur.archlinux.org/cgit/aur.git/plain/waterfox.desktop?h=waterfox-bin
    tee -i $WFXDESKTOP <<WFOX
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
Exec=waterfox %u
TryExec=$WFXBINPATH
Terminal=false
Type=Application
Icon=/usr/lib64/waterfox/browser/chrome/icons/default/default256.png
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
WFOX
  else
    echo -e "\n The waterfox.desktop file already exists!"
  fi

}

# Creates the symbolic for the main executable on /usr/bin
function symbolicWFX() {

  if [ ! -f "$WFXEXEC" ]; then
    echo -e "\nCreating the symbolic link...\n"
    ln -sv /usr/lib64/waterfox/waterfox /usr/bin/waterfox
  else
    echo -e "\nExecutable file is already there!\n"
  fi

}

# Change to /tmp so the downloaded file will be automatically deleted after restart or shutdown
echo -e "\nEntering /tmp...\n"
cd "$TMPDIR" && pwd

getLocalWFXVersion
getAvailableWFXVersion
getTheDrownedFox
extractIt
createDesktopFile
symbolicWFX
