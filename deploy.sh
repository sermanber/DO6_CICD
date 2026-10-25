#!/bin/bash
set -e

PROD_HOST="${PROD_HOST:-192.168.56.102}"
PROD_USER="${PROD_USER:-pickle_rick}"
SSH_KEY="/home/gitlab-runner/.ssh/id_rsa"

echo "=== Деплой на ${PROD_USER}@${PROD_HOST} ==="

# Проверяем, что бинарники на месте
if [ ! -f "src/cat/s21_cat" ]; then
    echo "❌ Не найден src/cat/s21_cat"
    exit 1
fi
if [ ! -f "src/grep/s21_grep" ]; then
    echo "❌ Не найден src/grep/s21_grep"
    exit 1
fi

# Копируем бинарники во временную папку на VM2
scp -i "$SSH_KEY" -o StrictHostKeyChecking=no \
    src/cat/s21_cat src/grep/s21_grep \
    "${PROD_USER}@${PROD_HOST}:/tmp/"

# Перемещаем в /usr/local/bin и делаем исполняемыми
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no "${PROD_USER}@${PROD_HOST}" \
    "sudo mv /tmp/s21_cat /tmp/s21_grep /usr/local/bin/ && \
     sudo chmod +x /usr/local/bin/s21_cat /usr/local/bin/s21_grep"

echo "=== Деплой завершён успешно ==="