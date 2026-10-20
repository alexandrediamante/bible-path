# Icons para PWA

**Você precisa adicionar dois arquivos PNG reais aqui:**

| Arquivo | Tamanho | Uso |
|---------|---------|-----|
| `Icon-192.png` | 192×192 | Ícone na home screen, splash |
| `Icon-512.png` | 512×512 | Splash screen, app store |

## Como gerar:

1. Crie uma imagem quadrada (512×512) com seu logo/ícone
2. Use ferramentas online:
   - https://www.pwabuilder.com/imageGenerator
   - https://favicon.io/favicon-generator/
   - https://realfavicongenerator.net/

3. Baixe e coloque aqui como:
   - `icons/Icon-192.png`
   - `icons/Icon-512.png`

## Ou use o script do Flutter (após ter uma imagem base):

```bash
# Instale o pacote
flutter pub add -d flutter_launcher_icons

# Configure no pubspec.yaml:
flutter_icons:
  android: false
  ios: false
  web:
    generate: true
    image_path: "assets/images/app_icon.png"  # sua imagem 512x512
    filename: "Icon"

# Rode
dart run flutter_launcher_icons
```

---

**Placeholder atual:** Os arquivos não existem ainda — o build web vai funcionar, mas o PWA não vai instalar corretamente sem ícones reais.