CREATE OR REPLACE PACKAGE pkg_pedido AS
    PROCEDURE prd_pedido (
        cod_cliente            NUMBER,
        cod_pedido             NUMBER,
        cod_pedido_relacionado NUMBER,
        cod_usuario            NUMBER,
        cod_vendedor           NUMBER,
        dat_cancelamento       DATE,
        dat_entrega            DATE,
        dat_pedido             DATE,
        seq_endereco_cliente   NUMBER,
        status                 VARCHAR2,
        val_desconto           NUMBER,
        val_total_pedido       NUMBER
    );

    FUNCTION fc_contar_pedidos RETURN NUMBER;

END pkg_pedido;

CREATE OR REPLACE PACKAGE BODY pkg_pedido AS

    PROCEDURE prd_pedido (
        cod_cliente            NUMBER,
        cod_pedido             NUMBER,
        cod_pedido_relacionado NUMBER,
        cod_usuario            NUMBER,
        cod_vendedor           NUMBER,
        dat_cancelamento       DATE,
        dat_entrega            DATE,
        dat_pedido             DATE,
        seq_endereco_cliente   NUMBER,
        status                 VARCHAR2,
        val_desconto           NUMBER,
        val_total_pedido       NUMBER
    ) IS
    BEGIN
        INSERT INTO pedido VALUES ( cod_pedido,
                                    cod_pedido_relacionado,
                                    cod_cliente,
                                    cod_usuario,
                                    cod_vendedor,
                                    dat_pedido,
                                    dat_cancelamento,
                                    dat_entrega,
                                    val_total_pedido,
                                    val_desconto,
                                    seq_endereco_cliente,
                                    status );

        COMMIT;
    END prd_pedido;

    FUNCTION fc_contar_pedidos RETURN NUMBER IS
        v_total NUMBER;
    BEGIN
        SELECT
            COUNT(1)
        INTO v_total
        FROM
            pedido;

        RETURN v_total;
    END fc_contar_pedidos;

END pkg_pedido;

-- funcao para contar pedidos --

SELECT
    pkg_pedido.fc_contar_pedidos
FROM
    dual;
    
-- funcao para adicionar pedido --

CALL pkg_pedido.prd_pedido(1, 171001, NULL, 30, 30,
                           NULL, sysdate, sysdate, NULL, 'processando',
                           760.50, 5394.12);
