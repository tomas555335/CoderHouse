```powerquery
let
    // Paso 1: Fuente de datos original cargada mediante "Especificar datos"
    Origen = Table.FromRows(Json.Document(Binary.Decompress(Binary.FromText("i45WMlTSUUrMy0vMU3DMK0rNK1GIz8vPSy1WKM/MS4nPyczLL1aKjQUA", BinaryEncoding.Base64), Compression.Deflate)), let _t = ((type nullable text) meta [Serialized.Text = true]) in type table [id_venta = _t, nombre_producto = _t, categoria = _t, precio = _t, fecha_venta = _t]),

    // Paso 2: Eliminar espacios en blanco al inicio y al final de la columna nombre_producto usando Text.Trim
    // Esto normaliza valores como " Laptop Pro 15 " a "Laptop Pro 15"
    LimpiarEspacios = Table.TransformColumns(Origen, {{"nombre_producto", Text.Trim, type text}}),

    // Paso 3: Estandarizar la columna categoria a Title Case (nombre propio)
    // Permite unificar "computación", "COMPUTACIÓN" y "Computación" a "Computación", y "accesorios"/"Accesorios" a "Accesorios"
    EstandarizarCategoria = Table.TransformColumns(LimpiarEspacios, {{"categoria", Text.Proper, type text}}),

    // Paso 4: Filtrar y eliminar registros de prueba
    // Al haberse estandarizado en el paso anterior a Title Case, "PRUEBA" ahora es "Prueba"
    // Excluimos las filas de prueba dejando solo los registros productivos
    EliminarPruebas = Table.SelectRows(EstandarizarCategoria, each [categoria] <> "Prueba"),

    // Paso 5: Definir tipos de datos correctos para cada variable del modelo
    // id_venta como entero, textos descriptivos, precio numérico y fecha_venta como fecha
    TiparColumnas = Table.TransformColumnTypes(EliminarPruebas, {
        {"id_venta", Int64.Type},
        {"nombre_producto", type text},
        {"categoria", type text},
        {"precio", type number},
        {"fecha_venta", type date}
    })

in
    TiparColumnas
