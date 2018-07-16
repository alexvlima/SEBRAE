import requests

url = "https://apiplataforma.sebrae.com.br/graphql"

payload = "{\"query\":\"{getEmpresasAleatorias(qtdElementos: 10)}\"}"
headers = {
    'Content-Type': "application/json",
    }

response = requests.request("POST", url, data=payload, headers=headers, verify=False)

print(response.text)
