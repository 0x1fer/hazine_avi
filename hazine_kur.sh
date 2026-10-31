#!/usr/bin/env bash
# hazine_kur.sh — Linux 101 "Boss" görevi: Hazine avı ortamını kurar.
#
# Kullanım:
#   bash hazine_kur.sh            # ~/hazine altına kurar
#   bash hazine_kur.sh -f         # varsa eskisini silip yeniden kurar
#
# Kullanılan konular: ls -a, cd (göreli/mutlak yol), cat, head, tail

set -euo pipefail

HEDEF="${HOME}/hazine"

# Bayrak parçaları base64 ile saklanır; script'e göz atan biri hemen görmesin diye.
# Kendi bayrağını koymak için: echo -n 'SGK{yeni_' | base64
PARCA1_B64="U0dLe2wxbnV4Xw=="   # SGK{l1nux_
PARCA2_B64="eTBsY3VzdX0="       # y0lcusu}

# Bayrak parçalarının satır numaraları (dosyalar 500 ve 300 satır)
PARCA1_SATIR=237   # arsiv/log.txt
PARCA2_SATIR=88    # arsiv/rapor.txt

# --- Argüman kontrolü ---------------------------------------------------------
if [[ -d "$HEDEF" ]]; then
    if [[ "${1:-}" == "-f" ]]; then
        rm -rf -- "$HEDEF"
    else
        echo "Hata: $HEDEF zaten var. Yeniden kurmak için: bash $0 -f" >&2
        exit 1
    fi
fi

parca1="$(echo "$PARCA1_B64" | base64 -d)"
parca2="$(echo "$PARCA2_B64" | base64 -d)"

# --- Yardımcı: sahte log satırları üretir -------------------------------------
# $1 = satır sayısı
sahte_log() {
    local seviyeler=("INFO" "INFO" "INFO" "DEBUG" "WARN" "ERROR")
    local mesajlar=(
        "kullanici oturum acti"
        "yedekleme tamamlandi"
        "baglanti zaman asimina ugradi"
        "disk kullanimi %87"
        "servis yeniden baslatildi"
        "yapilandirma dosyasi okundu"
        "gecersiz parola denemesi"
        "cron gorevi calisti"
    )
    local i
    for ((i = 1; i <= $1; i++)); do
        printf '2026-10-%02d %02d:%02d:%02d [%s] %s\n' \
            $((RANDOM % 28 + 1)) $((RANDOM % 24)) $((RANDOM % 60)) $((RANDOM % 60)) \
            "${seviyeler[RANDOM % ${#seviyeler[@]}]}" \
            "${mesajlar[RANDOM % ${#mesajlar[@]}]}"
    done
}

# --- Klasör yapısı ------------------------------------------------------------
GERCEK_ODA="$HEDEF/kapi1/kapi2/.gizli oda"   # adında boşluk var: tırnak veya \ gerektirir

mkdir -p "$HEDEF"/{buraya_bakma,kapi1/kapi3/bos/daha_bos,arsiv}
mkdir -p "$GERCEK_ODA"
# kapi2 içindeki sahte odalar (hepsinin adında alt çizgi var, gerçeğinde yok)
mkdir -p "$HEDEF"/kapi1/kapi2/{.gizli_oda,.eski_oda,oda_1,oda_2/kilitli_dolap,hazine_odasi}

# Başlangıç noktası
cat > "$HEDEF/BENI_OKU.txt" << 'EOF'
=== HAZINE AVI ===
Bayrak iki parcadan olusuyor. Ikisini birlestiren kazanir.

Ilk ipucu kapi1 klasorunun icinde.
Ama dikkat: her sey gozle gorulmuyor.
EOF

# Tuzak 1: yanıltıcı klasör
cat > "$HEDEF/buraya_bakma/bayrak.txt" << 'EOF'
Tebrikler! Bayrak: SGK{bu_sahte_bir_bayrak}

...sence bu kadar kolay olur muydu? Basa don.
EOF

# kapi1: gizli ipucu dosyası
cat > "$HEDEF/kapi1/.ipucu" << 'EOF'
Iyi gidiyorsun, gizli dosyayi buldun.
Siradaki adim kapi2'de. Orada bircok oda var ama sadece biri gercek.
EOF

# Tuzak 2: boş klasörler zinciri
cat > "$HEDEF/kapi1/kapi3/bos/daha_bos/not.txt" << 'EOF'
Burasi cikmaz sokak. Bir ust dizine degil, bastan dusun.
EOF

# --- kapi2: sahte odalar --------------------------------------------------------
K2="$HEDEF/kapi1/kapi2"

# Tuzak 4: gerçeğine en çok benzeyen sahte oda, yanlış haritayla
cat > "$K2/.gizli_oda/harita.txt" << 'EOF'
Gizli odayi buldun!

PARCA 1: ../../../arsiv/eski_log.txt dosyasinin SON 2 satirinda.
PARCA 2: ../hazine_odasi/bayrak.txt dosyasinin ILK satirinda.
EOF

cat > "$K2/.eski_oda/.not" << 'EOF'
Bu oda yillar once terk edildi. Haritayi tasidilar.
EOF

cat > "$K2/oda_1/not.txt" << 'EOF'
Bos bir oda. Burada hicbir sey yok.
EOF

cat > "$K2/oda_2/kilitli_dolap/not.txt" << 'EOF'
Dolabin kilidi kirik, icerisi bos. Biri senden once gelmis.
EOF

cat > "$K2/hazine_odasi/bayrak.txt" << 'EOF'
Bayrak: SGK{neredeyse_buldun}

Hazine odasi bu kadar acikta olur mu sence?
EOF

# Gerçek oda: ".gizli oda" (boşluklu). Asıl yönlendirme, göreli yol gerektirir
cat > "$GERCEK_ODA/harita.txt" << EOF
Gizli odayi buldun!

PARCA 1: ../../../arsiv/log.txt dosyasinin ${PARCA1_SATIR}. satirinda.
PARCA 2: ayni klasordeki rapor.txt dosyasinin ${PARCA2_SATIR}. satirinda.

Ipucu: dosyalar uzun. cat ile ekran dolar, baska yolu var.
EOF

# arsiv/log.txt: 500 satır, bayrağın 1. parçası PARCA1_SATIR. satırda
{
    sahte_log $((PARCA1_SATIR - 1))
    echo "2026-10-17 14:52:09 [FLAG] PARCA_1 = ${parca1}"
    sahte_log $((500 - PARCA1_SATIR))
} > "$HEDEF/arsiv/log.txt"

# arsiv/rapor.txt: 300 satır, bayrağın 2. parçası PARCA2_SATIR. satırda
{
    sahte_log $((PARCA2_SATIR - 1))
    echo "2026-10-09 08:15:44 [FLAG] PARCA_2 = ${parca2}"
    sahte_log $((300 - PARCA2_SATIR))
} > "$HEDEF/arsiv/rapor.txt"

# Tuzak 3: eski log, sahte parça son satırda
{
    sahte_log 200
    echo "2025-01-01 00:00:00 [FLAG] PARCA_1 = SGK{eski_surum_"
    echo "Bu dosya artik kullanilmiyor."
} > "$HEDEF/arsiv/eski_log.txt"

echo "Hazine avi hazir: $HEDEF"
echo "Baslamak icin: cd ~/hazine && ls"
