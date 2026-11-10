@actualizacion_completa
Feature: Actualización completa de productos
  Como administrador de la tienda
  Quiero modificar el nombre, precio, stock y categoría de un producto
  Para mantener actualizada la información del catálogo

  Background:
    Given que existe el producto "Escritorio" con ID 102 y stock actual de 5 unidades

  @happy_path
  Scenario: Reemplazar todos los datos editables de un producto
    When el administrador reemplaza el producto con ID 102 por nombre "Escritorio Regulable", precio 185000.50, stock 8 y categoría "Muebles"
    Then el producto actualizado debe tener nombre "Escritorio Regulable", precio 185000.50, stock 8 y categoría "Muebles"
    And el sistema debe responder con un código HTTP 200 OK

  @error_path
  Scenario: Rechazar una actualización completa con precio inválido
    When el administrador reemplaza el producto con ID 102 por nombre "Escritorio Regulable", precio -1.00, stock 8 y categoría "Muebles"
    Then el sistema debe responder con un código HTTP 422 Unprocessable Content
