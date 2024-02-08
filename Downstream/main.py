"""Основной модуль приложения"""
import asyncio
import subprocess
import time

import aio_pika
from aio_pika.exceptions import QueueEmpty


async def main():
    # Устанавливаем соединение с RabbitMQ на главном хосте
    connection = await aio_pika.connect_robust(
        "amqp://consumer:consumer@localhost:5673"
    )

    try:
        channel = await connection.channel()
        exchange = await channel.declare_exchange(
            name="FEDERATION",
            type=aio_pika.ExchangeType.FANOUT,
        )

        # Объявление очереди "FEDERATION"
        queue = await channel.declare_queue(name="FEDERATION", auto_delete=False, exclusive=False)
        # Привязка очереди к обмену
        await queue.bind(exchange=exchange, routing_key="FEDERATION")

        while True:
            await asyncio.sleep(1)
            try:
                message = await queue.get(no_ack=True)
                print(f'New message: {message.body.decode("utf-8")}')
                # pprint(message.headers)
            except QueueEmpty:
                pass

    except Exception as exc:
        print('ERROR: ', exc.__class__, exc)
    finally:
        await connection.close()


if __name__ == "__main__":
    subprocess.Popen(["/bin/bash", "Downstream/settings.sh", "set"])
    time.sleep(15)
    asyncio.run(main())
