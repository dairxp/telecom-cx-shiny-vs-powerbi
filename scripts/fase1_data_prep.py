import os
import csv
import shutil

# Rutas base
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA_DIR = os.path.join(BASE_DIR, "data")
RAW_DIR = os.path.join(DATA_DIR, "raw")
PROCESSED_DIR = os.path.join(DATA_DIR, "processed")
POWERBI_MODEL_DIR = os.path.join(PROCESSED_DIR, "data_model_powerbi")

os.makedirs(RAW_DIR, exist_ok=True)
os.makedirs(POWERBI_MODEL_DIR, exist_ok=True)

# 1. Copiar data original a raw
input_file = os.path.join(DATA_DIR, "data.csv")
raw_file = os.path.join(RAW_DIR, "respuestas_encuesta_raw.csv")
shutil.copy2(input_file, raw_file)
print(f"[OK] Archivo original respaldado en: {raw_file}")

# 2. Cargar y procesar datos
with open(raw_file, "r", encoding="utf-8", errors="replace") as f:
    reader = csv.reader(f)
    headers = next(reader)
    rows = list(reader)

print(f"[INFO] Total de registros leidos: {len(rows)}")

# Diccionario de operadores con IDs y colores oficiales
OPERADORES_INFO = {
    "Entel": {"id": 1, "color": "#002EFF", "nombre": "Entel"},
    "Claro": {"id": 2, "color": "#DA291C", "nombre": "Claro"},
    "Bitel": {"id": 3, "color": "#FFCC00", "nombre": "Bitel"},
    "Movistar": {"id": 4, "color": "#019DF4", "nombre": "Movistar"}
}

# Dimensiones Likert para CSAT
# Indices en headers:
# 6: Cobertura
# 7: Velocidad
# 8: Atencion
# 9: Precio
# 10: Datos

curated_records = []
dim_estudiantes = []
fact_respuestas = []
fact_percepciones = []
fact_fallas_lugar = []

