DROP TABLE PLATI CASCADE CONSTRAINTS;
DROP TABLE REZERVARI_SERVICII CASCADE CONSTRAINTS;
DROP TABLE REZERVARI CASCADE CONSTRAINTS;
DROP TABLE SERVICII CASCADE CONSTRAINTS;
DROP TABLE CAMERE CASCADE CONSTRAINTS;
DROP TABLE TIPURI_CAMERA CASCADE CONSTRAINTS;
DROP TABLE CLIENTI CASCADE CONSTRAINTS;
DROP TABLE ANGAJATI CASCADE CONSTRAINTS;
DROP SEQUENCE seq_tip_camera;
DROP SEQUENCE seq_angajati;
DROP SEQUENCE seq_clienti;
DROP SEQUENCE seq_servicii;
DROP SEQUENCE seq_rez;
DROP SEQUENCE seq_plati;
DROP SYNONYM cl;
DROP SYNONYM rez;
DROP INDEX idx_rez_id_client;

-- 1. TIPURI_CAMERA
CREATE TABLE TIPURI_CAMERA (
    ID_Tip          NUMBER(10)      PRIMARY KEY,
    Denumire        VARCHAR2(50)    NOT NULL,
    Capacitate_Max  NUMBER(2)       NOT NULL,
    Pret_Standard   NUMBER(8, 2)    NOT NULL
);

-- 2. CLIENTI
CREATE TABLE CLIENTI (
    ID_Client       NUMBER(10)      PRIMARY KEY,
    Nume            VARCHAR2(50)    NOT NULL,
    Prenume         VARCHAR2(50)    NOT NULL,
    Email           VARCHAR2(100)   UNIQUE,
    Telefon         VARCHAR2(20)    UNIQUE,
    Data_Nastere    DATE
);

-- 3. CAMERE
CREATE TABLE CAMERE (
    ID_Camera       NUMBER(10)      PRIMARY KEY,
    Numar_Camera    VARCHAR2(10)    NOT NULL UNIQUE,
    Etaj            NUMBER(2),
    ID_Tip          NUMBER(10)      NOT NULL
);

-- 4. SERVICII
CREATE TABLE SERVICII (
    ID_Serviciu             NUMBER(10)      PRIMARY KEY,
    Denumire                VARCHAR2(100)   NOT NULL UNIQUE,
    Cost                    NUMBER(6, 2)    NOT NULL
);

-- 5. REZERVARI
CREATE TABLE REZERVARI (
    ID_Rezervare        NUMBER(10)      PRIMARY KEY,
    ID_Client           NUMBER(10)      NOT NULL,
    ID_Camera           NUMBER(10)      NOT NULL,
    ID_Angajat          NUMBER(10)      NOT NULL,
    Data_Check_In       DATE            NOT NULL,
    Data_Check_Out      DATE            NOT NULL,
    Pret_Total          NUMBER(10, 2)   CHECK (Pret_Total IS NULL OR Pret_Total >= 0),
    Status_Rezervare    VARCHAR2(20)    DEFAULT 'CONFIRMATA'
);
-- Pretul total poate fi null în cazul rezervărilor în curs (încă nu a fost stabilită 
-- suma finală de plată) sau 0 în cazul rezervărilor anulate

-- 6. REZERVARI_SERVICII 
CREATE TABLE REZERVARI_SERVICII (
    ID_Rezervare        NUMBER(10)      NOT NULL,
    ID_Serviciu         NUMBER(10)      NOT NULL,
    Cantitate           NUMBER(3)       DEFAULT 1,
    Data_Serviciu       DATE            NOT NULL,
    CONSTRAINT pk_rs PRIMARY KEY (ID_Rezervare, ID_Serviciu, Data_Serviciu)
);
-- Cheie primară compusă, necesară pentru a putea identifica fiecare serviciu asociat unei 
-- rezervări și pentru a permite prestarea aceluiași serviciu în zile diferite

-- 7. PLATI
CREATE TABLE PLATI (
    ID_Plata            NUMBER(10)      PRIMARY KEY,
    ID_Rezervare        NUMBER(10)      NOT NULL,
    Data_Plata          DATE            DEFAULT SYSDATE,
    Suma                NUMBER(8, 2)    NOT NULL,
    Metoda_Plata        VARCHAR2(50)    NOT NULL
);

-- 8. ANGAJATI
CREATE TABLE ANGAJATI (
    ID_Angajat         NUMBER(10)       PRIMARY KEY,
    Nume               VARCHAR2(50)     NOT NULL,
    Prenume            VARCHAR2(50)     NOT NULL,
    Functie            VARCHAR2(50),
    Salariu            NUMBER(8, 2)     CHECK (Salariu > 0),
    ID_Manager         NUMBER(10)
);

-- Operatii LDD

-- 1. CAMERE: Leagă CAMERE de TIPURI_CAMERE
ALTER TABLE CAMERE
ADD CONSTRAINT fk_camere_tip
FOREIGN KEY (ID_Tip)
REFERENCES TIPURI_CAMERA (ID_Tip);

-- 2. REZERVARI: Leagă REZERVARI de CLIENT
ALTER TABLE REZERVARI
ADD CONSTRAINT fk_rezervari_client
FOREIGN KEY (ID_Client)
REFERENCES CLIENTI (ID_Client);

-- 3. REZERVARI: Leagă REZERVARI de CAMERE
ALTER TABLE REZERVARI
ADD CONSTRAINT fk_rezervari_camera
FOREIGN KEY (ID_Camera)
REFERENCES CAMERE (ID_Camera);

-- 4. REZERVARI_SERVICII: Leagă REZERVARI_SERVICII de REZERVARI
ALTER TABLE REZERVARI_SERVICII
ADD CONSTRAINT fk_rs_rezervare
FOREIGN KEY (ID_Rezervare)
REFERENCES REZERVARI (ID_Rezervare);

