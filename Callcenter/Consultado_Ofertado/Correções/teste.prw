Exemplo com lCria  = .F.       
cArq := CriaTrab(NIL, .F.)       
cIndice := "C9_AGREG+"+IndexKey()       
Index on &cIndice To &cArq 

Exemplo com lCria = .T.
aStru := {}
AADD(aStru,{ "MARK"   , "C",  1, 0})
AADD(aStru,{ "AGLUT"  , "C", 10, 0})
AADD(aStru,{ "NUMOP"  , "C", 10, 0})
AADD(aStru,{ "PRODUTO", "C", 15, 0})
AADD(aStru,{ "QUANT"  , "N", 16, 4})
AADD(aStru,{ "ENTREGA", "D",  8, 0})
AADD(aStru,{ "ENTRAJU", "D",  8, 0})
AADD(aStru,{ "ORDEM"  , "N",  4, 0})
AADD(aStru,{ "GERADO" , "C",  1, 0})

cArqTrab := CriaTrab(aStru, .T.)

USE &cArqTrab ALIAS TRB NEW

OrdBagExt()