for idx, r in enumerate(rows, start=1):
    id_resp = f"RESP_{idx:03d}"
    id_est = f"EST_{idx:03d}"
    timestamp = r[0].strip()
    edad = r[1].strip()
    genero = r[2].strip()
    
    # Limpieza de Area Academica (Ingeniería -> Ingenierías)
    area_raw = r[3].strip()
    if area_raw == "Ingeniería":
        area = "Ingenierías"
    else:
        area = area_raw
        
    operador_actual = r[4].strip()
    antiguedad = r[5].strip()
    
    # 5 dimensiones de satisfaccion
    sat_cobertura = int(r[6].strip())
    sat_velocidad = int(r[7].strip())
    sat_atencion = int(r[8].strip())
    sat_precio = int(r[9].strip())
    sat_datos = int(r[10].strip())
    
    csat_promedio = round((sat_cobertura + sat_velocidad + sat_atencion + sat_precio + sat_datos) / 5.0, 2)
    
    factor_importante = r[11].strip()
    problema_principal = r[12].strip()
    lugares_problema_raw = r[13].strip()
    sat_general_texto = r[14].strip()
    
    # Percepciones de cada operador
    percep_bitel = int(r[15].strip())
    percep_claro = int(r[16].strip())
    percep_entel = int(r[17].strip())
    percep_movistar = int(r[18].strip())
    
    # Pregunta 12: Recomendacion (NPS)
    recomienda_texto = r[19].strip()
    if recomienda_texto == "Definitivamente sí":
        nps_category = "Promotor"
        nps_weight = 1
    elif recomienda_texto in ["Probablemente no", "Definitivamente no"]:
        nps_category = "Detractor"
        nps_weight = -1
    else:
        nps_category = "Pasivo"
        nps_weight = 0
        
    # Pregunta 13: Consideracion de cambio (Churn)
    cambio_texto = r[20].strip()
    # Regla de riesgo de churn ponderada con CSAT
    if cambio_texto in ["Definitivamente sí", "Probablemente sí"]:
        riesgo_churn = "Alto"
    elif cambio_texto == "Tal vez":
        riesgo_churn = "Alto" if csat_promedio < 3.0 else "Medio"
    else: # "Probablemente no", "Definitivamente no"
        riesgo_churn = "Medio" if csat_promedio < 2.5 else "Bajo"
        
    # Desagregacion de fallas geograficas (Dummies / One-hot encoding)
    falla_univ = 1 if "universidad" in lugares_problema_raw.lower() else 0
    falla_casa = 1 if "casa" in lugares_problema_raw.lower() else 0
    falla_centro = 1 if "centro de puno" in lugares_problema_raw.lower() else 0
    falla_rural = 1 if "rural" in lugares_problema_raw.lower() else 0
    sin_fallas = 1 if "no tengo problemas" in lugares_problema_raw.lower() else 0
    
    # Registro completo curado (para Shiny)
    curated_row = {
        "id_respuesta": id_resp,
        "id_estudiante": id_est,
        "timestamp": timestamp,
        "edad": edad,
        "genero": genero,
        "area_academica": area,
        "operador_actual": operador_actual,
        "antiguedad_uso": antiguedad,
        "sat_cobertura": sat_cobertura,
        "sat_velocidad": sat_velocidad,
        "sat_atencion": sat_atencion,
        "sat_precio": sat_precio,
        "sat_datos": sat_datos,
        "csat_promedio": csat_promedio,
        "factor_importante": factor_importante,
        "problema_principal": problema_principal,
        "sat_general_texto": sat_general_texto,
        "percep_bitel": percep_bitel,
        "percep_claro": percep_claro,
        "percep_entel": percep_entel,
        "percep_movistar": percep_movistar,
        "recomienda_texto": recomienda_texto,
        "nps_category": nps_category,
        "nps_weight": nps_weight,
        "cambio_texto": cambio_texto,
        "riesgo_churn": riesgo_churn,
        "falla_universidad": falla_univ,
        "falla_casa": falla_casa,
        "falla_centro_puno": falla_centro,
        "falla_rural": falla_rural,
        "sin_fallas": sin_fallas
    }
    curated_records.append(curated_row)
    
    # 3. Modelado Estrella para Power BI
    # Dim_Estudiante
    dim_estudiantes.append({
        "id_estudiante": id_est,
        "edad": edad,
        "genero": genero,
        "area_academica": area,
        "antiguedad_uso": antiguedad
    })
    
    # Fact_Respuestas
    id_op = OPERADORES_INFO.get(operador_actual, {}).get("id", 0)
    fact_respuestas.append({
        "id_respuesta": id_resp,
        "id_estudiante": id_est,
        "id_operador": id_op,
        "timestamp": timestamp,
        "sat_cobertura": sat_cobertura,
        "sat_velocidad": sat_velocidad,
        "sat_atencion": sat_atencion,
        "sat_precio": sat_precio,
        "sat_datos": sat_datos,
        "csat_promedio": csat_promedio,
        "factor_importante": factor_importante,
        "problema_principal": problema_principal,
        "sat_general_texto": sat_general_texto,
        "recomienda_texto": recomienda_texto,
        "nps_category": nps_category,
        "nps_weight": nps_weight,
        "cambio_texto": cambio_texto,
        "riesgo_churn": riesgo_churn,
        "falla_universidad": falla_univ,
        "falla_casa": falla_casa,
        "falla_centro_puno": falla_centro,
        "falla_rural": falla_rural,
        "sin_fallas": sin_fallas
    })
    
    # Fact_PercepcionOperadores (Formato Largo / Tidy para comparar marcas)
    percepciones_dict = {
        "Bitel": percep_bitel,
        "Claro": percep_claro,
        "Entel": percep_entel,
        "Movistar": percep_movistar
    }
    for op_name, score in percepciones_dict.items():
        fact_percepciones.append({
            "id_respuesta": id_resp,
            "id_operador_evaluado": OPERADORES_INFO[op_name]["id"],
            "operador_evaluado": op_name,
            "score_percepcion": score,
            "es_cliente_actual": 1 if op_name == operador_actual else 0
        })
        
    # Fact_FallasLugar (Tabla puente para filtro desagregado de lugares)
    lugares_lista = [item.strip() for item in lugares_problema_raw.split(",") if item.strip()]
    for lug in lugares_lista:
        fact_fallas_lugar.append({
            "id_respuesta": id_resp,
            "lugar_falla": lug
        })

