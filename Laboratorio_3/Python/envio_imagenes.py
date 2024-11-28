import os
import glob
import serial
import time
from PIL import Image
import numpy as np

# Configuración para la comunicación serial
SERIAL_PORT = 'COM4'  
BAUD_RATE = 9600
START_CMD = b'\xFF'  # Comando de inicio
ACK_CMD = b'\x02'    # Comando de reconocimiento
NACK_CMD = b'\x03'   # Comando de rechazo

# Directorio que contiene las imágenes
image_folder = r'C:\Users\brabarmad\OneDrive - Estudiantes ITCR\Escritorio\Imagenes y python\raws'

# Archivo de log
log_file_path = 'serial_transmission_log.txt'

# Función para escribir en el archivo de log
def log_message(message):
    with open(log_file_path, 'a') as log_file:
        log_file.write(f"{time.strftime('%Y-%m-%d %H:%M:%S')} - {message}\n")

# Función para convertir datos a binario
def data_to_binary(data):
    return ' '.join(format(byte, '08b') for byte in data)

# Cargar imágenes desde la carpeta especificada
def load_images(folder_path):
    image_files = sorted(glob.glob(os.path.join(folder_path, '*')))
    log_message("Imágenes disponibles: " + ', '.join([os.path.basename(f) for f in image_files]))
    print("Imágenes disponibles:", [os.path.basename(f) for f in image_files])
    return image_files

# Decodificar imagen en formato RGB565 y mostrarla
def display_image_from_rgb565(data, width, height):
    pixels = []
    for i in range(0, len(data), 2):
        pixel = data[i] << 8 | data[i + 1]
        r = (pixel >> 11) & 0x1F
        g = (pixel >> 5) & 0x3F
        b = pixel & 0x1F
        r = (r << 3) | (r >> 2)
        g = (g << 2) | (g >> 4)
        b = (b << 3) | (b >> 2)
        pixels.append((r, g, b))
    
    image = Image.fromarray(np.array(pixels, dtype=np.uint8).reshape((height, width, 3)))
    image.show()

# Función para enviar una sola imagen a la FPGA
def send_image(ser, image_path, width, height):
    with open(image_path, 'rb') as file:
        image_data = file.read()
    
    ser.write(image_data)  # Envía los datos de la imagen
    binary_data = data_to_binary(image_data)
    log_message(f"Datos binarios enviados de '{os.path.basename(image_path)}': {binary_data}")
    print(f"Datos de imagen '{os.path.basename(image_path)}' enviados.")
    
    # Decodificar y mostrar la imagen
    display_image_from_rgb565(image_data, width, height)

def main():
    IMAGE_WIDTH = 240
    IMAGE_HEIGHT = 135

    # Cargar las imágenes disponibles
    image_files = load_images(image_folder)
    if not image_files:
        log_message("No se encontraron imágenes en la carpeta especificada.")
        print("No se encontraron imágenes en la carpeta especificada.")
        return
    
    try:
        # Abre el puerto serial
        ser = serial.Serial(SERIAL_PORT, BAUD_RATE, timeout=1)
        log_message("Puerto serial abierto.")
        time.sleep(2)  # Espera para inicializar la conexión

        while True:
            print("\nSelecciona una imagen para enviar (0 para salir):")
            for idx, file in enumerate(image_files, start=1):
                print(f"{idx}. {os.path.basename(file)}")
            
            choice = input("Ingresa el número de la imagen: ")
            if choice == '0':
                log_message("El usuario decidió salir del programa.")
                print("Saliendo del programa.")
                break

            try:
                choice_idx = int(choice) - 1
                if choice_idx < 0 or choice_idx >= len(image_files):
                    log_message("Opción inválida seleccionada.")
                    print("Opción inválida. Intenta de nuevo.")
                    continue
                
                image_path = image_files[choice_idx]
                log_message(f"Iniciando transmisión para la imagen '{os.path.basename(image_path)}'.")

                # Envía el comando de inicio y espera aceptación
                ser.write(START_CMD)
                log_message(f"Comando de inicio enviado: {data_to_binary(START_CMD)}")
                print("Comando de inicio enviado. Esperando respuesta de la FPGA...")

                start_time = time.time()
                while time.time() - start_time < 5:
                    if ser.in_waiting > 0:
                        response = ser.read(1)
                        response_binary = data_to_binary(response)
                        if response == ACK_CMD:
                            log_message(f"Respuesta de la FPGA: ACK ({response_binary})")
                            print("Comando de inicio aceptado por la FPGA. Enviando imagen...")
                            send_image(ser, image_path, IMAGE_WIDTH, IMAGE_HEIGHT)
                            break
                        elif response == NACK_CMD:
                            log_message(f"Respuesta de la FPGA: NACK ({response_binary})")
                            print("Comando de inicio rechazado por la FPGA. Abortando transmisión.")
                            break
                else:
                    log_message("No hubo respuesta al comando de inicio. Intento fallido.")
                    print("No hubo respuesta al comando de inicio. Intenta de nuevo.")

            except ValueError:
                log_message("Entrada inválida ingresada por el usuario.")
                print("Entrada inválida. Ingresa un número válido.")

        log_message("Finalizando programa.")
        print("\nFinalizando programa.")

    except serial.SerialException as e:
        log_message(f"Error en la comunicación serial: {e}")
        print(f"Error en la comunicación serial: {e}")
    except Exception as e:
        log_message(f"Ocurrió un error inesperado: {e}")
        print(f"Ocurrió un error: {e}")
    finally:
        if 'ser' in locals():
            ser.close()
            log_message("Puerto serial cerrado.")
            print("Puerto serial cerrado.")

if __name__ == "__main__":
    main()
