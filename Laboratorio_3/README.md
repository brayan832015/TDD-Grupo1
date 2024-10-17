# Proyecto de Diseño Digital: Microcontrolador basado en RISC-V

## Introducción

Este proyecto tiene como objetivo el diseño e implementación de un sistema digital basado en un microcontrolador con arquitectura **RISC-V (RV32I)**. El sistema se encarga de la comunicación con diferentes periféricos, como botones, switches, LEDs, una pantalla LCD, y dos interfaces UART para la transmisión y recepción de datos. 

El sistema completo se implementa en una **FPGA Nexys4** y una **FPGA Tangnano9k**, está compuesto por un microcontrolador de 32 bits, memorias RAM y ROM, controladores de periféricos, módulo SPI, pantalla LCD y módulos UART. El microcontrolador ejecuta un programa escrito en lenguaje ensamblador para coordinar todas las operaciones del sistema.

## Objetivos

1. Diseñar un sistema digital basado en un microcontrolador con el conjunto de instrucciones **RV32I**.
2. Implementar el hardware de forma modular, separando las tareas de control y procesamiento de datos.
3. Afinar y configurar correctamente la comunicación serial mediante el protocolo **UART**.
4. Implementar memorias **RAM** y **ROM** utilizando **IP-Cores**.
5. Validar el sistema completo mediante pruebas exhaustivas (testbenches) de cada módulo.

## Estructura del sistema

El sistema se divide en dos bloques principales:

1. **Sistema principal**: Controlado por un microcontrolador basado en **RISC-V**, con comunicación hacia periféricos de entrada/salida como botones, switches, LEDs, y dos interfaces UART. Este sistema se encarga de recibir y enviar datos al **Sistema Secundario**.

2. **Sistema secundario**: Dedicado exclusivamente al despliegue de imágenes en un panel LCD. Recibe comandos y datos del **Sistema Principal** a través de la interfaz UART y utiliza una interfaz **SPI** para controlar el display.

   ![Figura 1. Diagrama de alto nivel del sistema completo (tarjetas de desarrollo)](https://github.com/user-attachments/assets/4c0c8a08-7cee-4842-9ca5-36f3883da66a)

### Componentes del microcontrolador

El microcontrolador implementado se basa en el diseño **PicoRV32**, que soporta el conjunto de instrucciones **RV32I**. Se utilizan dos buses independientes para acceder a las memorias de programa (ROM) y datos (RAM). El sistema incluye un módulo **PLL** que genera una señal de reloj a 10 MHz para todo el diseño.

   ![Figura 2: Diagrama de bloques del sistema computacional a desarrollar](https://github.com/user-attachments/assets/917051c9-6e4c-491e-9d84-4d4e06c4ad5a)
   ![Figura 3: Diagrama de alto nivel del core para el microcontrolador de referencia](https://github.com/user-attachments/assets/0718e4c7-5cd9-4a6a-b224-fc079acb02f0)


#### Mapa de memoria

El mapa de memoria del sistema es el siguiente:

- **Memoria de Programa**: 2 KiB, direccionada desde `0x0000` hasta `0x0FFC`.
- **Memoria de Datos**: 100 KiB, direccionada desde `0x40000` hasta `0xFFFFF`.
- **Periféricos**: Incluyen switches, LEDs, y módulos UART mapeados en direcciones específicas.

   ![Figura 4: Mapa de memoria](https://github.com/user-attachments/assets/e5f81760-cd09-4647-809d-f500480a3c4c)


## Periféricos implementados

El sistema puede interactuar con varios periféricos:

1. **Switches y botones**: Se mapean en un registro accesible por el procesador. Incluyen circuitos de sincronización y anti-rebote para asegurar un correcto funcionamiento.
2. **LEDs**: Controlados desde un registro dedicado que permite encender y apagar los LEDs desde el microcontrolador.
3. **UART**: Dos interfaces UART son implementadas para la comunicación serie. Cada interfaz UART tiene un registro de control y dos registros de datos para la transmisión y recepción de bytes.

   ![Figura 5: Diagrama de bloques de alto nivel para la interfaz UART](https://github.com/user-attachments/assets/1edda5f4-6249-4e5e-bc4a-89e3c4778a66)


## Modo de operación

El software que corre en el microcontrolador tiene tres modos principales de operación:

1. **Modo REPOSO**: El sistema realiza un sondeo continuo de los periféricos (botones, switches y UART) esperando recibir un comando.
2. **Modo ALMACENAMIENTO**: Se activa al recibir un paquete de datos desde una PC conectada por UART. El sistema almacena las imágenes recibidas en la memoria RAM y enciende LEDs para indicar la cantidad de imágenes almacenadas.
3. **Modo DESPLEGAR**: Se activa al recibir un comando desde el sistema secundario. En este modo, el sistema envía una imagen almacenada en la RAM al panel LCD del sistema secundario.

   ![Figura 6: Diagrama de bloques de la aplicación](https://github.com/user-attachments/assets/76c71aad-cc1e-4299-aab5-e474bd0bfbdb)


## Comunicación serie UART

El sistema incluye dos módulos UART, cada uno con un registro de control y dos registros de datos. Los registros de control permiten activar la transmisión (`send`) o identificar la recepción de nuevos datos (`new_rx`). La comunicación entre el sistema principal y secundario también se realiza por UART, enviando comandos y datos para el despliegue en el panel LCD del sistema secundario.

## Aplicación en ensamblador

El programa que corre en el microcontrolador está escrito en lenguaje ensamblador RISC-V, implementando un ciclo indefinido que maneja los modos de operación descritos anteriormente. El uso de un ensamblador para **RV32I** permite generar el código máquina necesario para la correcta ejecución del programa en el microcontrolador PicoRV32.

## Requisitos de implementación

- **FPGA**: Nexys4 (principal) y Tangnano9k (secundario)
- **Microcontrolador**: PicoRV32 (RV32I)
- **Lenguaje de programación**: Ensamblador RISC-V
- **Periféricos**: Switches, botones, LEDs, UART (RS-232)

## Pruebas y verificación

Cada módulo del sistema debe contar con un **testbench** dedicado para verificar su correcto funcionamiento antes de la integración. Las pruebas incluyen la validación del microcontrolador, periféricos, y la correcta operación del protocolo UART.


