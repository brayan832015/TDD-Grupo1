.section .data
current_image_count: .word 0     # Contador de imágenes
max_images:         .word 8      # Número máximo de imágenes permitido
buffer:             .space 129600 # Buffer para almacenar 8 imágenes (8 * 16200 bytes)

.section .text
.globl _start

_start:
    jal reposo_mode              # Iniciar en modo REPOSO

# -----------------------------------------------------
# Modo REPOSO
# -----------------------------------------------------
reposo_mode:
    li t0, 0x02000               # Dirección de los interruptores
    lw t1, 0(t0)                 # Leer estado de los interruptores

    andi t2, t1, 0x01            # Verificar botón para DESPLEGAR (bit 0)
    bnez t2, desplegar_mode      # Si está activo, ir al modo DESPLEGAR

    li t3, 0x02010               # Dirección del registro de control del UART
    lw t4, 0(t3)                 # Verificar estado del UART
    andi t4, t4, 0x01            # Verificar si hay datos listos para leer
    bnez t4, almacenamiento_mode # Ir a ALMACENAMIENTO si hay datos disponibles

    j reposo_mode                # Permanecer en modo REPOSO si no hay eventos

# -----------------------------------------------------
# Modo ALMACENAMIENTO
# -----------------------------------------------------
almacenamiento_mode:
    jal retransmiter_mode
    beqz a0, exit_almacenamiento_mode  # Salir si RETRANSMITER falla

    la t5, buffer                # Dirección inicial del buffer para almacenar la imagen
    li t6, 16200                 # Tamaño de la imagen en bytes

almacenamiento_loop:
    li t3, 0x02010               # Dirección del registro de control del UART
    lw t2, 0(t3)
    andi t2, t2, 0x01            # Verificar si hay datos listos para leer
    beqz t2, almacenamiento_loop # Esperar hasta que haya datos

    li t4, 0x02018               # Dirección del UART para datos
    lb t2, 0(t4)                 # Leer byte del UART
    sb t2, 0(t5)                 # Almacenar byte en RAM
    addi t5, t5, 1               # Incrementar dirección en RAM
    addi t6, t6, -1              # Decrementar tamaño restante
    bnez t6, almacenamiento_loop # Continuar hasta que la imagen esté completa

    # Imagen almacenada exitosamente, incrementar contador de imágenes y actualizar LEDs
    la t0, current_image_count
    lw t3, 0(t0)
    addi t3, t3, 1               # Incrementar contador de imágenes
    sw t3, 0(t0)

    # Calcular la máscara de bits del LED según el contador de imágenes actual
    li t4, 0x2004                # Dirección de los LEDs
    li t2, 1                     # Bit de inicio del LED (0b00000001)
    sll t2, t2, t3               # Desplazar a la izquierda por (contador de imágenes - 1) para encender el LED correcto
    sw t2, 0(t4)                 # Actualizar LEDs con el nuevo patrón de bits

    # Verificar si se ha alcanzado el número máximo de imágenes
    la t0, max_images
    lw t4, 0(t0)
    bge t3, t4, deny_image       # Negar si se excede el límite de imágenes

exit_almacenamiento_mode:
    j reposo_mode                # Regresar al modo REPOSO

# -----------------------------------------------------
# Modo RETRANSMITER (subrutina de almacenamiento)
# -----------------------------------------------------
retransmiter_mode:
    li t0, 0x02018               # Dirección del UART para datos
    li t1, 0x01                  # Comando esperado para iniciar la transferencia de imagen
    lb t2, 0(t0)
    beq t2, t1, send_ack         # Enviar ACK si el comando coincide
    li a0, 0                     # Retornar 0 en caso de fallo
    jalr ra

send_ack:
    li t3, 0x02                  # Comando de ACK
    sb t3, 0(t0)                 # Enviar ACK vía UART
    nop                          # Retardo para el procesamiento del UART
    li a0, 1                     # Indicador de éxito
    jalr ra

deny_image:
    li t3, 0x03                  # Comando de NACK
    sb t3, 0(t0)                 # Enviar NACK vía UART
    nop                          # Retardo para el procesamiento del UART
    j reposo_mode                # Regresar al modo REPOSO

# -----------------------------------------------------
# Modo DESPLEGAR
# -----------------------------------------------------
desplegar_mode:
    la t0, current_image_count
    lw t5, 0(t0)
    beqz t5, exit_desplegar_mode # Salir si no hay imágenes

    la t6, buffer                # Dirección base del buffer
    li t4, 16200                 # Tamaño de desplazamiento de la imagen

    # Multiplicar por 16200 manualmente, ya que RV32I no soporta MUL
    mv t3, t5                    # Copiar el contador de imágenes a t3 para el cálculo del desplazamiento
    loop_offset:
        add t6, t6, t4           # Sumar 16200 bytes por imagen
        addi t3, t3, -1
        bnez t3, loop_offset     # Repetir hasta que se calcule el desplazamiento

desplegar_loop:
    lb t2, 0(t6)                 # Leer byte de la RAM
    li t4, 0x02018               # Dirección del UART para datos
    sb t2, 0(t4)                 # Enviar byte vía UART
    nop                          # Retardo para el procesamiento del UART
    addi t6, t6, 1               # Siguiente byte
    addi t5, t5, -1              # Decrementar tamaño de la imagen
    bnez t5, desplegar_loop      # Continuar hasta enviar toda la imagen

exit_desplegar_mode:
    j reposo_mode                # Regresar al modo REPOSO
