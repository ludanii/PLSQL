CREATE TABLE cliente (
    id_cliente  NUMBER PRIMARY KEY,
    nome        VARCHAR2(30),
    data_nasc   DATE,
    cpf_cnpj    NUMBER,
    id_genero   NUMBER,
    id_tipo_cli NUMBER
);

CREATE TABLE genero (
    id_genero NUMBER PRIMARY KEY,
    descricao VARCHAR(30)
);

ALTER TABLE cliente
    ADD CONSTRAINT fk_genero FOREIGN KEY ( id_genero )
        REFERENCES genero ( id_genero );

CREATE TABLE tipo_cliente (
    id_tipo_cli NUMBER PRIMARY KEY,
    descricao   VARCHAR2(30)
);

ALTER TABLE cliente
    ADD CONSTRAINT fk_tipo_cli FOREIGN KEY ( id_genero )
        REFERENCES tipo_cliente ( id_tipo_cli );

CREATE TABLE end_cliente (
    id_end      NUMBER PRIMARY KEY,
    logradouro  VARCHAR2(30),
    numero      NUMBER,
    cep         NUMBER,
    complemento VARCHAR2(50),
    referencia  VARCHAR2(30),
    id_bairro   NUMBER
);
    
--ALTER TABLE END_CLIENTE ADD PRIMARY KEY(ID_END);

CREATE TABLE bairro (
    id_bairro   NUMBER PRIMARY KEY,
    nome_bairro VARCHAR2(30),
    id_estado   NUMBER
);

ALTER TABLE end_cliente
    ADD CONSTRAINT fk_bairro FOREIGN KEY ( id_bairro )
        REFERENCES bairro ( id_bairro );

CREATE TABLE cidade (
    id_cidade   NUMBER PRIMARY KEY,
    nome_cidade VARCHAR2(30),
    id_estado   NUMBER
);

ALTER TABLE BAIRRO
ADD ID_CIDADE NUMBER;

ALTER TABLE bairro
    ADD CONSTRAINT fk_estado FOREIGN KEY ( id_cidade )
        REFERENCES cidade ( id_cidade );

CREATE TABLE estado (
    id_estado   NUMBER PRIMARY KEY,
    nome_estado VARCHAR2(30),
    id_pais     NUMBER
);

ALTER TABLE cidade
    ADD CONSTRAINT fk_cidade FOREIGN KEY ( id_estado )
        REFERENCES estado ( id_estado );

CREATE TABLE pais (
    id_pais   NUMBER PRIMARY KEY,
    nome_pais VARCHAR2(30)
)

ALTER TABLE estado
    ADD CONSTRAINT fk_pais FOREIGN KEY ( id_pais )
        REFERENCES pais ( id_pais );