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
PARCA1_B64="U0dLe2wxbnV4Xw=="
PARCA2_B64="eTBsY3VzdX0="

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
mkdir -p "$HEDEF"/{buraya_bakma,kapi1/kapi2/.gizli_oda,kapi1/kapi3/bos/daha_bos,arsiv}

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
Siradaki adim kapi2'de. Orada da bir oda var ama kapisi gizli.
EOF

# Tuzak 2: boş klasörler zinciri
cat > "$HEDEF/kapi1/kapi3/bos/daha_bos/not.txt" << 'EOF'
Burasi cikmaz sokak. Bir ust dizine degil, bastan dusun.
EOF

# kapi2/.gizli_oda: asıl yönlendirme (göreli yol gerektirir)
cat > "$HEDEF/kapi1/kapi2/.gizli_oda/harita.txt" << 'EOF'
Gizli odayi buldun!

PARCA 1: arsiv/log.txt dosyasinin EN SON satirinda.
PARCA 2: arsiv klasorundeki rapor.txt dosyasinin EN ILK satirinda.

Ipucu: dosyalar uzun. cat ile ekran dolar, baska yolu var.
EOF

# arsiv/log.txt: 500 satır, bayrağın 1. parçası son satırda
{
    sahte_log 499
    echo "2026-10-30 23:59:59 [FLAG] PARCA_1 = ${parca1}"
} > "$HEDEF/arsiv/log.txt"

# arsiv/rapor.txt: bayrağın 2. parçası ilk satırda
{
    echo "PARCA_2 = ${parca2}"
    sahte_log 300
} > "$HEDEF/arsiv/rapor.txt"

# Tuzak 3: eski log, sahte parça son satırda
{
    sahte_log 200
    echo "2025-01-01 00:00:00 [FLAG] PARCA_1 = SGK{eski_surum_"
    echo "Bu dosya artik kullanilmiyor."
} > "$HEDEF/arsiv/eski_log.txt"

echo "Hazine avi hazir: $HEDEF"
echo "Baslamak icin: cd ~/hazine && ls"
