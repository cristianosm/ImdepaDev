#include "protheus.ch"        


User Function TstLayer()

Local oDlg 

Local oLayer := FWLayer():new()

DEFINE MSDIALOG oDlg FROM 000,000 TO 500,500 PIXEL TITLE "FWLayer"

//Inicializa o FWLayer com a janela que ele pertencera e se sera exibido o botão de fechar

oLayer:init(oDlg,.T.)

//Cria as colunas do Layer

oLayer:addCollumn('Col01',60,.F.)
oLayer:addCollumn('Col02',40,.F.)  

//Adiciona Janelas as colunas

oLayer:addWindow('Col01','C1_Win01','Janela 01',60,.T.,.F.,{|| Alert("Clique janela 01!") },,{|| Alert("Janela 01 recebeu foco!") })
oLayer:addWindow('Col01','C1_Win02','Janela 02',40,.T.,.T.,{|| Alert("Clique janela 02!") },,{|| Alert("Janela 02 recebeu foco!") })
oLayer:addWindow('Col02','C2_Win01','Janela 01',60,.T.,.F.,{|| Alert("Clique janela 01 Coluna 2!") },,{|| Alert("Janela 01 recebeu foco Coluna 2!") })
oLayer:getWinPanel('Col02','C2_Win01')                             

//Coloca o botão de split na coluna
oLayer:setColSplit('Col01',CONTROL_ALIGN_RIGHT,,{|| Alert("Split Col01!") })

ACTIVATE MSDIALOG oDlg CENTERED

Return