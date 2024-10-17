# Sistema Principal: FPGA Nexys4

## Descripción

Esta carpeta contiene el código y las configuraciones para el **Sistema Principal** implementado en la FPGA **Nexys4**. El sistema se basa en un microcontrolador de 32 bits compatible con la arquitectura **RISC-V (RV32I)**, encargado de gestionar la interacción con periféricos como botones, switches, LEDs, y dos módulos UART. El sistema se comunica con un **Sistema Secundario** (implementado en otra FPGA) a través de una interfaz **UART** para controlar el despliegue de imágenes en un display LCD.

## Componentes principales

1. **Microcontrolador RISC-V**: Implementado usando el núcleo **PicoRV32**, ejecuta un programa en ensamblador para controlar las operaciones del sistema.
2. **Memorias**:
   - **ROM**: Almacena el programa que se ejecuta en el microcontrolador.
   - **RAM**: Almacena los datos procesados por el microcontrolador, incluidas las imágenes recibidas.
3. **Periféricos**:
   - **Switches y botones**: Usados para interactuar manualmente con el sistema.
   - **LEDs**: Indican el estado del sistema y la cantidad de imágenes almacenadas.
   - **UART**: Dos interfaces UART para la comunicación con una PC y con el Sistema Secundario.

## Modos de operación

El sistema tiene tres modos de operación principales:

1. **REPOSO**: El sistema espera instrucciones, realizando un sondeo continuo de periféricos y UART.
2. **ALMACENAMIENTO**: Recibe imágenes desde una PC conectada por UART y las almacena en la RAM.
3. **DESPLEGAR**: Envía imágenes almacenadas en la RAM hacia el Sistema Secundario para ser desplegadas en el panel LCD.

## Comunicación UART

El sistema principal cuenta con dos módulos **UART**:
- **UART A**: Conectado a una PC para recibir imágenes.
- **UART B**: Conectado al Sistema Secundario para transmitir las imágenes almacenadas.

## Mapa de memoria

- **Memoria de programa (ROM)**: 2 KiB, desde `0x0000` hasta `0x0FFF`.
- **Memoria de datos (RAM)**: 100 KiB, desde `0x40000` hasta `0xFFFFF`.
- **Periféricos**: Mapeados en direcciones específicas, como LEDs, switches, y UART.

## Requisitos

- **FPGA**: Nexys4
- **Microcontrolador**: PicoRV32 (RV32I)
- **Lenguaje de programación**: Ensamblador RISC-V

