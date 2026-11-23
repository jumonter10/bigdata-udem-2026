# Memo · Competencia entre plataformas en NYC

Para: equipo de analítica de movilidad.
De: Juan Monterrosa.
Periodo: enero–marzo de 2024. Caso A.

El paquete contiene 60.268.466 viajes en 46.715 registros diarios por
zona y empresa. Uber concentra 44.440.688 viajes (73,74 %) y Lyft
15.827.778 (26,26 %). Estas cuotas describen el paquete del curso,
no todo el transporte de Nueva York.

El ingreso total registrado suma 1.383.046.448,43 para Uber y
474.649.141,57 para Lyft. No representa beneficio ni ingreso neto
de las plataformas. De enero a marzo los viajes aumentan 8,24 %
y 8,32 %, respectivamente. Son totales mensuales, no tasas diarias.

Las zonas de mayor volumen son JFK Airport, LaGuardia Airport y
East Village. En Uber lidera JFK, con 810.070 viajes; en Lyft,
LaGuardia, con 295.689. La propina ponderada por viajes es 1,06
para Uber y 1,18 para Lyft. Esta diferencia no demuestra mayor
satisfacción: puede depender del tipo de viaje y de los usuarios.

Se identifican 34 cruces mensuales desde una cuota de 70 % o menos
hasta más del 70 %, todos de Uber. Astoria Park pasa de 67,0379 %
a 75,4491 % en febrero: +8,4112 puntos porcentuales.
Se recomienda vigilar estos cruces junto con su volumen de viajes:
las cuotas de zonas pequeñas pueden variar mucho con pocos casos.
El 70 % es un umbral analítico, no una conclusión legal de monopolio.

Supuestos y calidad:
El grano es fecha–zona–empresa. Las combinaciones mensuales ausentes
se interpretan como cero viajes dentro del paquete. Si una zona-mes
no tiene viajes, su cuota es indefinida. Enero no se compara con
diciembre porque este último está fuera del periodo.

Se evitó duplicar viajes al unir por nombre de zona: el catálogo
pasó de 265 filas a 262 nombres únicos antes del cruce.
Las propinas se ponderaron por viajes y la lluvia se guardó una
sola vez por día. Los promedios reconstruidos son aproximados
por el redondeo del origen.

Los controles originales confirmaron filas y viajes, ausencia de
duplicados del grano y ausencia de hechos sin dimensiones.
La verificación oficial aprobó 4 de 4 controles.
