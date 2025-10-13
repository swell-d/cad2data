docker build -t cad2data:latest .

docker run -d --name cad2data --restart unless-stopped -v /var/www/360/share:/share -p 5001:5001 cad2data:latest

docker system prune -f
