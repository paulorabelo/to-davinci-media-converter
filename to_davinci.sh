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
# COMO USAR?
# $ ./to_davinci.sh /caminho/para/os/videos
#
# ------------------------------------------------------------------------ #
# Changelog:
#
#   v1.0 07/03/2019, Mateus Muller:
#     - Primeira versao.
#   v1.1 23/09/2019, Mateus Muller:
#     - Corrigido bug no find.
#   v1.2 06/10/2019, Mateus Muller:
#     - Adicionado "uniq".
#   v2.0 22/11/2025, Paulo & Gemini 3.0:
#     - Adicionado suporte HIBRIDO (Video e Audio no mesmo script).
#     - Audio agora converte para .wav (PCM).
#     - Video mantem conversao para .mov (MPEG4).
#
# ------------------------------------------------------------------------ #
# Testado em:
#   bash 5.0.3
#   zsh 5.9
# ------------------------------------------------------------------------ #
#
# -------------------------------VARIAVEIS----------------------------------------- #
DESTINO_CONVERTER="$1"
IFS=$'\n'

# -------------------------------EXECUCAO----------------------------------------- #

echo "=== INICIANDO CONVERSAO HIBRIDA (v2.0) ==="
echo "Analise recursiva em: $DESTINO_CONVERTER"
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
    # Cria a pasta 'convertidos' DENTRO do diretorio onde achou os arquivos
    if [ ! -d "$diretorio_conversao/convertidos" ]; then
        echo "Criando pasta: $diretorio_conversao/convertidos"
        mkdir "$diretorio_conversao/convertidos"
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

      # Define o caminho de saida (agora local)
      CAMINHO_SAIDA="$diretorio_conversao/convertidos"

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
            # Flag -vn garante que ignoramos video (capas de album, etc)
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