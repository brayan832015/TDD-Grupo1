# Sistema Secundario: FPGA Tang Nano 9K

## Descripción

Este repositorio contiene el código y las configuraciones para el **Sistema Secundario** implementado en la FPGA **Tang Nano 9K**. El propósito de este sistema es recibir comandos e imágenes desde el **Sistema Principal** (Nexys4) a través de la interfaz **UART** y desplegar las imágenes recibidas en un panel **LCD** usando la interfaz **SPI**. 

## Componentes Principales

1. **Controlador UART**: Recibe comandos e imágenes desde el sistema principal. Los datos recibidos se procesan y reenvían al controlador de display.
2. **Controlador SPI**: Interfaz que maneja la comunicación con el panel LCD para el despliegue de imágenes.
3. **Panel de Teclas Local**: Permite la interacción con el usuario local. Los datos ingresados por las teclas son enviados al Sistema Principal por medio de UART.

## Funcionalidad Principal

El sistema secundario tiene dos funciones principales:
1. **Recepción y Despliegue de Imágenes**: Recibe imágenes byte por byte desde el Sistema Principal a través del UART, las procesa y las envía al display LCD utilizando la interfaz SPI.
2. **Envío de Datos al Sistema Principal**: El sistema también puede enviar comandos o datos desde el panel de teclas hacia el sistema principal a través del mismo puerto UART para solicitar una imagen específica.

## Protocolo de Comunicación

- **UART**: El sistema se comunica con el sistema principal por UART para la transmisión de imágenes y comandos.
- **SPI**: La interfaz SPI se utiliza para enviar los datos de las imágenes al panel LCD para su despliegue.

## Requisitos

- **FPGA**: Tang Nano 9K
- **Periféricos**: Display LCD con interfaz SPI
- **Interfaz UART**: Comunicación con el sistema principal
