#include "protheus.ch"        // incluido pelo assistente de conversao do AP5 IDE em 25/01/02
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍŃÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍŃÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍŃÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±şPrograma  łFCALCSP   şAutor  łJULIO JACOVENKO     ş Data ł  12/30/15   ş±±
±±ĚÍÍÍÍÍÍÍÍÍÍŘÍÍÍÍÍÍÍÍÍÍĘÍÍÍÍÍÍÍĎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍĘÍÍÍÍÍÍĎÍÍÍÍÍÍÍÍÍÍÍÍÍą±±
±±şDesc.     łRODAR WORKFLOW A CADA 30 DIAS                               ş±±
±±ş          łBUSCANDO 90 DIAS PARA TRAS (3 MESES)                        ş±±
±±ĚÍÍÍÍÍÍÍÍÍÍŘÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍą±±
±±şUso       ł IMDEPA                                                     ş±±
±±ČÍÍÍÍÍÍÍÍÍÍĎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍĽ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
#include "topconn.ch"
#include "protheus.ch"
USER FUNCTION FCALCSP()
Local cQUERY, cQUERY1
Local cDataIni:=dDataBase-90
Local nCount:=0
Private  NAVGFRT   := SUPERGETMV("IMD_AVGFRT"  , , 3000)    //VLR PARA CALCULO DO AVG FRT ST
Private  NDIASAVG  := SUPERGETMV("IMD_DIAAVG" , , 90)    //VLR PARA CALCULO DO AVG FRT ST
                                    

///PRIMEIRO LIMPAMOS OS CALCULOS JA FEITOS
///POIS NAO PODE TER 'CALCULOS ANTERIORES' A 90 DIAS
///USADO SOMENTE NA HOMOLOGACAO
/*
cSql:= " UPDATE "+RetSqlName("SA1")
cSql+= " SET "
cSql+= " A1_AVGDATA =' ', A1_AVGFIXO = 0 "
cSql+= " WHERE "      
cSql+= " A1_AVGDATA<>' ' "
TCSQLExec( cSql )
TCSQLExec('COMMIT')
*/


///AGORA VAMOS BUSCAR CLIENTES
///QUER EFETURARM COMPRAS NOS ULTIMOS 90 DIAS
///    
cQUERY :=""
cQUERY+=" SELECT A1_EST, A1_GRPSEG, SA1.* FROM SA1010 SA1 "
cQUERY+=" WHERE A1_EST='SP' "
cQUERY+=" AND (A1_GRPSEG LIKE '__1%' OR A1_GRPSEG LIKE '__3%') "  //grpser tem de ser com final 1 ou 3
cQUERY+=" AND A1_ULTCOM>='20151001' AND A1_ULTCOM<='20151231' "         //PARA PRIMEIRA CARGA
//cQUERY+=" AND A1_ULTCOM>=TO_CHAR(SYSDATE-"+STR(NDIASAVG)+",'YYYYMMDD') " //PARA AS PROXIMAS CARGAS        //pega a data do banco e volta 90 dias
//cQUERY+=" AND A1_TPFRET<>'F' "                                    //nao pode ser FOB
//cQUERY+=" AND A1_CLIFRTE = '1' "                                  //tem de ser cliente especial
//cQUERY+=" AND A1_VINCULO NOT IN ('#CM','CM','#PP','PP') "           //nao pode ser CM ou PP
cQUERY+=" AND D_E_L_E_T_ <>'*' "
cQuery := ChangeQuery(cQuery)
TCQUERY cQuery NEW ALIAS "TRBSA1"
            
dBSELECTarea("TRBSA1")
dBGoTOP()
WHILE !EOF()   

