# 🎬 DaVinci Resolve Media Converter (Linux)

![License](https://img.shields.io/badge/license-MIT-green)
![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20macOS-lightgrey?logo=linux)
![Shell](https://img.shields.io/badge/shell-Bash%20%7C%20Zsh-4EAA25?logo=gnubash)
![Dependency](https://img.shields.io/badge/depends-FFmpeg-FFmpeg?logo=ffmpeg)
![Status](https://img.shields.io/badge/status-Estável-brightgreen)

> **Script Bash automatizado** para preparar arquivos de mídia (vídeo/áudio) para edição no **DaVinci Resolve Free** no Linux, resolvendo a incompatibilidade com codecs proprietários (AAC, H.264/H.265, etc.).

## 🎯 O Problema

A versão **gratuita do DaVinci Resolve no Linux** não possui licenças para codecs proprietários, causando:
- ❌ Arquivos / (H.264/H.265) não importam ou ficam sem vídeo
- ❌ Áudio AAC (, ) não reproduz ou dá erro
- ❌ Falta de suporte nativo a HEVC/VP9 em algumas distros

## ✨ A Solução

Este script converte **recursivamente** todos os arquivos de uma pasta para codecs **edit-friendly**:
| Tipo | Entrada Suportada | Saída (Edição) | Codec Vídeo | Codec Áudio |
|------|-------------------|----------------|-------------|-------------|
| **Vídeo** | , , , , , , , , ,  |  | **MPEG-4 Part 2** (,  — qualidade máxima) | **PCM 16-bit** () |
| **Áudio** | , , , , , ,  |  | — (descartado via ) | **PCM 16-bit** () |

## 🚀 Funcionalidades

- ✅ **Híbrido:** Processa vídeos e áudios na mesma execução
- ✅ **Recursivo:** Varre todas as subpastas automaticamente
- ✅ **Organizado:** Cria pasta  em **cada diretório** original, preservando estrutura
- ✅ **Inteligente:** Pula arquivos já convertidos (não reconverte)
- ✅ **Robusto:** Trata corretamente nomes com espaços e caracteres especiais ()
- ✅ **Codecs Otimizados:** Qualidade máxima para edição (sem perdas visuais/sonoras)
- ✅ **Zero Dependências Extras:** Apenas / + 

## 🛠️ Requisitos

- `bash` ou `zsh`
- `ffmpeg`

```Bash
# Para instalar o ffmpeg no Ubuntu/Mint/Debian:
sudo apt install ffmpeg
```

> **Testado em:** Linux Mint 21+, Ubuntu 20.04+, Debian 11+, Fedora 38+, Arch Linux

## 📦 Como Usar

### 1. Clone o Repositório
```bash
git clone https://github.com/paulorabelo/to-davinci-media-converter.git
cd to-davinci-media-converter
```

### 2. Dê Permissão de Execução
```bash
chmod +x to_davinci.sh
```

### 3. Execute
```bash
# Sintaxe: ./to_davinci.sh <pasta_com_arquivos_originais>
./to_davinci.sh /home/usuario/Videos/ProjetoX

# Exemplo com caminho relativo
./to_davinci.sh ./meus_videos_raw
```

### 4. Resultado
```
/home/usuario/Videos/ProjetoX/
├── video1.mp4          ← Original (mantido)
├── audio1.m4a          ← Original (mantido)
└── convertidos/        ← Criado automaticamente
    ├── video1.mov      ← Pronto para DaVinci!
    └── audio1.wav      ← Pronto para DaVinci!
```

## 🔍 Explicação Técnica (Code Breakdown)

### 1. Variáveis e Ambiente
```bash
DESTINO_CONVERTER="$1"
IFS=$'\n'
```
- : Caminho da pasta alvo (argumento CLI)
- : **Internal Field Separator** = quebra de linha apenas. **Essencial** para nomes com espaços.

### 2. Mapeamento de Diretórios (Primeiro Loop)
```bash
for diretorio_conversao in $(find "$DESTINO_CONVERTER" ... -printf "%h\n" | sort | uniq)
```
- Busca **diretórios únicos** que contêm arquivos de interesse
- Evita processar a mesma pasta múltiplas vezes

### 3. Criação da Pasta 
```bash
if [ ! -d "$diretorio_conversao/convertidos" ]; then
    mkdir "$diretorio_conversao/convertidos"
fi
```
- Pasta criada **por diretório** — mantém organização paralela aos originais

### 4. Processamento de Arquivos (Segundo Loop)
```bash
for arquivo_conversao in $(find "$diretorio_conversao" ... -printf "%f\n")
```
- Lista apenas nomes de arquivo () dentro de cada pasta mapeada

### 5. Normalização de Extensão
```bash
EXTENSAO="${arquivo_conversao##*.}"
EXTENSAO="${EXTENSAO,,}"
```
- : Remove tudo antes do último  (pega extensão)
- : **Lowercase** — trata , ,  igualmente

### 6. Decisão Vídeo vs Áudio + FFmpeg

**Vídeo:**
```bash
ffmpeg -i "input" -codec:v mpeg4 -q:v 0 -codec:a pcm_s16le "output.mov"
```
- : MPEG-4 Visual, **qualidade máxima** (lossless visual)
- : Áudio PCM 16-bit little-endian (compatível total)

**Áudio:**
```bash
ffmpeg -i "input" -vn -codec:a pcm_s16le "output.wav"
```
- : **Video Null** — descarta stream de vídeo (ex: capa de álbum em .m4a)
- Saída : Padrão da indústria para edição

## 🧪 Testando Rapidamente

```bash
# Crie pasta de teste com arquivos de exemplo
mkdir -p teste_conversao
# Coloque alguns .mp4/.m4a lá
./to_davinci.sh ./teste_conversao
# Verifique pasta convertidos/
ls -la teste_conversao/convertidos/
```

## ⚙️ Personalização

Edite o script para ajustar:
- **Qualidade de vídeo:** Mude  para  (menor = melhor, mas arquivo maior)
- **Codecs de saída:** Substitua  por  (se tiver licença) ou 
- **Extensões suportadas:** Adicione/remova no .
./.git
./.git/info
./.git/info/exclude
./.git/objects
./.git/objects/info
./.git/objects/pack
./.git/objects/pack/pack-323638ea8d00cc79fd23020ce12be54f9ecd4629.idx
./.git/objects/pack/pack-323638ea8d00cc79fd23020ce12be54f9ecd4629.pack
./.git/objects/pack/pack-323638ea8d00cc79fd23020ce12be54f9ecd4629.rev
./.git/hooks
./.git/hooks/applypatch-msg.sample
./.git/hooks/pre-commit.sample
./.git/hooks/commit-msg.sample
./.git/hooks/prepare-commit-msg.sample
./.git/hooks/pre-rebase.sample
./.git/hooks/sendemail-validate.sample
./.git/hooks/pre-receive.sample
./.git/hooks/update.sample
./.git/hooks/pre-applypatch.sample
./.git/hooks/push-to-checkout.sample
./.git/hooks/pre-merge-commit.sample
./.git/hooks/post-update.sample
./.git/hooks/pre-push.sample
./.git/hooks/fsmonitor-watchman.sample
./.git/description
./.git/refs
./.git/refs/heads
./.git/refs/heads/main
./.git/refs/tags
./.git/refs/remotes
./.git/refs/remotes/origin
./.git/refs/remotes/origin/HEAD
./.git/packed-refs
./.git/config
./.git/index
./.git/HEAD
./.git/branches
./.git/logs
./.git/logs/refs
./.git/logs/refs/heads
./.git/logs/refs/heads/main
./.git/logs/refs/remotes
./.git/logs/refs/remotes/origin
./.git/logs/refs/remotes/origin/HEAD
./.git/logs/HEAD
./README.md
./to_davinci.sh com 
- **Pasta de saída:** Mude  para outro nome

## 📋 Checklist de Compatibilidade DaVinci Resolve Free (Linux)

| Formato | Código | Suportado? |
|---------|--------|------------|
| MPEG-4 Part 2 (.mov) |  | ✅ **Sim** (Recomendado) |
| Apple ProRes (.mov) |  | ❌ Não (requer licença) |
| DNxHR/DNxHD (.mov) |  | ⚠️ Parcial |
| H.264/H.265 (.mp4) | / | ❌ Não (Free version) |
| PCM Audio (.wav/.mov) |  | ✅ **Sim** |
| AAC Audio |  | ❌ Não |

## 🤝 Contribuindo

1. Fork o projeto
2. Crie branch ()
3. Commit (On branch feature/melhoria
nothing to commit, working tree clean)
4. Push ()
5. Pull Request

### Ideias de Melhoria
- [ ] Suporte a processamento paralelo ( ou )
- [ ] Barra de progresso visual
- [ ] Log detalhado em arquivo ()
- [ ] Modo *dry-run* (simula sem converter)
- [ ] Suporte a legendas (,  → convertendo para texto)

## 📄 Licença

Este projeto está sob a licença **MIT**. Veja [LICENSE](LICENSE).

## 🙏 Créditos

- **Ideia original:** Henrique ([Diolinux](https://www.diolinux.com.br/2019/02/codecs-certos-no-davinci-resolve.html)) e Mateus Müller
- **Refatoração, expansão e documentação:** Paulo Rabelo (com suporte de IA)

## 👨‍💻 Autor

**Paulo Rabelo**
- GitHub: [@paulorabelo](https://github.com/paulorabelo)
- Blog: [blog.paulorabelo.dev.com.br](https://blog.paulorabelo.dev.com.br)
- LinkedIn: [Paulo Rabelo](https://www.linkedin.com/in/paulorabelooficial/)

---

<div align="center">
  <sub>Feito para a comunidade Linux + DaVinci Resolve 🎬</sub><br>
  <sub>Se este script economizou seu tempo, <a href="https://github.com/paulorabelo/to-davinci-media-converter">⭐ deixe uma estrela!</a></sub>
</div>
