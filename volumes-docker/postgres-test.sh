#!/bin/bash

# Переменные
OLD_PATH="/home/vasa/postgres-data"
NEW_BASE="/home/vasa/new_location"
NEW_PATH="${NEW_BASE}/postgres-data"

echo "=== 1. Очистка старых контейнеров ==="
sudo docker rm -f postgres-container 2>/dev/null
sudo docker rm -f postgres-container-new 2>/dev/null

echo "=== 2. Очистка старых данных ==="
sudo rm -rf ${OLD_PATH}
sudo rm -rf ${NEW_BASE}

echo "=== 3. Запуск PostgreSQL (версия 17 для совместимости) ==="
sudo docker run -d \
  --name postgres-container \
  -e POSTGRES_PASSWORD=mysecretpassword \
  -e POSTGRES_USER=myuser \
  -e POSTGRES_DB=mydb \
  -v ${OLD_PATH}:/var/lib/postgresql/data \
  -p 5432:5432 \
  postgres:17

echo "=== 4. Ожидание запуска PostgreSQL ==="
sleep 10

echo "=== 5. Создание тестовых данных ==="
sudo docker exec postgres-container psql -U myuser -d mydb -c "CREATE TABLE test (id SERIAL, name VARCHAR(50));"
sudo docker exec postgres-container psql -U myuser -d mydb -c "INSERT INTO test (name) VALUES ('test1'), ('test2');"
sudo docker exec postgres-container psql -U myuser -d mydb -c "SELECT * FROM test;"

echo "=== 6. Проверка содержимого каталога данных ==="
sudo ls -la ${OLD_PATH}

echo "=== 7. Остановка и удаление контейнера ==="
sudo docker stop postgres-container
sudo docker rm postgres-container

echo "=== 8. Перенос каталога в новое место ==="
sudo mkdir -p ${NEW_BASE}
sudo mv ${OLD_PATH} ${NEW_BASE}/

echo "=== 9. Запуск нового контейнера с новым путем ==="
sudo docker run -d \
  --name postgres-container-new \
  -e POSTGRES_PASSWORD=mysecretpassword \
  -e POSTGRES_USER=myuser \
  -e POSTGRES_DB=mydb \
  -v ${NEW_PATH}:/var/lib/postgresql/data \
  -p 5432:5432 \
  postgres:17

echo "=== 10. Ожидание запуска ==="
sleep 10

echo "=== 11. Проверка сохранности данных ==="
sudo docker exec postgres-container-new psql -U myuser -d mydb -c "SELECT * FROM test;"

echo "=== Готово! Данные сохранены ==="