-- 5. REZERVARI_SERVICII: Leagă REZERVARI_SERVICII de SERVICII
ALTER TABLE REZERVARI_SERVICII
ADD CONSTRAINT fk_rs_serviciu
FOREIGN KEY (ID_Serviciu)
REFERENCES SERVICII (ID_Serviciu);

-- 6. PLATI: Leagă PLATI de REZERVARI
ALTER TABLE PLATI
ADD CONSTRAINT fk_plati_rezervare
FOREIGN KEY (ID_Rezervare)
REFERENCES REZERVARI (ID_Rezervare);

-- 7. REZERVARI: Leagă REZERVARI de ANGAJATI
ALTER TABLE REZERVARI
ADD CONSTRAINT fk_rezervari_angajat
FOREIGN KEY (ID_Angajat)
REFERENCES ANGAJATI (ID_Angajat);

-- 8. PLATI: Adaugă o restricție CHECK
ALTER TABLE PLATI
ADD CONSTRAINT ck_metoda_plata CHECK (UPPER(Metoda_Plata) IN ('CARD', 'CASH', 'TRANSFER'));

-- 9. SERVICII: Adaugă nivel ierarhic
ALTER TABLE SERVICII
ADD ID_Serviciu_Parinte NUMBER(10);

-- 10. SERVICII: Leagă nivelul ierarhic
ALTER TABLE SERVICII
ADD CONSTRAINT fk_servicii_parinte
FOREIGN KEY (ID_Serviciu_Parinte)
REFERENCES SERVICII (ID_Serviciu);

-- 11. CLIENTI: Verifică formatul email-ului
ALTER TABLE CLIENTI
ADD CONSTRAINT ck_email_format
CHECK (Email LIKE '%@%.%');

-- 12. ANGAJATI: Adaugă nivelul ierarhic
ALTER TABLE ANGAJATI
ADD CONSTRAINT fk_angajati_manager
FOREIGN KEY (ID_Manager)
REFERENCES ANGAJATI (ID_Angajat);

-- 13. REZERVARI: Verifică datele de check-in și check-out
ALTER TABLE REZERVARI
ADD CONSTRAINT ck_date_rezervare
CHECK (Data_Check_Out > Data_Check_In);

-- 14. REZERVARI: Verifică statusul rezervării
ALTER TABLE REZERVARI
ADD CONSTRAINT ck_status_rezervare
CHECK (UPPER(Status_Rezervare) IN ('CONFIRMATA', 'ANULATA', 'FINALIZATA')); 

-- Operatii LMD

-- Am folosit secvențe pentru a ușura procesul de înregistrare a datelor

-- 1. TIPURI_CAMERA: Adăugarea a 10 înregistrări

CREATE SEQUENCE seq_tip_camera
START WITH 1 
INCREMENT BY 1
MAXVALUE 100 
NOCYCLE;

INSERT INTO TIPURI_CAMERA VALUES (seq_tip_camera.NEXTVAL, 'Single Standard', 1, 200);
INSERT INTO TIPURI_CAMERA VALUES (seq_tip_camera.NEXTVAL, 'Double Standard', 2, 350);
INSERT INTO TIPURI_CAMERA VALUES (seq_tip_camera.NEXTVAL, 'Twin Standard', 2, 300);
INSERT INTO TIPURI_CAMERA VALUES (seq_tip_camera.NEXTVAL, 'Triple Standard', 2, 450);
INSERT INTO TIPURI_CAMERA VALUES (seq_tip_camera.NEXTVAL, 'Suite Standard', 4, 600);
INSERT INTO TIPURI_CAMERA VALUES (seq_tip_camera.NEXTVAL, 'Single Deluxe', 1, 300);
INSERT INTO TIPURI_CAMERA VALUES (seq_tip_camera.NEXTVAL, 'Double Deluxe', 2, 450);
INSERT INTO TIPURI_CAMERA VALUES (seq_tip_camera.NEXTVAL, 'Twin Deluxe', 2, 400);
INSERT INTO TIPURI_CAMERA VALUES (seq_tip_camera.NEXTVAL, 'Triple Deluxe', 2, 650);
INSERT INTO TIPURI_CAMERA VALUES (seq_tip_camera.NEXTVAL, 'Suite Deluxe', 4, 700);

-- 2. CLIENTI: Adăugarea a 11 înregistrări

CREATE SEQUENCE seq_clienti
START WITH 1 
INCREMENT BY 1
MAXVALUE 1000 
NOCYCLE;

