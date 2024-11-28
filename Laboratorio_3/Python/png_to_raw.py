import os
from PIL import Image

def convert_png_to_raw_rgb565(input_folder="pngs", output_folder="raws"):
    # Crear carpeta de salida si no existe
    if not os.path.exists(output_folder):
        os.makedirs(output_folder)

    # Recorrer cada archivo en la carpeta de entrada
    for filename in os.listdir(input_folder):
        if filename.endswith(".png"):
            # Ruta completa del archivo de entrada
            input_path = os.path.join(input_folder, filename)

            # Cargar la imagen
            with Image.open(input_path) as img:
                # Asegurar que la imagen esté en modo RGB
                img = img.convert("RGB")

                # Obtener los píxeles en formato RGB565
                rgb565_data = []
                for r, g, b in img.getdata():
                    # Convertir cada píxel a RGB565
                    r5 = (r >> 3) & 0x1F
                    g6 = (g >> 2) & 0x3F
                    b5 = (b >> 3) & 0x1F
                    rgb565 = (r5 << 11) | (g6 << 5) | b5
                    rgb565_data.append(rgb565)

                # Convertir los valores a bytes
                raw_data = bytearray()
                for color in rgb565_data:
                    raw_data.append((color >> 8) & 0xFF)  # Byte alto
                    raw_data.append(color & 0xFF)        # Byte bajo

                # Guardar el archivo .raw
                output_filename = os.path.splitext(filename)[0] + ".raw"
                output_path = os.path.join(output_folder, output_filename)
                with open(output_path, "wb") as raw_file:
                    raw_file.write(raw_data)

                print(f"Convertido: {input_path} -> {output_path}")

# Ejecutar la conversión
convert_png_to_raw_rgb565()
