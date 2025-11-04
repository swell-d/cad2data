services:
  cad2data:
    user: "1000:1000"
    build:
      context: .
      dockerfile: Dockerfile-cad2data
    image: cad2data:latest
    restart: unless-stopped
    ports:
      - "5001:5001"
    read_only: true
    tmpfs:
      - /tmp
      - /home/mambauser:uid=1000,gid=1000,mode=700
    security_opt:
      - no-new-privileges:true
    cap_drop:
      - ALL
    volumes:
      - /var/www/360/share:/share:rw
    environment:
      DEBUG: 0
    init: true
    healthcheck:
      test: [ "CMD-SHELL", "curl -fsS http://127.0.0.1:5001/health || exit 1" ]
      interval: 30s
      timeout: 5s
      retries: 5
      start_period: 10s
# test