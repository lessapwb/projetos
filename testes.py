# DICAS SOBRE PYTHON:
# FUNÇÃO input(): Ela recebe como parâmetro uma String que será visível ao usuário, 
# onde geralmente informa que tipo de informação ele está esperando receber;
# FUNÇÃO print(): Ela é a responsável por imprimir os dados e informar os valores no terminal;

# Abaixo segue um exemplo de código que você pode ou não utilizar
segundos = int(input())

# TODO: Complete os espaços em branco com as operações que calculam a duração em segundos.
minutos = int(segundos/60)
segundos = int(segundos - (minutos * 60))
horas = int(minutos/60)
minutos = int(minutos - (horas * 60))

# DICA: O Método format() cria uma String que contém campos entre chaves que são 
# substituídas pelos argumentos do format.
print("{}:{}:{}".format(horas, minutos, segundos))