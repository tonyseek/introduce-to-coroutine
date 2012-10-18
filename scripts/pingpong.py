from time import sleep
from greenlet import greenlet

@greenlet
def ping():
    while True:
        print("ping")
        sleep(1)
        pong.switch()

@greenlet
def pong():
    while True:
        print("pong")
        sleep(1)
        ping.switch()

if __name__ == "__main__":
    ping.switch()
