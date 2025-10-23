from ignis.widgets import Widget
import random

from theme_colors import col

class BackgroundSentence (Widget.Window):
    def __init__(self, sentences=None, monitor = None):

        self.box = Widget.Box(
            spacing = 6,
            vertical = True,
            child = []
        )

        super().__init__(
            namespace = 'background-sentence',
            monitor = monitor,
            child = self.box,
            layer = 'bottom',
            anchor = ['top'],
            margin_top = 40
        )
        self.update_theme()
        if sentences:
            random_sentence = random.choice(sentences)
            self.box.set_child(self.generate(random_sentence))

    def update_theme (self):
        self.set_style(f'background-color:transparent;color:{col('on_background')};font-size:1.2rem;')
    
    def generate (self, sentence):
        ''' sentence format must be (main, *translate, *transliteration)'''
        lst = [
            Widget.Label(label=sentence[0], style="font-size:210%;"),
        ]
        if len(sentence) > 2 and sentence[2]:
            lst.append(Widget.Label(label=sentence[2], style="font-size:80%;"))
        if len(sentence) > 1 and sentence[1]:
            lst.append(Widget.Separator(vertical=False))
            lst.append(Widget.Label(label=sentence[1]))
        return lst
'''
    "sentences": [
        ["私の心はバグです", "My heart is a bug", "Watashi no kokoro wa bagu desu"],
        ["私は死んだ", "I'm dead", "Watashiwashinda"],
        ["Oro ger små saker en stor skugga", "Worry often gives a small thing a big shadow", "Swedish proverb"],
        ["Ibland kan man inte se skogen på grund av alla träd", "When the sage points at the moon, the fool looks at the finger", "Sometimes you cannot see the forest because of all the trees"],
        ["Allt sak har sin tid", "Everything has its time", "Swedish proverb"],
        ["Bättre tiga än illa tala", "Better to keep quiet than to speak poorly", "Swedish proverb"],
        ["Elda inte för kråkorna", "Something like “Don't waste resources", "Don't light a fire for the crows"],
        ["En gång är ingen gång, två gånger är en vana", "One time is no time, two times is a habit/tradition", "Swedish proverb"],
        ["En olycka kommer sällan ensam", "Misery loves company", "An accident rarely comes alone"],
        ["Alea iacta est"],
        ["Auribus lupum teneo", "I'm holding the wolf by the ears"]
    ]
'''