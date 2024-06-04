import requests
import pandas as pd

# Ampliando df para visualizar todas as colunas
pd.set_option('display.max_columns', None)

# Definindo a URL da API
url = "https://api.elsevier.com/content/search/scopus"

# Parâmetros para a requisição
params = {
    "query": 'TITLE-ABS-KEY ( "marketing" AND ( "data-driven" and "data driven" ) )',
    "apiKey": "f4b02ed7622b9888bb5b1b126d560c36",
    "count": 200,  # Definindo o número máximo de registros por página
    "start": 0  # Começando a partir do primeiro registro
}

all_results = []  # Lista para armazenar todos os resultados

while True:
    # Fazendo a requisição GET
    response = requests.get(url=url, params=params)

    # Verificando se a requisição foi bem sucedida
    if response.status_code == 200:
        # Transformando a resposta em um objeto JSON
        data = response.json()

        try:
            # Adicionando os resultados desta página à lista geral
            all_results.extend(data['search-results']['entry'])
        except KeyError:
            # Se a chave 'entry' não estiver presente na resposta, apenas continue para a próxima iteração
            pass

        # Verificando se há mais resultados para recuperar
        if int(data['search-results']['opensearch:itemsPerPage']) == 0:
            # Se não houver mais resultados, interrompa o loop
            break

        # Atualizando o índice do próximo registro a ser recuperado
        params['start'] += params['count']
    else:
        # print("Erro na requisição", response.status_code)
        break

# Imprimindo o número total de resultados obtidos
# print("Total de resultados:", len(all_results))

df_results = pd.DataFrame(all_results)

# Removendo colunas desnecessárias
columns = ['@_fa', 
           'link',
           'prism:url',
           'eid',
           'pii',
           'subtype',
           'source-id',
           'openaccess',
           'openaccessFlag',
           'article-number',
           'freetoread',
           'freetoreadLabel',
           'prism:aggregationType',
           'prism:publicationName',
           'prism:issn',
           'prism:volume',
           'prism:issueIdentifier',
           'prism:pageRange',
           'prism:coverDisplayDate',
           'prism:isbn',
           'prism:eIssn',
           'pubmed-id']


df_results = df_results.drop(columns=columns)


# Tratando a coluna dc:identifier - Removendo o prefixo 'SCOPUS_ID:'
df_results['dc:identifier'] = df_results['dc:identifier'].str.replace('SCOPUS_ID:', '')

# Tratando a coluna affiliation - Transformando em uma lista de strings
# Removendo [] da coluna affiliation
df_results['affiliation'] = df_results['affiliation'].apply(lambda x: [aff['affilname'] for aff in x][0] if isinstance(x, list) and x else None)

# Filtrando para registros que são artigos
df_results = df_results[df_results['subtypeDescription'] == 'Article']
# Adicionando a coluna 'abstract' ao DataFrame

# Função para obter o resumo com base no DOI
def get_abstract(doi):
    url = f"https://api.elsevier.com/content/abstract/doi/{doi}?apiKey=78ad236d4ac36f50eb36db481f4741a1"
    headers = {'Accept': 'application/json'}
    response = requests.get(url, headers=headers)
    data = response.json()
    try:
        abstract_content = data["abstracts-retrieval-response"]["item"]["bibrecord"]["head"]["abstracts"]
        return abstract_content
    except KeyError:
        return None

# Itera sobre os valores da coluna prism:doi e obtém os resumos
df_results['abstract'] = df_results['prism:doi'].apply(get_abstract)
# Exportando dataframe como csv
df_results.to_csv('scopus_data_driven_marketing.csv', index=False)
df_results.to_excel('scopus_data_driven_marketing.xlsx', index=False)

# Importando as bibliotecas necessário para llm com langchain
from langchain.agents.agent_types import AgentType
from langchain_experimental.agents.agent_toolkits import create_csv_agent
from langchain_openai import ChatOpenAI
import os
from dotenv import load_dotenv
import warnings

# Suprimir avisos de depreciação
warnings.filterwarnings('ignore', category=DeprecationWarning)

# Carregar variáveis de ambiente do arquivo .env
load_dotenv()

# Acessar a chave da API do OpenAI
openai_api_key = os.getenv('OPENAI_API_KEY')

agent = create_csv_agent(
    ChatOpenAI(temperature=0.9, model="gpt-4o"), #gpt-3.5-turbo-0125
    "scopus_data_driven_marketing.csv",
    verbose=True,
    agent_type=AgentType.OPENAI_FUNCTIONS,
)
# Criando uma conversa com while
while True:
    input_text = input("Me fala alguma coisa (Se quiser sair, digite '000'): ")
    if input_text == '000':
        print("Até mais!")
        break
    agent.run(input_text)
