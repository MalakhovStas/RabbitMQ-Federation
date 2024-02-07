#!/bin/bash

# Очищает сохраненные данные контейнеров  sudo /bin/bash settings.sh clean
if [[ -n "$1" ]] && [[ "${1#*.}" == "clean" ]]; then
 	echo store celaning
	rm -Rf store/mnesia
fi

# Подготовка пользователей  sudo /bin/bash settings.sh set
if [[ -n "$1" ]] && [[ "${1#*.}" == "set" ]]; then
	docker exec -i -t rabbit-upstream rabbitmqctl add_user consumer consumer
	docker exec -i -t rabbit-upstream rabbitmqctl add_user broker broker
	docker exec -i -t rabbit-upstream rabbitmqctl set_permissions admin    ".*" ".*" ".*"
	docker exec -i -t rabbit-upstream rabbitmqctl set_permissions consumer ".*" ".*" ".*"
	docker exec -i -t rabbit-upstream rabbitmqctl set_permissions broker   ".*" ".*" ".*"
  docker exec -i -t rabbit-upstream rabbitmq-plugins enable rabbitmq_federation
  docker exec -i -t rabbit-upstream rabbitmq-plugins enable rabbitmq_federation_management
fi

# /bin/bash Upstream/settings.sh set
#sudo rm -rf Upstream/docker/store
