import os
import glob
import serial
import time

# Configuración para la comunicación serial (ajusta estos valores según sea necesario)
SERIAL_PORT = 'COM6'  # Actualiza con el puerto correcto
BAUD_RATE = 9600
START_CMD = b'\x01'  # Comando de inicio (utiliza el valor de byte adecuado)
ACK_CMD = b'\x02'    # Comando de reconocimiento
NACK_CMD = b'\x03'   # Comando de rechazo

# Directorio que contiene las imágenes
image_folder = 'C:\\Users\\Jeffrey\\OneDrive - Estudiantes ITCR\\V año II Semestre\\2. Taller de Diseño Digital\\Laboratorio 3\\Aplicacion RV32I\\rawimages' # Actualiza con la ruta de tu carpeta

# Cargar 8 imágenes desde la carpeta especificada
def load_images(folder_path):
    images = []
    image_files = sorted(glob.glob(os.path.join(folder_path, '*')))  # Obtiene todos los archivos en la carpeta
    for image_file in image_files[:8]:  # Solo lee los primeros 8 archivos
        with open(image_file, 'rb') as file:
            images.append(file.read())  # Lee el archivo como datos binarios
    print("Imágenes cargadas:", [os.path.basename(f) for f in image_files[:8]])
    return images

# Función para enviar una sola imagen a la FPGA
def send_image(ser, image):
    ser.write(image)  # Envía los datos de la imagen
    print("Datos de imagen enviados.")

def main():
    # Cargar las imágenes en la lista
    images = load_images(image_folder)
    if len(images) < 8:
        print("Advertencia: Se encontraron menos de 8 imágenes. Asegúrate de que haya 8 imágenes en la carpeta.")
    
    try:
        # Abre el puerto serial
        ser = serial.Serial(SERIAL_PORT, BAUD_RATE, timeout=1)
        time.sleep(2)  # Espera para que la conexión serial se inicialice

        for index, image in enumerate(images):
            print(f"\nIniciando transmisión para la imagen {index + 1}")

            # Envía el comando de inicio y espera aceptación
            ser.write(START_CMD)
            print("Comando de inicio enviado. Esperando respuesta de la FPGA...")

            # Espera el reconocimiento de la FPGA para comenzar
            start_time = time.time()
            while time.time() - start_time < 5:  # Tiempo de espera de 5 segundos
                if ser.in_waiting > 0:
                    response = ser.read(1)
                    if response == ACK_CMD:
                        print("Comando de inicio aceptado por la FPGA. Enviando imagen...")
                        send_image(ser, image)  # Solo envía la imagen si el comando de inicio es aceptado
                        break  # Pasa a la siguiente imagen en caso de éxito
                    elif response == NACK_CMD:
                        print("Comando de inicio rechazado por la FPGA. Abortando transmisión.")
                        return
            else:
                print("No hubo respuesta al comando de inicio. Abortando transmisión.")
                return

        print("\nLas imágenes han sido transmitidas con éxito.")
    
    except serial.SerialException as e:
        print(f"Error en la comunicación serial: {e}")
    except Exception as e:
        print(f"Ocurrió un error: {e}")
    finally:
        if 'ser' in locals():  # Verifica si 'ser' fue creado
            ser.close()  # Cierra el puerto serial
            print("Puerto serial cerrado.")

# Llamar a la función main directamente
if __name__ == "__main__":
    main()