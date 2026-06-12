#!/bin/bash

# ============================================================
# SCRIPT: Menjalankan Golden Tests - Tsiqahub UI
# ============================================================
# 
# Penggunaan:
#   ./run_golden_tests.sh [option]
#
# Options:
#   all          - Jalankan semua golden tests (default)
#   auth         - Test layar autentikasi saja
#   main         - Test layar utama saja
#   chat         - Test layar chat saja
#   admin        - Test admin & feedback saja
#   security     - Test security screens saja
#   additional   - Test layar tambahan saja
#   update       - Update semua golden baseline
#   verify       - Verifikasi tanpa update (check only)
#   help         - Tampilkan bantuan
#
# Contoh:
#   ./run_golden_tests.sh all
#   ./run_golden_tests.sh auth
#   ./run_golden_tests.sh update
#   ./run_golden_tests.sh verify
#
# ============================================================

set -e

# Warna untuk output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Directory script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_DIR="$SCRIPT_DIR/test"

# Fungsi bantuan
show_help() {
    echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║   📸 Golden Test Runner - Tsiqahub UI                   ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Penggunaan:${NC}"
    echo "  ./run_golden_tests.sh [option]"
    echo ""
    echo -e "${YELLOW}Options:${NC}"
    echo "  all          Jalankan semua golden tests (default)"
    echo "  auth         Test layar autentikasi (login, register, dll)"
    echo "  main         Test layar utama (beranda, menu, profil)"
    echo "  chat         Test layar chat (daftar chat, ruang chat, call)"
    echo "  admin        Test admin dashboard & feedback"
    echo "  security     Test pattern lock screens"
    echo "  additional   Test viewer, settings, onboarding"
    echo "  update       Update semua golden baseline screenshots"
    echo "  verify       Verifikasi tanpa update (check only)"
    echo "  help         Tampilkan bantuan ini"
    echo ""
    echo -e "${YELLOW}Contoh:${NC}"
    echo "  ./run_golden_tests.sh all          # Semua tests"
    echo "  ./run_golden_tests.sh auth         # Auth tests saja"
    echo "  ./run_golden_tests.sh update       # Update baseline"
    echo "  ./run_golden_tests.sh verify       # Verify changes"
    echo ""
}

# Fungsi jalankan test
run_test() {
    local test_file=$1
    local description=$2
    local update_flag=${3:-}
    
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}📱 Running: ${description}${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    if [ -f "$TEST_DIR/$test_file" ]; then
        cd "$SCRIPT_DIR"
        flutter test "test/$test_file" $update_flag --reporter=compact
        echo -e "${GREEN}✅ ${description} selesai!${NC}"
    else
        echo -e "${RED}❌ File test tidak ditemukan: $test_file${NC}"
        exit 1
    fi
}

# Main script
case "${1:-all}" in
    all)
        echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║   🚀 Menjalankan SEMUA Golden Tests                  ║${NC}"
        echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
        
        run_test "golden_auth_screens_test.dart" "Layar Autentikasi"
        run_test "golden_main_screens_test.dart" "Layar Utama"
        run_test "golden_chat_screens_test.dart" "Layar Chat"
        run_test "golden_admin_feedback_screens_test.dart" "Admin & Feedback"
        run_test "golden_security_screens_test.dart" "Security (Pattern Lock)"
        run_test "golden_additional_screens_test.dart" "Layar Tambahan"
        
        echo -e "\n${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║   ✅ SEMUA GOLDEN TESTS SELESAI!                     ║${NC}"
        echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
        ;;
    
    auth)
        run_test "golden_auth_screens_test.dart" "Layar Autentikasi" "${2:-}"
        ;;
    
    main)
        run_test "golden_main_screens_test.dart" "Layar Utama" "${2:-}"
        ;;
    
    chat)
        run_test "golden_chat_screens_test.dart" "Layar Chat" "${2:-}"
        ;;
    
    admin)
        run_test "golden_admin_feedback_screens_test.dart" "Admin & Feedback" "${2:-}"
        ;;
    
    security)
        run_test "golden_security_screens_test.dart" "Security (Pattern Lock)" "${2:-}"
        ;;
    
    additional)
        run_test "golden_additional_screens_test.dart" "Layar Tambahan" "${2:-}"
        ;;
    
    update)
        echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║   📸 Update SEMUA Golden Baseline Screenshots        ║${NC}"
        echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
        echo -e "${YELLOW}⚠️  Ini akan meng-overwrite semua baseline screenshots!${NC}"
        echo -e "${YELLOW}   Pastikan perubahan UI memang disengaja.${NC}"
        echo ""
        
        run_test "golden_auth_screens_test.dart" "Update: Layar Autentikasi" "--update-goldens"
        run_test "golden_main_screens_test.dart" "Update: Layar Utama" "--update-goldens"
        run_test "golden_chat_screens_test.dart" "Update: Layar Chat" "--update-goldens"
        run_test "golden_admin_feedback_screens_test.dart" "Update: Admin & Feedback" "--update-goldens"
        run_test "golden_security_screens_test.dart" "Update: Security" "--update-goldens"
        run_test "golden_additional_screens_test.dart" "Update: Layar Tambahan" "--update-goldens"
        
        echo -e "\n${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║   ✅ SEMUA BASELINE BERHASIL DIUPDATE!               ║${NC}"
        echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
        echo -e "\n${YELLOW}💡 Jangan lupa commit perubahan:${NC}"
        echo -e "   git add test/goldens/"
        echo -e "   git commit -m \"chore: update golden baseline screenshots\""
        ;;
    
    verify)
        echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║   🔍 Verifikasi Golden Tests (No Update)             ║${NC}"
        echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
        echo -e "${YELLOW}⚠️  Mode verifikasi - akan gagal jika ada perbedaan${NC}"
        echo ""
        
        run_test "golden_auth_screens_test.dart" "Verify: Layar Autentikasi"
        run_test "golden_main_screens_test.dart" "Verify: Layar Utama"
        run_test "golden_chat_screens_test.dart" "Verify: Layar Chat"
        run_test "golden_admin_feedback_screens_test.dart" "Verify: Admin & Feedback"
        run_test "golden_security_screens_test.dart" "Verify: Security"
        run_test "golden_additional_screens_test.dart" "Verify: Layar Tambahan"
        
        echo -e "\n${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║   ✅ VERIFIKASI BERHASIL - Tidak Ada Perubahan!      ║${NC}"
        echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
        ;;
    
    help|--help|-h)
        show_help
        ;;
    
    *)
        echo -e "${RED}❌ Option tidak dikenal: $1${NC}"
        echo ""
        show_help
        exit 1
        ;;
esac
