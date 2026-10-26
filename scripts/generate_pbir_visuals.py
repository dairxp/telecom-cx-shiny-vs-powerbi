import os
import json

BASE_PAGE_DIR = os.path.join(
    os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
    "powerbi",
    "telecom.Report",
    "definition",
    "pages",
    "f0f97130578a9aea56e4"
)
VISUALS_DIR = os.path.join(BASE_PAGE_DIR, "visuals")
os.makedirs(VISUALS_DIR, exist_ok=True)

SCHEMA_VC = "https://developer.microsoft.com/json-schemas/fabric/item/report/definition/visualContainer/2.1.0/schema.json"

def create_card_visual(name, x, y, w, h, table, measure, tab_order):
    return {
        "$schema": SCHEMA_VC,
        "name": name,
        "position": {
            "x": x,
            "y": y,
            "z": 1000,
            "height": h,
            "width": w,
            "tabOrder": tab_order
        },
        "visual": {
            "visualType": "card",
            "query": {
                "queryState": {
                    "Values": {
                        "projections": [
                            {
                                "field": {
                                    "Measure": {
                                        "Expression": {
                                            "SourceRef": {
                                                "Entity": table
                                            }
                                        },
                                        "Property": measure
                                    }
                                },
                                "queryRef": f"{table}.{measure}",
                                "nativeQueryRef": measure
                            }
                        ]
                    }
                }
            }
        }
    }

def create_slicer_visual(name, x, y, w, h, table, column, tab_order):
    return {
        "$schema": SCHEMA_VC,
        "name": name,
        "position": {
            "x": x,
            "y": y,
            "z": 1000,
            "height": h,
            "width": w,
            "tabOrder": tab_order
        },
        "visual": {
            "visualType": "slicer",
            "query": {
                "queryState": {
                    "Values": {
                        "projections": [
                            {
                                "field": {
                                    "Column": {
                                        "Expression": {
                                            "SourceRef": {
                                                "Entity": table
                                            }
                                        },
                                        "Property": column
                                    }
                                },
                                "queryRef": f"{table}.{column}",
                                "nativeQueryRef": column,
                                "active": True
                            }
                        ]
                    }
                }
            }
        }
    }

def create_donut_visual(name, x, y, w, h, cat_table, cat_col, val_table, val_measure, tab_order):
    return {
        "$schema": SCHEMA_VC,
        "name": name,
        "position": {
            "x": x,
            "y": y,
            "z": 1000,
            "height": h,
            "width": w,
            "tabOrder": tab_order
        },
        "visual": {
            "visualType": "donutChart",
            "query": {
                "queryState": {
                    "Category": {
                        "projections": [
                            {
                                "field": {
                                    "Column": {
                                        "Expression": {
                                            "SourceRef": {
                                                "Entity": cat_table
                                            }
                                        },
                                        "Property": cat_col
                                    }
                                },
                                "queryRef": f"{cat_table}.{cat_col}",
                                "nativeQueryRef": cat_col,
                                "active": True
                            }
                        ]
                    },
                    "Y": {
                        "projections": [
                            {
                                "field": {
                                    "Measure": {
                                        "Expression": {
                                            "SourceRef": {
                                                "Entity": val_table
                                            }
                                        },
                                        "Property": val_measure
                                    }
                                },
                                "queryRef": f"{val_table}.{val_measure}",
                                "nativeQueryRef": val_measure
                            }
                        ]
                    }
                }
            },
            "drillFilterOtherVisuals": True
        }
    }

