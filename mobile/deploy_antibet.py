--- FILE START: deploy_antibet.py --- CONTENT START:
import argparse
import os
import re

def deploy_files(delivery_file):
    """Lê o arquivo de entrega e implanta os arquivos no sistema de arquivos."""
    print("--- ORION Deployment Utility (Python) ---")
    
    if not os.path.exists(delivery_file):
        print(f"ERROR: Deployment file '{delivery_file}' not found.")
        return

    # MODO FINAL: Lê o arquivo inteiro e limpa caracteres invisíveis
    try:
        # Usa 'utf-8-sig' para ler o arquivo de forma segura, ignorando BOM
        with open(delivery_file, 'r', encoding='utf-8-sig') as f:
            content = f.read()
    except Exception as e:
        print(f"ERROR reading delivery file: {e}")
        return

    # 1. Normaliza quebras de linha e limpa caracteres de retorno de carro
    content = content.replace('\r\n', '\n').replace('\r', '\n')
    
    # 2. Divide os blocos usando a string exata, ignorando regex flags complexas
    tag_start = '--- FILE START: '
    tag_content_start = '--- CONTENT START:\n'
    tag_content_end = '\n--- CONTENT END: ---'
    
    file_blocks = content.split(tag_start)
    files_to_deploy = file_blocks[1:]
    
    if not files_to_deploy:
        print("No files found for deployment. Check file content and tags.")
        return

    print(f"{len(files_to_deploy)} files found. Starting deployment...")
    deployed_count = 0

    for block in files_to_deploy:
        try:
            # 3. Extrai o caminho (tudo até o CONTENT START)
            path_end = block.find(tag_content_start)
            if path_end == -1: continue

            relative_path = block[:path_end].strip()
            
            # 4. Extrai o conteúdo (entre CONTENT START e CONTENT END)
            content_start_index = path_end + len(tag_content_start)
            content_end_index = block.rfind(tag_content_end)

            if content_end_index == -1: continue

            file_content = block[content_start_index:content_end_index].strip()
            
            # 5. Salva o arquivo
            full_path = os.path.join(os.getcwd(), relative_path)
            directory = os.path.dirname(full_path)

            if not os.path.exists(directory):
                os.makedirs(directory, exist_ok=True)
                # print(f"Created directory: {directory}")

            with open(full_path, 'w', encoding='utf-8') as outfile:
                outfile.write(file_content)
            print(f"Successfully deployed: {relative_path}")
            deployed_count += 1
            
        except Exception as e:
            print(f"ERROR deploying block: {e}")

    print("--- Deployment Complete ---")
    print(f"{deployed_count} files successfully deployed.")

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="ORION Deployment Utility for AntiBet.")
    parser.add_argument('--delivery', type=str, required=True, help="The path to the delivery text file (e.g., 'orion_delivery.txt').")
    args = parser.parse_args()
    
    deploy_files(args.delivery)
--- CONTENT END: ---