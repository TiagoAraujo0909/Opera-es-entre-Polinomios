Um programa em Erlang que usa o modelo cliente-servidor para calcular operações entre polinômios (somas, subtrações e multiplicações).
A forma como decidi representar cada monômio foi pelo tuplo:

{Coeficiente,{Variável,Expoente}}, i.e: 3𝑥 → {3,{”x”,2}}.

Decidi esta forma porque pensei que, posteriormente, seria mais fácil realizar operações sobre polinômios, nomeadamente a multiplicação.
Sendo assim, os polinômios são representados por listas de monômios:

[{Coeficiente,{Variável,Expoente}}], i.e: 3𝑥^2 +2𝑥 + 1 → [{3,{”x”,2}}, {2,{“x”,1}, {1,{[],1}}].

-------------

Exemplo de execução (simples).
1) Compilação:
c(poli).
2) Iniciar processo Servidor:
poli:start().
3) Execução:
P1 = [{1,{"x",2}}].
P2 = [{2,{"x",2}},{1,{"y",1}},{-1,{"",0}}].

Adição

poli:add(P1,P2).


Subtração

poli:sub(P1,P2).


Multiplicação

poli:mult(P1,P2).

-------------

Exemplo de execução (ambiente distribuído).

Terminal 1: erl -sname server

Terminal 2: erl -sname client

Terminal 1: c(poli).
            poli:start().
            
Terminal 2: P1 = [{2,{“x”,2}}].
            P2 = [{3,{"x",1}},{-1,{"y",1}}].
            
Tudo o resto no terminal 2 (cliente):

Adição:

rpc:call(‘<servername>’,poli,add,[P1,P2]).

Subtração:
            
rpc:call(‘<servername>’,poli,sub,[P1,P2]).

Multiplicação:
            
rpc:call('<servername>,',poli,mult,[P1,P2]).