INSERT INTO CLIENTI VALUES (seq_clienti.NEXTVAL, 'Popescu', 'Maria', 'popescumaria@yahoo.com', '0748264819', TO_DATE('01-01-2000', 'DD-MM-YYYY'));
INSERT INTO CLIENTI VALUES (seq_clienti.NEXTVAL, 'Ionescu', 'Andrei', 'ionescuandrei@yahoo.com', '0745698236', TO_DATE('20-10-1985', 'DD-MM-YYYY'));
INSERT INTO CLIENTI VALUES (seq_clienti.NEXTVAL, 'Georgescu', 'Elena', 'georgescuelena@outlook.com', '0798632003', TO_DATE('12-03-1995', 'DD-MM-YYYY'));
INSERT INTO CLIENTI VALUES (seq_clienti.NEXTVAL, 'Dumitru', 'Cristian', 'dumitrucristi@gmail.com', '0711365988', TO_DATE('25-07-1998', 'DD-MM-YYYY'));
INSERT INTO CLIENTI VALUES (seq_clienti.NEXTVAL, 'Stoica', 'Anca', 'stoicaanca@outlook.com', '0766985456', TO_DATE('30-12-1992', 'DD-MM-YYYY'));
INSERT INTO CLIENTI VALUES (seq_clienti.NEXTVAL, 'Radu', 'Mihai', 'radumihai@gmail.com', '0769889365', TO_DATE('12-02-2003', 'DD-MM-YYYY'));    
INSERT INTO CLIENTI VALUES (seq_clienti.NEXTVAL, 'Ghinea', 'Andreea', 'ghineanadreea@yahoo.com', '0756984235', TO_DATE('06-12-2002', 'DD-MM-YYYY'));
INSERT INTO CLIENTI VALUES (seq_clienti.NEXTVAL, 'Preda', 'Florentina', 'predaflorentina@outlook.com', '0745236984', TO_DATE('30-06-1999', 'DD-MM-YYYY'));
INSERT INTO CLIENTI VALUES (seq_clienti.NEXTVAL, 'Popa', 'Valentin', 'popavalentin@gmail.com', '0745632149', TO_DATE('04-09-2003', 'DD-MM-YYYY'));
INSERT INTO CLIENTI VALUES (seq_clienti.NEXTVAL, 'Munteanu', 'Cosmin', 'munteanucosmin@gmail.com', '0745236985', TO_DATE('25-11-2000', 'DD-MM-YYYY'));
INSERT INTO CLIENTI VALUES (seq_clienti.NEXTVAL, 'Stan', 'Stefan', 'stanstefan@yahoo.com', '0769894320', TO_DATE('23-06-2001', 'DD-MM-YYYY'));

-- 3. ANGAJATI: Adăugarea a 10 înregistrări (inclusiv numele meu)

CREATE SEQUENCE seq_angajati
START WITH 1 
INCREMENT BY 1
MAXVALUE 1000
NOCYCLE;

INSERT INTO ANGAJATI VALUES (seq_angajati.NEXTVAL, 'Hanu', 'Denisa', 'Director Hotel', 10000, NULL);
INSERT INTO ANGAJATI VALUES (seq_angajati.NEXTVAL, 'Udrea', 'Carina', 'Manager Receptie', 6500, (SELECT ID_Angajat FROM ANGAJATI WHERE Functie = 'Director Hotel'));
INSERT INTO ANGAJATI VALUES (seq_angajati.NEXTVAL, 'Marin', 'Radu', 'Receptioner', 4200, (SELECT ID_Angajat FROM ANGAJATI WHERE Functie = 'Manager Receptie'));
INSERT INTO ANGAJATI VALUES (seq_angajati.NEXTVAL, 'Stan', 'Cristian', 'Receptioner', 4200, (SELECT ID_Angajat FROM ANGAJATI WHERE Functie = 'Manager Receptie'));
INSERT INTO ANGAJATI VALUES (seq_angajati.NEXTVAL, 'Gheorghe', 'Ion', 'Manager Restaurant', 6000, (SELECT ID_Angajat FROM ANGAJATI WHERE Functie = 'Director Hotel'));
INSERT INTO ANGAJATI VALUES (seq_angajati.NEXTVAL, 'Pavel', 'Ioana', 'Bucatar', 5500, (SELECT ID_Angajat FROM ANGAJATI WHERE Functie = 'Manager Restaurant'));
INSERT INTO ANGAJATI VALUES (seq_angajati.NEXTVAL, 'Tudor', 'Gabriela', 'Ospatar', 3800, (SELECT ID_Angajat FROM ANGAJATI WHERE Functie = 'Manager Restaurant'));
INSERT INTO ANGAJATI VALUES (seq_angajati.NEXTVAL, 'Enache', 'Daniela', 'Sef Curatenie', 4800, (SELECT ID_Angajat FROM ANGAJATI WHERE Functie = 'Director Hotel'));
INSERT INTO ANGAJATI VALUES (seq_angajati.NEXTVAL, 'Andrei', 'Camelia', 'Camerista', 3500, (SELECT ID_Angajat FROM ANGAJATI WHERE Functie = 'Sef Curatenie'));
INSERT INTO ANGAJATI VALUES (seq_angajati.NEXTVAL, 'Popa', 'Elena', 'Camerista', 3500, (SELECT ID_Angajat FROM ANGAJATI WHERE Functie = 'Sef Curatenie'));

-- 4. CAMERE: Adăugarea a 10 înregistrări
-- Nu am mai folosit secvență deoarece camerele au id-ul identic cu numărul și este mai ușor să introducem manual

INSERT INTO CAMERE VALUES (101, '101', 1, (SELECT ID_Tip FROM TIPURI_CAMERA WHERE Denumire = 'Single Standard'));
INSERT INTO CAMERE VALUES (102, '102', 1, (SELECT ID_Tip FROM TIPURI_CAMERA WHERE Denumire = 'Double Standard'));
INSERT INTO CAMERE VALUES (103, '103', 1, (SELECT ID_Tip FROM TIPURI_CAMERA WHERE Denumire = 'Twin Standard'));
INSERT INTO CAMERE VALUES (104, '104', 1, (SELECT ID_Tip FROM TIPURI_CAMERA WHERE Denumire = 'Triple Standard'));
INSERT INTO CAMERE VALUES (105, '105', 1, (SELECT ID_Tip FROM TIPURI_CAMERA WHERE Denumire = 'Suite Standard'));
INSERT INTO CAMERE VALUES (201, '201', 2, (SELECT ID_Tip FROM TIPURI_CAMERA WHERE Denumire = 'Single Deluxe'));
INSERT INTO CAMERE VALUES (202, '202', 2, (SELECT ID_Tip FROM TIPURI_CAMERA WHERE Denumire = 'Double Deluxe'));
INSERT INTO CAMERE VALUES (203, '203', 2, (SELECT ID_Tip FROM TIPURI_CAMERA WHERE Denumire = 'Twin Deluxe'));
INSERT INTO CAMERE VALUES (204, '204', 2, (SELECT ID_Tip FROM TIPURI_CAMERA WHERE Denumire = 'Triple Deluxe'));
INSERT INTO CAMERE VALUES (205, '205', 2, (SELECT ID_Tip FROM TIPURI_CAMERA WHERE Denumire = 'Suite Deluxe'));

