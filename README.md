# 🎬 DaVinci Resolve Media Converter (Linux)

Um script em Bash robusto e automatizado para preparar arquivos de mídia (vídeo e áudio) para edição no DaVinci Resolve em ambientes Linux (especialmente Mint/Ubuntu).

Este script resolve o problema comum da versão gratuita do DaVinci Resolve no Linux não suportar codecs proprietários como AAC ou H.264/H.265, convertendo-os automaticamente para formatos compatíveis e amigáveis para edição.

## 🚀 Funcionalidades

- **Híbrido:** Detecta e processa tanto vídeos quanto áudios na mesma execução.
    
- **Recursivo:** Varre todas as subpastas do diretório alvo.
    
- **Organizado:** Cria uma pasta `convertidos` dentro de cada diretório original, mantendo a estrutura do projeto.
    
- **Inteligente:** Pula arquivos que já foram convertidos anteriormente.
    
- **Codecs Otimizados:**
    
    - **Vídeo:** Converte para MPEG-4 (Visual) com qualidade máxima (`q:v 0`) e áudio PCM.
        
    - **Áudio:** Converte para WAV (PCM 16-bit), ideal para edição sem perdas.
        

## 🛠️ Requisitos

- `bash` ou `zsh`
    
- `ffmpeg`
    

Bash

```
# Para instalar o ffmpeg no Ubuntu/Mint/Debian:
sudo apt install ffmpeg
```

## 📦 Como Usar

1. Dê permissão de execução ao script:
    
    Bash
    
    ```
    chmod +x to_davinci.sh
    ```
    
2. Execute apontando para a pasta onde estão seus arquivos originais:
    
    Bash
    
    ```
    ./to_davinci.sh /home/usuario/MeusVideos
    ```
    

---

## 🔍 Explicação Técnica (Code Breakdown)

Abaixo, o detalhamento do funcionamento interno do script para fins de estudo e manutenção.

### 1. Definição de Variáveis e Ambiente

Bash

```
DESTINO_CONVERTER="$1"
IFS=$'\n'
```

- **`DESTINO_CONVERTER`**: Captura o primeiro argumento passado via linha de comando (o caminho da pasta alvo).
    
- **`IFS=$'\n'`**: Redefine o _Internal Field Separator_ para quebra de linha. Isso é crucial para que o script não quebre ao encontrar arquivos com espaços no nome (ex: "Meu Video.mp4").
    

### 2. O Primeiro Loop (Mapeamento de Diretórios)

Bash

```
for diretorio_conversao in $(find "$DESTINO_CONVERTER" ... -printf "%h\n" | sort | uniq)
```

O script não busca arquivos imediatamente para conversão. Primeiro, ele mapeia **quais pastas** contêm arquivos de interesse.

- **`find ... -type f`**: Busca apenas arquivos.
    
- **`-iname`**: Busca extensões ignorando maiúsculas/minúsculas (vídeos e áudios).
    
- **`-printf "%h\n"`**: Imprime apenas o diretório pai onde o arquivo foi encontrado.
    
- **`sort | uniq`**: Remove duplicatas, gerando uma lista limpa de pastas para processar.
    

### 3. Criação da Pasta de Destino

Bash

```
if [ ! -d "$diretorio_conversao/convertidos" ]; then
    mkdir "$diretorio_conversao/convertidos"
fi
```

Para cada pasta encontrada no passo anterior, o script verifica se existe uma subpasta chamada `convertidos`. Se não existir, ela é criada. Isso mantém os arquivos gerados organizados junto aos originais.

### 4. O Segundo Loop (Processamento de Arquivos)

Bash

```
for arquivo_conversao in $(find "$diretorio_conversao" ... -printf "%f\n")
```

Agora, dentro de cada pasta específica, o script lista os arquivos novamente, mas desta vez pegando apenas o nome do arquivo (`%f`).

### 5. Normalização de Extensão

Bash

```
EXTENSAO="${arquivo_conversao##*.}"
EXTENSAO="${EXTENSAO,,}"
```

- **`${var##*.}`**: Remove tudo antes do último ponto, isolando a extensão.
    
- **`${var,,}`**: Converte a string da extensão para letras minúsculas. Isso garante que `.MP4`, `.Mp4` e `.mp4` sejam tratados igualmente.
    

### 6. A Lógica de Decisão (Vídeo vs. Áudio)

O script utiliza condicionais `if/elif` para decidir qual comando `ffmpeg` utilizar.

#### Tratamento de Vídeo (.mp4, .mov, etc.)

Bash

```
ffmpeg -i "input" -codec:v mpeg4 -q:v 0 -codec:a pcm_s16le "output.mov"
```

- **`-codec:v mpeg4 -q:v 0`**: Transcodifica o vídeo para MPEG-4 Part 2 com o fator de qualidade máximo (lossless ou visualmente lossless). Este formato é nativamente suportado pelo Linux Mint e DaVinci Free.
    
- **`-codec:a pcm_s16le`**: Converte o áudio para PCM (WAV não comprimido) 16-bit, evitando problemas de sincronia e incompatibilidade de codecs como AAC.
    

#### Tratamento de Áudio (.m4a, .mp3, etc.)

Bash

```
ffmpeg -i "input" -vn -codec:a pcm_s16le "output.wav"
```

- **`-vn`**: "Video Null". Garante que qualquer stream de vídeo (comum em arquivos de áudio que contêm a capa do álbum embutida) seja descartado, prevenindo erros.
    
- **Saída .wav**: Gera um arquivo de áudio puro, padrão da indústria para edição.
    

---
Créditos

Baseado na ideia original de Henrique ([Diolinux](https://www.diolinux.com.br/2019/02/codecs-certos-no-davinci-resolve.html)) e Mateus Müller. Refatorado e expandido por Paulo com suporte de IA.
