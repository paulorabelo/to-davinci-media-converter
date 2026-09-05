#!/usr/bin/env bash
#
# to_davinci.sh - Script para conversao de videos e audios para o DaVinci Resolve.
#
# Website:     https://4fasters.com.br
# Autor:       Mateus Gabriel Muller
#
# Creditos:
# Os creditos vao todos para o Henrique da equipe do Diolinux que lancou a ideia.
# >>>> https://www.diolinux.com.br/2019/02/codecs-certos-no-davinci-resolve.html <<<<
#
# ------------------------------------------------------------------------ #
# O QUE ELE FAZ?
# Recebe como parametro um diretorio e faz uma busca recursiva de arquivos de
# video e audio, convertendo para formatos amigaveis ao DaVinci Resolve (MPEG4/PCM).
# Ele cria uma subpasta chamada "convertidos" dentro de cada local encontrado.
#
# ------------------------------------------------------------------------ #
# COMO USAR?
# Modo padrão (cria pasta "convertidos" junto aos originais):
# $ ./to_davinci.sh /caminho/para/os/videos
#
# Modo com destino personalizado:
# $ ./to_davinci.sh /caminho/para/os/videos /caminho/para/destino
# ------------------------------------------------------------------------ #

DESTINO_CONVERTER="$1"
DIRETORIO_DESTINO_CUSTOM="$2"
IFS=$'\n'

echo "=== INICIANDO CONVERSAO HIBRIDA (v2.1) ==="
echo "Analise recursiva em: $DESTINO_CONVERTER"

# Se o segundo argumento foi informado, valida ou cria a pasta de destino global
if [ -n "$DIRETORIO_DESTINO_CUSTOM" ]; then
    mkdir -p "$DIRETORIO_DESTINO_CUSTOM"
    echo "Destino personalizado definido: $DIRETORIO_DESTINO_CUSTOM"
else
    echo "Destino: Pasta 'convertidos' local ao lado dos originais"
fi
echo "------------------------------------------"

# 1. Busca DIRETORIOS que contenham videos OU audios
for diretorio_conversao in $(find "$DESTINO_CONVERTER" -type f \( \
                                                               -iname \*.mov \
                                                               -o -iname \*.mp4 \
                                                               -o -iname \*.mkv \
                                                               -o -iname \*.webm \
                                                               -o -iname \*.m4a \
                                                               -o -iname \*.mp3 \
                                                               -o -iname \*.wav \
                                                               -o -iname \*.ogg \
                                                               \) -printf "%h\n" | \
                                                               sort | \
                                                               uniq)
do
    # Define o caminho de saida dinamicamente
    if [ -n "$DIRETORIO_DESTINO_CUSTOM" ]; then
        CAMINHO_SAIDA="$DIRETORIO_DESTINO_CUSTOM"
    else
        CAMINHO_SAIDA="$diretorio_conversao/convertidos"
        if [ ! -d "$CAMINHO_SAIDA" ]; then
            echo "Criando pasta: $CAMINHO_SAIDA"
            mkdir -p "$CAMINHO_SAIDA"
        fi
    fi

    # 2. Busca ARQUIVOS dentro dessas pastas para processar
    for arquivo_conversao in $(find "$diretorio_conversao" -type f \( \
                                                                   -iname \*.mov \
                                                                   -o -iname \*.mp4 \
                                                                   -o -iname \*.mkv \
                                                                   -o -iname \*.webm \
                                                                   -o -iname \*.m4a \
                                                                   -o -iname \*.mp3 \
                                                                   -o -iname \*.wav \
                                                                   -o -iname \*.ogg \
                                                                   \) -printf "%f\n")
    do
      
      # Pega a extensao do arquivo e converte para minuscula
      EXTENSAO="${arquivo_conversao##*.}"
      EXTENSAO="${EXTENSAO,,}" 

      # --- LOGICA DE DECISAO ---
      
      # CASO 1: E VIDEO?
      if [[ "$EXTENSAO" == "mp4" || "$EXTENSAO" == "mov" || "$EXTENSAO" == "mkv" || "$EXTENSAO" == "webm" ]]; then
          
          NOME_SAIDA="${arquivo_conversao%.*}.mov"
          
          if [ ! -f "$CAMINHO_SAIDA/$NOME_SAIDA" ]; then
            echo "[VIDEO] Convertendo: $arquivo_conversao"
            ffmpeg -v error -i "$diretorio_conversao/$arquivo_conversao" \
                   -codec:v mpeg4 -q:v 0 \
                   -codec:a pcm_s16le \
                   -max_muxing_queue_size 9999 \
                   "$CAMINHO_SAIDA/$NOME_SAIDA"
          else
            echo "[VIDEO] Ja existe: $NOME_SAIDA"
          fi

      # CASO 2: E AUDIO?
      elif [[ "$EXTENSAO" == "m4a" || "$EXTENSAO" == "mp3" || "$EXTENSAO" == "wav" || "$EXTENSAO" == "ogg" ]]; then
          
          NOME_SAIDA="${arquivo_conversao%.*}.wav"

          if [ ! -f "$CAMINHO_SAIDA/$NOME_SAIDA" ]; then
            echo "[AUDIO] Convertendo: $arquivo_conversao"
            ffmpeg -v error -i "$diretorio_conversao/$arquivo_conversao" \
                   -vn \
                   -codec:a pcm_s16le \
                   "$CAMINHO_SAIDA/$NOME_SAIDA"
          else
            echo "[AUDIO] Ja existe: $NOME_SAIDA"
          fi
      fi

    done
done

echo "------------------------------------------"
echo "Processo finalizado!"