# 4. Exportar a CSV
# A. Dataset Curado para Shiny
with open(os.path.join(PROCESSED_DIR, "dataset_curado.csv"), "w", encoding="utf-8", newline="") as f:
    writer = csv.DictWriter(f, fieldnames=list(curated_records[0].keys()))
    writer.writeheader()
    writer.writerows(curated_records)
print(f"[OK] Generado: {os.path.join(PROCESSED_DIR, 'dataset_curado.csv')}")

# B. Dim_Estudiante.csv
with open(os.path.join(POWERBI_MODEL_DIR, "Dim_Estudiante.csv"), "w", encoding="utf-8", newline="") as f:
    writer = csv.DictWriter(f, fieldnames=list(dim_estudiantes[0].keys()))
    writer.writeheader()
    writer.writerows(dim_estudiantes)
print(f"[OK] Generado: {os.path.join(POWERBI_MODEL_DIR, 'Dim_Estudiante.csv')}")

# C. Dim_Operador.csv
dim_operadores = [
    {"id_operador": v["id"], "operador": v["nombre"], "color_hex": v["color"]}
    for v in OPERADORES_INFO.values()
]
with open(os.path.join(POWERBI_MODEL_DIR, "Dim_Operador.csv"), "w", encoding="utf-8", newline="") as f:
    writer = csv.DictWriter(f, fieldnames=["id_operador", "operador", "color_hex"])
    writer.writeheader()
    writer.writerows(dim_operadores)
print(f"[OK] Generado: {os.path.join(POWERBI_MODEL_DIR, 'Dim_Operador.csv')}")

# D. Fact_Respuestas.csv
with open(os.path.join(POWERBI_MODEL_DIR, "Fact_Respuestas.csv"), "w", encoding="utf-8", newline="") as f:
    writer = csv.DictWriter(f, fieldnames=list(fact_respuestas[0].keys()))
    writer.writeheader()
    writer.writerows(fact_respuestas)
print(f"[OK] Generado: {os.path.join(POWERBI_MODEL_DIR, 'Fact_Respuestas.csv')}")

# E. Fact_PercepcionOperadores.csv
with open(os.path.join(POWERBI_MODEL_DIR, "Fact_PercepcionOperadores.csv"), "w", encoding="utf-8", newline="") as f:
    writer = csv.DictWriter(f, fieldnames=list(fact_percepciones[0].keys()))
    writer.writeheader()
    writer.writerows(fact_percepciones)
print(f"[OK] Generado: {os.path.join(POWERBI_MODEL_DIR, 'Fact_PercepcionOperadores.csv')}")

# F. Fact_FallasLugar.csv
with open(os.path.join(POWERBI_MODEL_DIR, "Fact_FallasLugar.csv"), "w", encoding="utf-8", newline="") as f:
    writer = csv.DictWriter(f, fieldnames=list(fact_fallas_lugar[0].keys()))
    writer.writeheader()
    writer.writerows(fact_fallas_lugar)
print(f"[OK] Generado: {os.path.join(POWERBI_MODEL_DIR, 'Fact_FallasLugar.csv')}")

print("\n--- RESUMEN EJECUTIVO DE DATA CURADA ---")
print(f"Total encuestados validos: {len(curated_records)}")
for op in ["Entel", "Claro", "Bitel", "Movistar"]:
    sub = [r for r in curated_records if r["operador_actual"] == op]
    n = len(sub)
    csat_avg = sum(r["csat_promedio"] for r in sub) / n
    prom = sum(1 for r in sub if r["nps_category"] == "Promotor")
    det = sum(1 for r in sub if r["nps_category"] == "Detractor")
    nps = ((prom - det) / n) * 100
    churn_alto = sum(1 for r in sub if r["riesgo_churn"] == "Alto")
    print(f"[{op}] N={n} | CSAT={csat_avg:.2f} | NPS={nps:+5.1f} | Churn Alto={churn_alto} ({churn_alto/n*100:.1f}%)")