-- 5. SERVICII: Adăugarea a 10 înregistrări

CREATE SEQUENCE seq_servicii
START WITH 1 
INCREMENT BY 1
MAXVALUE 100
NOCYCLE;

INSERT INTO SERVICII (ID_Serviciu, Denumire, Cost) VALUES (seq_servicii.NEXTVAL, 'Spa', 0);
INSERT INTO SERVICII (ID_Serviciu, Denumire, Cost) VALUES (seq_servicii.NEXTVAL, 'Masaj', 150);
INSERT INTO SERVICII (ID_Serviciu, Denumire, Cost) VALUES (seq_servicii.NEXTVAL, 'Sauna', 50);
INSERT INTO SERVICII (ID_Serviciu, Denumire, Cost) VALUES (seq_servicii.NEXTVAL, 'Restaurant', 0);
INSERT INTO SERVICII (ID_Serviciu, Denumire, Cost) VALUES (seq_servicii.NEXTVAL, 'Mic Dejun', 50);
INSERT INTO SERVICII (ID_Serviciu, Denumire, Cost) VALUES (seq_servicii.NEXTVAL, 'Cina Romantica', 250);
INSERT INTO SERVICII (ID_Serviciu, Denumire, Cost) VALUES (seq_servicii.NEXTVAL, 'Room Service', 70);
INSERT INTO SERVICII (ID_Serviciu, Denumire, Cost) VALUES (seq_servicii.NEXTVAL, 'Transport', 0);
INSERT INTO SERVICII (ID_Serviciu, Denumire, Cost) VALUES (seq_servicii.NEXTVAL, 'Transfer Aeroport', 100);
INSERT INTO SERVICII (ID_Serviciu, Denumire, Cost) VALUES (seq_servicii.NEXTVAL, 'Inchiriere Auto', 250);

-- Serviciile de tip categorie au cost 0, ele au fost incluse pentru a îndeplini cerința legată de niveluri ierarhice

-- 6. SERVICII: Setarea ID_Serviciu_Parinte pentru servciile din categoria 'Spa'

UPDATE SERVICII
SET ID_Serviciu_Parinte = (SELECT ID_Serviciu FROM SERVICII WHERE Denumire = 'Spa')
WHERE Denumire IN ('Masaj', 'Sauna');

-- 7. SERVICII: Setarea ID_Serviciu_Parinte pentru serviciile din catagoria 'Restaurant'

UPDATE SERVICII
SET ID_Serviciu_Parinte = (SELECT ID_Serviciu FROM SERVICII WHERE Denumire = 'Restaurant')
WHERE Denumire IN ('Mic Dejun', 'Cina Romantica', 'Room Service');

-- 8. SERVICII: Setarea ID_Serviciu_Parinte pentru serviciile din catagoria 'Transport'

UPDATE SERVICII
SET ID_Serviciu_Parinte = (SELECT ID_Serviciu FROM SERVICII WHERE Denumire = 'Transport')
WHERE Denumire IN ('Transfer Aeroport', 'Inchiriere Auto');

-- 9. REZERVARI: Adăugarea a 12 înregistrări

CREATE SEQUENCE seq_rez
START WITH 1 
INCREMENT BY 1
MAXVALUE 2000
NOCYCLE;

