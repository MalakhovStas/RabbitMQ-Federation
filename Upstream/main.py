"""Основной модуль приложения"""
import asyncio
import subprocess

import aio_pika
import time


async def main():
    # Устанавливаем соединение с RabbitMQ на главном хосте
    connection = await aio_pika.connect_robust(
        "amqp://broker:broker@localhost:5672"
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

        count = 0
        while True:
            count += 1
            input_text = input(f'Введите текст сообщения {count}: ')
            message_text = f'Сообщение #{count}: {input_text}'
            # Отправляем сообщение через федерацию
            await exchange.publish(
                aio_pika.Message(body=message_text.encode('utf-8', errors='ignore')),
                routing_key="FEDERATION"
            )
    except Exception as exc:
        print('ERROR: ', exc.__class__, exc)
    finally:
        await connection.close()


if __name__ == "__main__":
    subprocess.Popen(["/bin/bash", "Upstream/settings.sh", "set"])
    time.sleep(15)
    asyncio.run(main())
