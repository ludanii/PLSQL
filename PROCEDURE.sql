insert into pais values(77,'JAMAICA');

--- Criar um bloco anônimo para realizar esse mesmo INSERT; ---

DECLARE 
    v_id NUMBER := &VALOR;
    v_nome VARCHAR2(30) := '&NOME';
BEGIN
    INSERT INTO pais VALUES (
        v_id,
        v_nome
    );
COMMIT;
END;

CREATE OR REPLACE PROCEDURE insert_pais (
    v_id NUMBER,
    v_nome VARCHAR2
) AS
BEGIN
    INSERT INTO pais VALUES (
        v_id,
        v_nome
    );
    
    COMMIT;
END insert_pais;

--- os 4 fazem a mesma coisa para inserir (depende da linguagem do backend) ---

EXEC insert_pais(586, 'AFRICA DO SUL');

EXECUTE insert_pais(586, 'AFRICA DO SUL');

CALL insert_pais(586, 'AFRICA DO SUL');

BEGIN
insert_pais();
END;


CREATE OR REPLACE PROCEDURE UPDATE_PAIS(
    P_COD NUMBER,
    P_NOME VARCHAR2
) AS 
BEGIN
    UPDATE PAIS
    SET
        NOM_PAIS = P_NOME
    WHERE
        COD_PAIS = P_COD;
        
    COMMIT;
END UPDATE_PAIS;

CREATE OR REPLACE PROCEDURE delete_pais (
    p_cod NUMBER
) AS
BEGIN
    DELETE FROM pais
    WHERE
        cod_pais = p_cod;
        COMMIT;
END delete_pais;
SELECT 
    A.COD_PEDIDO,
    B.COD_CLIENTE,
    B.NOM_CLIENTE,
    A.DAT_PEDIDO,
    D.NOM_PRODUTO
FROM
    PEDIDO A
    INNER JOIN CLIENTE B ON ( A .COD_CLIENTE = B.COD_CLIENTE )
    INNER JOIN ITEM_PEDIDO C ON ( A.COD_PEDIDO = C.COD_PEDIDO )
    INNER JOIN PRODUTO D ON ( C.COD_PRODUTO = D.COD_PRODUTO )
WHERE
    A.COD_CLIENTE = 74
    AND A.COD_PEDIDO = 130501
    
    
    
CREATE OR REPLACE PROCEDURE SELECT_PEDIDO (
) AS BEGIN
   SELECT FROM PEDIDO A
   INNER JOIN CLIENTE B ON ( A .COD_CLIENTE = B.COD_CLIENTE )
    INNER JOIN ITEM_PEDIDO C ON ( A.COD_PEDIDO = C.COD_PEDIDO )
    INNER JOIN PRODUTO D ON ( C.COD_PRODUTO = D.COD_PRODUTO )
   SET 
    COD_PEDIDO = A.COD_PEDIDO
    COD_CLIENTE = B.COD_CLIENTE
    NOM_CLIENTE = B.NOM_CLIENTE
    DAT_PEDIDO = A.DAT_PEDIDO
    NOM_PRODUTO = D.NOM_PRODUTO
WHERE
    A.COD_CLIENTE = 74
    AND A.COD_PEDIDO = 130501
COMMIT
END SELECT_PEDIDO;
