SET SERVEROUTPUT ON;  -- Comando para ativar a visualiza��o da sa�da --

-- Loop --
DECLARE 
	V_CONTADOR NUMBER(2):= 1; 
BEGIN 
LOOP 	
	DBMS_OUTPUT.PUT_LINE(V_CONTADOR); 
	V_CONTADOR := V_CONTADOR + 1; 
	EXIT WHEN V_CONTADOR > 20; 
END LOOP; 
END;


-- While --
DECLARE 
    V_CONTADOR NUMBER(2):= 1; 
BEGIN 
    WHILE V_CONTADOR <= 20 LOOP
    DBMS_OUTPUT.PUT_LINE(V_CONTADOR); 	
    V_CONTADOR := V_CONTADOR + 1; 
END LOOP; 
END;

-- For --
BEGIN 
    FOR V_CONTADOR IN 1..20 LOOP 	
    DBMS_OUTPUT.PUT_LINE(V_CONTADOR); 
    END LOOP; 
END;

-- For reverse --

BEGIN 
    FOR V_CONTADOR IN REVERSE 1..20 LOOP 	
    DBMS_OUTPUT.PUT_LINE(V_CONTADOR); 
    END LOOP; 
END;



-- Exerc�cio de Tabuada --

BEGIN 
    FOR X IN 1..10 LOOP 	
    DBMS_OUTPUT.PUT_LINE(X * 5); 
    END LOOP; 
END;

-- Identificador e contador de pares e impares entre um intervalo --

DECLARE
    pares NUMBER := 0;
    impares NUMBER := 0; 
BEGIN
    FOR INTERVALO IN 1..50 LOOP
    IF MOD(INTERVALO, 2) = 0 THEN
            pares := pares + 1;
        ELSE
            impares := impares + 1;
        END IF;
    END LOOP; 
    DBMS_OUTPUT.PUT_LINE('Quantidade de n�meros pares: ' || pares);
    DBMS_OUTPUT.PUT_LINE('Quantidade de n�meros �mpares: ' || impares);
END;

-- Exibir e m�dia dos valores pares em um intervalo num�rico e soma dos �mpares --

DECLARE
    pares NUMBER := 0;
    qnt_pares number := 0;
    impares NUMBER := 0; 
BEGIN
    FOR INTERVALO IN 1..10 LOOP
    IF MOD(INTERVALO, 2) = 0 THEN
            pares := pares + INTERVALO;
            qnt_pares := qnt_pares + 1;
        ELSE
            impares := impares + INTERVALO;
        END IF;
    END LOOP; 
    DBMS_OUTPUT.PUT_LINE('A m�dia de n�meros pares: ' || pares || '/' || qnt_pares || ' = ' || pares/qnt_pares);
    DBMS_OUTPUT.PUT_LINE('A soma dos n�meros �mpares: ' || impares);
END;




