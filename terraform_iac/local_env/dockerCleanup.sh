reactId=$(docker ps -q -f label=react_fe)
expressId=$(docker ps -q -f label=express_be)
docker kill $expressId && docker rm $expressId
docker kill $reactId && docker rm $reactId
docker rmi express_be:dev
docker rmi react_fe:dev
docker rmi express_be:latest
docker rmi react_fe:latest
docker network rm react_2_express