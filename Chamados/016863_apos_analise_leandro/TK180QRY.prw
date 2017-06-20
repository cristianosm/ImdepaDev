#include 'protheus.ch'
#include 'parmtype.ch'

/*****************************************************************************\
**---------------------------------------------------------------------------**
** FUN��O   : TK180QRY.prw | AUTOR : Cristiano Machado | DATA : 16/06/2017   **
**---------------------------------------------------------------------------**
** DESCRI��O: Esse ponto de entrada permite adicionar uma express�o na query **
**            de sele��o dos t�tulos para gera��o. Isso porque cada cliente  **
**            pode possuir uma regra de neg�cio espec�fica para a gera��o    **
**            dos t�tulos de clientes inadimplentes. Por exemplo, n�o gerar  **
**            os t�tulos dos clientes padr�o e administradoras financeiras;  **
**            na express�o do filtro, adicionar os c�digos desses clientes   **
**            que n�o podem ser gerados no arquivo SK1.                      **
**            Esse ponto de entrada ser� executado no momento em que for     **
**            selecionada a op��o Gerar, da rotina de Sele��o de T�tulos,    **
**            que tem por objetivo incluir os t�tulos vencidos e n�o pagos   **
**            na tabela de refer�ncia de t�tulos (SK1).                      **
**---------------------------------------------------------------------------**
** USO : Especifico para imdepa Tele-Cobran�a                                **
**---------------------------------------------------------------------------**
**---------------------------------------------------------------------------**
** ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                         **
**---------------------------------------------------------------------------**
** PROGRAMADOR | DATA | MOTIVO DA ALTERACAO                                  **
**---------------------------------------------------------------------------**
**             |      |                                                      **
**             |      |                                                      **
\*---------------------------------------------------------------------------*/
*******************************************************************************
User function TK180QRY()
*******************************************************************************
Local cSql := '' 

//| Utilizado parametro MV_TMKCOBR conteudo: FT ,NF   
//| Filtro utilizado durante a geracao de lista de cobranca contendo os tipos de titulos, separados por virgula                                            

cSql += ' '

Return cSql