def create_table_visual(name, x, y, w, h, projections_list, tab_order):
    proj_objs = []
    for item in projections_list:
        if item["type"] == "Column":
            proj_objs.append({
                "field": {
                    "Column": {
                        "Expression": {"SourceRef": {"Entity": item["table"]}},
                        "Property": item["prop"]
                    }
                },
                "queryRef": f"{item['table']}.{item['prop']}",
                "nativeQueryRef": item["prop"]
            })
        else:
            proj_objs.append({
                "field": {
                    "Measure": {
                        "Expression": {"SourceRef": {"Entity": item["table"]}},
                        "Property": item["prop"]
                    }
                },
                "queryRef": f"{item['table']}.{item['prop']}",
                "nativeQueryRef": item["prop"]
            })
            
    return {
        "$schema": SCHEMA_VC,
        "name": name,
        "position": {
            "x": x,
            "y": y,
            "z": 1000,
            "height": h,
            "width": w,
            "tabOrder": tab_order
        },
        "visual": {
            "visualType": "tableEx",
            "query": {
                "queryState": {
                    "Values": {
                        "projections": proj_objs
                    }
                }
            }
        }
    }

visuals = [
    # KPIs superiores
    ("v_card_encuestados", create_card_visual("v_card_encuestados", 380, 30, 340, 150, "Fact_Respuestas", "Total Encuestados", 1)),
    ("v_card_csat", create_card_visual("v_card_csat", 750, 30, 340, 150, "Fact_Respuestas", "CSAT Promedio", 2)),
    ("v_card_nps", create_card_visual("v_card_nps", 1120, 30, 340, 150, "Fact_Respuestas", "NPS Score", 3)),
    ("v_card_churn", create_card_visual("v_card_churn", 1490, 30, 340, 150, "Fact_Respuestas", "% Churn Alto", 4)),
    
    # Segmentadores a la izquierda
    ("v_slicer_operador", create_slicer_visual("v_slicer_operador", 40, 210, 300, 250, "Dim_Operador", "operador", 5)),
    ("v_slicer_area", create_slicer_visual("v_slicer_area", 40, 480, 300, 250, "Dim_Estudiante", "area_academica", 6)),
    ("v_slicer_genero", create_slicer_visual("v_slicer_genero", 40, 750, 300, 250, "Dim_Estudiante", "genero", 7)),
    
    # Donut Chart: Market Share
    ("v_donut_market", create_donut_visual("v_donut_market", 380, 210, 680, 420, "Dim_Operador", "operador", "Fact_Respuestas", "Total Encuestados", 8)),
    
    # Tabla Resumen de Operadores
    ("v_table_summary", create_table_visual("v_table_summary", 1080, 210, 750, 420, [
        {"type": "Column", "table": "Dim_Operador", "prop": "operador"},
        {"type": "Measure", "table": "Fact_Respuestas", "prop": "Total Encuestados"},
        {"type": "Measure", "table": "Fact_Respuestas", "prop": "CSAT Promedio"},
        {"type": "Measure", "table": "Fact_Respuestas", "prop": "NPS Score"},
        {"type": "Measure", "table": "Fact_Respuestas", "prop": "% Churn Alto"}
    ], 9)),
    
    # Tabla Inferior: Detalle Estudiantil
    ("v_table_detail", create_table_visual("v_table_detail", 380, 660, 1450, 360, [
        {"type": "Column", "table": "Fact_Respuestas", "prop": "id_estudiante"},
        {"type": "Column", "table": "Dim_Operador", "prop": "operador"},
        {"type": "Column", "table": "Dim_Estudiante", "prop": "area_academica"},
        {"type": "Column", "table": "Dim_Estudiante", "prop": "antiguedad_uso"},
        {"type": "Column", "table": "Fact_Respuestas", "prop": "csat_promedio"},
        {"type": "Column", "table": "Fact_Respuestas", "prop": "nps_category"},
        {"type": "Column", "table": "Fact_Respuestas", "prop": "riesgo_churn"},
        {"type": "Column", "table": "Fact_Respuestas", "prop": "problema_principal"}
    ], 10))
]

for v_id, v_data in visuals:
    v_dir = os.path.join(VISUALS_DIR, v_id)
    os.makedirs(v_dir, exist_ok=True)
    v_path = os.path.join(v_dir, "visual.json")
    with open(v_path, "w", encoding="utf-8") as f:
        json.dump(v_data, f, indent=2, ensure_ascii=False)
    print(f"[OK] Visual creado: {v_id}")

print(f"\n[EXITO] {len(visuals)} objetos visuales generados en: {VISUALS_DIR}")
