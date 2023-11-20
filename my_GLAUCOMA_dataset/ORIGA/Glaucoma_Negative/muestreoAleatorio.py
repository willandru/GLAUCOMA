import os
import random
import shutil

# Obtener la lista de archivos en el directorio actual
files_in_directory = os.listdir(os.getcwd())

# Seleccionar al azar 20 archivos (puedes ajustar este número según tus necesidades)
selected_files = random.sample(files_in_directory, min(20, len(files_in_directory)))

# Crear la carpeta sampled_20 si no existe
sampled_folder_path = os.path.join(os.getcwd(), 'sampled_20')
os.makedirs(sampled_folder_path, exist_ok=True)

# Copiar los archivos seleccionados a la carpeta sampled_20
for file_name in selected_files:
    source_path = os.path.join(os.getcwd(), file_name)
    destination_path = os.path.join(sampled_folder_path, file_name)
    shutil.copy2(source_path, destination_path)

print("Proceso completado. Se copiaron {} archivos al azar a la carpeta 'sampled_20'.".format(len(selected_files)))
