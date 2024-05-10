from langchain_community.llms import OpenAI
from langchain.prompts import PromptTemplate
from langchain.chains import LLMChain
from dotenv import load_dotenv

load_dotenv()

def oscar(filme, ano, llm):

    prompt = PromptTemplate(
        input_variables=['filmes','ano'],
        template="Quantos oscars o filme {filme} ganhou em {ano}?"
    )
    oscar_chain = LLMChain(llm=llm, prompt=prompt)
    response = oscar_chain({'filme': filme, 'ano': ano})
    return response
llm = OpenAI(temperature=0, model='gpt-3.5-turbo-instruct')


if __name__ == "__main__":
    response = oscar('Oppenheimer', 2024, llm)
    print(response['text'])