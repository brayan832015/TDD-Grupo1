.section .data

.section .text
.globl _start

_start:
    # Iniciar en modo REPOSO
    li s1, 0x00040000           # Dirección inicial RAM
    li a7, 0
    li a2, 0
    jal reposo_mode

# -----------------------------------------------------
# Modo REPOSO
# -----------------------------------------------------
reposo_mode:
    li t0, 0x02020              # Dirección del registro de control del UART B
    lw t1, 0(t0)                # Leer estado de los interruptores
    andi t1, t1, 0x00000002
    bnez t1, desplegar_mode     # Si hay new_rx en UART B, ir a modo DESPLEGAR

    # Verificar si hay datos en el UART A para activar modo ALMACENAMIENTO
    li t3, 0x02010                      # Dirección del registro de control del UART A
    lw t4, 0(t3)                        # Leer estado del UART
    andi t4, t4, 0x00000002             # Verificar si hay datos listos para leer
    bnez t4, almacenamiento_mode        # Si hay datos en UART A, ir a modo ALMACENAMIENTO

    # Permanecer en modo REPOSO si no hay eventos
    j reposo_mode

# -----------------------------------------------------
# Modo ALMACENAMIENTO
# -----------------------------------------------------
almacenamiento_mode:
    # Llamar a modo RETRANSMITIR para verificar el comando
    jal retransmitir_mode

    beqz a0, exit_almacenamiento_mode  # Si RETRANSMITIR falla, salir

    # Comenzar a recibir imagen desde la PC
    li t6, 64800                # Tamaño de la imagen en bytes (240 * 135 * 2)
    #li t6, 5 

almacenamiento_loop:
    # Leer cada byte del UART y almacenarlo en RAM
    li t3, 0x02010              # Dirección del registro de control del UART
    lw t5, 0(t3)                # Leer estado del UART
    andi t2, t5, 0x02           # Verificar si hay datos listos para leer
    beqz t2, almacenamiento_loop # Esperar hasta que haya datos

    li t4, 0x0201C              # Dirección del UART para recibir datos
    lb t2, 0(t4)                # Leer byte del UART
    sb t2, 0(s1)                # Almacenar byte en RAM
    addi s1, s1, 1              # Incrementar byte en RAM
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
    li t1, 1                    # Cargar 1 para el shift
    beqz a7, first_image        # Si es la primera imagen
    slli a7, a7, 1              # Shift left 1 bit
    or a7, a7, t1               # OR con el valor anterior
    addi a2, a2, 1
    j continue_count
    
first_image:
    li a7, 1                    # Primera imagen, establecer bit 0
    li a2, 1

continue_count:
    sw a7, 0(t0)                # Almacenar contador imagenes actualizado

exit_almacenamiento_mode:

    # Verificar carga de RAM con LEDs (prueba provisional)
    #############################################
    #li t0, 0x02004
    #li t2, 0x040000
    #lw t3, 0(t2)
    #sw t3, 0(t0)
    #############################################

    j reposo_mode               # Regresar al modo REPOSO

# -----------------------------------------------------
# Modo RETRANSMITIR (subrutina de almacenamiento)
# -----------------------------------------------------
retransmitir_mode:
    li t0, 0x0201C              # Dirección del registro de datos para recibir
    li t1, 0xFFFFFFFF                 # Comando esperado para iniciar la transferencia de imagen
    # Leer comando desde UART
    lb t2, 0(t0)

    #######################################################
    # Verificar si se excede el límite de imágenes
    li t4, 8                    # 8 imagenes maximo
    bge a2, t4, deny_image      # Si se excede, negar más imágenes    
    #######################################################

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

    # Leer valor del registro en memoria
    li t3, 0x0202C        # Cargar dirección en t3
    lb t1, 0(t3)         # Cargar byte en t1
    
    # Comparar con valores ASCII (1=0x31 hasta 8=0x38)
    li t2, 0x31          # ASCII '1'
    beq t1, t2, imagen1
    li t2, 0x32          # ASCII '2' 
    beq t1, t2, imagen2
    li t2, 0x33          # ASCII '3'
    beq t1, t2, imagen3
    li t2, 0x34          # ASCII '4'
    beq t1, t2, imagen4
    li t2, 0x35          # ASCII '5'
    beq t1, t2, imagen5
    li t2, 0x36          # ASCII '6'
    beq t1, t2, imagen6
    li t2, 0x37          # ASCII '7'
    beq t1, t2, imagen7
    li t2, 0x38          # ASCII '8'
    beq t1, t2, imagen8
    j desplegar_mode                # Si no coincide, saltar al continuar_desplegaral

imagen1:
    li t0, 0x040000             # Cargar 1 en t0
    j continuar_desplegar
imagen2:
    li t0, 0x0104800             # Cargar 2 en t0
    j continuar_desplegar
imagen3:
    li t0, 0x169600             # Cargar 3 en t0
    j continuar_desplegar
imagen4:
    li t0, 0x234400             # Cargar 4 en t0
    j continuar_desplegar
imagen5:
    li t0, 0x299200             # Cargar 5 en t0
    j continuar_desplegar
imagen6:
    li t0, 0x364000             # Cargar 6 en t0
    j continuar_desplegar
imagen7:
    li t0, 0x428800             # Cargar 7 en t0
    j continuar_desplegar
imagen8:
    li t0, 0x493600             # Cargar 8 en t0

continuar_desplegar:
    # Continuar con el resto del programa

    li t6, 64800     # Tamaño de la imagen en bytes (240 * 135 * 2)
    #li t6, 5 

    li t1, 0x02020      # Dirección reg control UART B
    sw zero, 0(t1)      # Apagar new_rx

desplegar_loop:

    # Enviar cada byte de la imagen a través del UART
    lb t2, 0(t0)                # Leer byte de la RAM
    li t4, 0x02028              # Dirección del UART para datos
    sb t2, 0(t4)                # Almacenar byte reg envío

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

    #####################
    li t1, 0x02020      # Dirección reg control UART B
    li t3, 0x01
    sw t3, 0(t1)        # Activar send
    #####################


    addi t6, t6, -1             # Siguiente byte
    addi t0, t0, 1              # Decrementar tamaño de la imagen
    li t5, 300


    

nops:
    li t1, 0x02020              # Dirección del registro de control del UART
    lw t2, 0(t1)                # Leer estado del UART

    addi t5, t5, -1
    bnez t5, nops


    bnez t6, desplegar_loop     # Continuar hasta enviar toda la imagen

exit_desplegar_mode:
    j reposo_mode               # Regresar al modo REPOSO