INSERT INTO REZERVARI VALUES (seq_rez.NEXTVAL, (SELECT ID_Client FROM CLIENTI WHERE Telefon = '0748264819'), 101, 3, TO_DATE('10-01-2026', 'DD-MM-YYYY'), TO_DATE('15-01-2026', 'DD-MM-YYYY'), 980, 'CONFIRMATA');
INSERT INTO REZERVARI VALUES (seq_rez.NEXTVAL, (SELECT ID_Client FROM CLIENTI WHERE Telefon = '0745698236'), 102, 4, TO_DATE('05-10-2025', 'DD-MM-YYYY'), TO_DATE('10-10-2025', 'DD-MM-YYYY'), 1315, 'FINALIZATA');
INSERT INTO REZERVARI VALUES (seq_rez.NEXTVAL, (SELECT ID_Client FROM CLIENTI WHERE Telefon = '0798632003'), 103, 3, TO_DATE('05-10-2025', 'DD-MM-YYYY'), TO_DATE('10-10-2025', 'DD-MM-YYYY'), 1365, 'FINALIZATA');
INSERT INTO REZERVARI VALUES (seq_rez.NEXTVAL, (SELECT ID_Client FROM CLIENTI WHERE Telefon = '0711365988'), 104, 4, TO_DATE('13-03-2026', 'DD-MM-YYYY'), TO_DATE('21-03-2026', 'DD-MM-YYYY'), 2000, 'CONFIRMATA');
INSERT INTO REZERVARI VALUES (seq_rez.NEXTVAL, (SELECT ID_Client FROM CLIENTI WHERE Telefon = '0766985456'), 105, 3, TO_DATE('13-03-2026', 'DD-MM-YYYY'), TO_DATE('21-03-2026', 'DD-MM-YYYY'), 2000, 'CONFIRMATA');
INSERT INTO REZERVARI VALUES (seq_rez.NEXTVAL, (SELECT ID_Client FROM CLIENTI WHERE Telefon = '0769889365'), 201, 4, TO_DATE('01-01-2026', 'DD-MM-YYYY'), TO_DATE('04-01-2026', 'DD-MM-YYYY'), 600, 'ANULATA');
INSERT INTO REZERVARI VALUES (seq_rez.NEXTVAL, (SELECT ID_Client FROM CLIENTI WHERE Telefon = '0756984235'), 202, 3, TO_DATE('28-12-2025', 'DD-MM-YYYY'), TO_DATE('02-01-2026', 'DD-MM-YYYY'), 3920, 'FINALIZATA');
INSERT INTO REZERVARI VALUES (seq_rez.NEXTVAL, (SELECT ID_Client FROM CLIENTI WHERE Telefon = '0745236984'), 203, 4, TO_DATE('05-04-2026', 'DD-MM-YYYY'), TO_DATE('08-06-2026', 'DD-MM-YYYY'), 4920, 'CONFIRMATA');
INSERT INTO REZERVARI VALUES (seq_rez.NEXTVAL, (SELECT ID_Client FROM CLIENTI WHERE Telefon = '0745632149'), 101, 3, TO_DATE('16-03-2026', 'DD-MM-YYYY'), TO_DATE('18-03-2026', 'DD-MM-YYYY'), 1000, 'ANULATA');
INSERT INTO REZERVARI VALUES (seq_rez.NEXTVAL, (SELECT ID_Client FROM CLIENTI WHERE Telefon = '0745236985'), 101, 4, TO_DATE('16-03-2026', 'DD-MM-YYYY'), TO_DATE('20-03-2026', 'DD-MM-YYYY'), 1500, 'CONFIRMATA');
INSERT INTO REZERVARI VALUES (seq_rez.NEXTVAL, (SELECT ID_Client FROM CLIENTI WHERE Telefon = '0745698236'), 102, 4, TO_DATE('05-10-2026', 'DD-MM-YYYY'), TO_DATE('10-10-2026', 'DD-MM-YYYY'), 2600, 'CONFIRMATA');
INSERT INTO REZERVARI VALUES (seq_rez.NEXTVAL, (SELECT ID_Client FROM CLIENTI WHERE Telefon = '0798632003'), 103, 3, TO_DATE('05-10-2026', 'DD-MM-YYYY'), TO_DATE('10-10-2026', 'DD-MM-YYYY'), 2300, 'CONFIRMATA');

-- Creez o vedere astfel încât să simplific codul
-- Am folosit 'CREATE OR REPLACE' pentru a putea rula tot script-ul de mai multe ori fără probleme

-- Creez un index pentru a optimiza timpul de căutare al ID-urilor pentru VIEW

CREATE INDEX idx_rez_id_client
ON REZERVARI(ID_Client);

CREATE OR REPLACE VIEW v_rez AS
SELECT R.ID_Rezervare, R.Data_Check_In, C.Telefon
FROM CLIENTI C, REZERVARI R
WHERE C.ID_client = R.ID_Client;

-- 10. REZERVARI_SERVICII: Adăugarea a 10 înregistrări

INSERT INTO REZERVARI_SERVICII VALUES ((SELECT ID_Rezervare FROM v_rez WHERE Telefon = '0748264819' AND Data_Check_In = TO_DATE('10-01-2026', 'DD-MM-YYYY')), (SELECT ID_Serviciu FROM SERVICII WHERE Denumire = 'Masaj'), 1, TO_DATE('07-01-2026', 'DD-MM-YYYY'));
INSERT INTO REZERVARI_SERVICII VALUES ((SELECT ID_Rezervare FROM v_rez WHERE Telefon = '0745698236' AND Data_Check_In = TO_DATE('05-10-2025', 'DD-MM-YYYY')), (SELECT ID_Serviciu FROM SERVICII WHERE Denumire = 'Cina Romantica'), 1, TO_DATE('08-10-2025', 'DD-MM-YYYY'));
INSERT INTO REZERVARI_SERVICII VALUES ((SELECT ID_Rezervare FROM v_rez WHERE Telefon = '0798632003' AND Data_Check_In = TO_DATE('05-10-2025', 'DD-MM-YYYY')), (SELECT ID_Serviciu FROM SERVICII WHERE Denumire = 'Transfer Aeroport'), 1, TO_DATE('07-10-2025', 'DD-MM-YYYY'));
INSERT INTO REZERVARI_SERVICII VALUES ((SELECT ID_Rezervare FROM v_rez WHERE Telefon = '0711365988' AND Data_Check_In = TO_DATE('13-03-2026', 'DD-MM-YYYY')), (SELECT ID_Serviciu FROM SERVICII WHERE Denumire = 'Mic Dejun'), 1, TO_DATE('16-03-2026', 'DD-MM-YYYY'));
INSERT INTO REZERVARI_SERVICII VALUES ((SELECT ID_Rezervare FROM v_rez WHERE Telefon = '0766985456' AND Data_Check_In = TO_DATE('13-03-2026', 'DD-MM-YYYY')), (SELECT ID_Serviciu FROM SERVICII WHERE Denumire = 'Sauna'), 1, TO_DATE('20-03-2026', 'DD-MM-YYYY'));
INSERT INTO REZERVARI_SERVICII VALUES ((SELECT ID_Rezervare FROM v_rez WHERE Telefon = '0756984235' AND Data_Check_In = TO_DATE('28-12-2025', 'DD-MM-YYYY')), (SELECT ID_Serviciu FROM SERVICII WHERE Denumire = 'Masaj'), 1, TO_DATE('02-01-2026', 'DD-MM-YYYY'));
INSERT INTO REZERVARI_SERVICII VALUES ((SELECT ID_Rezervare FROM v_rez WHERE Telefon = '0745236984' AND Data_Check_In = TO_DATE('05-04-2026', 'DD-MM-YYYY')), (SELECT ID_Serviciu FROM SERVICII WHERE Denumire = 'Inchiriere Auto'), 1, TO_DATE('08-06-2026', 'DD-MM-YYYY'));
INSERT INTO REZERVARI_SERVICII VALUES ((SELECT ID_Rezervare FROM v_rez WHERE Telefon = '0745236985' AND Data_Check_In = TO_DATE('16-03-2026', 'DD-MM-YYYY')), (SELECT ID_Serviciu FROM SERVICII WHERE Denumire = 'Cina Romantica'), 1, TO_DATE('20-03-2026', 'DD-MM-YYYY'));
INSERT INTO REZERVARI_SERVICII VALUES ((SELECT ID_Rezervare FROM v_rez WHERE Telefon = '0745698236' AND Data_Check_In = TO_DATE('05-10-2026', 'DD-MM-YYYY')), (SELECT ID_Serviciu FROM SERVICII WHERE Denumire = 'Mic Dejun'), 1, TO_DATE('10-10-2026', 'DD-MM-YYYY'));
INSERT INTO REZERVARI_SERVICII VALUES ((SELECT ID_Rezervare FROM v_rez WHERE Telefon = '0798632003' AND Data_Check_In = TO_DATE('05-10-2026', 'DD-MM-YYYY')), (SELECT ID_Serviciu FROM SERVICII WHERE Denumire = 'Transfer Aeroport'), 1, TO_DATE('10-10-2026', 'DD-MM-YYYY'));

