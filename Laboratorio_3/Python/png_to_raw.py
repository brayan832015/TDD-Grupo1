import os
from PIL import Image
import numpy as np

def convert_to_raw_rgb565(image_path, output_path):
    # Cargar la imagen y convertirla a RGB
    img = Image.open(image_path).convert('RGB')
    img_data = np.array(img, dtype=np.uint8)  # Convierte a un array de 8 bits por canal

    # Crear un array para almacenar el formato RGB565
    rgb565_data = np.zeros((img_data.shape[0], img_data.shape[1]), dtype=np.uint16)
    
    # Convertir cada pixel a RGB565
    for y in range(img_data.shape[0]):
        for x in range(img_data.shape[1]):
            r, g, b = img_data[y, x]
            # R en los primeros 5 bits, G en los siguientes 6 bits, B en los últimos 5 bits
            rgb565 = ((r & 0xF8) << 8) | ((g & 0xFC) << 3) | (b >> 3)
            rgb565_data[y, x] = rgb565

    # Guardar como archivo RAW de 16 bits
    with open(output_path, 'wb') as raw_file:
        raw_file.write(rgb565_data.tobytes())

# Función para procesar todas las imágenes en la carpeta "pngs"
def batch_convert_png_to_raw(input_folder, output_folder):
    # Crear la carpeta de salida si no existe
    os.makedirs(output_folder, exist_ok=True)

    # Procesar los archivos de imagen numerados de 1 a 8
    for i in range(1, 9):
        input_path = os.path.join(input_folder, f"{i}.png")
        output_path = os.path.join(output_folder, f"{i}.raw")

        if os.path.exists(input_path):
            print(f"Convirtiendo {input_path} a {output_path} en formato RGB565...")
            convert_to_raw_rgb565(input_path, output_path)
            print(f"Imagen {i}.png convertida y guardada como {i}.raw")
        else:
            print(f"Advertencia: {input_path} no existe. Verifica el archivo.")

# Ejemplo de uso
input_folder = "./pngs"
output_folder = "./raws"
batch_convert_png_to_raw(input_folder, output_folder)
