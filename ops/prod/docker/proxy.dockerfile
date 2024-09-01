# 使用 nginx:alpine 基礎映像
FROM nginx:alpine3.19

# 複製本地的 nginx 配置文件到容器內
COPY ./ops/prod/nginx/conf.d/default.conf /etc/nginx/conf.d/

# 暴露端口
EXPOSE 80

# 啟動 nginx 服務
CMD ["nginx", "-g", "daemon off;"]