-- 11. PLATI: Adăugarea a 10 înregistrări

CREATE SEQUENCE seq_plati
START WITH 1 
INCREMENT BY 1
MAXVALUE 2000
NOCYCLE;

INSERT INTO PLATI VALUES (seq_plati.NEXTVAL, (SELECT ID_Rezervare FROM v_rez WHERE Telefon = '0748264819' AND Data_Check_In = TO_DATE('10-01-2026', 'DD-MM-YYYY')), TO_DATE('15-01-2026', 'DD-MM-YYYY'), 980, 'Cash');
INSERT INTO PLATI VALUES (seq_plati.NEXTVAL, (SELECT ID_Rezervare FROM v_rez WHERE Telefon = '0745698236' AND Data_Check_In = TO_DATE('05-10-2025', 'DD-MM-YYYY')), TO_DATE('10-10-2025', 'DD-MM-YYYY'), 1315, 'Cash');
INSERT INTO PLATI VALUES (seq_plati.NEXTVAL, (SELECT ID_Rezervare FROM v_rez WHERE Telefon = '0798632003' AND Data_Check_In = TO_DATE('05-10-2025', 'DD-MM-YYYY')), TO_DATE('10-10-2025', 'DD-MM-YYYY'), 1365, 'Cash');
INSERT INTO PLATI VALUES (seq_plati.NEXTVAL, (SELECT ID_Rezervare FROM v_rez WHERE Telefon = '0711365988' AND Data_Check_In = TO_DATE('13-03-2026', 'DD-MM-YYYY')), TO_DATE('21-03-2026', 'DD-MM-YYYY'), 2000, 'Card');
INSERT INTO PLATI VALUES (seq_plati.NEXTVAL, (SELECT ID_Rezervare FROM v_rez WHERE Telefon = '0766985456' AND Data_Check_In = TO_DATE('13-03-2026', 'DD-MM-YYYY')), TO_DATE('21-03-2026', 'DD-MM-YYYY'), 2000, 'Transfer');
INSERT INTO PLATI VALUES (seq_plati.NEXTVAL, (SELECT ID_Rezervare FROM v_rez WHERE Telefon = '0756984235' AND Data_Check_In = TO_DATE('28-12-2025', 'DD-MM-YYYY')), TO_DATE('02-01-2026', 'DD-MM-YYYY'), 3920, 'Card');
INSERT INTO PLATI VALUES (seq_plati.NEXTVAL, (SELECT ID_Rezervare FROM v_rez WHERE Telefon = '0745236984' AND Data_Check_In = TO_DATE('05-04-2026', 'DD-MM-YYYY')), TO_DATE('08-06-2026', 'DD-MM-YYYY'), 4920, 'Transfer');
INSERT INTO PLATI VALUES (seq_plati.NEXTVAL, (SELECT ID_Rezervare FROM v_rez WHERE Telefon = '0745236985' AND Data_Check_In = TO_DATE('16-03-2026', 'DD-MM-YYYY')), TO_DATE('20-03-2026', 'DD-MM-YYYY'), 1500, 'Cash');
INSERT INTO PLATI VALUES (seq_plati.NEXTVAL, (SELECT ID_Rezervare FROM v_rez WHERE Telefon = '0745698236' AND Data_Check_In = TO_DATE('05-10-2026', 'DD-MM-YYYY')), TO_DATE('10-10-2026', 'DD-MM-YYYY'), 2600, 'Card');
INSERT INTO PLATI VALUES (seq_plati.NEXTVAL, (SELECT ID_Rezervare FROM v_rez WHERE Telefon = '0798632003' AND Data_Check_In = TO_DATE('05-10-2026', 'DD-MM-YYYY')), TO_DATE('10-10-2026', 'DD-MM-YYYY'), 2300, 'Card');

-- 12. REZERVARI_SERVICII: Ștergerea serviciului 'Cina Romantica' din tabela părinte

DELETE FROM REZERVARI_SERVICII
WHERE ID_Serviciu = (SELECT ID_serviciu 
                     FROM SERVICII
                     WHERE Denumire = 'Cina Romantica');

-- 13. REZERVARI_SERVICII: Ștergerea serviciului 'Cina Romantica' din tabela copil

DELETE FROM SERVICII
WHERE Denumire = 'Cina Romantica';

-- 14. CLIENTI: Înregistrarea clientului în baza de date/modificarea numărului de telefon dacă este deja înregistrat

