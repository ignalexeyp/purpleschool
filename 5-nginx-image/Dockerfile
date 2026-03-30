FROM nginx:alpine

# Удаляем стандартную конфигурацию nginx
RUN rm /etc/nginx/conf.d/default.conf

# Копируем нашу конфигурацию в nginx
COPY default.conf /etc/nginx/conf.d/

# Копируем HTML файл в директорию nginx
COPY index.html /usr/share/nginx/html/

# Открываем порт 80 (nginx слушает этот порт внутри контейнера)
EXPOSE 80

# Запускаем nginx
CMD ["nginx", "-g", "daemon off;"]
