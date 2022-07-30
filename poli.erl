-module(poli).
-export([start/0,loop/0,add/2,sum/2,addpoli/1,sub/2,subtract/2,negative/1,mult/2,multiply/2,distr/2,sorted/1,bsortexe/1,bsort/1]).

%==================================================
%spawn

start() ->
  register(poli, spawn(poli,loop,[])).

%==================================================
%chamadas do servidor

sum(Poli1, Poli2) ->
  List = addpoli(Poli1) ++ addpoli(Poli2),
  bsortexe(addpoli(List)).

subtract(Poli1, Poli2) ->
  Poli3 = negative(addpoli(Poli2)),
  bsortexe(addpoli(addpoli(Poli1) ++ addpoli(Poli3))).

multiply(Poli1, Poli2) ->
  bsortexe(distr(addpoli(Poli1), addpoli(Poli2))).

%==================================================
%funcoes auxiliares

%normalizacao
addpoli([]) -> [];
addpoli([A]) -> [A];
addpoli([{Coef1,{Var,Exp}} , {Coef2,{Var,Exp}} | T]) ->
  Coef3 = Coef1+Coef2,
  addpoli([{Coef3,{Var,Exp}} | T]);
addpoli([{Coef1,{Var1,Exp1}} , {Coef2,{Var2,Exp2}} | T]) ->
  [{Coef2,{Var2,Exp2}}] ++ addpoli([{Coef1,{Var1,Exp1}} | T]).

%simetrico
negative([]) -> [];
negative([{Coef,{Var,Exp}}|T]) ->
  Coef2 = Coef*(-1),
  [{Coef2,{Var,Exp}}] ++ negative(T).

%propiedade distributiva
distr([],[]) -> [];
distr([{_,{_,_}}|_],[]) -> [];
distr([],[{_,{_,_}}|_]) -> [];
%mesma variavel
distr([{Coef1,{Var,Exp1}}|T1],[{Coef2,{Var,Exp2}}|T2]) ->
  [{Coef1*Coef2,{Var,Exp1+Exp2}}] 
    ++ distr([{Coef1,{Var,Exp1}}|T1],T2)
    ++ distr(T1,[{Coef2,{Var,Exp2}}|T2]);
%variáveis diferentes mas com vazia
distr([{Coef1, {[], _}} | T1], [{Coef2, {Var2, Exp2}} | T2]) ->
  [{Coef1*Coef2, {Var2, Exp2}}]
    ++ distr(T1,[{Coef2,{Var2,Exp2}}|T2]);
distr([{Coef1, {Var1, Exp1}} | T1], [{Coef2, {[], _}} | T2]) ->
  [{Coef1*Coef2, {Var1, Exp1}}]
    ++ distr([{Coef1,{Var1,Exp1}}|T1],T2);
%variáveis diferentes
distr([{Coef1, {Var1, Exp1}} | T1], [{Coef2, {Var2, Exp2}} | T2]) ->
  [{Coef1*Coef2, {{Var1, Var2}, {Exp1, Exp2}}}]
    ++ distr([{Coef1,{Var1,Exp1}}|T1],T2)
    ++ distr(T1,[{Coef2,{Var2,Exp2}}|T2]).

%==================================================
%bubblesort

%process list
bsortexe(List) ->
  Sorted = sorted(List),
  if
    (not Sorted) -> 
      List2 = bsort(List),
      bsortexe(List2);
    true -> 
      List
  end.

%algoritmo bubble sort aplicado a lista
bsort([]) -> [];
bsort([A]) -> [A];
bsort([{Coef1,{Var1,Exp1}} , {Coef2,{Var2,Exp2}} | T]) ->
  if
    (Var1 < Var2) ->
        [{Coef1,{Var1,Exp1}}] ++ bsort([{Coef2,{Var2,Exp2}} | T]);
    (Var1 == Var2) ->
      if
        (Exp1 < Exp2) ->
          [{Coef2,{Var2,Exp2}}] ++ bsort([{Coef1,{Var1,Exp1}} | T]);
        true ->
          [{Coef1,{Var1,Exp1}}] ++ bsort([{Coef2,{Var2,Exp2}} | T])
        end;
    true -> 
      [{Coef2,{Var2,Exp2}}] ++ bsort([{Coef1,{Var1,Exp1}} | T])
  end.

%verifica se lista esta ordenada
sorted([]) -> true;
sorted([{_,{_,_}}]) -> true;
sorted([{_,{Var1,Exp1}},{Coef2,{Var2,Exp2}} | T]) -> 
  if
    (((Var1 == Var2) and (Exp1 > Exp2)) or (Var1 < Var2)) ->
      sorted([{Coef2,{Var2,Exp2}}|T]);
    true -> 
      false
  end.

%==================================================
%cliente
add(Poli1, Poli2) -> rpc({add,Poli1,Poli2}).
sub(Poli1, Poli2) -> rpc({sub,Poli1,Poli2}).
mult(Poli1, Poli2) -> rpc({mult,Poli1,Poli2}).

rpc(Q)->
  poli ! {self(), Q},
  receive 
    {response, Result} -> Result
  end.

%==================================================
%servidor

loop() ->
  receive
    %soma de polinomios
    { From, {add, Poli1, Poli2} } -> 
      From ! {response, sum(Poli1,Poli2)},
      loop();
    %subtracao de polinomios
    { From, {sub, Poli1, Poli2} } -> 
      From ! {response, subtract(Poli1,Poli2)},
      loop();
    { From, {mult, Poli1, Poli2} } -> 
      From ! {response, multiply(Poli1,Poli2)},
      loop()
    end.

%==================================================