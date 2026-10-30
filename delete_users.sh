#!/bin/bash

# Автоматически определяем папку, где лежит сам скрипт, и ищем users.txt рядом
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
USER_LIST="$SCRIPT_DIR/users.txt"

# Проверяем, запущен ли скрипт с правами sudo
if [ "$EUID" -ne 0 ]; then
  echo "Пожалуйста, запустите скрипт через sudo!"
  exit 1
fi

# Читаем файл построчно, защищаясь от отсутствия Enter в конце файла
while read -r username || [ -n "$username" ]
do
  # Пропускаем пустые строки
  [ -z "$username" ] && continue

  # Проверяем, существует ли вообще такой пользователь в системе перед удалением
  if id "$username" &>/dev/null; then
    echo "Удаление пользователя: $username и его домашней папки..."
    
    # Удаляем пользователя и очищаем его каталог /home/имя
    deluser --remove-home "$username"
  else
    echo "Пользователь $username не найден в системе, пропускаем."
  fi

done < "$USER_LIST"

echo "Готово! Все пользователи из списка удалены."