MERGE INTO CLIENTI C
USING (SELECT 
        'popescumaria@yahoo.com' AS Email,
        'Popescu' AS Nume,
        'Maria' AS Prenume,
        '0799578632' AS Telefon,
        TO_DATE('01-01-2000', 'DD-MM-YYYY') AS Data_Nastere
        FROM dual) Source
ON (C.Email = Source.Email)
WHEN MATCHED THEN
UPDATE SET C.Telefon = Source.Telefon
WHEN NOT MATCHED THEN
INSERT (ID_Client, Nume, Prenume, Email, Telefon, Data_Nastere)
VALUES (seq_clienti.NEXTVAL, Source.Nume, Source.Prenume, Source.Email, Source.Telefon, Source.Data_Nastere);

COMMIT;

--tipuri camera, clienti, camere, angajati, servicii, rezervari, rez srv, plati

SELECT * FROM PLATI;

-- PLATI: Ștergerea și recuperarea tabelei
DROP TABLE PLATI;
FLASHBACK TABLE PLATI TO BEFORE DROP;

-- INTEROGĂRI

CREATE SYNONYM cl FOR CLIENTI;
CREATE SYNONYM rez FOR REZERVARI;

-- 1. Afișați numele, prenumele și numărul de telefon ale clienților care au efectuat cel puțin o rezervare

SELECT  DISTINCT cl.Nume, cl.Prenume, cl.Telefon
FROM cl, rez
WHERE cl.ID_Client = rez.ID_Client;

-- 2. Afișați rezervările confirmate, împreună cu numărul camerei și data de check-in.

SELECT rez.ID_Rezervare, rez.Data_Check_In, C.Numar_Camera
FROM rez, CAMERE C
WHERE rez.ID_Camera = C.ID_Camera AND UPPER(rez.Status_Rezervare) = 'CONFIRMATA'
ORDER BY rez.Data_Check_In;

-- 3. Determinați numărul total de rezervări pentru fiecare client.

SELECT cl.Nume, cl.Prenume, COUNT(rez.ID_Rezervare) AS Nr_Rezervari
FROM cl, rez
WHERE cl.ID_Client = rez.ID_Client
GROUP BY cl.Nume, cl.Prenume;

-- 4. Afișați clienții care au beneficiat de serviciul 'Masaj'.

SELECT cl.ID_client, cl.Nume, cl.Prenume
FROM cl, SERVICII S, rez, REZERVARI_SERVICII RS
WHERE cl.ID_Client = rez.ID_Client 
AND rez.ID_Rezervare = RS.ID_Rezervare 
AND RS.ID_Serviciu = S.ID_Serviciu
AND S.Denumire = 'Masaj';

-- 5. Afișați rezervarea cu valoarea maximă a prețului total.

SELECT *
FROM rez
WHERE Pret_Total = (SELECT MAX(Pret_Total)
                    FROM rez);

-- 6. Calculați suma totală încasată de hotel din plăți.

SELECT SUM(Suma) AS Total_Incasari
FROM PLATI;

-- 7. Afișați serviciile care fac parte din categoria 'Restaurant'.

SELECT ID_serviciu, Denumire, Cost
FROM SERVICII
WHERE ID_Serviciu_Parinte = (SELECT ID_Serviciu
                             FROM SERVICII
                             WHERE Denumire = 'Restaurant');

-- 8. Afișați rezervările efectuate în anul 2025, împreună cu data de check-in.

SELECT ID_rezervare, Data_Check_In
FROM rez
WHERE EXTRACT(YEAR FROM Data_Check_In) = 2025;

-- 9. Afișați clienții al căror nume începe cu litera 'P'.

SELECT Nume, Prenume
FROM cl
WHERE Nume LIKE 'P%';

-- 10. Afișați rezervările care au prețul total între 1000 și 3000 lei.

SELECT ID_Rezervare, Pret_Total
FROM rez
WHERE Pret_Total BETWEEN 1000 AND 3000
ORDER BY Pret_Total;

-- 11. Afișați clienții care nu au nicio rezervare.

SELECT cl.ID_Client, cl.Nume, cl.Prenume
FROM cl, rez
WHERE cl.ID_Client = rez.ID_Client (+)
AND rez.ID_Rezervare IS NULL;

-- 12. Afișați numărul total de rezervări pentru fiecare status, doar pentru statusrurile cu cel puțin 3 rezervări.

SELECT Status_Rezervare, COUNT(*) AS Numar_Rezervari
FROM rez
GROUP BY Status_Rezervare
HAVING COUNT(*) >= 3;

-- 13. Afișați tipul rezervării: scumpă (>3000), medie (1500-3000), ieftină (<1500)

SELECT ID_Rezervare, Pret_Total,
CASE
    WHEN Pret_Total > 3000 THEN 'Scumpa'
    WHEN Pret_Total BETWEEN 1500 AND 3000 THEN 'Medie'
    ELSE 'Ieftina'
END AS Tip_Rezervare
FROM rez
ORDER BY Pret_Total;

-- 14. Afișați luna check-in-ului în format text

SELECT ID_Rezervare, TO_CHAR(Data_check_In, 'Month') AS Luna_Check_In
FROM rez;

-- 15. Afișați clienții care au făcut rezervări și au beneficiat de servicii.

SELECT cl.ID_Client, cl.Nume, cl.Prenume
FROM cl, rez
WHERE cl.ID_Client = rez.ID_Client
INTERSECT
SELECT cl.ID_client, cl.Nume, cl.Prenume
FROM cl, rez, REZERVARI_SERVICII RS
WHERE cl.ID_Client = rez.ID_Client
AND rez.ID_Rezervare = RS.ID_Rezervare;

