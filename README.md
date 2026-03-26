# SQL Project

## Описание проекта

Этот проект представляет собой комплексное решение для изучения и практики SQL

1. **Транспортные средства** - управление данными об автомобилях, мотоциклах и велосипедах
2. **Автомобильные гонки** - информация о классах автомобилей, гонках и результатах
3. **Бронирование отелей** - система управления бронированием номеров в отелях
4. **Структура организации** - иерархическая структура сотрудников, проектов и задач

## Инструкция по запуску

### Требования
- Docker Desktop (или Docker Engine с Docker Compose)
- Git

### Шаги для запуска

1. **Клонировать репозиторий:**
```bash
git clone https://github.com/TkachenkoRP/sql-project.git
cd sql-project
```

2. **Запустить контейнер PostgreSQL:**
```bash
docker-compose up -d
```

3. **Проверить статус контейнера:**
```bash
docker-compose ps
```

4. **Подключиться к PostgreSQL:**
```bash
docker exec -it sql_project_postgres psql -U postgres
```

5. **Просмотреть созданные базы данных:**
```sql
\l
```

Вы должны увидеть следующие базы данных:
- `vehicles` - транспортные средства
- `racing` - автомобильные гонки
- `hotel` - бронирование отелей
- `organization` - структура организации

6. **Подключиться к конкретной базе:**
```sql
\c vehicles
\dt  -- показать все таблицы
```

### Остановка контейнера

```bash
docker-compose down
```

Для полного удаления данных (включая volume):
```bash
docker-compose down -v
```

## Подключение через клиент SQL

- **Host:** localhost
- **Port:** 5432
- **Database:** vehicles, racing, hotel, organization
- **Username:** postgres
- **Password:** postgres

### Быстрый доступ к задачам

- [Транспортные средства (2 задачи)](vehicles)
- [Автомобильные гонки (5 задач)](racing)
- [Бронирование отелей (3 задачи)](hotel)
- [Структура организации (3 задачи)](organization)

## Проверка решений

### Запуск конкретного решения

```bash
# Подключение к базе данных
docker exec -it sql_project_postgres psql -U postgres -d vehicles

# Выполнение решения задачи 1 из vehicles
\i sql-test/vehicles/task1.sql

# Выполнение решения задачи 1 из racing
\c racing
\i sql-test/racing/task1.sql
```