# Analisis de calidad de los CSV de Invacom (pasos 13 y 14)
# Uso: python scripts/analisis_calidad.py
import csv
from collections import Counter
from pathlib import Path

CARPETA = Path(__file__).resolve().parent.parent / "base_datos" / "classicmodels_scalecars"


def leer(nombre):
    with open(CARPETA / nombre, encoding="utf-8", newline="") as f:
        return list(csv.DictReader(f))


archivos = ["customers.csv", "employees.csv", "offices.csv", "orders.csv",
            "orderdetails.csv", "products.csv", "productlines.csv", "payments.csv"]
datos = {a: leer(a) for a in archivos}

print("== Estructura y valores NULL ==")
for nombre, filas in datos.items():
    print(f"{nombre}: {len(filas)} filas, {len(filas[0])} columnas")
    for col in filas[0]:
        nulos = sum(1 for f in filas if f[col] == "NULL")
        espacios = sum(1 for f in filas if f[col] != f[col].strip())
        if nulos or espacios:
            print(f"   {col}: NULL={nulos} espacios_sobrantes={espacios}")

print("\n== Claves primarias repetidas ==")
claves = {"customers.csv": ["customerNumber"], "employees.csv": ["employeeNumber"],
          "offices.csv": ["officeCode"], "orders.csv": ["orderNumber"],
          "orderdetails.csv": ["orderNumber", "productCode"], "products.csv": ["productCode"],
          "productlines.csv": ["productLine"], "payments.csv": ["customerNumber", "checkNumber"]}
for nombre, cols in claves.items():
    valores = [tuple(f[c] for c in cols) for f in datos[nombre]]
    print(f"{nombre} ({' + '.join(cols)}): {len(valores) - len(set(valores))} repetidas")

print("\n== Claves foraneas sin registro relacionado ==")
relaciones = [("orderdetails.csv", "orderNumber", "orders.csv", "orderNumber"),
              ("orderdetails.csv", "productCode", "products.csv", "productCode"),
              ("orders.csv", "customerNumber", "customers.csv", "customerNumber"),
              ("customers.csv", "salesRepEmployeeNumber", "employees.csv", "employeeNumber"),
              ("employees.csv", "officeCode", "offices.csv", "officeCode"),
              ("employees.csv", "reportsTo", "employees.csv", "employeeNumber"),
              ("payments.csv", "customerNumber", "customers.csv", "customerNumber"),
              ("products.csv", "productLine", "productlines.csv", "productLine")]
for hijo, col, padre, col_padre in relaciones:
    existentes = {f[col_padre] for f in datos[padre]}
    huerfanos = [f[col] for f in datos[hijo] if f[col] != "NULL" and f[col] not in existentes]
    print(f"{hijo}.{col} -> {padre}: {len(huerfanos)} sin relacion")

print("\n== Otros hallazgos ==")
clientes, pedidos = datos["customers.csv"], datos["orders.csv"]
con_pedidos = {p["customerNumber"] for p in pedidos}
print("Paises distintos sin recortar espacios:", len({c["country"] for c in clientes}))
print("Paises distintos recortando espacios:", len({c["country"].strip() for c in clientes}))
print("Clientes sin pedidos:", sum(1 for c in clientes if c["customerNumber"] not in con_pedidos))
print("Estados de pedidos:", dict(Counter(p["status"] for p in pedidos)))
print("Puestos:", dict(Counter(e["jobTitle"] for e in datos["employees.csv"])))
correos = Counter(e["email"] for e in datos["employees.csv"])
print("Correos repetidos:", [c for c, n in correos.items() if n > 1])
vendidos = {d["productCode"] for d in datos["orderdetails.csv"]}
print("Productos sin ventas:", [p["productCode"] for p in datos["products.csv"] if p["productCode"] not in vendidos])
