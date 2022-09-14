## Copy Dockerfile and start.sh file to VM

`scp ./dockeragent/Dockerfile user@vm-ip-address:/home/user/dockeragent/Dockerfile`
`scp ./dockeragent/start.sh user@vm-ip-address:/home/user/dockeragent/start.sh`

## Update and Upgrade the VM

`sudo apt update && sudo apt upgrade -y`

## Install the Docker

```bash

sudo apt install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker

```

## Make docker Run without ROOT

```bash

sudo groupadd docker
sudo usermod -aG docker kamal
newgrp docker

```

## Build Docker Image

```bash

cd ./dockeragent
docker build -t dockeragent:latest .

```

## Run the Agent

```bash

docker run \
  -e AZP_URL='https://dev.azure.com/kamal8/' \
  -e AZP_TOKEN='r662njc36uw27s77hj2kyipfytwhsyh66y6iyzp3qbu2xfsy7stq' \
  -e AZP_AGENT_NAME='myagenttwo' \
  -e AZP_POOL='containers-pool' \
  --name myagenttwo -d dockeragent:latest

```

| The `--once` argument can be used if you always want a new agent for every job.
