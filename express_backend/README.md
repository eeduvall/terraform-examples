## Containerize the app
Run `docker build --platform linux/amd64 -t express_be:dev .` from the directory

## Running locally
`docker network create -d bridge --subnet 172.10.0.0/16 react_2_express`
`docker run -dt -p 3001:3001 --network react_2_express --hostname express.be.com --label=express_be express_be:dev`