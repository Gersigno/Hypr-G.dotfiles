#!/usr/bin/env bash

# Test script pour vérifier le système de notifications Quickshell

echo "=== Test du système de notifications Quickshell ==="
echo

# 1. Vérifier que Quickshell tourne
echo "1. Vérification que Quickshell tourne..."
if pgrep -f quickshell > /dev/null; then
    echo "✓ Quickshell est en cours d'exécution"
else
    echo "✗ Quickshell ne tourne pas"
    exit 1
fi

echo

# 2. Envoyer une notification de test
echo "2. Envoi d'une notification de test..."
notify-send "Test Quickshell" "Notification de test pour vérifier l'intégration D-Bus"

echo "✓ Notification envoyée"

echo

# 3. Attendre un peu
echo "3. Attente de 2 secondes pour que la notification soit traitée..."
sleep 2

echo

# 4. Vérifier les logs
echo "4. Vérification des logs pour les notifications reçues..."
LOG_FILE=$(ls -t /run/user/1000/quickshell/by-id/*/log.qslog | head -1)

if grep -q "Nouvelle notification D-Bus reçue" "$LOG_FILE" 2>/dev/null; then
    echo "✓ Notification D-Bus détectée dans les logs"
    grep "Nouvelle notification D-Bus reçue" "$LOG_FILE" | tail -1
else
    echo "✗ Aucune notification D-Bus trouvée dans les logs"
fi

echo

# 5. Vérifier le nombre de notifications dans le service
echo "5. État du service de notifications..."
if grep -q "\[Notifications\] Liste" "$LOG_FILE" 2>/dev/null; then
    echo "✓ Service de notifications actif"
    grep "\[Notifications\] Liste" "$LOG_FILE" | tail -1
else
    echo "✗ Service de notifications non trouvé dans les logs"
fi

echo
echo "=== Test terminé ==="