class Bus:
    subscribers = {}

    @classmethod
    def subscribe(cls, fn, topic='all'):
        if not topic in cls.subscribers:
            cls.subscribers[topic] = []
        cls.subscribers[topic].append(fn)
        # print('subscribing', topic, cls.subscribers)

    @classmethod
    def publish(cls, msg, topic = 'all'):
        if topic in cls.subscribers:
            # print('calling', topic, cls.subscribers)
            for fn in cls.subscribers[topic]:
                fn(msg)