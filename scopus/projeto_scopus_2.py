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
openai_api_key = os.getenv('sk-proj-hNilou3jBHVjOg7PMGSbT3BlbkFJRQxI1IgJ322AasuUbIMo')

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
