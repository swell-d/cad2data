docker build -t cad2data:latest --label keep=true .

docker run -d --name cad2data-keeper --restart unless-stopped --network none --entrypoint sleep cad2data:latest infinity

docker system prune -f --filter label!=keep=true
