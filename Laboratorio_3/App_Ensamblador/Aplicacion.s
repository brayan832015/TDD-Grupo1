.section .data
# current_image_count: .word 0     # Contador de imágenes
max_images:         .word 8      # Número máximo de imágenes permitido

# .org 0x40000                     # buffer inicia en el address 262144 (0x40000)
# buffer: .space 129600            # Buffer para almacenar 8 imágenes (8 * 64800 bytes / 4)

.section .text
.globl _start

_start:
    # Iniciar en modo REPOSO
    li s1, 0x00040000           # Dirección inicial RAM
    jal reposo_mode

# -----------------------------------------------------
# Modo REPOSO
# -----------------------------------------------------
reposo_mode:
    li t0, 0x02000              # Dirección de los interruptores
    lw t1, 0(t0)                # Leer estado de los interruptores

    # Verificar si se presiona un botón para activar modo DESPLEGAR
    andi t2, t1, 0x01           # Asumiendo que el botón para DESPLEGAR es el bit 0
    bnez t2, desplegar_mode     # Si el bit 0 está activo, ir a modo DESPLEGAR

    # Verificar si hay datos en el UART para activar modo ALMACENAMIENTO
    li t3, 0x02010              # Dirección del registro de control del UART
    lw t4, 0(t3)                # Leer estado del UART
    andi t4, t4, 0x00000002           # Verificar si hay datos listos para leer
    bnez t4, almacenamiento_mode # Si hay datos, ir a modo ALMACENAMIENTO

    # Permanecer en modo REPOSO si no hay eventos
    j reposo_mode

# -----------------------------------------------------
# Modo ALMACENAMIENTO
# -----------------------------------------------------
almacenamiento_mode:
    # Llamar a modo RETRANSMITER para verificar el comando
    jal retransmiter_mode

    beqz a0, exit_almacenamiento_mode  # Si RETRANSMITER falla, salir

    # Comenzar a recibir imagen desde la PC
    # la t5, buffer               # Dirección inicial del buffer para almacenar la imagen
    # li s1, 0x00040000           # Dirección inicial RAM
    li t6, 64800                # Tamaño de la imagen en bytes (240 * 135 * 2)

almacenamiento_loop:
    # Leer cada byte del UART y almacenarlo en RAM
    li t3, 0x02010              # Dirección del registro de control del UART
    lw t5, 0(t3)                # Leer estado del UART
    andi t2, t5, 0x02           # Verificar si hay datos listos para leer
    beqz t2, almacenamiento_loop # Esperar hasta que haya datos

    li t4, 0x0201C              # Dirección del UART para recibir datos
    lb t2, 0(t4)                # Leer byte del UART
    sb t2, 0(s1)                # Almacenar byte en RAM
    addi s1, s1, 1              # Incrementar dirección en RAM
    addi t6, t6, -1             # Decrementar tamaño restante

    #########
    andi s2, t5, 0x01
    bnez s2, escribir1
    li t0, 0x00                 # Apagar new_rx
    sw t0, 0(t3)                # Escribir reg control
    j guardar_RAM
    #########

escribir1:
    li t0, 0x01                 # Dejar send activo
    sw t0, 0(t3)                # Escribir reg control

guardar_RAM:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

    bnez t6, almacenamiento_loop   # Repetir hasta que la imagen esté completa

    # Actualizar contador de imágenes
    li t0, 0x02004
    lw t3, 0(t0)                # Leer contador de imágenes
    addi t3, t3, 1              # Incrementar contador
    sw t3, 0(t0)                # Almacenar contador actualizado

    # Verificar si se excede el límite de imágenes
    la t0, max_images           # Cargar la dirección de max_images
    lw t4, 0(t0)
    bge t3, t4, deny_image      # Si se excede, negar más imágenes

exit_almacenamiento_mode:
    j reposo_mode               # Regresar al modo REPOSO

# -----------------------------------------------------
# Modo RETRANSMITER (subrutina de almacenamiento)
# -----------------------------------------------------
retransmiter_mode:
    li t0, 0x0201C              # Dirección del registro de datos para recibir
    li t1, 0x01                 # Comando esperado para iniciar la transferencia de imagen
    # Leer comando desde UART
    lb t2, 0(t0)
    beq t2, t1, send_ack        # Si el comando es correcto, enviar confirmación
    li a0, 0                    # Si es incorrecto, regresar 0 (fallo)
    jalr ra                     # Regresar a la dirección de retorno

send_ack:
    li t0, 0x02018              # Dirección del registro de datos para enviar
    li t3, 0x02                 # Comando aceptación
    sw t3, 0(t0)                # Cargar registro de datos con comando aceptación
    li t0, 0x02010              # Dirección del registro de control
    li t3, 0x01                 # Señal para iniciar la transmisión
    sw t3, 0(t0)                # Enviar señal de inicio a través del UART
    li a0, 1                    # Indicar éxito
    jalr ra                     # Regresar a la dirección de retorno

deny_image:
    li t0, 0x02018              # Dirección del registro de datos para enviar
    li t3, 0x03                 # Código de negación
    sw t3, 0(t0)                # Enviar negación a través del UART
    li t0, 0x02010              # Dirección del registro de control
    li t3, 0x01                 # Señal para iniciar la transmisión
    sw t3, 0(t0)                # Enviar señal de inicio a través del UART
    j reposo_mode               # Regresar al modo REPOSO

# -----------------------------------------------------
# Modo DESPLEGAR
# -----------------------------------------------------

desplegar_mode:
    # Recuperar contador de imágenes almacenadas
    la t0, current_image_count  # Cargar la dirección de current_image_count
    lw t5, 0(t0)
    beqz t5, exit_desplegar_mode  # Salir si no hay imágenes

    # Dirección inicial en RAM para la última imagen
    # la t6, buffer               # Cargar la dirección del buffer
    slli t5, t5, 14            # Multiplicar por 16200 para el offset de la imagen
    add t6, t6, t5

desplegar_loop:
    # Enviar cada byte de la imagen a través del UART
    lb t2, 0(t6)                # Leer byte de la RAM
    li t4, 0x02018              # Dirección del UART para datos
    sb t2, 0(t4)                # Enviar byte a través del UART
    addi t6, t6, 1              # Siguiente byte
    addi t5, t5, -1             # Decrementar tamaño de la imagen
    bnez t5, desplegar_loop     # Continuar hasta enviar toda la imagen

exit_desplegar_mode:
    j reposo_mode               # Regresar al modo REPOSO
