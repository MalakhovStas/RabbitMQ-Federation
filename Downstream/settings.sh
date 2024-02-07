#!/bin/bash

# Очищает сохраненные данные контейнеров  sudo /bin/bash settings.sh clean
if [[ -n "$1" ]] && [[ "${1#*.}" == "clean" ]]; then
 	echo store celaning
	rm -Rf store/mnesia
fi

# Подготовка пользователей  sudo /bin/bash settings.sh set
if [[ -n "$1" ]] && [[ "${1#*.}" == "set" ]]; then
	docker exec -i -t rabbit-downstream rabbitmqctl add_user consumer consumer
	docker exec -i -t rabbit-downstream rabbitmqctl add_user broker broker

	docker exec -i -t rabbit-downstream rabbitmqctl set_permissions admin    ".*" ".*" ".*"
	docker exec -i -t rabbit-downstream rabbitmqctl set_permissions consumer ".*" ".*" ".*"
	docker exec -i -t rabbit-downstream rabbitmqctl set_permissions broker   ".*" ".*" ".*"

	docker exec -i -t rabbit-downstream rabbitmq-plugins enable rabbitmq_federation
  docker exec -i -t rabbit-downstream rabbitmq-plugins enable rabbitmq_federation_management

#  docker exec -i -t rabbit-downstream rabbitmqctl set_parameter federation-upstream origin '{"uri":"amqp://consumer:consumer@host.docker.internal:93.175.5.195:5672"}'
  docker exec -i -t rabbit-downstream rabbitmqctl set_parameter federation-upstream origin '{"uri":"amqp://consumer:consumer@host.docker.internal:5672"}'
  docker exec -i -t rabbit-downstream rabbitmqctl set_policy --apply-to exchanges federation-exchange-policy ".*FEDERATION.*" '{"federation-upstream-set":"all"}' --priority 10 --apply-to all
fi

# /bin/bash Downstream/settings.sh set
#sudo rm -rf Downstream/docker/store