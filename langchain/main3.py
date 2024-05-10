import os
from langchain import hub
from dotenv import load_dotenv
from langchain_openai import ChatOpenAI
from langchain_community.tools import YouTubeSearchTool
from langchain_community.tools.google_trends import GoogleTrendsQueryRun
from langchain_community.utilities.google_trends import GoogleTrendsAPIWrapper
from langchain.agents import create_openai_functions_agent, AgentExecutor

load_dotenv()

os.environ["SERPAPI_API_KEY"] = "732d108978c1845a8272ae257d237561f3844fbea17fed7a2e0a809b1d6ef2a2"

# Tools
youtube_tool = YouTubeSearchTool()
google_trends = GoogleTrendsQueryRun(api_wrapper=GoogleTrendsAPIWrapper())
tools = [youtube_tool, google_trends]


# Prompt
prompt = hub.pull('hwchase17/openai-functions-agent')


# LLM
llm = ChatOpenAI(model = 'gpt-4', temperature = 0.3)

# Juntar Tools Prompt LLM, Agent
agent = create_openai_functions_agent(llm, tools, prompt)

# Executor
agent_executor = AgentExecutor(agent = agent, tools = tools, verbose = True)

# agent_executor.invoke({'input': 'Olá, tudo bem?'})
# agent_executor.invoke({'input': 'Me dê alguns links de vídeos no youtube que falam sobre llms'})
agent_executor.invoke({'input': 'Me informe as principais tendência do metaverso nas transformações urbanas baseado no google trends!'})