-- 16. Afișați camerele care nu au fost niciodată rezervate.

SELECT C.ID_Camera, C.Numar_Camera, TP.Denumire
FROM CAMERE C, TIPURI_CAMERA TP
WHERE C.ID_Tip = TP.ID_Tip
MINUS
SELECT C.ID_Camera, C.Numar_Camera, TP.Denumire
FROM CAMERE C, TIPURI_CAMERA TP, rez
WHERE C.ID_Tip = TP.ID_Tip
AND C.ID_Camera = rez.ID_Camera;

-- 17. Afișați clienții care au fie rezervări, fie plăți efectuate (sau ambele).

SELECT cl.ID_Client, cl.Nume, cl.Prenume
FROM cl, rez
WHERE cl.ID_Client = rez.ID_Client
UNION
SELECT cl.ID_Client, cl.Nume, cl.Prenume
FROM cl, rez, PLATI P
WHERE cl.ID_Client = rez.ID_Client
AND rez.ID_Rezervare = P.ID_Rezervare;

-- 18. Afișați lista tuturor serviciilor folosind cererea ierahică.

SELECT LEVEL AS Nivel, LPAD(' ', (LEVEL-1)*3) || Denumire AS Serviciu
FROM SERVICII
START WITH ID_Serviciu_Parinte IS NULL
CONNECT BY PRIOR ID_Serviciu = ID_Serviciu_Parinte;

-- 19. Afișați traseul ierarhic complet al angajaților.

SELECT SYS_CONNECT_BY_PATH(Functie, ' -> ') AS Ierarhie
FROM ANGAJATI
START WITH ID_Manager IS NULL
CONNECT BY PRIOR ID_Angajat = ID_Manager;


-- 20. Afișați data rezervării și numărul de zile până la check-in.

SELECT ID_Rezervare, Data_Check_In,
       CASE
        WHEN Data_Check_In > SYSDATE THEN TRUNC(Data_Check_In - SYSDATE)
        ELSE NULL
       END AS Zile_Pana_La_Check_In
FROM rez;

-- 21. Afișați rezervările folosind o vedere.

SELECT * FROM v_rez;

-- 22. Afișați clienții care au rezervări în camerele 101, 102, 103.

SELECT cl.ID_Client, cl.Nume, cl.Prenume, rez.ID_Rezervare, rez.ID_Camera
FROM cl, rez
WHERE cl.ID_Client = rez.ID_Client
AND rez.ID_Camera IN (101, 102, 103);

-- 23. Introduceți o rezervare nouă pentru un client existent.

INSERT INTO rez VALUES (seq_rez.NEXTVAL, (SELECT ID_client FROM cl WHERE Telefon = '0769894320'), 102, 3, TO_DATE('24-07-2026', 'DD-MM-YYYY'), TO_DATE('29-07-2026', 'DD-MM-YYYY'), 1800, 'CONFIRMATA');

-- 24. Actualizați prețul total al rezervărilor, considerând valoarea 0 pentru cele anulate.

UPDATE rez
SET Pret_Total = NVL(Pret_Total, 0)
WHERE Status_Rezervare = 'ANULATA';

-- 25. Ștergeți rezervările anulate care nu au plăți asociate.

DELETE FROM rez
WHERE Status_Rezervare = 'ANULATA'
AND ID_rezervare NOT IN (SELECT ID_Rezervare FROM PLATI);

-- 26. Afișați rezervările și descrieți statusul lor sub formă de text explicit.

SELECT ID_Rezervare, DECODE(Status_Rezervare, 'CONFIRMATA', 'Rezervare Activa', 
                                              'FINALIZATA', 'Rezervare Incheiata',
                                              'ANULATA', 'Rezervare Anulata',
                                              'Status Necunoscut') AS Descriere_Status
FROM rez;

-- 27. Afișați inițiala prenumelui și primele 3 litere din numele clienților.

SELECT SUBSTR(Nume, 1, 3) AS Prefix_Nume, SUBSTR(Prenume, 1, 1) AS Initiala_Prenume
FROM cl;

-- 28. Afișați rezervările nefinalizate, cu preț mai mic de 2000 lei, împreună cu numele clientului și numărul camerei.

SELECT rez.ID_Rezervare, cl.Nume, cl.Prenume, rez.Pret_Total, C.Numar_Camera
FROM cl, rez, CAMERE C
WHERE rez.ID_client = cl.ID_Client
AND rez.ID_Camera = C.ID_Camera
AND rez.Status_Rezervare != 'FINALIZATA'
AND rez.Pret_Total < 2000;

-- 29. Afișați clienții care au rezervări în camere cu capacitate de cel mult 2 persoane.

SELECT cl.ID_Client, cl.Nume, cl.Prenume
FROM cl, rez
WHERE cL.ID_Client = rez.ID_Client
AND rez.ID_Camera IN (SELECT C.ID_Camera 
                      FROM CAMERE C, TIPURI_CAMERA TC 
                      WHERE C.ID_Tip = TC.ID_Tip 
                      AND TC.Capacitate_Max <= 2);
                      
-- 30. Afișați clienții care au făcut rezervări în camere de tip Deluxe, iar prima literă a numelui este P, G sau M, pentru rezervări efectuate după 01.01.2026.

SELECT cl.Nume, cl.Prenume
FROM cl, rez, CAMERE C, TIPURI_CAMERA TC
WHERE cl.ID_Client = rez.ID_client
AND rez.ID_Camera = C.ID_Camera
AND C.ID_Tip = TC.ID_Tip
AND TC.Denumire LIKE '%Deluxe%'
AND SUBSTR(cl.Nume, 1, 1) IN ('P', 'G', 'M')
AND rez.Data_Check_In > TO_DATE('01-01-2026', 'DD-MM-YYYY');
