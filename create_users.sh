#!/bin/bash

# Автоматически определяем папку, где лежит сам скрипт
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
USER_LIST="$SCRIPT_DIR/users.txt"
REPORT_FILE="$SCRIPT_DIR/passwords_report.txt"

# Проверяем, запущен ли скрипт с правами sudo
if [ "$EUID" -ne 0 ]; then
  echo "Пожалуйста, запустите скрипт через sudo!"
  exit 1
fi

# Очищаем старый файл отчетов, если он существовал, и создаем новый
echo "=== ОТЧЕТ О СОЗДАННЫХ АККАУНТАХ И ВРЕМЕННЫХ ПАРОЛЯХ ===" > "$REPORT_FILE"
echo "Дата создания: $(date)" >> "$REPORT_FILE"
echo "--------------------------------------------------------" >> "$REPORT_FILE"

# Защищаем файл отчета: читать и писать в него может ТОЛЬКО root (права 600)
chmod 600 "$REPORT_FILE"

# Читаем файл построчно 
while read -r username || [ -n "$username" ]
do
  # Пропускаем пустые строки
  [ -z "$username" ] && continue

  echo "Создание пользователя: $username..."

  # ГЕНЕРАЦИЯ ПАРОЛЯ: берем 12 случайных символов 
  password=$(openssl rand -base64 12 | tr -d '/+=')

  # Шифруем сгенерированный пароль для Linux
  PASSWORD_HASH=$(openssl passwd -6 "$password")

  # Создаем пользователя
  useradd -m -s /bin/bash -G video,audio,render,plugdev -p "$PASSWORD_HASH" "$username"

  # Заставляем сменить пароль при первом входе
  chage -d 0 "$username" 

  # Записываем логин и сгенерированный пароль в секретный файл отчета
  echo "Логин: $username  |  Временный пароль: $password" >> "$REPORT_FILE"

done < "$USER_LIST"

echo "--------------------------------------------------------" >> "$REPORT_FILE"
echo "Готово! Все пользователи созданы. Пароли сохранены в файл: passwords_report.txt"

