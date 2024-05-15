#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import json
import pandas as pd
from Bio import SeqIO
import requests

#The REST-API and the function for searching the URL were defined. The inference data obtained before (RefSeq accession number) were noted

url = "https://rest.uniprot.org"
csv = "~/TFM/chromosome_analysis_cleaned.csv"
df = pd.read_csv(csv)
inference = df["Inference"]

def get_url(url, **kwargs):
    response = requests.get(url, **kwargs)
    
    if (response.status_code == 200):
        print("The request was a success!")
        return response.json()
    else:
        print(f"There's a problem with {url}")
        return None

#Empty dataframes were defined to save the information
go_bp_dump = []
go_mf_dump= []
go_cc_dump =[]

all_endpoints = []

#For each line of inference, if there was no data ('-') or if the URL gave an error, it was noted in the empty dataframes of each category.
for line in inference:
    go_mf_terms = []
    go_cc_terms = []
    go_bp_terms = []

    if line=="-":
        error = "-"
        go_mf_terms.append(error)
        go_cc_terms.append(error)
        go_bp_terms.append(error)
        
    else:
        endpoint =  get_url(f"{url}/uniprotkb/search?$fields=go%go_p%go_c%go_f&query={line}")
        if endpoint==None:
            error = "Error in url"
            go_mf_terms.append(error)
            go_cc_terms.append(error)
            go_bp_terms.append(error) 

  #If everything was correct, the information from each group was extracted following the dictionary structure of the REST-APi output and added to their respective dataframes.
        else:
            for result in endpoint['results']:
                all_endpoints.append(endpoint)
                references = result.get('uniProtKBCrossReferences', {})

                for database in references:
                        if database.get("database") == 'GO':
                            properties = database.get('properties', {})

                            for i in properties:
                                if i.get("key") == 'GoTerm':
                                        go_term = i.get('value', '')

                                        if go_term.startswith('F:'):
                                            go_term = go_term.replace('F:', '', 1).strip()
                                            go_mf_terms.append(go_term)

                                        elif go_term.startswith('C:'):
                                            go_term = go_term.replace('C:', '', 1).strip()
                                            go_cc_terms.append(go_term)
                                            

                                        elif go_term.startswith('P:'):
                                            go_term = go_term.replace('P:', '', 1).strip()
                                            go_bp_terms.append(go_term)
                                    

    go_bp_dump.append(', '.join(go_bp_terms))
    go_mf_dump.append(', '.join(go_mf_terms))
    go_cc_dump.append(', '.join(go_cc_terms))

df['Biological Procces'] = go_bp_dump
df['Molecular Function'] = go_mf_dump
df['Cellular Component'] = go_cc_dump

#Save
df.to_csv("~/TFM/chromosome_analysis_cleaned_actualizado.csv", index=True)
with open("all_endpoints.txt", 'w') as file:
    json.dump(all_endpoints, file, indent=4)
