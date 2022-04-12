import json
import csv
import os

"""Script pour convertir le fichier export.json en CSV"""

nboucles = 0  # variable pour compter le nombre d'itération
path = os.path.dirname(os.path.abspath(__file__))  # chemin du fichier actuel

# ouvrir le fichier de json en écriture
with open(os.path.join(path, "export.json"), mode="r") as f:
    source = json.load(f)

# ouvrir le fichier de sortie en écriture
with open(os.path.join(path, "export.csv"), mode="w", encoding="utf-8") as f:
    writer = csv.writer(f, delimiter="\t", quotechar="\"")
    # itérer sur chaque catalogue. à la permier itération, écrire le nom des colonnes
    # et les données du 1e catalogue; ensuite, écrire uniquement les données des catalogues
    for k, v in source.items():
        nboucles += 1
        if nboucles == 1:
            writer.writerow(["id_catalogue"] + list(v.keys()))
            writer.writerow([k] + list(v.values()))
        else:
            writer.writerow([k] + list(v.values()))
