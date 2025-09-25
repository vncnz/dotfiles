class Bus:
    subscribers = []

    @classmethod
    def subscribe(cls, fn):
        cls.subscribers.append(fn)

    @classmethod
    def publish(cls, msg):
        for fn in cls.subscribers:
            fn(msg)