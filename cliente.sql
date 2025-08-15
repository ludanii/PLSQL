CREATE TABLE INSERT_CLIENTES (
    ID NUMBER,
    NOME VARCHAR2(40),
    EMAIL VARCHAR2(50),
    DATA_CADASTRO DATE
);



CREATE OR REPLACE PACKAGE PKG_AULA_01 AS 
    PROCEDURE PRD_INSERT_CLIENTE (
        P_ID NUMBER,
        P_NOME VARCHAR2,
        P_EMAIL VARCHAR2,
        P_DATA_CADASTRO DATE
    );
    
    FUNCTION FC_CONTAR_CLIENTES RETURN NUMBER;
END PKG_AULA_01;

CREATE OR REPLACE PACKAGE BODY pkg_aula_01 AS

    PROCEDURE prd_insert_cliente (
        p_id            NUMBER,
        p_nome          VARCHAR2,
        p_email         VARCHAR2,
        p_data_cadastro DATE
    ) IS
    BEGIN
        INSERT INTO insert_clientes VALUES ( p_id,
                                             p_nome,
                                             p_email,
                                             p_data_cadastro );

        COMMIT;
    END prd_insert_cliente;

    FUNCTION fc_contar_clientes RETURN NUMBER IS
        v_total NUMBER;
    BEGIN
        SELECT
            COUNT(1)
        INTO v_total
        FROM
            insert_clientes;

        RETURN v_total;
    END fc_contar_clientes;

END pkg_aula_01;



SELECT
    pkg_aula_01.fc_contar_clientes
FROM
    dual;

CALL pkg_aula_01.prd_insert_cliente(10, 'VERGILIO', 'PF1788@FIAP.COM.BR', sysdate);