///FAZ A MEDIA
///DOS ULTIMOS 90 DIAS
///DOS CLIENTES QUE EFETURAM COMPRAS NOS ULTIMOS 90 DIAS
///VIA SA1_ULTCOM e QUE ESTEJAM NOS GRUPOS FINAL 1 E FINAL 3
///PEGA TODAS AS FILIAIS, POIS O CLIENTE PODE TER COMPRADO POR
///OUTRA FILIAL QUE NAO SP
///    
cQUERY1:=""
cQUERY1+=" SELECT AVG(F2_VALBRUT) MEDIA FROM SF2010 SF2 "
//cQUERY1+=" WHERE TO_CHAR(F2_EMISSAO)>=TO_CHAR(SYSDATE-"+STR(NDIASAVG)+",'YYYYMMDD') "  ///emissao >= data do banco - 90 (3 mesess)
cQUERY1+=" WHERE F2_EMISSAO>= '20151001' AND F2_EMISSAO<='20151231' " //PARA PRIMEIRA CARGA
cQUERY1+=" AND F2_CLIENTE='"+TRBSA1->A1_COD+"' " //'005317'
cQUERY1+=" AND F2_LOJA='"+TRBSA1->A1_LOJA+"' "       //'02'
cQUERY1+=" AND F2_TIPO='N' "  //SOMENTE COMPRA  
cQUERY1+=" AND D_E_L_E_T_ <>'*' "
cQuery1 := ChangeQuery(cQuery1)
TCQUERY cQuery1 NEW ALIAS "TRBSF2"

dBSelectArea('TRBSF2')
TRBSF2->(DbGotop())
//TRBSF2->( dbEval( {||nCount++},,,1 ) )
                     
NMEDIA:=0
DO WHILE !EOF()
  NMEDIA:=TRBSF2->MEDIA
  TRBSF2->(DBSKIP())
ENDDO
dbSelectArea("TRBSF2")
dbCloseArea()

LAVGFIXO     :=SA1->(FieldPos("A1_AVGFIXO")) > 0 //SE EXISTE CAMPO A1_AVGFIXO

IF LAVGFIXO
	   DbselectArea("SA1");DbSetOrder(1);DbGoTop()
		DbSeek(xFilial("SA1")+TRBSA1->A1_COD+TRBSA1->A1_LOJA, .F.)
   		RecLock("SA1",.F.)
   		SA1->A1_AVGFIXO :=NMEDIA      //medida calculada   tipo N,13,2
   		SA1->A1_AVGDATA :=DDatabase   //data do calculo    tipo Data
   		SA1->(MSUNLOCK())
ENDIF   		

/*
    //////////////////////////////////////////////////
	IF NMEDIA>=NAVGFRT //3000   //GRAVA LABEL A2_LIBCFIXO = .T., CASO CONTRARIO .F.
	   DbselectArea("SA1");DbSetOrder(1);DbGoTop()
		DbSeek(xFilial("SA1")+TRBSA1->A1_COD+TRBSA1->A1_LOJA, .F.)
   		RecLock("SA1",.F.)
   		SA1->A1_AVGFIXO :=NMEDIA      //medida calculada   tipo N,13,2
   		SA1->A1_AVGDATA :=DDatabase   //data do calculo    tipo Data
   		SA1->(MSUNLOCK())
	ELSE
	    DbselectArea("SA1");DbSetOrder(1);DbGoTop()
		DbSeek(xFilial("SA1")+TRBSA1->A1_COD+TRBSA1->A1_LOJA, .F.)
   		RecLock("SA1",.F.)
   		//SA1->A1_LIBCFIX :=.F.         //nao libera carro fixo
 		SA1->A1_AVGFIXO :=NMEDIA      //media calculada
  		SA1->A1_AVGDATA :=DDatabase   //data do calculo
   		SA1->(MSUNLOCK())
	ENDIF        
    /////////////////////////////////////////////////
*/

///vamos ao proximo cliente
DBSELECTAREA('TRBSA1')
TRBSA1->(DBSKIP())
ENDDO                  


dbSelectArea("TRBSA1")
dbCloseArea()

RETURN