#include 'protheus.ch'
#include 'parmtype.ch'

/*****************************************************************************\
**---------------------------------------------------------------------------**
** FUNÇÃO   : TK180QRY.prw | AUTOR : Cristiano Machado | DATA : 16/06/2017   **
**---------------------------------------------------------------------------**
** DESCRIÇÃO: Esse ponto de entrada permite adicionar uma expressão na query **
**            de seleção dos títulos para geração. Isso porque cada cliente  **
**            pode possuir uma regra de negócio específica para a geração    **
**            dos títulos de clientes inadimplentes. Por exemplo, não gerar  **
**            os títulos dos clientes padrão e administradoras financeiras;  **
**            na expressão do filtro, adicionar os códigos desses clientes   **
**            que não podem ser gerados no arquivo SK1.                      **
**            Esse ponto de entrada será executado no momento em que for     **
**            selecionada a opção Gerar, da rotina de Seleção de Títulos,    **
**            que tem por objetivo incluir os títulos vencidos e não pagos   **
**            na tabela de referência de títulos (SK1).                      **
**---------------------------------------------------------------------------**
** USO : Especifico para imdepa Tele-Cobrança                                **
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