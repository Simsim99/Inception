# The name of your compose file
COMPOSE_FILE = srcs/docker-compose.yml

# Default target when you just type 'make'
all: up

# Build and start the infrastructure in detached mode (background)
# -f(--file): Tells Docker Compose which YAML file to read.
#  -d(--detach): Runs your containers in the background. It frees
# up your terminal prompt immediately so you can keep typing commands
# while the containers run silently. without it Docker will attach your
# terminal to the containers' outputs, flooding your screen with live logs
# and blocking your terminal until you hit Ctrl + C 
# --build: Forces Docker to build (or rebuild) the container
# images before starting them, t checks your custom Dockerfiles (e.g.,
# for Nginx, MariaDB, WordPress) to compile any recent code changes
# into fresh images. without it, if you edit a Dockerfile or configuration,
# Docker Compose might just reuse an old cached image instead of applying your updates.

up:
	mkdir -p /home/ouchouir/data/mariadb
	mkdir -p /home/ouchouir/data/wordpress
	docker compose -f $(COMPOSE_FILE) up -d --build

# Stop and remove the containers (but keep the volumes/data)
down:
	docker compose -f $(COMPOSE_FILE) down

# Stop, remove containers, AND delete the volumes (fresh slate)
clean:
# without -v: Your containers stop, but your WordPress posts, users, and MariaDB database
# stay safe in storage. Next time you run make up, all your data is still there.
# with -v: t wipes out the containers AND deletes all database tables and uploaded files
# saved inside Docker's volume storage. You get a completely fresh, blank slate. 
	docker compose -f $(COMPOSE_FILE) down -v
    # Optional: remove the data folder on the host machine
	sudo rm -rf /home/$(USER)/data/mariadb
	sudo rm -rf /home/$(USER)/data/wordpress

# Just show the logs of what's happening (useful for debugging)
logs:
	docker compose -f $(COMPOSE_FILE) logs -f

# Shortcut to restart everything
re: down up

# Tell Make these targets don't represent actual files
.PHONY: all up down clean logs re
