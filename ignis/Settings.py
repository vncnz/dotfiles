from pydantic import BaseModel, Field, ValidationError
import json
import os

class Config(BaseModel):
    # theme: str = "dark"
    # autosave: bool = True
    # autosave_interval: int = Field(10, ge=1)
    wallpaper: str | None = None
    sentences: list[tuple] = []

def load_config(path=None):
    if not path: path = os.path.expanduser('~/.config/ignis/settings.json')
    try:
        with open(path) as f:
            raw = json.load(f)
    except FileNotFoundError:
        return Config()
    except json.JSONDecodeError as e:
        print(f"⚠️ Config corrotta ({e}); uso defaults.")
        return Config()
    
    print(json.dumps(raw, indent=4))

    # Prova validazione completa
    try:
        return Config(**raw)
    except ValidationError as e:
        print("⚠️ Alcuni valori non validi, uso defaults per quelli errati:")
        defaults = Config()
        partial = defaults.dict()
        for field, value in raw.items():
            try:
                # validazione isolata per campo singolo
                validated = Config.model_fields[field].annotation(value)
                partial[field] = value
            except Exception:
                print(f"  - Campo '{field}' errato ({value!r}), default: {partial[field]!r}")
        return Config(**partial)

_config = load_config()

def reload_config ():
    global _config
    _config = load_config()

class _ConfigProxy:
    def __getattr__(self, name):
        return getattr(_config, name)
    def __setattr__(self, name, value):
        if name.startswith('_'):
            super().__setattr__(name, value)
        else:
            setattr(_config, name, value)

config = _ConfigProxy()